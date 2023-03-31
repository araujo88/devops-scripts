variable "vpc_cidr" {
    description = "Value of the CIDR range for the VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_name" {
    description = "Value of the name for the VPC"
    type = string
    default = "MyTestVPC"
}

variable "subnet_cidr" {
    description = "Value of the subnet cidr for the VPC"
    type = string
    default = "10.0.1.0/24"
}

variable "subnet_name" {
    description = "Value fo the subnet name for the VPC"
    type = string
    default = "MyTestSubnet"
}

variable "igw_name" {
    description = "Value of the internet gateway for the VPC"
    type = string
    default = "MyTestIGW"
}

variable "ec2_ami" {
    description = "Value fo the AMI ID for the EC2 instance"
    type = string
    default = "ami-04473c3d3be6a927f"
}

variable "ec2_name" {
    description = "Value of the name for the EC2 instance"
    type = string
    default = "MyTestEC2"
}
