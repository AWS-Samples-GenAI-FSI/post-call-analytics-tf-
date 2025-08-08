variable "stack_name" {
  description = "Name of the stack"
  type        = string
}

variable "environment" {
  description = "Environment type"
  type        = string
}

variable "support_files_bucket_name" {
  description = "Name of the support files bucket"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "transcribe_role_arn" {
  description = "ARN of the Transcribe service role"
  type        = string
}

variable "transcribe_lambda_role_arn" {
  description = "ARN of the Transcribe Lambda role"
  type        = string
}

variable "step_functions_role_arn" {
  description = "ARN of the Step Functions role"
  type        = string
}

variable "step_functions_role_name" {
  description = "Name of the Step Functions role"
  type        = string
}

variable "ffmpeg_layer_arn" {
  description = "ARN of the FFMPEG Lambda layer"
  type        = string
}

variable "pyutils_layer_arn" {
  description = "ARN of the PyUtils Lambda layer"
  type        = string
}

variable "step_function_name" {
  description = "Name of the Step Function"
  type        = string
}

variable "call_summarization" {
  description = "Call summarization type"
  type        = string
}

variable "summarization_bedrock_model_id" {
  description = "Bedrock model ID for summarization"
  type        = string
}

variable "summarization_sagemaker_endpoint_name" {
  description = "SageMaker endpoint name for summarization"
  type        = string
  default     = ""
}

variable "summarization_sagemaker_endpoint_arn" {
  description = "SageMaker endpoint ARN for summarization"
  type        = string
  default     = ""
}

variable "summarization_llm_third_party_api_key" {
  description = "Third party LLM API key"
  type        = string
  default     = ""
}

variable "summarization_lambda_function_arn" {
  description = "Lambda function ARN for custom summarization"
  type        = string
  default     = ""
}

variable "llm_table_name" {
  description = "Name of the LLM table"
  type        = string
}

variable "output_bucket_name" {
  description = "Output S3 bucket name"
  type        = string
}

variable "output_bucket_arn" {
  description = "Output S3 bucket ARN"
  type        = string
}