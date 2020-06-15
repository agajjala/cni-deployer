# CNI Terraform
```bash
cni-tf
├── Applications     --> CNI Kubernetes Applications
│   ├── Makefile
│   └── cni-inbound  --> CNI Inbound HelmChart Template Definitions
|   └── cni-outbound --> CNI Outbound HelmChart Template Definitions
├── Infrastructure
│   ├── deployer     --> Command Line Tool for deployment
│   └── provider     --> TF Infrastructure-as-code
├── scripts          --> Utility scripts
├── src              --> Scripts used to manage k8s deployments
└── README.md
```

## Requirements

1. Install Terraform:

    ```
    brew install terraform
    ```

2. Install the AWS CLI:

    ```
    brew install awscli
    ```

    If it is already installed, ensure it is updated to the latest version:

    ```
    brew upgrade awscli
    ```

3. Install kubectl:

    ```
    brew install kubectl
    ```

If you have Docker installed, follow these additional steps ([this will ensure your `kubectl` symlinks point to the brew installation](https://stackoverflow.com/a/55737973)):
    
   ```
   rm /usr/local/bin/kubectl
   brew link --overwrite kubernetes-cli
   ```


4. Install [aws-iam-authenticator](https://github.com/awsdocs/amazon-eks-user-guide/blob/master/doc_source/install-aws-iam-authenticator.md):

    ```
    brew install aws-iam-authenticator
    ```

5. Install Helm:
    ```
    brew install kubernetes-helm
    ```

6. Confirm your `python` alias points to `python3`

7. Install `python` packages:

    ```
   pip install -r requirements.txt
   ```

## Deploy a test environment using CodePipeline

1. Ensure the `master` branch of [cni-manifests](https://github.com/sf-sdn/cni-manifests) has the manifest you wish to deploy. If it does not yet exist or requires further changes, raise a PR for the changes required.

2. Ensure you have [cni-manifests](https://github.com/sf-sdn/cni-manifests) cloned locally and checked out to the latest `master` after PRs from step 1 are merged, if any were needed.

3. Run the following script:

    ```
   ./scripts/deploy_pipeline.sh <PATH TO MANIFEST FILE>
   ```

4. Once the above script completes, you should have a CodePipeline deployed to the region specified in the manifest.

In each stage of the pipeline, there is a manual approval step following each plan step. These manual approval steps require manual confirmation before the pipeline will proceed further.

## deploy.py

#### Init

`init` configures the Terraform state backend for a given module using metadata from the provided manifest. It is needed to be run before running low-level commands such as `terraform import` or `terraform state`.

#### Validate

`validate` is a read-only command that verifies a provided `-module` (along with its nested modules) is syntactically valid. This check is purely static and does not take into account provided variables or existing state.

    python deployer/deploy.py -c validate -module provider/aws/cni_test/ -manifest test_manifest.yaml

#### Plan

`plan` is a read-only command that outputs the exact list of changes Terraform will perform. This list of changes is stored as a `terraform_plan` file in the provided `-module` directory. This file is used by a successive `apply` command to perform the listed changes.

    python deployer/deploy.py -c plan -module provider/aws/cni_test/ -manifest test_manifest.yaml

#### Apply

The `apply` command reads the `terraform_plan` file output by the previous `plan` run and performs each change that was listed. `plan` should always be run before `apply`.

    python deployer/deploy.py -c apply -module provider/aws/cni_test/ -manifest test_manifest.yaml

#### Destroy

The `destroy` command destroys all infrastructure created by Terraform. This command will prompt for confirmation before destroying.

    python deployer/deploy.py -c destroy -module provider/aws/cni_test/ -manifest test_manifest.yaml
    
#### Refresh

The `refresh` command updates Terraform's state to reflect real-world infrastructure. This is useful to detect drift from last-known state, such as in the event of an `apply` or `destroy` interruption.

    python deployer/deploy.py -c destroy -module provider/aws/cni_test/ -manifest test_manifest.yaml

## Deploy to EKS clusters

1. First, make sure your manifest is under `Manifests/Dev`. In the parent directory of this repository, run the following command:

```
make template
```

This will run `helm` to generate a number of k8s service files based on the contents of your manifest.

2. To submit services to a running EKS cluster, you will first need to update your local `kubeconfig` to point to it. Do this by running the following:

```
aws eks --region <REGION> update-kubeconfig --name <NAME OF EKS CLUSTER>
```

3. Run the next command to deploy the generated service files to the EKS cluster:

```
kubectl apply -f Manifest/Output/<RESOURCE_PREFIX>-<INBOUND OR OUTBOUND>-data-plane/cni-inbound/templates/
```

The EKS cluster should now be fully provisioned.

Note: in order too deploy to both the inbound and outbound EKS clusters, you'll need to repeat steps 2 and 3 for both inbound and outbound.
