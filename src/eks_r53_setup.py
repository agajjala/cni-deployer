import os
import sys
import subprocess
import yaml
import boto3
import botocore
import time
from eks_dataplane_deploy import *

def aws_ssm_fetch_parameter(parameter_name):
    ssm = boto3.client('ssm')
    try:
        parameter = ssm.get_parameter(
            Name=parameter_name, 
            WithDecryption=True
        )
    except Exception as error:
        print(error)
        sys.exit(1)
    return parameter["Parameter"]["Value"]

def aws_add_r53_record(source, target, hosted_zone_id):
    client = boto3.client('route53')
    try:
	    response = client.change_resource_record_sets(
            HostedZoneId=hosted_zone_id,
		    ChangeBatch= {
                'Comment': 'add %s -> %s' % (source, target),
                'Changes': [
				    {
				        'Action': 'UPSERT',
				        'ResourceRecordSet': {
						    'Name': source,
						    'Type': 'CNAME',
						    'TTL': 60,
						    'ResourceRecords': [{'Value': target}]
					    }
				    }
                ]
		    }
        )
    except Exception as error:
        print(error)
        sys.exit(1)

def add_outbound_k8s_lb_dns_records(env_name, deployment_id, region, vpc_suffix, outbound_lb_url):
    #/dev-us-west-2/kev-test/stack_base/r53/sfdcsb
    r53_parameter_key = '/{}-{}/{}/stack_base/r53/sfdcsb'.format(env_name, region, deployment_id)
    outbound_hostedzone_id = aws_ssm_fetch_parameter(r53_parameter_key)
    print(outbound_hostedzone_id)
    outbound_nlb_dns_url = 'core-{}.{}.aws.{}.cni{}.sfdcsb.net'.format(vpc_suffix, env_name, region, env_name)
    print("Outbound-%s DNS URLName: %s" %(vpc_suffix, outbound_nlb_dns_url))
    print("Adding CNAME Record for %s --> %s in HostedZone: %s" % (outbound_nlb_dns_url, outbound_lb_url, outbound_hostedzone_id))
    aws_add_r53_record(outbound_nlb_dns_url, outbound_lb_url, outbound_hostedzone_id)
    print("Done")