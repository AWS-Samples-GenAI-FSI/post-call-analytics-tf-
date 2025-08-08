variable "stack_name" {
  description = "Stack name"
  type        = string
}

variable "api_gateway_id" {
  description = "API Gateway ID"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "audio_bucket_name" {
  description = "Audio bucket name"
  type        = string
}

variable "data_bucket_name" {
  description = "Data bucket name"
  type        = string
}

variable "audio_bucket_prefix" {
  description = "Audio bucket prefix"
  type        = string
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