output "table_name" {
  description = "Name of the LLM table"
  value       = aws_dynamodb_table.tf_llm_table.name
}

output "table_arn" {
  description = "ARN of the LLM table"
  value       = aws_dynamodb_table.tf_llm_table.arn
}