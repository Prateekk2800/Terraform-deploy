terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-03695d52f0d883f65"
  instance_type          = "t3.micro"
  key_name               = "LinuxKP"
  iam_instance_profile   = "EC2-SSM-Role"
  tags = {
    Name = "TerraServer"
  }
}

output "instance_id" {
  value = aws_instance.example.id
}