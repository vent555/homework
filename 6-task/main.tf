provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "test-1" {
  ami = "ami-0767046d1677be5a0"
  instance_type = "t2.micro"
  
  tags = {
    "Name" = "terraform-example"
  }
}