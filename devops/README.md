# Set up Clamour AWS environment

## Prerequisites

To follow the instructions, you will need:

 - The Terraform CLI (1.2.0) installed.
 - The AWS CLI installed.
 - AWS account and associated credentials that allow you to create resources.
 - AWS S3 backend that stores the state as a given key in a given bucket.

### IAM credentials
 
To use your IAM credentials to authenticate the Terraform AWS provider, add the following configuration in *~/.aws/credentials* with proper keys:

```text
[clamour]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

### Terraform S3 remote store backend

To enable the AWS S3 remote store backend, create a AWS S3 bucket named *clamour*.

## Create resources on AWS

To initialize a working directory containing Terraform configuration files, run the following:

```bash
 $ cd terraform
 $ terraform init
```

After the initialization, run the following command to execute actions proposed in the Terraform plan:

```bash
 $ terraform apply
```

### Authenticate dev users to access EKS

Run the following command and output the EKS auth config YAML file:

```bash
 $ terraform output aws_auth_config_map > aws-auth-config-map.yaml
```

The resulting file looks like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::xxxxxxxxxxx:role/clamour-eks-node-group-YYYYMMDDhhmmssxxxxxxxxxxxx
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
```

To authenticate *clamour* to access EKS, configure the *aws-auth-config-map.yaml* as follows with the proper IAM ARN:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::xxxxxxxxxxx:role/clamour-eks-node-group-YYYYMMDDhhmmssxxxxxxxxxxxx
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  # Add the following
  mapUsers: |
    - userarn: arn:aws:iam::xxxxxxxxxxx:user/clamour
      username: clamour
      groups:
        - system:masters
```
