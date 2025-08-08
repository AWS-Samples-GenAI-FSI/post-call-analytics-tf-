# UI Module - Main orchestrator
module "cognito" {
  source = "./cognito"
  
  stack_name = var.stack_name
  admin_email = var.admin_email
  admin_username = var.admin_username
  allowed_signup_domain = var.allowed_signup_domain
}

module "lambda_functions" {
  source = "./lambda"
  
  stack_name = var.stack_name
  api_gateway_id = ""
  table_name = var.table_name
  audio_bucket_name = var.audio_bucket_name
  data_bucket_name = var.data_bucket_name
  audio_bucket_prefix = var.audio_bucket_prefix
  pyutils_layer_arn = var.pyutils_layer_arn
  llm_table_name = var.llm_table_name
  fetch_transcript_arn = var.fetch_transcript_arn
  summarizer_arn = var.summarizer_arn
  call_summarization = var.call_summarization
  summarization_bedrock_model_id = var.summarization_bedrock_model_id
  summarization_llm_third_party_api_key = var.summarization_llm_third_party_api_key
}

module "api_gateway" {
  source = "./api-gateway"
  
  stack_name = var.stack_name
  user_pool_id = module.cognito.user_pool_id
  user_pool_arn = module.cognito.user_pool_arn
  table_name = var.table_name
  audio_bucket_name = var.audio_bucket_name
  data_bucket_name = var.data_bucket_name
  audio_bucket_prefix = var.audio_bucket_prefix
  pyutils_layer_arn = var.pyutils_layer_arn
  llm_table_name = var.llm_table_name
  fetch_transcript_arn = var.fetch_transcript_arn
  summarizer_arn = var.summarizer_arn
  call_summarization = var.call_summarization
  summarization_bedrock_model_id = var.summarization_bedrock_model_id
  lambda_functions = module.lambda_functions.lambda_functions
  
  depends_on = [module.lambda_functions]
}

module "web" {
  source = "./web"
  
  stack_name = var.stack_name
  audio_bucket_name = var.audio_bucket_name
  data_bucket_name = var.data_bucket_name
  api_uri = module.api_gateway.api_uri
  auth_base_uri = module.cognito.auth_base_uri
  user_pool_client_id = module.cognito.user_pool_client_id
  user_pool_id = module.cognito.user_pool_id
  
  depends_on = [module.api_gateway, module.cognito]
}

# Callback URLs are updated post-deployment via update-callback-urls.sh script