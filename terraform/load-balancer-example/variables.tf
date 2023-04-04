variable "aws_region" {
	description = "AWS region"
	type = string
	default = "sa-east-1"
}

variable "ec2_ami" {
    description = "Value fo the AMI ID for the EC2 instance"
    type = string
    default = "ami-04473c3d3be6a927f"
}