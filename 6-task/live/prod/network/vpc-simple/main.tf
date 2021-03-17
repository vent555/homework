provider "aws" {
    region = "eu-central-1"
}

terraform {
    backend "s3" {
        key = "prod/network/vpc-simple/terraform.tfstate"
    }
}

module "vpc" {
  source = "github.com/vent555/tf-module-example//network/vpc?ref=v0.1.0"
  #source = "../../modules/network/vpc/"

  name = "simple-example"

  cidr = "10.100.0.0/21"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets = ["10.100.4.0/24", "10.100.5.0/24", "10.100.6.0/24"]
  public_subnets  = ["10.100.0.0/24", "10.100.1.0/24"]

  single_nat_gateway = true

  tags = {
    Owner       = "vent555"
    Environment = "prod"
  }

  vpc_tags = {
    Name = "vpc-prod"
  }
}