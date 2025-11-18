terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Use existing IAM Instance Profile
data "aws_iam_instance_profile" "ssm_profile" {
  name = "EC2-SSM-Role"  # your existing role name
}

# Default VPC data
data "aws_vpc" "default" {
  default = true
}

# Security Group
resource "aws_security_group" "web_sg_1" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-03695d52f0d883f65" # Ubuntu 22.04 or Amazon Linux
  instance_type          = "t3.micro"
  key_name               = "LinuxKP"               # Your keypair
  iam_instance_profile   = data.aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.web_sg_1.id]

  tags = {
    Name = "TerraServer"
  }
}

# Outputs
output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
