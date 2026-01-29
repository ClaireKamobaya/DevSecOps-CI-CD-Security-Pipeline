terraform {
  backend "http" {
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "example" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
data "aws_security_group" "runner_sg" {
    name = "launch-wizard-4"
}
resource "aws_security_group" "my_project_sg"{
    name = "claire-updated-ansible-test-sg"
    description = "Allow SSH from GitLab Runner only"

    ingress{
        description ="SSH from GitLab Runner"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [data.aws_security_group.runner_sg.id]
}
    ingress{
        description = "SSH from anywhere for Ansible"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
}

    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "my_instance" {
    ami = data.aws_ami.example.id
    instance_type = "t3.micro"
    key_name = "ClaireTestKeyPair"
    vpc_security_group_ids = [aws_security_group.my_project_sg.id]

    root_block_device {
        volume_size = 10
    }

    ebs_block_device {
        device_name = "/dev/sdf"
        volume_size = 10
    }

    tags = {
        Name = "IT351-ProjectInstance", Lab7 = "completed"
    }
}

output "instance_ip" {
    value = aws_instance.my_instance.public_ip
}
