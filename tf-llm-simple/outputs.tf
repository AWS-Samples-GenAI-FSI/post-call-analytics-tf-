output "table_name" {
  description = "Name of the simple LLM table"
  value       = aws_dynamodb_table.llm_simple_table.name
}

output "table_arn" {
  description = "ARN of the simple LLM table"
  value       = aws_dynamodb_table.llm_simple_table.arn
}