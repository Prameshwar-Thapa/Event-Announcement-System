output "s3_website_url" {
  description = "S3 website URL"
  value       = module.s3_frontend.website_url
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3_frontend.bucket_name
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.api_gateway.api_url
}

output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = module.sns_notifications.topic_arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda_processor.function_name
}
