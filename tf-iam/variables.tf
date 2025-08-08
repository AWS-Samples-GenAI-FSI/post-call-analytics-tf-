variable "stack_name" {
  description = "Name of the stack"
  type        = string
}

variable "environment" {
  description = "Environment type"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "input_bucket_arn" {
  description = "ARN of the input bucket"
  type        = string
}

variable "output_bucket_arn" {
  description = "ARN of the output bucket"
  type        = string
}

variable "support_files_bucket_arn" {
  description = "ARN of the support files bucket"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}