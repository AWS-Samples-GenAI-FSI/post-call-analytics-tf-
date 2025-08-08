# API Gateway Lambda Integrations - COMPLETE SET
locals {
  lambda_functions = {
    head         = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.head}/invocations"
    get          = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.get}/invocations"
    list         = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.list}/invocations"
    search       = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.search}/invocations"
    entities     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.entities}/invocations"
    languages    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.languages}/invocations"
    swap         = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.swap}/invocations"
    presign      = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.presign}/invocations"
    genai_query  = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.genai_query}/invocations"
    genai_refresh = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_functions.genai_refresh}/invocations"
  }
}

# List endpoint
resource "aws_api_gateway_resource" "list" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "list"
}

resource "aws_api_gateway_method" "list" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.list.id
  http_method            = "GET"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "list" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.list.id
  http_method = aws_api_gateway_method.list.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.list
}

# Search endpoint
resource "aws_api_gateway_resource" "search" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "search"
}

resource "aws_api_gateway_method" "search" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.search.id
  http_method            = "GET"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "search" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.search.id
  http_method = aws_api_gateway_method.search.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.search
}

# Presign endpoint
resource "aws_api_gateway_resource" "presign" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "presign"
}

resource "aws_api_gateway_method" "presign" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.presign.id
  http_method            = "GET"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "presign" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.presign.id
  http_method = aws_api_gateway_method.presign.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.presign
}

# Get endpoint
resource "aws_api_gateway_resource" "get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "get"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.get.id
  http_method            = "GET"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.get.id
  http_method = aws_api_gateway_method.get.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.get
}



# Entities endpoint
resource "aws_api_gateway_resource" "entities" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "entities"
}

resource "aws_api_gateway_method" "entities" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.entities.id
  http_method            = "GET"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "entities" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.entities.id
  http_method = aws_api_gateway_method.entities.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.entities
}

# Languages endpoint
resource "aws_api_gateway_resource" "languages" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "languages"
}

resource "aws_api_gateway_method" "languages" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.languages.id
  http_method            = "GET"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "languages" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.languages.id
  http_method = aws_api_gateway_method.languages.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.languages
}

# Head endpoint
resource "aws_api_gateway_resource" "head" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "head"
}

resource "aws_api_gateway_method" "head" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.head.id
  http_method            = "GET"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "head" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.head.id
  http_method = aws_api_gateway_method.head.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.head
}

# Swap endpoint
resource "aws_api_gateway_resource" "swap" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "swap"
}

resource "aws_api_gateway_method" "swap" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.swap.id
  http_method            = "POST"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "swap" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.swap.id
  http_method = aws_api_gateway_method.swap.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.swap
}

# GenAI Query endpoint
resource "aws_api_gateway_resource" "genaiquery" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "genaiquery"
}

resource "aws_api_gateway_method" "genaiquery" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.genaiquery.id
  http_method            = "GET"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "genaiquery" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.genaiquery.id
  http_method = aws_api_gateway_method.genaiquery.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.genai_query
}

# GenAI Refresh endpoint
resource "aws_api_gateway_resource" "genairefresh" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "genairefresh"
}

resource "aws_api_gateway_method" "genairefresh" {
  rest_api_id            = aws_api_gateway_rest_api.main.id
  resource_id            = aws_api_gateway_resource.genairefresh.id
  http_method            = "POST"
  authorization          = "COGNITO_USER_POOLS"
  authorizer_id          = aws_api_gateway_authorizer.cognito.id
  authorization_scopes   = ["openid"]
}

resource "aws_api_gateway_integration" "genairefresh" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.genairefresh.id
  http_method = aws_api_gateway_method.genairefresh.http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = local.lambda_functions.genai_refresh
}

# OPTIONS methods for CORS
resource "aws_api_gateway_method" "options_endpoints" {
  for_each = {
    list = aws_api_gateway_resource.list.id
    search = aws_api_gateway_resource.search.id
    get = aws_api_gateway_resource.get.id
    head = aws_api_gateway_resource.head.id
    entities = aws_api_gateway_resource.entities.id
    languages = aws_api_gateway_resource.languages.id
    presign = aws_api_gateway_resource.presign.id
    swap = aws_api_gateway_resource.swap.id
    genaiquery = aws_api_gateway_resource.genaiquery.id
    genairefresh = aws_api_gateway_resource.genairefresh.id
  }
  
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = each.value
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_endpoints" {
  for_each = aws_api_gateway_method.options_endpoints
  
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_endpoints" {
  for_each = aws_api_gateway_method.options_endpoints
  
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_endpoints" {
  for_each = aws_api_gateway_method.options_endpoints
  
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  
  depends_on = [
    aws_api_gateway_integration.options_endpoints,
    aws_api_gateway_method_response.options_endpoints
  ]
}

# Lambda permissions
resource "aws_lambda_permission" "api_gateway" {
  for_each = {
    list         = "list"
    search       = "search"
    presign      = "presign"
    get          = "get"
    head         = "head"
    entities     = "entities"
    languages    = "languages"
    swap         = "swap"
    genaiquery   = "genai_query"
    genairefresh = "genai_refresh"
  }
  
  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_functions[each.value]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}