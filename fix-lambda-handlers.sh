#!/bin/bash
# Script to fix the Lambda function handler configuration

# Set colors for console output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Lambda handler configuration fix...${NC}"

# Verify AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI could not be found. Please install it first.${NC}"
    exit 1
fi

# Get stack name from terraform.tfvars
STACK_NAME=$(grep stack_name terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
if [ -z "$STACK_NAME" ]; then
    echo -e "${RED}Could not determine stack name from terraform.tfvars${NC}"
    exit 1
fi

echo -e "${YELLOW}Detected stack name: ${STACK_NAME}${NC}"

# Get AWS region from terraform.tfvars
AWS_REGION=$(grep aws_region terraform.tfvars | cut -d'=' -f2 | tr -d ' "')
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="us-east-1"
    echo -e "${YELLOW}Using default region: ${AWS_REGION}${NC}"
else
    echo -e "${YELLOW}Detected region: ${AWS_REGION}${NC}"
fi

# Fix Lambda function handlers - the issue was incorrect handler paths
echo -e "${YELLOW}Fixing Lambda function handlers...${NC}"

# Update all UI Lambda function handlers to use src/ prefix
LAMBDA_FUNCTIONS=(
    "${STACK_NAME}-ui-list:src/list.handler"
    "${STACK_NAME}-ui-search:src/search.handler"
    "${STACK_NAME}-ui-languages:src/languages.handler"
    "${STACK_NAME}-ui-entities:src/entities.handler"
    "${STACK_NAME}-ui-swap:src/swap.handler"
    "${STACK_NAME}-ui-get:src/get.handler"
    "${STACK_NAME}-ui-head:src/head.handler"
    "${STACK_NAME}-ui-presign:src/presign.handler"
)

for lambda_config in "${LAMBDA_FUNCTIONS[@]}"; do
    IFS=':' read -r function_name handler <<< "$lambda_config"
    echo -e "${YELLOW}Updating ${function_name} handler to ${handler}...${NC}"
    
    aws lambda update-function-configuration \
        --function-name "${function_name}" \
        --handler "${handler}" \
        --region "${AWS_REGION}" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ${function_name} handler updated successfully${NC}"
    else
        echo -e "${RED}✗ Failed to update ${function_name} handler${NC}"
    fi
done

echo -e "${GREEN}Lambda handler configuration fix completed!${NC}"
echo -e "${YELLOW}The API endpoints should now work correctly.${NC}"