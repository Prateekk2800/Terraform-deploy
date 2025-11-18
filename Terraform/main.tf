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

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "EC2SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonSSMManagedInstanceCore
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Security Group allowing HTTP/SSH
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"
  ingress = [
    {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0dba2cb6798deb6d8" # Amazon Linux 2
  instance_type = "t3.micro"
  key_name      = "LinuxKP"              # your key pair
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "TerraformWebServer"
  }
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "EC2SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

# Output instance ID and public IP
output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
