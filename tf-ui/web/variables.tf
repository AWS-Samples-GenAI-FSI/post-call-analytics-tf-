variable "stack_name" {
  description = "Stack name"
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

variable "api_uri" {
  description = "API Gateway URI"
  type        = string
  default     = ""
}

variable "auth_base_uri" {
  description = "Cognito auth base URI"
  type        = string
  default     = ""
}

variable "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  type        = string
  default     = ""
}

variable "user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
  default     = ""
}