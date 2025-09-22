variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "source_dir" {
  description = "Path to frontend source files"
  type        = string
}
