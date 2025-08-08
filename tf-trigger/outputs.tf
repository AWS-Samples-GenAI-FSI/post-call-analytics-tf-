output "file_drop_trigger_arn" {
  description = "ARN of the file drop trigger Lambda function"
  value       = aws_lambda_function.tf_file_drop_trigger.arn
}

output "transcribe_eventbridge_arn" {
  description = "ARN of the Transcribe EventBridge Lambda function"
  value       = aws_lambda_function.tf_transcribe_eventbridge.arn
}

output "roles_for_kms_key" {
  description = "Comma-separated list of role ARNs for KMS key access"
  value = join(", ", [
    "\"${var.file_drop_trigger_role_arn}\"",
    "\"${var.transcribe_eventbridge_role_arn}\""
  ])
}