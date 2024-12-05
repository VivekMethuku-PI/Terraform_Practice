provider "aws" {
    region = "ap-south-1"
}
module "Account_api_ECR" {
    source = "../modules/ecr_repository"
    ecr_name = "account_apis"  
}