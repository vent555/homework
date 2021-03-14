#configure terraform to store state files in s3bucket
#!!!key must be different in every module!!!
terraform {
    backend "s3" {
        key = "stage/services/webserver-cluster/terraform.tfstate"
    }
}
#point provider and region
provider "aws" {
    region = "eu-central-1"
}

#import module
module "webserver_cluster" {
    #where module is located. Link on Github repository.
    #Always download latest version for test cluster.
    source = "github.com/vent555/tf-module-example//services/webserver-cluster"
    #cluster_name to deploy
    cluster_name = "webservers-stage"
    #where the information about the DB connection is originated for the stage cluster
    db_remote_state_bucket = "vent555-bucket"
    db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
    #Type and min/max number (for ASG) of EC2 instance to run
    instance_type = "t2.micro"
    min_size = 2
    max_size = 4
}

#for testing purpose we can apply traffic permit rule to ALB
resource "aws_security_group_rule" "allow_testing_inbound" {
  type = "ingress"
  #rule applied to policy group for ALB
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}