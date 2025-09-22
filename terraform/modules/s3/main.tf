# S3 bucket for static website hosting
resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 bucket policy for public read access
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  depends_on = [aws_s3_bucket_public_access_block.frontend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}

# Upload frontend files
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "${var.source_dir}/index.html"
  content_type = "text/html"
  etag         = filemd5("${var.source_dir}/index.html")
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "style.css"
  source       = "${var.source_dir}/style.css"
  content_type = "text/css"
  etag         = filemd5("${var.source_dir}/style.css")
}

resource "aws_s3_object" "script" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "script.js"
  source       = "${var.source_dir}/script.js"
  content_type = "application/javascript"
  etag         = filemd5("${var.source_dir}/script.js")
}
