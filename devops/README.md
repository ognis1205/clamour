# Set up Clamour AWS environment

## Prerequisites

To follow the instructions, you will need:

 - The Terraform CLI installed.
 - The AWS CLI installed.
 - AWS account and associated credentials that allow you to create resources.
 
To use your IAM credentials to authenticate the Terraform AWS provider, add the following configuration in *~/.aws/credentials*:

```text
[clamour]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```
