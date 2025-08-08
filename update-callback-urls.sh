#!/bin/bash

# Update Cognito callback URLs with actual CloudFront URL
set -e

echo "🔄 Updating Cognito callback URLs..."

# Use region from environment (set by one-click deploy)
REGION=${AWS_REGION:-$(aws configure get region)}
echo "🌍 Using region: $REGION"

# Get outputs from Terraform
WEB_URI=$(terraform output -raw web_uri 2>/dev/null || echo "")
USER_POOL_ID=$(terraform output -raw user_pool_id 2>/dev/null || echo "")
USER_POOL_CLIENT_ID=$(terraform output -raw user_pool_client_id 2>/dev/null || echo "")

if [ -z "$WEB_URI" ] || [ -z "$USER_POOL_ID" ] || [ -z "$USER_POOL_CLIENT_ID" ]; then
    echo "⚠️  Missing required outputs - skipping callback URL update"
    exit 0
fi

echo "📍 Web URI: $WEB_URI"
echo "🔑 User Pool: $USER_POOL_ID"
echo "🔑 Client ID: $USER_POOL_CLIENT_ID"

# Update Cognito User Pool Client with region
aws cognito-idp update-user-pool-client \
    --region "$REGION" \
    --user-pool-id "$USER_POOL_ID" \
    --client-id "$USER_POOL_CLIENT_ID" \
    --callback-urls "$WEB_URI" "$WEB_URI/" \
    --logout-urls "$WEB_URI" "$WEB_URI/" \
    --allowed-o-auth-flows "code" \
    --allowed-o-auth-scopes "email" "openid" "profile" \
    --allowed-o-auth-flows-user-pool-client \
    --supported-identity-providers "COGNITO" \
    --explicit-auth-flows "ALLOW_USER_SRP_AUTH" "ALLOW_REFRESH_TOKEN_AUTH"

echo "✅ Cognito callback URLs updated successfully!"