# Main Terraform configuration for Event Announcement System
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # Backend configuration - uncomment and configure for remote state
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "event-announcement-system/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "EventAnnouncementSystem"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random ID for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Module for Frontend Hosting
module "s3_frontend" {
  source = "./modules/s3"

  bucket_name = "${var.project_name}-frontend-${random_id.bucket_suffix.hex}"
  environment = var.environment
  source_dir  = "../src/frontend"
}

# SNS Module for Notifications
module "sns_notifications" {
  source = "./modules/sns"

  topic_name  = "${var.project_name}-notifications"
  environment = var.environment

  email_subscriptions = var.email_subscriptions
  sms_subscriptions   = var.sms_subscriptions
}

# Lambda Module for Event Processing
module "lambda_processor" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-processor"
  environment   = var.environment

  sns_topic_arn = module.sns_notifications.topic_arn
  source_dir    = "../src/lambda"
}

# API Gateway Module
module "api_gateway" {
  source = "./modules/api_gateway"

  api_name    = "${var.project_name}-api"
  environment = var.environment

  lambda_function_arn  = module.lambda_processor.function_arn
  lambda_function_name = module.lambda_processor.function_name
}
