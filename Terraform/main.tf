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

# Use the existing IAM Role (already imported)
data "aws_iam_role" "ssm_role" {
  name = "EC2SSMRole"
}

# Use the existing Security Group (already imported)
data "aws_security_group" "web_sg" {
  name = "web-sg"
}

# EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-083654bd07b5da81d"  # Ubuntu 22.04 LTS
  instance_type          = "t3.micro"
  iam_instance_profile   = data.aws_iam_role.ssm_role.name
  vpc_security_group_ids = [data.aws_security_group.web_sg.id]
  key_name               = "LinuxKP"

  tags = {
    Name = "WebServer"
  }

  # Install Apache on launch
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install apache2 -y
              sudo systemctl enable apache2
              sudo systemctl start apache2
              EOF
}

# Outputs
output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
