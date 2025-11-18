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

# Use existing IAM Role (imported)
data "aws_iam_role" "ssm_role" {
  name = "EC2-SSM-Role"
}

# Create an EC2 instance
resource "aws_instance" "web" {
  ami                    = "ami-03695d52f0d883f65" # Ubuntu 22.04 LTS for ap-south-1
  instance_type          = "t3.micro"
  key_name               = "LinuxKP"              # Your existing key pair
  vpc_security_group_ids = ["sg-02bc82cc403b4f622"]
  iam_instance_profile   = data.aws_iam_role.ssm_role.name

  tags = {
    Name = "TerraWebServer"
  }
}

# Output EC2 instance info
output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
