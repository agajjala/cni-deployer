import os
import sys
import time
import json
import boto3
import botocore
from kubernetes import client, config
from eks_dataplane_deploy import *
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
        self.ec2Client = boto3.client("ec2")
        return

    def aws_ec2_create_tags(self, resources, tags):
        try:
            response = self.ec2Client.create_tags(Resources=resources, Tags=tags)
        except botocore.exceptions.ClientError as error:
            print("Failed to create Tags for Resources: " + resources)
            raise error

    def aws_ddb_get_item(self, table_name, key):
        try:
            response = self.ddbClient.get_item(TableName=table_name, Key=key)
        except botocore.exceptions.ClientError as error:
            pprint("Failed to get AWS DDB Item: %s, in table: %s." % (key, table_name))
            raise error

        if "Item" not in response:
            print("AWS DDB Table: %s has no items matching with key: %s" % (table_name, key))
            return None

        return response["Item"]

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
            print("Failed to modify loadbalancer attributes for LB: %s" % (lb_name))
            raise error

        print("LB Attributes Modified: %s" % (response["Attributes"][0]))

    def aws_nlb_get_name(self, lb_name):
        nlb_name = lb_name.split("-", 1)[0]
        nlb_net = lb_name.split("-", 1)[1].split(".", 1)[0]
        return "net/{}/{}".format(nlb_name, nlb_net)

    def aws_create_vpc_endpoint_service_configuration(self, lb_name, tags):
        lb_arn = [self.aws_elb_get_lb_arn(lb_name)]
        try:
            response = self.ec2Client.create_vpc_endpoint_service_configuration(
                NetworkLoadBalancerArns=lb_arn, AcceptanceRequired=True
            )
        except botocore.exceptions.ClientError as error:
            print("Failed to create vpc endpoint service configuration for LB_NAME: %s" % (lb_name))
            raise error

        # create tags
        self.aws_ec2_create_tags(resources=[response["ServiceConfiguration"]["ServiceId"]], tags=tags)
        return (
            response["ServiceConfiguration"]["ServiceId"],
            response["ServiceConfiguration"]["ServiceName"],
            response["ServiceConfiguration"]["ServiceState"],
        )

    def aws_describe_vpc_endpoint_service_configurations(self, serviceID, Filters):
        try:
            if serviceID != "":
                response = self.ec2Client.describe_vpc_endpoint_service_configurations(ServiceIds=[serviceID], Filters=Filters)
            else:
                response = self.ec2Client.describe_vpc_endpoint_service_configurations(Filters=Filters)
        except botocore.exceptions.ClientError as error:
            print("Failed to describe vpc endpoint service configuration for ServiceID: %s" % (serviceID))
            raise error

        if len(response["ServiceConfigurations"]) != 1:
            print("Invalid vpc endpoint service configuration for ServiceID: %s" % (serviceID))
            return "", "", ""

        print(
            "vpc endpoint service configuration state: %s for ServiceID: %s"
            % (response["ServiceConfigurations"][0]["ServiceState"], serviceID)
        )
        return (
            response["ServiceConfigurations"][0]["ServiceId"],
            response["ServiceConfigurations"][0]["ServiceName"],
            response["ServiceConfigurations"][0]["ServiceState"],
        )

    def aws_create_vpc_endpoint_connection_notification(self, serviceID, ConnNotifArn, ConnNotifEvents):
        try:
            response = self.ec2Client.create_vpc_endpoint_connection_notification(
                ServiceId=serviceID, ConnectionNotificationArn=ConnNotifArn, ConnectionEvents=ConnNotifEvents
            )
        except botocore.exceptions.ClientError as error:
            print("Failed to create vpc endpoint connection notification for ServiceID: %s" % (serviceID))
            raise error

        print("Created vpc endpoint connection notification for ServiceID: %s" % (serviceID))

    def aws_modify_vpc_endpoint_service_permissions(self, serviceID, AllowedPrincipals):
        try:
            response = self.ec2Client.modify_vpc_endpoint_service_permissions(
                ServiceId=serviceID, AddAllowedPrincipals=AllowedPrincipals
            )
        except botocore.exceptions.ClientError as error:
            print("Failed to modify vpc endpoint service permissions for ServiceID: %s" % (serviceID))
            raise error
        print("Modified VPC Endpoint service permissions for ServiceID: %s(%s)" % (serviceID, response["ReturnValue"]))


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
        assert svc_list[0].status.load_balancer.ingress != None
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

    # Get the  VPC Endpoint service configuration from DDB for Inbound NLB if present
    inbound_ddb_key = {"id": {"S": "endpoint"}}
    inbound_cfg_settings_tbl_name = "{}-{}-{}_InboundConfigSettings".format(
        manifest_data["env_name"], manifest_data["region"], manifest_data["deployment_id"]
    )
    ddb_item = awsClient.aws_ddb_get_item(table_name=inbound_cfg_settings_tbl_name, key=inbound_ddb_key)
    if ddb_item == None:
        print("Inbound Config Settings Table endpoint info empty")
        print("Creating the VPC Endpoint service configuration...")
        Tags = [
            {"Key": "env_name", "Value": manifest_data["env_name"]},
            {"Key": "deployment_id", "Value": manifest_data["deployment_id"]},
            {"Key": "region", "Value": manifest_data["region"]},
        ]
        svcID, svcName, svcState = awsClient.aws_create_vpc_endpoint_service_configuration(
            lb_name=nlb_name.split("-", 1)[0], tags=Tags
        )

        time.sleep(10)
        # Get the lastest status of the VPC Endpoint service configuration
        Filters = [{"Name": "service-name", "Values": [svcName]}, {"Name": "service-state", "Values": ["Available"]}]
        svcID, svcName, svcState = awsClient.aws_describe_vpc_endpoint_service_configurations(serviceID=svcID, Filters=Filters)
        print("Created ServiceID: %s, ServiceName: %s, ServiceState: %s" % (svcID, svcName, svcState))

        # Create a VPC EndPoint Connection Notification
        conn_notif_arn_parameter_key = "/{}-{}/{}/inbound-data-plane/vpce-sns-topic".format(
            manifest_data["env_name"], manifest_data["region"], manifest_data["deployment_id"]
        )
        connNotifARN = awsClient.aws_ssm_fetch_parameter(parameter_name=conn_notif_arn_parameter_key)
        awsClient.aws_create_vpc_endpoint_connection_notification(
            serviceID=svcID, ConnNotifArn=connNotifARN, ConnNotifEvents=["Accept", "Reject", "Connect", "Delete"]
        )

        # Update the VPC Endpoint Service Permissions
        awsClient.aws_modify_vpc_endpoint_service_permissions(serviceID=svcID, AllowedPrincipals=["*"])

        # Update DDB with the VPC Endpoint Service Info
        inbound_svc_id = {"service_id": svcID}
        inbound_ddb_item = {"id": {"S": "endpoint"}, "Payload": {"S": json.dumps(inbound_svc_id)}}
        awsClient.aws_ddb_put_item(inbound_cfg_settings_tbl_name, inbound_ddb_item)

        inbound_svc_name = {"service_name": svcName}
        inbound_ddb_item = {"id": {"S": "info"}, "Payload": {"S": json.dumps(inbound_svc_name)}}
        awsClient.aws_ddb_put_item(inbound_cfg_settings_tbl_name, inbound_ddb_item)
    else:
        svc_info = json.loads(ddb_item["Payload"]["S"])
        svcID, svcName, svcState = awsClient.aws_describe_vpc_endpoint_service_configurations(
            serviceID=svc_info["service_id"], Filters=[]
        )
        print("Retrieved ServiceID: %s, ServiceName: %s, ServiceState: %s" % (svcID, svcName, svcState))


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
        for vpc_suffix in [str(key) for key in outbound_vpc_cfg.keys()]:
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


def eks_nlb_setup(manifest_data, direction):
    awsClient = AwsHelper()
    if direction == "inbound":
        # Setup Inbound EKS Cluster
        print("*************************************************")
        print("*           INBOUND EKS NLB SETUP               *")
        print("*************************************************")
        inbound_eks_nlb_setup(awsClient, manifest_data)
    elif direction == "outbound":
        # Setup Outbound EKS Cluster
        print("*************************************************")
        print("*           OUTBOUND EKS NLB SETUP              *")
        print("*************************************************")
        outbound_eks_nlb_setup(awsClient, manifest_data)
    else:
        print("Invalid direction")
        sys.exit(1)
