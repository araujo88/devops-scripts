provider "aws" {
    region = var.aws_region
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-pair"
  public_key = file("key.pub")
}

resource "aws_vpc" "example" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "example-vpc"
    }
}

resource "aws_subnet" "frontend" {
    vpc_id     = aws_vpc.example.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "sa-east-1a"

    tags = {
        Name = "frontend"
    }
}

resource "aws_subnet" "backend" {
    vpc_id     = aws_vpc.example.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "sa-east-1b"

    tags = {
        Name = "backend"
    }
}

resource "aws_security_group" "frontend" {
    vpc_id      = aws_vpc.example.id

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
}

resource "aws_security_group" "backend" {
    vpc_id      = aws_vpc.example.id

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        security_groups = [aws_security_group.frontend.id]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = [aws_security_group.frontend.id] # add the frontend security group
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_launch_configuration" "backend" {
    image_id    = var.ec2_ami
    instance_type = "t3.micro"
    security_groups = [aws_security_group.backend.id]
    associate_public_ip_address = true
    key_name      = aws_key_pair.my_key_pair.key_name
    user_data = <<-EOF
                #!/bin/bash -ex
                sudo apt-get update
                sudo apt-get install nginx -y
                sudo apt-get install net-tools -y
                sudo systemctl enable nginx
                sudo systemctl start nginx
                sudo service nginx stop
                sudo service nginx restart
                EOF
}

resource "aws_autoscaling_group" "backend" {
    launch_configuration = aws_launch_configuration.backend.name
    vpc_zone_identifier = [aws_subnet.backend.id]
    min_size = 1
    max_size = 3
    health_check_grace_period = 300
    health_check_type = "EC2"
    target_group_arns = [aws_lb_target_group.backend.arn]

    tag {
        key = "Name"
        value = "backend-instance"
        propagate_at_launch = true
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_instance" "frontend" {
    ami           = var.ec2_ami
    instance_type = "t3.micro"
    key_name      = aws_key_pair.my_key_pair.key_name
    subnet_id = aws_subnet.frontend.id
    vpc_security_group_ids = [aws_security_group.frontend.id]
    associate_public_ip_address = true

    tags = {
        Name = "frontend-instance"
    }

    user_data = <<-EOF
    #!/bin/bash -ex
    sudo apt-get update
    sudo apt-get install nginx -y
    sudo apt-get install net-tools -y
    sudo systemctl enable nginx
    sudo systemctl start nginx
    sudo service nginx stop
    sudo service nginx restart
    EOF
}

resource "aws_internet_gateway" "example" {
    vpc_id = aws_vpc.example.id

    tags = {
    Name = "example-igw"
    }
}

resource "aws_route_table" "frontend" {
    vpc_id = aws_vpc.example.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.example.id
    }

    tags = {
        Name = "frontend-rt"
    }
}

resource "aws_route_table" "backend" {
    vpc_id = aws_vpc.example.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.example.id
    }

    tags = {
        Name = "backend-rt"
    }
}

resource "aws_route_table_association" "frontend" {
    subnet_id = aws_subnet.frontend.id
    route_table_id = aws_route_table.frontend.id
}

# Associates route table with subnet
resource "aws_route_table_association" "backend" {
    subnet_id = aws_subnet.backend.id
    route_table_id = aws_route_table.backend.id
}

resource "aws_lb" "example" {
    name = "example-lb"
    internal = false
    load_balancer_type = "application"
    subnets = [aws_subnet.frontend.id, aws_subnet.backend.id] # add the backend subnet
    security_groups = [aws_security_group.frontend.id] # allow traffic from frontend

    tags = {
        Name = "example-lb"
    }
}

resource "aws_lb_target_group" "backend" {
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.example.id

    tags = {
        Name = "backend-tg"
    }
}

resource "aws_lb_listener" "frontend" {
    load_balancer_arn = aws_lb.example.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.backend.arn
    }
}
