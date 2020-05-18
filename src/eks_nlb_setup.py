import os
import sys
import subprocess
import yaml
import boto3
import botocore
import time
from kubernetes import client, config
from eks_dataplane_deploy import *

INBOUND_NAMESPACE = "cni-inbound"
OUTBOUND_NAMESPACE = "cni-outbound"
WAIT_TIMEOUT = 300

# Fetch the AWS NLB ARN 
def aws_elb_get_lb_arn(lb_name):
    client = boto3.client('elbv2')
    try:
        print('Calling ELBv2 describe_load_balancers() API')
        response = client.describe_load_balancers(
            Names=[
                lb_name
            ],
        )
    except botocore.exceptions.ClientError as error:
        raise error

    return response["LoadBalancers"][0]["LoadBalancerArn"]

# Fetch the AWS NLB TargetGroup ARN 
def aws_elb_get_tg_arn(lb_arn):
    client = boto3.client('elbv2')
    # Get Target-Group ARN to modify attributes
    try:
        response = client.describe_target_groups(
            LoadBalancerArn=lb_arn
        )
    except botocore.exceptions.ClientError as error:
        print("Failed to describe_target_groups()")
        raise error
    return response["TargetGroups"][0]["TargetGroupArn"]

# Enable PPV2 for the Target Group
def aws_elb_enable_ppv2_attr(tg_arn):
    client = boto3.client('elbv2')
    # Modify the TG-Attr to enable PPV2
    try:
        response = client.modify_target_group_attributes(
            TargetGroupArn=tg_arn,
            Attributes=[
                {
                    'Key': 'proxy_protocol_v2.enabled',
                    'Value': 'true'
                },
            ]
        )
    except botocore.exceptions.ClientError as error:
        print("Failed to describe_target_groups()")
        raise error

    print ("PPV2 Enabled: %s" %(response["Attributes"][0]))

def aws_elb_enable_crosszone_lb(lb_arn):
    client = boto3.client('elbv2')
    try:
        response = client.modify_load_balancer_attributes(
            LoadBalancerArn=lb_arn,
            Attributes=[
                {
                    'Key': 'load_balancing.cross_zone.enabled',
                    'Value': 'true'
                },
            ]
        )
    except botocore.exceptions.ClientError as error:
        print("Failed to describe_target_groups()")
        raise error

    print ("LB Cross-Zone Enabled: %s" %(response["Attributes"][0]))

def aws_elb_modify_tg_attributes(lb_arn, enable_ppv2, enable_crosszone_lb):
    print("Modifying Attributes for LB: %s" %(lb_arn))
    if enable_ppv2:
        tg_arn = aws_elb_get_tg_arn(lb_arn)
        aws_elb_enable_ppv2_attr(tg_arn)

    if enable_crosszone_lb:
        aws_elb_enable_crosszone_lb(lb_arn)

def get_eks_nlb_name(namespace):
    #Fetch the K8S Service name
    config.load_kube_config(os.path.join(os.environ["HOME"], '.kube/config'))
    v1 = client.CoreV1Api()
    timeout_start = time.time()
    while time.time() < timeout_start + WAIT_TIMEOUT:
        svc_list = v1.list_namespaced_service(namespace)
        if len(svc_list.items) > 0:
            nlb_name = svc_list.items[0].status.load_balancer.ingress[0].hostname
            return nlb_name
        else:
            time.sleep(10)
            continue
    print("Timed out while provisioning load balancer DNS name")
    sys.exit(1)

def outbound_eks_nlb_setup(manifest_data):
    if "outbound_vpcs_config" in manifest_data:
        outbound_vpc_cfg = manifest_data['outbound_vpcs_config']
        outbound_vpcs_count = len(outbound_vpc_cfg['vpc_cidrs'])
        for vpc_count in range(outbound_vpcs_count):
            cluster_name = '{}-{}-{}-{}-data-plane'.format(manifest_data['env_name'], manifest_data['region'], manifest_data['deployment_id'], "outbound-" + str(vpc_count + 1))
            update_kubeconfig(cluster_name, manifest_data['region'])
            outbound_nlb_name = get_eks_nlb_name(OUTBOUND_NAMESPACE)
            print("Outbound-%s NLB Name: %s" %(str(vpc_count + 1), outbound_nlb_name))
            lb_arn = aws_elb_get_lb_arn(outbound_nlb_name.split('-', 1)[0])
            aws_elb_modify_tg_attributes(lb_arn, enable_ppv2=False, enable_crosszone_lb=True)


def inbound_eks_nlb_setup(manifest_data):
    cluster_name = '{}-{}-{}-{}-data-plane'.format(manifest_data['env_name'], manifest_data['region'], manifest_data['deployment_id'], "inbound")
    update_kubeconfig(cluster_name, manifest_data['region'])
    inbound_nlb_name = get_eks_nlb_name(INBOUND_NAMESPACE)
    print("Inbound NLB Name: %s" %(inbound_nlb_name))
    lb_arn = aws_elb_get_lb_arn(inbound_nlb_name.split('-', 1)[0])
    aws_elb_modify_tg_attributes(lb_arn, enable_ppv2=True, enable_crosszone_lb=True)

def eks_nlb_setup(manifest_data):    
    inbound_eks_nlb_setup(manifest_data)
    outbound_eks_nlb_setup(manifest_data)


