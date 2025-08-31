terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.11.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Identify name of Docker Image in ECR. Here we use the tag name of the image.

resource "aws_ecr_repository" "demo_nginx_image" {
  name = "demo_nginx_image"
}