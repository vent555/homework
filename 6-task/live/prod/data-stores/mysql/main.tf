provider "aws" {
    region = "eu-central-1"
}

terraform {
    backend "s3" {
        key = "prod/data-stores/mysql/terraform.tfstate"
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