#!/bin/bash

# Auto-destroy script for failed deployments
set -e

echo "🔥 Auto-destroying failed deployment..."

# Check if terraform state exists
if [ -f "terraform.tfstate" ] || [ -f ".terraform/terraform.tfstate" ]; then
    echo "Found terraform state, destroying resources..."
    terraform destroy -auto-approve
    echo "✅ Resources destroyed successfully"
else
    echo "No terraform state found, nothing to destroy"
fi

# Clean up terraform files
rm -f terraform.tfstate*
rm -f tfplan
rm -rf .terraform/

echo "🧹 Cleanup completed"