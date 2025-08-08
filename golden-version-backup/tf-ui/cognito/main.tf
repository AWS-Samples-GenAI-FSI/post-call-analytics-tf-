resource "aws_cognito_user_pool" "main" {
  name = "${var.stack_name}-user-pool"

  auto_verified_attributes = ["email"]
  
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = var.allowed_signup_domain == "" ? true : false
  }

  schema {
    attribute_data_type = "String"
    name               = "email"
    required           = true
    mutable           = true
  }

  tags = {
    Name = "${var.stack_name}-user-pool"
  }
}

resource "aws_cognito_user_pool_client" "main" {
  name         = "${var.stack_name}-user-pool-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false
  
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true
  
  callback_urls = ["https://localhost:3000/"]
  logout_urls   = ["https://localhost:3000/"]
  
  lifecycle {
    ignore_changes = [callback_urls, logout_urls]
  }
  
  supported_identity_providers = ["COGNITO"]
  
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.stack_name}-${random_string.domain_suffix.result}"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "random_string" "domain_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_cognito_user" "admin" {
  user_pool_id = aws_cognito_user_pool.main.id
  username     = var.admin_username
  
  attributes = {
    email = var.admin_email
    email_verified = "true"
  }
  
  temporary_password = random_password.admin_temp_password.result
  
  lifecycle {
    ignore_changes = [temporary_password]
  }
}

resource "random_password" "admin_temp_password" {
  length  = 12
  special = true
  upper   = true
  lower   = true
  numeric = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}