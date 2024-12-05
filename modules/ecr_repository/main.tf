provider "aws" {
    region = "ap-south-1"
  
}
resource "aws_ecr_repository" "ECR_REPOSITORY" {
    name = var.ecr_name
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
      scan_on_push = true
    }
    tags = {
        Environment="Testing"
        Team       ="Devops "
    }
  
}