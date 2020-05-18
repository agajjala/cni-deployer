import argparse
import os
import sys
import subprocess
import yaml
from eks_nlb_setup import *


def get_fixed_arguments(args):
    """
    return the fixed arguments as a dictionary
    :param args:
    :return:
    """
    return vars(args)


def validate_arguments(args):
    """
    args must have the terraform command and path to the .tf configuration file
    :param args:
    :return:
    """
    assert (args.get('deploy_stage') is not None)
    assert ((args.get('deploy_stage') == "deploy")
            or (args.get('deploy_stage') == "validate"))
    assert (args.get('direction') is not None)
    assert ((args.get('direction') == "inbound")
            or (args.get('direction') == "outbound"))
    assert (args.get('manifest') is not None)


def process_manifest_file(manifest_file):
    with open(manifest_file, 'r') as file:
        return yaml.load(file, Loader=yaml.FullLoader)


def update_kubeconfig(cluster_name, aws_region):
    # aws eks --region <region> update-kubeconfig --name <eks-cluster-name>
    response = subprocess.run(
        ['aws', 'eks', '--region', aws_region, "update-kubeconfig", "--name", cluster_name])
    if response.returncode > 1:
        print(response)
        sys.exit('Updating KUBECONFIG failed')


def validate_eks_templates(cluster_name, templates_path):
    print("*** Validating EKS Cluster Templates for Cluster: %s ***" %
          (cluster_name))
    response = subprocess.run(['kubectl', 'diff', '-f', templates_path])
    # 0 No differences were found.
    # 1 Differences were found.
    # >1 Kubectl or diff failed with an error.
    if response.returncode == 0:
        print("No template differences were found for EKS Cluster: %s." % (cluster_name))
        return
    elif response.returncode == 1:
        print("Template differences were found for EKS Cluster: %s." % (cluster_name))
        print(response)
        return
    else:
        print(response)
        sys.exit('Validating EKS Cluster Templates failed')
    return


def deploy_eks_templates(cluster_name, templates_path):
    print("*** Deploying EKS Cluster Templates for Cluster: %s ***" %
          (cluster_name))
    response = subprocess.run(['kubectl', 'apply', '-f', templates_path])
    if response.returncode > 0:
        print(response)
        sys.exit('Deploying EKS Cluster Templates failed')


def inbound_eks_deploy(deploy_stage, manifest_data, cluster_name_suffix):
    cluster_name = '{}-{}-{}-{}-data-plane'.format(manifest_data['env_name'], manifest_data['region'], manifest_data['deployment_id'], cluster_name_suffix)
    templates_path = 'Manifests/Output/{}/cni-{}/templates/'.format(cluster_name, cluster_name_suffix)
    update_kubeconfig(cluster_name, manifest_data['region'])
    if deploy_stage == "validate":
        validate_eks_templates(cluster_name, templates_path)
    else:
        deploy_eks_templates(cluster_name, templates_path)


def outbound_eks_deploy(deploy_stage, manifest_data):

     if "outbound_vpcs_config" in manifest_data:
        outbound_vpc_cfg = manifest_data['outbound_vpcs_config']
        outbound_vpcs_count = len(outbound_vpc_cfg['vpc_cidrs'])
        for vpc_count in range(outbound_vpcs_count):
            cluster_name = '{}-{}-{}-{}-data-plane'.format(manifest_data['env_name'], manifest_data['region'], manifest_data['deployment_id'], "outbound-" + str(vpc_count + 1))
            templates_path = 'Manifests/Output/{}/cni-{}/templates/'.format(cluster_name, "outbound")
            update_kubeconfig(cluster_name, manifest_data['region'])
        if deploy_stage == "validate":
            validate_eks_templates(cluster_name, templates_path)
        else:
            deploy_eks_templates(cluster_name, templates_path)


def run(args):
    """
    run the eks template validation for the given cluster
    :param args:
    :return:
    """

    manifest_data = process_manifest_file(args["manifest"])
    if args["direction"] == "inbound":
        inbound_eks_deploy(args["deploy_stage"], manifest_data, args["direction"])
    else:
        outbound_eks_deploy(args["deploy_stage"], manifest_data)
    
    if args["deploy_stage"] == "validate":
        eks_nlb_setup(manifest_data)

def main():
    parser = argparse.ArgumentParser(
        description="This program validates EKS Application Templates with existing EKS cluster and Deploys them.")
    parser.add_argument(
        "--deploy-stage", help="option to validate/deploy the EKS templates")
    parser.add_argument(
        "--manifest", help="path to the manifest file describing the deployment")
    parser.add_argument(
        "--direction", help="cluster direction inbound/outbound")
    args = parser.parse_args()
    deploy_args = get_fixed_arguments(args)

    print("Arguments: {}".format(deploy_args))
    validate_arguments(deploy_args)
    run(deploy_args)


if __name__ == '__main__':
    main()
