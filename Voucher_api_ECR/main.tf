provider "aws" {
    region = "ap-south-1"
}
module "Voucher_ECR" {
    source = "../modules/ecr_repository"
    ecr_name = "voucher_api"  
}