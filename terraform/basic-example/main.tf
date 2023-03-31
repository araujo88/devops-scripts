# Provider Block
provider "aws" {
	profile = "default"
	region = "sa-east-1"	
}

# Resources Block
resource "aws_instance" "app_server" {
	ami = "ami-04473c3d3be6a927f"
	instance_type = var.ec2_instance_type

	tags = {
		Name = var.instance_name
	}
}
