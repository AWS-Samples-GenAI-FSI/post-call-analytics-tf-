output "input_bucket_name" {
  description = "Name of the input bucket"
  value       = local.input_bucket_name
}

output "output_bucket_name" {
  description = "Name of the output bucket"
  value       = local.output_bucket_name
}

output "support_files_bucket_name" {
  description = "Name of the support files bucket"
  value       = local.support_files_bucket_name
}

output "bulk_upload_bucket_name" {
  description = "Name of the bulk upload bucket"
  value       = local.bulk_upload_bucket_name
}

output "input_bucket_arn" {
  description = "ARN of the input bucket"
  value       = local.create_input_bucket ? aws_s3_bucket.tf_input_bucket[0].arn : "arn:aws:s3:::${var.input_bucket_name}"
}

output "output_bucket_arn" {
  description = "ARN of the output bucket"
  value       = local.create_output_bucket ? aws_s3_bucket.tf_output_bucket[0].arn : "arn:aws:s3:::${var.output_bucket_name}"
}

output "support_files_bucket_arn" {
  description = "ARN of the support files bucket"
  value       = local.create_support_files_bucket ? aws_s3_bucket.tf_support_files_bucket[0].arn : "arn:aws:s3:::${var.support_files_bucket_name}"
}

output "bulk_upload_bucket_arn" {
  description = "ARN of the bulk upload bucket"
  value       = local.create_bulk_upload_bucket ? aws_s3_bucket.tf_bulk_upload_bucket[0].arn : "arn:aws:s3:::${var.bulk_upload_bucket_name}"
}