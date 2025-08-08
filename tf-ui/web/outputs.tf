output "web_bucket_name" {
  value = aws_s3_bucket.web.id
}

output "web_bucket_arn" {
  value = aws_s3_bucket.web.arn
}

output "web_uri" {
  value = "https://${aws_cloudfront_distribution.web.domain_name}"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.web.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.web.domain_name
}