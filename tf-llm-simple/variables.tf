variable "llm_table_name" {
  description = "Name of the LLM table"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}