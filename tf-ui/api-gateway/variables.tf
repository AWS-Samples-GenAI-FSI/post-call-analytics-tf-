variable "stack_name" {
  description = "Stack name"
  type        = string
}

variable "user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
}

variable "user_pool_arn" {
  description = "Cognito User Pool ARN"
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

variable "lambda_functions" {
  description = "Lambda function ARNs"
  type = object({
    head         = string
    get          = string
    list         = string
    search       = string
    entities     = string
    languages    = string
    swap         = string
    presign      = string
    genai_query  = string
    genai_refresh = string
  })
  default = {
    head         = ""
    get          = ""
    list         = ""
    search       = ""
    entities     = ""
    languages    = ""
    swap         = ""
    presign      = ""
    genai_query  = ""
    genai_refresh = ""
  }
}