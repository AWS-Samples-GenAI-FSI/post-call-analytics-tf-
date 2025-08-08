output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "api_arn" {
  value = aws_api_gateway_rest_api.main.arn
}

output "api_uri" {
  value = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/prod"
}

output "authorizer_id" {
  value = aws_api_gateway_authorizer.cognito.id
}

data "aws_region" "current" {}