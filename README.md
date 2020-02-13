# cni-tf

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

5. Confirm your `python` alias points to `python3`

## Deploy a test environment

1. Make a copy of the base configuration file.

    ```
   cp base_config.tfvars.json cni_test.tfvars.json
   ```

2. Populate the empty values in `cni_test.tfvars.json` to reflect your desired setup. The table below details the meaning of each field.

    | Name | Description | Type
    |------|-------------|------|
    | region | Name of the AWS region to deploy to | `string` |
    | env | Name of the environment to deploy to | `string` |
    | deployment\_id | Short ID used to further distinguish a deployment. Must be less than 10 characters. | `string` |
    | tags | Map of tags used to annotate each resource supporting tags | `map(string)` |
    | artifact\_bucket | Name of the S3 bucket in which artifacts are stored | `string` |
    | lambda\_layer\_s3\_key | Name of the lambda layer object in the artifact bucket | `string` |
    | lambda\_function\_s3\_key | Name of the lambda function object in the artifact bucket | `string` |
    | inbound\_vpc\_cidr | CIDR of the inbound VPC | `string` |
    | inbound\_data\_plane\_cluster\_name | Name to give the inbound data plane cluster in EKS | `string` |
    | outbound\_vpc\_cidr | CIDR of the outbound VPC | `string` |
    | outbound\_data\_plane\_cluster\_name | Name to give the outbound data plane cluster in EKS | `string` |

3. Run the following command to perform a sanity check on your configuration file:

   ```
   python deployer/deploy.py -c plan -module $(pwd)/provider/aws/cni-test/ -tfvars $(pwd)/cni_test.tfvars.json
   ```

4. If the previous step was successful, run this command to deploy the environment:

    ```
    python deployer/deploy.py -c apply -module $(pwd)/provider/aws/cni-test/ -tfvars $(pwd)/cni_test.tfvars.json
    ```

5. You should now have a running test environment.

## deploy.py

#### Validate

The `validate` is a read-only command that verifies a provided `-module` is syntactically valid. This check is purely static and does not take into account provided variables or existing state.

    python deployer/deploy.py -c validate -module $(pwd)/provider/aws/cni-test/

#### Plan

`plan` is a read-only command that outputs the exact list of changes Terraform will perform. This list of changes is stored as a `terraform_plan` file in the provided `-module` directory. This file is used by a successive `apply` command to perform the listed changes.

    python deployer/deploy.py -c plan -module $(pwd)/provider/aws/cni-test/ -tfvars $(pwd)/cni_test.tfvars.json

#### Apply

The `apply` command reads the `terraform_plan` file output by the previous `plan` run and performs each change that was listed. `plan` should always be run before `apply`.

    python deployer/deploy.py -c apply -module $(pwd)/provider/aws/cni-test/ -tfvars $(pwd)/cni_test.tfvars.json

#### Destroy

The `destroy` command destroys all infrastructure created by Terraform. This command will prompt for confirmation before destroying.

    python deployer/deploy.py -c apply -module $(pwd)/provider/aws/cni-test/ -tfvars $(pwd)/cni_test.tfvars.json