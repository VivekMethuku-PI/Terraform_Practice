provider "aws" {
    region = "ap-south-1"
}
module "Client_ECR" {
    source = "../modules/ecr_repository"
    ecr_name = "client_app"  
}