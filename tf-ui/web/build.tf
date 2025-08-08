data "aws_region" "current" {}

# React App Build and Deploy
resource "null_resource" "react_build" {
  triggers = {
    api_uri = var.api_uri
    auth_base_uri = var.auth_base_uri
    user_pool_client_id = var.user_pool_client_id
    audio_bucket_name = var.audio_bucket_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e  # Exit on any error
      
      cd ${path.module}/../react-app
      
      # Create runtime config file in public folder
      cat > public/config.js << 'EOF'
window.pcaSettings = {
  auth: {
    uri: '${var.auth_base_uri}',
    clientId: '${var.user_pool_client_id}'
  },
  api: {
    uri: '${var.api_uri}'
  },
  s3: {
    region: '${data.aws_region.current.name}',
    bucket: '${var.audio_bucket_name}'
  },
  genai: {
    query: true
  }
};
EOF
      
      # Install dependencies and build
      npm install --silent --no-audit --no-fund || exit 1
      npm install react-scripts --silent || exit 1
      npm run build || exit 1
      
      # Verify build directory exists and has content
      if [ ! -d "build" ] || [ -z "$(ls -A build)" ]; then
        echo "ERROR: Build failed - build directory is empty or missing"
        exit 1
      fi
      
      # Upload to S3 directly
      aws s3 sync build/ s3://${aws_s3_bucket.web.id}/ --delete || exit 1
      
      # Verify S3 upload succeeded
      if ! aws s3 ls s3://${aws_s3_bucket.web.id}/index.html > /dev/null 2>&1; then
        echo "ERROR: S3 upload failed - index.html not found"
        exit 1
      fi
      
      # Invalidate CloudFront
      aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.web.id} --paths "/*" || exit 1
      
      echo "SUCCESS: React app built and deployed successfully"
    EOT
    
    working_dir = "${path.root}"
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'React build cleanup completed'"
  }
  
  depends_on = [aws_s3_bucket.web, aws_cloudfront_distribution.web]
}