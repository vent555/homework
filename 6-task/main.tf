variable "server_port" {
  description   = "Server port to listen http requests"
  type          = number
  default       = 8080
}
#output server public IP address 
output "public_ip" {
  #link variable with ec2 instance
  value = aws_instance.test-1.public_ip
  description = "Public ip of the web server"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "test-1" {
  ami                      = "ami-0767046d1677be5a0"
  instance_type            = "t2.micro"
  #to link ec2-instance with security group:
  vpc_security_group_ids   = [ aws_security_group.instance.id ]
  
  #create start-on-boot script
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  tags      = {
    "Name" = "terraform-example"
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