output "layer_arn" {
  description = "ARN of the FFMPEG Lambda layer"
  value       = aws_lambda_layer_version.tf_ffmpeg_layer.arn
}

output "zip_name" {
  description = "Name of the FFMPEG zip file"
  value       = "ffmpeg.zip"
}