output "web_uri" {
  value = module.web.web_uri
}

output "api_uri" {
  value = module.api_gateway.api_uri
}

output "auth_base_uri" {
  value = module.cognito.auth_base_uri
}

output "user_pool_client_id" {
  value = module.cognito.user_pool_client_id
}

output "user_pool_id" {
  value = module.cognito.user_pool_id
}

output "web_bucket_name" {
  value = module.web.web_bucket_name
}

output "cloudfront_distribution_id" {
  value = module.web.cloudfront_distribution_id
}