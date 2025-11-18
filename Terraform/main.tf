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

# ----------------------------------
# Get default VPC
# ----------------------------------
data "aws_vpc" "default" {
  default = true
}

# ----------------------------------
# Get default subnet
# ----------------------------------
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ----------------------------------
# IAM ROLE & INSTANCE PROFILE (for SSM)
# ----------------------------------
resource "aws_iam_role" "ec2_ssm_role" {
  name = "EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "EC2-SSM-InstanceProfile"
  role = aws_iam_role.ec2_ssm_role.name
}

# ----------------------------------
# Security Group (HTTP + Outbound)
# ----------------------------------
resource "aws_security_group" "web_sg" {
  name        = "ec2-web-sg"
  description = "Allow HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP"
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

# ----------------------------------
# EC2 INSTANCE
# ----------------------------------
resource "aws_instance" "myserver" {
  ami           = "ami-0f5ee92e2d63afc18"  # Ubuntu 22.04 LTS (ap-south-1)
  instance_type = "t2.micro"

  key_name = "LinuxKP"

  subnet_id = data.aws_subnets.default.ids[0]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  tags = {
    Name = "MyServer"
  }
}
