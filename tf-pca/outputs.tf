output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.tf_pca_state_machine.arn
}

output "step_function_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.tf_pca_state_machine.arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.tf_pca_state_machine.name
}

output "fetch_transcript_arn" {
  description = "ARN of the fetch transcript Lambda function"
  value       = aws_lambda_function.tf_fetch_transcript.arn
}

output "fetch_transcript_lambda_arn" {
  description = "ARN of the fetch transcript Lambda function"
  value       = aws_lambda_function.tf_fetch_transcript.arn
}

output "summarizer_arn" {
  description = "ARN of the summarizer Lambda function"
  value       = aws_lambda_function.tf_summarize.arn
}

output "summarizer_lambda_arn" {
  description = "ARN of the summarizer Lambda function"
  value       = aws_lambda_function.tf_summarize.arn
}

output "roles_for_kms_key" {
  description = "Comma-separated list of role ARNs for KMS key access"
  value = join(", ", [
    "\"${aws_iam_role.tf_lambda_execution_role.arn}\"",
    "\"${aws_iam_role.tf_summarize_lambda_role.arn}\""
  ])
}