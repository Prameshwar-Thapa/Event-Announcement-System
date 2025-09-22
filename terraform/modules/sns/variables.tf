variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "email_subscriptions" {
  description = "List of email addresses for subscriptions"
  type        = list(string)
  default     = []
}

variable "sms_subscriptions" {
  description = "List of phone numbers for SMS subscriptions"
  type        = list(string)
  default     = []
}
