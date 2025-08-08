output "stack_name" {
  description = "Stack name"
  value       = var.stack_name
}

output "input_bucket_name" {
  description = "Input S3 bucket name"
  value       = module.tf_s3.input_bucket_name
}

output "output_bucket_name" {
  description = "Output S3 bucket name"
  value       = module.tf_s3.output_bucket_name
}

output "support_files_bucket_name" {
  description = "Support files S3 bucket name"
  value       = module.tf_s3.support_files_bucket_name
}

output "step_function_arn" {
  description = "Step Function ARN"
  value       = module.tf_pca.step_function_arn
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.tf_ddb.table_name
}

# UI Outputs (conditional)
output "web_uri" {
  description = "Web application URI"
  value       = var.enable_ui ? module.tf_ui[0].web_uri : null
}

output "api_uri" {
  description = "API Gateway URI"
  value       = var.enable_ui ? module.tf_ui[0].api_uri : null
}

output "auth_base_uri" {
  description = "Cognito authentication base URI"
  value       = var.enable_ui ? module.tf_ui[0].auth_base_uri : null
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = var.enable_ui ? module.tf_ui[0].user_pool_client_id : null
}

output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = var.enable_ui ? module.tf_ui[0].user_pool_id : null
}

output "web_bucket_name" {
  description = "Web hosting S3 bucket name"
  value       = var.enable_ui ? module.tf_ui[0].web_bucket_name : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.enable_ui ? module.tf_ui[0].cloudfront_distribution_id : null
}