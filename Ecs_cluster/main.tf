provider "aws" {
    region = "ap-south-1"
}
module "Ecs_cluster" {
  source = "../modules/ECS_CLUSTER"
  cluster_name = "Pivms_Cluster_TF"
}