variable "server_port" {
  description   = "Server port to listen http requests"
  type          = number
  default       = 8080
}
#output server public IP address 
output "alb_dns_name" {
  #link variable with ec2 instance
  value = aws_lb.example.dns_name
  description = "DNS name of the load balancer"
}

#point provider and region
provider "aws" {
  region = "eu-central-1"
}

#Each EC2 instance locates in own VPC subnet
#which locates in isolate availability zone.
#Request information about VPC 
#which will use to auto scaling launch resources.
data "aws_vpc" "default" {
  default = true
}
#Use one more data source to extract VPC subnets from whole VPC cloud 
data "aws_subnet_ids" "default" {
  #link to aws_vpc data source by id  
  vpc_id = data.aws_vpc.default.id
}

#Application load balancer
resource "aws_lb" "example" {
  name                  = "terraform-asg-example"
  load_balancer_type    ="application"
  #extract VPC zone ids from data source aws_subnet_ids
  subnets               = data.aws_subnet_ids.default.ids
  #link to traffic policy for ALB
  security_groups       = [aws_security_group.alb.id]
}
#traffic policy for ALB
resource "aws_security_group" "alb" {
  name = "terraform-example-alb"
  #permit http requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #permit any output
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#ALB consist of three parts:
#1. Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn  = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"
  
  #Default action is response with "404: not found"
  default_action {
    type = "fixed-response"

    fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code  = 404
    }
  }
}
#2. Listener rule
resource "aws_lb_listener_rule" "asg" {
  listener_arn  = aws_lb_listener.http.arn
  priority      = 100

  condition {
    path_pattern {
        values  = ["*"]
    }
  }

  action {
    type                = "forward"
    target_group_arn    = aws_lb_target_group.asg.arn
  }
}
#3. Target group
resource "aws_lb_target_group" "asg" {
  name      = "terraform-asg-example"
  port      = var.server_port
  protocol  = "HTTP"
  vpc_id    = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#auto scaling group to launch EC2 instance on demand
resource "aws_autoscaling_group" "test-group" {
  #use link as launch_configuration name
  launch_configuration  = aws_launch_configuration.test-1.name
  #extract VPC zone ids from data source aws_subnet_ids
  vpc_zone_identifier   = data.aws_subnet_ids.default.ids
  #link to Target group in ALB
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  #from 2 to 10 ec2 instance will launched
  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }

}

#use aws_launch_configuration instead aws_instance =>
#change ami to image_id, vpc_security_group_ids to security_groups
resource "aws_launch_configuration" "test-1" {
  image_id          = "ami-0767046d1677be5a0"
  instance_type     = "t2.micro"
  #to link ec2-instance with security group:
  security_groups   = [ aws_security_group.instance.id ]
  
  #create start-on-boot script
  user_data         = <<-EOF
                        #!/bin/bash
                        echo "Hello, World!" > index.html
                        nohup busybox httpd -f -p ${var.server_port} &
                        EOF
  #configuration param is used then auto scaling implemented
  lifecycle {
    create_before_destroy = true
  }
}

#this resource exports attribute "id" to refer on them.
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
}