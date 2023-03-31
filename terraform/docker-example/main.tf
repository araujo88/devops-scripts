# Provider configuration
provider "aws" {
	profile = "default"
	region = "sa-east-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id     = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "Public Subnet"
    }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
    vpc_id     = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "Private Subnet"
    }
}

# Create a route table for public subnet
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }

    tags = {
        Name = "Public Route Table"
    }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_subnet_association" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

# Create a security group for EC2 instances in the public subnet
resource "aws_security_group" "public_security_group" {
    name_prefix = "public_sg"
    vpc_id = aws_vpc.my_vpc.id

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
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Public Security Group"
    }
}

# Create a security group for EC2 instances in the private subnet
resource "aws_security_group" "private_security_group" {
    name_prefix = "private_sg"
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Private Security Group"
    }
}

# Launch an EC2 instance in the public subnet
resource "aws_instance" "public_ec2_instance" {
    ami           = "ami-0c09384a7d7c5b943"
    instance_type = "t3.micro"
    subnet_id     = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.public_security_group.id]
    associate_public_ip_address = true
    tags = {
        Name = "Public EC2 Instance"
    }

    user_data = <<-EOF
    #!/bin/bash -ex

    "sudo snap install docker",
    "sudo docker login --username=YOUR_USERNAME --password=YOUR_PASSWORD",
    "sudo docker pull YOUR_USERNAME/IMAGE_NAME:TAG_NAME",
    "sudo docker run -d -p 80:80 YOUR_USERNAME/IMAGE_NAME:TAG_NAME"
    EOF
}

#Launch an EC2 instance in the private subnet
resource "aws_instance" "private_ec2_instance" {
    ami = "ami-0c09384a7d7c5b943"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.private_subnet.id
    vpc_security_group_ids = [aws_security_group.private_security_group.id]
    associate_public_ip_address = true
    tags = {
        Name = "Private EC2 Instance"
    }
}