variable "stack_name" {
  description = "Name of the stack"
  type        = string
}

variable "environment" {
  description = "Environment type"
  type        = string
}

variable "retention_days" {
  description = "Retention days for S3 objects"
  type        = number
}

variable "input_bucket_name" {
  description = "Input bucket name (leave empty to auto-create)"
  type        = string
}

variable "output_bucket_name" {
  description = "Output bucket name (leave empty to auto-create)"
  type        = string
}

variable "support_files_bucket_name" {
  description = "Support files bucket name (leave empty to auto-create)"
  type        = string
}

variable "bulk_upload_bucket_name" {
  description = "Bulk upload bucket name (leave empty to auto-create)"
  type        = string
}