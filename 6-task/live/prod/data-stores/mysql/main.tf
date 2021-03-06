provider "aws" {
    region = "eu-central-1"
}

terraform {
    backend "s3" {
        key = "prod/data-stores/mysql/terraform.tfstate"
    }
}

#Data source lets pick information about network
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config  = {
    bucket = "vent555-bucket"
    key    = "prod/network/vpc-simple/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_db_instance" "example" {
    identifier_prefix = "prod-db"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "exampledatabase"
    username = "admin"
    password = var.db_password
    skip_final_snapshot = true
    apply_immediately = true
}

resource "aws_db_subnet_group" "example" {
  name       = "private-subnets-prod"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  tags = {
    Name = "DB subnets group"
  }
}