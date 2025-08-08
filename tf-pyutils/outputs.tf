output "layer_arn" {
  description = "ARN of the PyUtils Lambda layer"
  value       = aws_lambda_layer_version.tf_pyutils_layer.arn
}