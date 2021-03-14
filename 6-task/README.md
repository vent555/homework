# Task 6. Create terraform configuration files to deploy infrastructure in AWS cloud.

## Running
Amazon S3 Bucket is used to store environment state (tfstate files). Use -backend-config option to point backend.hlc file then init:
```sh
terraform init -backend-config=../../../backend.hlc
```

## Description
Stage and production webserver-cluster deploy modules call a template module from a GitHub repository:
* https://github.com/vent555/tf-module-example
* Stage always uses latest version of module.
* Prod uses only stable version of module.

## Content
### live/global/s3
Conteins configuration to deploy S3 bucket for maintaining terraform state files.

### live/prod is a product environment
* data-stores/mysql conteins configuration to deploy DB used by application.
* services/webserver-cluster conteins configuration to deploy application in webserver cluster.

### live/stage is a test environment
Similar to product environment.

### backend.hlc
Conteins config for S3 bucket to store tfstate files:
```
encrypt = true
#You must point your values for parameters below
region = "eu-central-1"
bucket = "vent555-bucket"
dynamodb_table = "vent555-bucket-locks"
```
