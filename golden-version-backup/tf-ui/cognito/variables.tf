variable "stack_name" {
  description = "Stack name"
  type        = string
}

variable "admin_email" {
  description = "Admin email"
  type        = string
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "admin"
}

variable "allowed_signup_domain" {
  description = "Allowed signup domain"
  type        = string
  default     = "*"
}