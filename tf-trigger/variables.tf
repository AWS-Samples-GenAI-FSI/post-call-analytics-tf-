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

variable "input_bucket_name" {
  description = "Name of the input bucket"
  type        = string
}

variable "input_bucket_arn" {
  description = "ARN of the input bucket"
  type        = string
}

variable "input_bucket_raw_audio_prefix" {
  description = "Prefix for raw audio files"
  type        = string
}

variable "input_bucket_orig_transcripts_prefix" {
  description = "Prefix for original transcripts"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "file_drop_trigger_role_arn" {
  description = "ARN of the file drop trigger role"
  type        = string
}



variable "transcribe_eventbridge_role_arn" {
  description = "ARN of the Transcribe EventBridge role"
  type        = string
}

variable "pyutils_layer_arn" {
  description = "ARN of the PyUtils Lambda layer"
  type        = string
}

variable "call_summarization" {
  description = "Call summarization type"
  type        = string
}