#configure terraform to store state files in s3bucket
#!!!key must be different in every module!!!
terraform {
    backend "s3" {
        key = "prod/services/webserver-cluster/terraform.tfstate"
    }
}
#point provider and region
provider "aws" {
    region = "eu-central-1"
}

#import module
module "webserver_cluster" {
    #where module is located. Link on Github repository.
    #Download strict pointed version for product cluster.
    source = "github.com/vent555/tf-module-example//services/webserver-cluster?ref=v0.1.0"
    #cluster_name to deploy
    cluster_name = "webservers-prod"
    #where the information about the DB connection is originated for the prod cluster
    db_remote_state_bucket = "vent555-bucket"
    db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
    #where the information about the VPC is originated for the stage cluster
    vpc_remote_state_bucket = "vent555-bucket"
    vpc_remote_state_key = "prod/network/vpc-simple/terraform.tfstate"
    #Type and min/max number (for ASG) of EC2 instance to run
    instance_type = "t2.micro"
    min_size = 2
    max_size = 10
}

#if we need change infrastructure performance depending on day time 
#for example, described in resources below
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    scheduled_action_name = "scale-out-during-business-hours"
    min_size = 2
    max_size = 10
    desired_capacity = 10
    recurrence = "0 9 * * *"
    #Output var from module webserver_cluster,
    #which point name of ASG for current resource application
    autoscaling_group_name = module.webserver_cluster.asg_name
  }
resource "aws_autoscaling_schedule" "scale_in_at_night" {
    scheduled_action_name = "scale-in-at-night"
    min_size = 2
    max_size = 10
    desired_capacity = 2
    recurrence = "0 17 * * *"
    #Output var from module webserver_cluster,
    #which point name of ASG for current resource application
    autoscaling_group_name = module.webserver_cluster.asg_name
  }