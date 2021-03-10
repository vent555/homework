provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "test-1" {
  ami = "ami-0767046d1677be5a0"
  instance_type = "t2.micro"
  #to link ec2-instance with security group:
  vpc_security_group_ids = [ aws_security_group.instance.id ]
  
  #create start-on-boot script
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    "Name" = "terraform-example"
  }
}

#this resource exports attribute "id" to refer on them.
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
}