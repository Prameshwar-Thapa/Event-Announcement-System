variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "event-announcement"
}

variable "email_subscriptions" {
  description = "List of email addresses for SNS subscriptions"
  type        = list(string)
  default     = ["admin@example.com"]
}

variable "sms_subscriptions" {
  description = "List of phone numbers for SMS subscriptions"
  type        = list(string)
  default     = []
}
