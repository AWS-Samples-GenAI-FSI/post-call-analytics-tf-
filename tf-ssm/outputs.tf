output "step_function_name" {
  description = "Full Step Function name with stack prefix"
  value       = "${var.stack_name}-${var.step_function_name}"
}