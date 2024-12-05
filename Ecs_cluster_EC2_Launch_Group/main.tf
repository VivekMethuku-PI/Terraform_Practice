provider "aws" {
  region = "ap-south-1" # Change to your preferred AWS region
}

# Create an ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-ec2"
}

# Create an Auto Scaling Group for EC2 Instances
resource "aws_autoscaling_group" "ecs_asg" {
  launch_configuration = aws_launch_configuration.ecs_lc.id
  min_size             = 1
  max_size             = 5
  desired_capacity     = 1
  vpc_zone_identifier  = ["subnet-006d411d629c883ce","subnet-03a50740a0e72e863"] # Replace with your subnet IDs
  force_delete         = true
}

# Create a Launch Configuration for EC2 Instances
resource "aws_launch_configuration" "ecs_lc" {
  name          = "ecs-launch-configuration"
  image_id      = "ami-018bf378c35021448" # Amazon Linux 2 ECS optimized AMI
  instance_type = "t2.micro"
  key_name      = "pivms" # Replace with your key pair name
  security_groups = [aws_security_group.ecs_instance_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name}" >> /etc/ecs/ecs.config
            EOF
}

# Create a Security Group for the EC2 instances
resource "aws_security_group" "ecs_instance_sg" {
  name        = "ecs-instance-sg"
  description = "Allow traffic for ECS EC2 instances"
  vpc_id      = "vpc-075a97b2731ec0684" # Replace with your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for ECS Instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach ECS policy to the IAM role
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Create an Instance Profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# ECS Capacity Provider for Auto Scaling Group
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 75
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 5
    }

  }
}

# Associate Capacity Provider with ECS Cluster
resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 1
    base              = 0
  }
}
