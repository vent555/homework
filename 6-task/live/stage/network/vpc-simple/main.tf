provider "aws" {
    region = "eu-central-1"
}

terraform {
    backend "s3" {
        key = "stage/network/vpc-simple/terraform.tfstate"
    }
}

module "vpc" {
  source = "github.com/vent555/tf-module-example//network/vpc?ref=v0.1.0"
  #source = "../../modules/network/vpc/"

  name = "simple-example"

  cidr = "10.10.0.0/22"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets  = ["10.10.0.0/25", "10.10.0.128/25"]

  single_nat_gateway = true

  tags = {
    Owner       = "vent555"
    Environment = "stage"
  }

  vpc_tags = {
    Name = "vpc-stage"
  }
}