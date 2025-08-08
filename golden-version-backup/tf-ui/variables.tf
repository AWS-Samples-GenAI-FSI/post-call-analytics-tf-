variable "stack_name" {
  description = "Stack name"
  type        = string
}

variable "admin_email" {
  description = "Admin email for Cognito"
  type        = string
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "admin"
}

variable "allowed_signup_domain" {
  description = "Allowed signup email domain"
  type        = string
  default     = "*"
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "audio_bucket_name" {
  description = "Audio S3 bucket name"
  type        = string
}

variable "data_bucket_name" {
  description = "Data S3 bucket name"
  type        = string
}

variable "audio_bucket_prefix" {
  description = "Audio bucket prefix"
  type        = string
  default     = "originalAudio"
}

variable "pyutils_layer_arn" {
  description = "PyUtils layer ARN"
  type        = string
}

variable "llm_table_name" {
  description = "LLM table name"
  type        = string
}

variable "fetch_transcript_arn" {
  description = "Fetch transcript Lambda ARN"
  type        = string
}

variable "summarizer_arn" {
  description = "Summarizer Lambda ARN"
  type        = string
}

variable "call_summarization" {
  description = "Call summarization type"
  type        = string
}

variable "summarization_bedrock_model_id" {
  description = "Bedrock model ID"
  type        = string
}

variable "summarization_llm_third_party_api_key" {
  description = "Third party API key"
  type        = string
  default     = ""
}

variable "web_uri" {
  description = "Web URI for callback URLs"
  type        = string
  default     = "https://example.com"
}