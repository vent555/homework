
#configure terraform to store state files in s3bucket
#!!!key must be different in every module!!!
terraform {
    backend "s3" {
        key = "global/s3/terraform.tfstate"
    }
}

provider "aws" {
  region = "eu-central-1"
}
#create s3bucket to store terraform file states
#and future porpose
resource "aws_s3_bucket" "terraform_state" {
    bucket = "vent555-bucket"

    lifecycle {
        prevent_destroy = true
    }

    versioning {
        enabled = true
    }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}
#create DB to block while running terraform apply action
resource "aws_dynamodb_table" "terraform_locks" {
    name = "vent555-bucket-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}
