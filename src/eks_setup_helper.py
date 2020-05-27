import os
import sys
import subprocess
import yaml
import boto3
import botocore
import time
from kubernetes import client, config
from eks_dataplane_deploy import *
import json
from pprint import pprint

INBOUND_NAMESPACE = "cni-inbound"
OUTBOUND_NAMESPACE = "cni-outbound"
WAIT_TIMEOUT = 300


class AwsHelper:
    def __init__(self):
        self.elbClient = boto3.client("elbv2")
        self.ssmClient = boto3.client("ssm")
        self.r53Client = boto3.client("route53")
        self.ddbClient = boto3.client("dynamodb")
        self.ec2Resource = boto3.resource("ec2")
        return

    def aws_ddb_put_item(self, table_name, item):
        try:
            response = self.ddbClient.put_item(TableName=table_name, Item=item)
        except botocore.exceptions.ClientError as error:
            pprint("Failed to add a AWS DDB Item in %s, for item: %s." % (table_name, item))
            raise error
        pprint("Added item: %s to DDB Table: %s" % (item, table_name))

    def aws_get_vpc_id(self, vpc_filters):
        return list(self.ec2Resource.vpcs.filter(Filters=vpc_filters))

    def aws_get_vpc_subnets(self, subnet_filters):
        return list(self.ec2Resource.subnets.filter(Filters=subnet_filters))

    def aws_get_vpc_security_groups(self, sg_filters):
        return list(self.ec2Resource.security_groups.filter(Filters=sg_filters))

    def aws_add_r53_record(self, source, target, hosted_zone_id):
        try:
            response = self.r53Client.change_resource_record_sets(
                HostedZoneId=hosted_zone_id,
                ChangeBatch={
                    "Comment": "Add %s -> %s" % (source, target),
                    "Changes": [
                        {
                            "Action": "UPSERT",
                            "ResourceRecordSet": {
                                "Name": source,
                                "Type": "CNAME",
                                "TTL": 60,
                                "ResourceRecords": [{"Value": target}],
                            },
                        }
                    ],
                },
            )
        except botocore.exceptions.ClientError as error:
            print("Failed to add a AWS Route53 Record for %s --> %s in HostedZoneID: %s" % (source, target, hosted_zone_id))
            raise error

        print(
            "Added CNAME Record for %s --> %s in HostedZone: %s. Status: %s"
            % (source, target, hosted_zone_id, response["ChangeInfo"]["Status"])
        )

    def aws_ssm_put_parameter(self, parameter_name, parameter_value, parameter_type):
        try:
            parameter = self.ssmClient.put_parameter(
                Name=parameter_name, Value=parameter_value, Type=parameter_type, Overwrite=True
            )
        except botocore.exceptions.ClientError as error:
            print("Failed to put AWS Systems Manager parameter: %s" % (parameter_name))
            raise error
        return

    def aws_ssm_fetch_parameter(self, parameter_name):
        try:
            parameter = self.ssmClient.get_parameter(Name=parameter_name, WithDecryption=True)
        except botocore.exceptions.ClientError as error:
            print("Failed to fetch AWS Systems Manager parameter: %s" % (parameter_name))
            raise error

        return parameter["Parameter"]["Value"]

    def aws_elb_get_lb_arn(self, lb_name):
        try:
            response = self.elbClient.describe_load_balancers(Names=[lb_name])
        except botocore.exceptions.ClientError as error:
            print("Failed to retrieve AWS NLB Info: %s" % (lb_name))
            raise error

        return response["LoadBalancers"][0]["LoadBalancerArn"]

    def aws_elb_get_tg_arn(self, lb_name):
        try:
            response = self.elbClient.describe_target_groups(LoadBalancerArn=self.aws_elb_get_lb_arn(lb_name))
        except botocore.exceptions.ClientError as error:
            print("Failed to retrieve AWS NLB TgtGroup Info: %s" % (lb_name))
            raise error

        return response["TargetGroups"][0]["TargetGroupArn"]

    def aws_elb_modify_tgt_attr(self, lb_name, attrKey, attrValue):
        try:
            response = self.elbClient.modify_target_group_attributes(
                TargetGroupArn=self.aws_elb_get_tg_arn(lb_name), Attributes=[{"Key": attrKey, "Value": attrValue}]
            )
        except botocore.exceptions.ClientError as error:
            print("Failed to modify target group attributes for LB: %s" % (lb_name))
            raise error

        print("TGT_GRP Attributes Modified: %s" % (response["Attributes"][0]))

    def aws_elb_modify_lb_attr(self, lb_name, attrKey, attrValue):
        try:
            response = self.elbClient.modify_load_balancer_attributes(
                LoadBalancerArn=self.aws_elb_get_lb_arn(lb_name), Attributes=[{"Key": attrKey, "Value": attrValue}]
            )
        except botocore.exceptions.ClientError as error:
            print("Failed to modify loadbalancer attributes for LBn: %s" % (lb_name))
            raise error

        print("LB Attributes Modified: %s" % (response["Attributes"][0]))

    def aws_nlb_get_name(self, lb_name):
        nlb_name = lb_name.split("-", 1)[0]
        nlb_net = lb_name.split("-", 1)[1].split(".", 1)[0]
        return "net/{}/{}".format(nlb_name, nlb_net)


class K8sClient:
    def __init__(self):
        config.load_kube_config(os.path.join(os.environ["HOME"], ".kube/config"))
        self.k8sV1Client = client.CoreV1Api()
        return

    def get_k8s_services(self, namespace):
        try:
            timeout_start = time.time()
            while time.time() < timeout_start + WAIT_TIMEOUT:
                svc_list = self.k8sV1Client.list_namespaced_service(namespace)
                if len(svc_list.items) > 0:
                    return svc_list.items
                else:
                    time.sleep(10)
                    continue
        except:
            print("Failed to fetch the services list for given namespace.")
            sys.exit(1)
        return

    def get_k8s_nlb_name(self, namespace):
        svc_list = self.get_k8s_services(namespace)
        return svc_list[0].status.load_balancer.ingress[0].hostname


def inbound_eks_nlb_setup(awsClient, manifest_data):
    # Update KUBECONFIG to INBOUND EKS Cluster
    cluster_name = "{}-{}-{}-{}-data-plane".format(
        manifest_data["env_name"], manifest_data["region"], manifest_data["deployment_id"], "inbound"
    )
    update_kubeconfig(cluster_name, manifest_data["region"])
    k8sClient = K8sClient()

    # Fetch the NLB Name for the Inbound EKS Cluster
    nlb_name = k8sClient.get_k8s_nlb_name(INBOUND_NAMESPACE)
    print("Retrieved Inbound NLB Name: %s" % (nlb_name))

    # Update SSM Parameter Store with NLB Name
    nlb_arn = awsClient.aws_nlb_get_name(nlb_name)
    awsClient.aws_ssm_put_parameter(
        parameter_name="/{}-{}/{}/inbound-data-plane/nlb-name".format(
            manifest_data["env_name"], manifest_data["region"], manifest_data["deployment_id"]
        ),
        parameter_value=nlb_arn,
        parameter_type="SecureString",
    )

    # Set the LB Attributes for Inbound EKS Cluster
    awsClient.aws_elb_modify_lb_attr(
        lb_name=nlb_name.split("-", 1)[0], attrKey="load_balancing.cross_zone.enabled", attrValue="true"
    )

    # Set the LB TGT GRP Atrributes for Inbound EKS Cluster
    awsClient.aws_elb_modify_tgt_attr(lb_name=nlb_name.split("-", 1)[0], attrKey="proxy_protocol_v2.enabled", attrValue="true")


def outbound_eks_nlb_setup(awsClient, manifest_data):
    # Fetch SFDCSB.NET Hosted ZOne -ID from AWS SSM
    r53_parameter_key = "/{}-{}/{}/stack_base/r53/sfdcsb".format(
        manifest_data["env_name"], manifest_data["region"], manifest_data["deployment_id"]
    )
    zone_id = awsClient.aws_ssm_fetch_parameter(parameter_name=r53_parameter_key)
    print("OUTBOUND VPC's SFDCSB.NET HostedZone-ID: %s" % (zone_id))

    # SETUP N-OUTBOUND VPC's

    if "outbound_vpcs_config" in manifest_data:
        outbound_vpc_cfg = manifest_data["outbound_vpcs_config"]
        outbound_infra_vpcs_info = list()
        for vpc_suffix in outbound_vpc_cfg.keys():
            # Update KUBECONFIG to OUTBOUND EKS Cluster
            cluster_name = "{}-{}-{}-{}-data-plane".format(
                manifest_data["env_name"], manifest_data["region"], manifest_data["deployment_id"], "outbound-" + vpc_suffix
            )
            update_kubeconfig(cluster_name, manifest_data["region"])
            k8sClient = K8sClient()

            # Fetch the NLB Name for the OUTBOUND EKS Cluster
            nlb_name = k8sClient.get_k8s_nlb_name(OUTBOUND_NAMESPACE)
            print("Retrieved Outbound-%s NLB Name: %s" % (vpc_suffix, nlb_name))

            # Update SSM Parameter Store with NLB Name
            nlb_arn = awsClient.aws_nlb_get_name(nlb_name)
            awsClient.aws_ssm_put_parameter(
                parameter_name="/{}-{}/{}/outbound-data-plane/{}/nlb-name".format(
                    manifest_data["env_name"], manifest_data["region"], manifest_data["deployment_id"], vpc_suffix
                ),
                parameter_value=nlb_arn,
                parameter_type="SecureString",
            )
            
            # Set the LB Attributes for OUTBOUND EKS Cluster
            awsClient.aws_elb_modify_lb_attr(
                lb_name=nlb_name.split("-", 1)[0], attrKey="load_balancing.cross_zone.enabled", attrValue="true"
            )

            # Add CNAME Records for OUTBOUND EKS NLB NAMES IN SFDCSB.NET Zone
            if not manifest_data["enable_sitebridge"]:
                print("********** OUTBOUND EKS NLB DNS SETUP ***********")
                dns_name = "core-{}.{}.aws.{}.cni{}.sfdcsb.net".format(
                    vpc_suffix, manifest_data["env_name"], manifest_data["region"], manifest_data["env_name"]
                )
                awsClient.aws_add_r53_record(dns_name, nlb_name, zone_id)

            # Add the DDB Records for INFRA_VPCs
            infra_vpc_info = dict()
            vpc_name = "{}-{}-{}-outbound-{}".format(
                manifest_data["env_name"], manifest_data["region"], manifest_data["deployment_id"], vpc_suffix
            )
            vpc_filters = [{"Name": "tag:Name", "Values": [vpc_name]}]
            vpcs = list(awsClient.ec2Resource.vpcs.filter(Filters=vpc_filters))
            infra_vpc_info["vpc_id"] = vpcs[0].id

            # Subnet Filters
            subnet_filters = [
                {"Name": "vpc-id", "Values": [vpcs[0].id]},
                {"Name": "tag:kubernetes.io/role/internal-elb", "Values": ["1"]},
            ]
            subnets = list(awsClient.ec2Resource.subnets.filter(Filters=subnet_filters))
            subnet_list = list()
            for subnet in subnets:
                subnet_list.append(subnet.id)
            infra_vpc_info["subnet_ids"] = subnet_list

            # Security Group Filters
            sg_filters = [{"Name": "vpc-id", "Values": [vpcs[0].id]}, {"Name": "group-name", "Values": ["*-nginx"]}]
            sg_list = list()
            sgs = list(awsClient.ec2Resource.security_groups.filter(Filters=sg_filters))
            for sg in sgs:
                sg_list.append(sg.id)
            infra_vpc_info["security_group_ids"] = sg_list
            infra_vpc_info["status"] = "inService"
            infra_vpc_info["total_capacity"] = 500
            if not manifest_data["enable_sitebridge"]:
                infra_vpc_info["proxy_url"] = "https://{}:443".format(nlb_name)
            else:
                infra_vpc_info["proxy_url"] = "https://core-{}.{}.aws.{}.cni{}.sfdcsb.net:443".format(
                    vpc_suffix, manifest_data["env_name"], manifest_data["region"], manifest_data["env_name"]
                )
            outbound_infra_vpcs_info.append(infra_vpc_info)
        print("******** OUTBOUND INFRA VPC'S DDB SETUP *********")
        outbound_cfg_settings_tbl_name = "{}-{}-{}_OutboundConfigSettings".format(
            manifest_data["env_name"], manifest_data["region"], manifest_data["deployment_id"]
        )
        outbound_ddb_item = {"id": {"S": "infra_vpcs"}, "Payload": {"S": json.dumps(outbound_infra_vpcs_info)}}
        awsClient.aws_ddb_put_item(outbound_cfg_settings_tbl_name, outbound_ddb_item)
    else:
        print("Missing Outbound VPCs config in the manifest file")
        sys.exit(1)


def eks_nlb_setup(manifest_data):
    awsClient = AwsHelper()

    # Setup Inbound EKS Cluster
    print("*************************************************")
    print("*           INBOUND EKS NLB SETUP               *")
    print("*************************************************")
    inbound_eks_nlb_setup(awsClient, manifest_data)

    # Setup Outbound EKS Cluster
    print("*************************************************")
    print("*           OUTBOUND EKS NLB SETUP              *")
    print("*************************************************")
    outbound_eks_nlb_setup(awsClient, manifest_data)
