resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.stack_name}-api"
  description = "PCA UI API Gateway"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Enable CORS for all resources
resource "aws_api_gateway_gateway_response" "cors" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  response_type = "DEFAULT_4XX"
  
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
  }
}

resource "aws_api_gateway_gateway_response" "cors_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  response_type = "DEFAULT_5XX"
  
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
  }
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [var.user_pool_arn]
}

# CORS configuration
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_rest_api.main.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_rest_api.main.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,PUT,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Deployment - depends on integrations
resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_method.options,
    aws_api_gateway_integration.options,
    aws_api_gateway_integration_response.options,
    aws_api_gateway_method.list,
    aws_api_gateway_integration.list,
    aws_api_gateway_method.search,
    aws_api_gateway_integration.search,
    aws_api_gateway_method.get,
    aws_api_gateway_integration.get,

    aws_api_gateway_method.head,
    aws_api_gateway_integration.head,
    aws_api_gateway_method.entities,
    aws_api_gateway_integration.entities,
    aws_api_gateway_method.languages,
    aws_api_gateway_integration.languages,
    aws_api_gateway_method.presign,
    aws_api_gateway_integration.presign,
    aws_api_gateway_method.swap,
    aws_api_gateway_integration.swap,
    aws_api_gateway_method.genaiquery,
    aws_api_gateway_integration.genaiquery,
    aws_api_gateway_method.genairefresh,
    aws_api_gateway_integration.genairefresh,
    aws_api_gateway_method.options_endpoints,
    aws_api_gateway_integration.options_endpoints,
    aws_api_gateway_integration_response.options_endpoints,
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "prod"
  
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.options_endpoints,
      aws_api_gateway_integration.options_endpoints,
      aws_api_gateway_integration_response.options_endpoints,
    ]))
  }
  
  lifecycle {
    create_before_destroy = true
  }
}