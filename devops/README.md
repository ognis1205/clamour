# Set up Clamour AWS environment

## Prerequisites

To follow the instructions, you will need:

 - The Terraform CLI (~> 1.2.0) installed.
 - The AWS CLI installed.
 - AWS account and associated credentials that allow you to create resources.
 - AWS S3 backend that stores the state as a given key in a given bucket.
 
To use your IAM credentials to authenticate the Terraform AWS provider, add the following configuration in *~/.aws/credentials*:

```text
[clamour]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

To enable the AWS S3 remote store backend, create a AWS S3 bucket named *clamour*.
