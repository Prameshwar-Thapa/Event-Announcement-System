output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "website_url" {
  description = "Website URL"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}
