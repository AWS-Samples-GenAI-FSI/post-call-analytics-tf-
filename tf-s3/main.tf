locals {
  create_input_bucket         = var.input_bucket_name == ""
  create_output_bucket        = var.output_bucket_name == ""
  create_support_files_bucket = var.support_files_bucket_name == ""
  create_bulk_upload_bucket   = var.bulk_upload_bucket_name == ""

  input_bucket_name         = local.create_input_bucket ? "tf-${var.stack_name}-input-${random_id.tf_bucket_suffix.hex}" : var.input_bucket_name
  output_bucket_name        = local.create_output_bucket ? "tf-${var.stack_name}-output-${random_id.tf_bucket_suffix.hex}" : var.output_bucket_name
  support_files_bucket_name = local.create_support_files_bucket ? "tf-${var.stack_name}-support-${random_id.tf_bucket_suffix.hex}" : var.support_files_bucket_name
  bulk_upload_bucket_name   = local.create_bulk_upload_bucket ? "tf-${var.stack_name}-bulk-${random_id.tf_bucket_suffix.hex}" : var.bulk_upload_bucket_name
}

resource "random_id" "tf_bucket_suffix" {
  byte_length = 4
}

# Input Bucket
resource "aws_s3_bucket" "tf_input_bucket" {
  count  = local.create_input_bucket ? 1 : 0
  bucket = local.input_bucket_name
  force_destroy = true

  tags = {
    Name        = "tf-${var.stack_name}-input-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_input_bucket_encryption" {
  count  = local.create_input_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_input_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_input_bucket_lifecycle" {
  count  = local.create_input_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_input_bucket[0].id

  rule {
    id     = "StorageClassAndRetention"
    status = "Enabled"

    filter {}

    expiration {
      days = var.retention_days
    }

    transition {
      days          = 1
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "tf_input_bucket_cors" {
  count  = local.create_input_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_input_bucket[0].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Output Bucket
resource "aws_s3_bucket" "tf_output_bucket" {
  count  = local.create_output_bucket ? 1 : 0
  bucket = local.output_bucket_name
  force_destroy = true

  tags = {
    Name        = "tf-${var.stack_name}-output-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_output_bucket_encryption" {
  count  = local.create_output_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_output_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_output_bucket_lifecycle" {
  count  = local.create_output_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_output_bucket[0].id

  rule {
    id     = "LifecycleRule"
    status = "Enabled"

    filter {}

    expiration {
      days = var.retention_days
    }

    transition {
      days          = 1
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

# Support Files Bucket
resource "aws_s3_bucket" "tf_support_files_bucket" {
  count  = local.create_support_files_bucket ? 1 : 0
  bucket = local.support_files_bucket_name
  force_destroy = true

  tags = {
    Name        = "tf-${var.stack_name}-support-files-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_support_files_bucket_encryption" {
  count  = local.create_support_files_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_support_files_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bulk Upload Bucket
resource "aws_s3_bucket" "tf_bulk_upload_bucket" {
  count  = local.create_bulk_upload_bucket ? 1 : 0
  bucket = local.bulk_upload_bucket_name
  force_destroy = true

  tags = {
    Name        = "tf-${var.stack_name}-bulk-upload-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_bulk_upload_bucket_encryption" {
  count  = local.create_bulk_upload_bucket ? 1 : 0
  bucket = aws_s3_bucket.tf_bulk_upload_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}