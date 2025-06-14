provider "aws" {
  region = "us-east-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Key pair
resource "aws_key_pair" "clo_key" {
  key_name   = "shrey-key"
  public_key = file("${path.module}/shrey-key.pub")
}

# Security group
resource "aws_security_group" "clo_sg" {
  name        = "clo835-sg"
  description = "Allow SSH and app traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port 8081"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port 8082"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App port 8083"
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance
resource "aws_instance" "app_server" {
  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.clo_key.key_name
  vpc_security_group_ids      = [aws_security_group.clo_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "CLO835-App-Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install docker -y
              service docker start
              usermod -a -G docker ec2-user
              chkconfig docker on
              EOF
}

# ECR repo for WebApp
resource "aws_ecr_repository" "webapp_repo" {
  name = "webapp-repo"
}

# ECR repo for MySQL
resource "aws_ecr_repository" "mysql_repo" {
  name = "mysql-repo"
}
