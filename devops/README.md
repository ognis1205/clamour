# Set up Clamour AWS environment

## Prerequisites

To follow the instructions, you will need:

 - The Terraform CLI (1.2.0) installed.
 - The AWS CLI installed.
 - AWS account and associated credentials that allow you to create resources.
 - AWS S3 backend that stores the state as a given key in a given bucket.

### IAM credentials
 
To use your IAM credentials to authenticate the Terraform AWS provider, configure your AWS CLI with proper proper values:

```bash
 $ aws configure --profile clamour
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: ap-southeast-1
Default output format [None]: text
 $ export AWS_DEFAULT_PROFILE=clamour
 $ export AWS_ACCESS_KEY_ID=
 $ export AWS_SECRET_ACCESS_KEY=
 $ aws sts get-caller-identity
xxxxxxxxxxxx    arn:aws:iam::yyyyyyyyyyyy:user/clamour  ZZZZZZZZZZZZZZZZZZZZZ
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
 $ terraform output aws_auth_config_map | sed -e '/<<EOT$/d;/^EOT$/d;/^$/d' > aws-auth-config-map.yaml
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

To authenticate *clamour* user to access EKS, configure *aws-auth-config-map.yaml* as follows with the proper IAM ARN:

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

After configuring *aws-auth-config-map.yaml*, update *kubeconfig* and apply *ConfigMap*:

```bash
 $ aws eks update-kubeconfig --name clamour-k8s
 $ kubectl apply -f aws-auth-configmal.yaml
```
 
 To check if the above configurations is applied properly, run the following commands:
 
```bash
 $ kubectl config view
 $ kubectl cluster-info
```

## Claen up resources on AWS

```bash
 $ cd terraform
 $ terraform destroy
```
