output "transcribe_role_arn" {
  description = "ARN of the Transcribe service role"
  value       = aws_iam_role.tf_transcribe_role.arn
}

output "transcribe_lambda_role_arn" {
  description = "ARN of the Transcribe Lambda role"
  value       = aws_iam_role.tf_transcribe_lambda_role.arn
}

output "step_functions_role_arn" {
  description = "ARN of the Step Functions role"
  value       = aws_iam_role.tf_step_functions_role.arn
}

output "file_drop_trigger_role_arn" {
  description = "ARN of the file drop trigger role"
  value       = aws_iam_role.tf_file_drop_trigger_role.arn
}

output "configure_bucket_role_arn" {
  description = "ARN of the configure bucket role"
  value       = aws_iam_role.tf_configure_bucket_role.arn
}

output "transcribe_eventbridge_role_arn" {
  description = "ARN of the Transcribe EventBridge role"
  value       = aws_iam_role.tf_transcribe_eventbridge_role.arn
}

output "roles_for_kms_key" {
  description = "Comma-separated list of role ARNs for KMS key access"
  value = join(", ", [
    "\"${aws_iam_role.tf_transcribe_lambda_role.arn}\"",
    "\"${aws_iam_role.tf_transcribe_role.arn}\"",
    "\"${aws_iam_role.tf_file_drop_trigger_role.arn}\""
  ])
}