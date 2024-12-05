provider "aws" {
    region = "ap-south-1"
}
module "Redemption_ECR" {
    source = "../modules/ecr_repository"
    ecr_name = "redemption_api"  
}