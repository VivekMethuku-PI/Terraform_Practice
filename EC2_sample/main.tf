provider "aws" {
    region = "ap-south-1"
  
}
module "ec2_instance" {
    source = "../modules/ec2_instance"
    ami_value = "ami-0dee22c13ea7a9a67"
    instance_type_value = "t2.micro"
    subnet_id = "subnet-006d411d629c883ce" 
}