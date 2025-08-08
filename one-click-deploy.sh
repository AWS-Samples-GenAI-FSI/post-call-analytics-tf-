#!/bin/bash

set -e

# Colors for banner
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner function
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║        🎯 Amazon Transcribe Post Call Analytics             ║"
    echo "║                   One-Click Deployment                       ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Status function
show_status() {
    local step="$1"
    local message="$2"
    local status="$3"
    
    case $status in
        "progress")
            echo -e "${YELLOW}[$step/7] 🔄 $message...${NC}"
            ;;
        "success")
            echo -e "${GREEN}[$step/7] ✅ $message${NC}"
            ;;
        "error")
            echo -e "${RED}[$step/7] ❌ $message${NC}"
            ;;
    esac
}

# Main deployment
main() {
    show_banner
    
    echo -e "${BLUE}Welcome to Post Call Analytics Deployment!${NC}"
    echo ""
    
    # Step 1: Region Selection
    show_status "1" "Region Selection" "progress"
    echo ""
    echo "Please select your deployment region:"
    echo ""
    echo "1) us-east-1 (N. Virginia) - Recommended"
    echo "2) us-west-2 (Oregon)"
    echo "3) ap-southeast-2 (Sydney)"
    echo "4) eu-west-1 (Ireland)"
    echo "5) ap-northeast-1 (Tokyo)"
    echo ""
    
    while true; do
        read -p "Enter your choice (1-5): " region_choice
        case $region_choice in
            1) AWS_REGION="us-east-1"; break;;
            2) AWS_REGION="us-west-2"; break;;
            3) AWS_REGION="ap-southeast-2"; break;;
            4) AWS_REGION="eu-west-1"; break;;
            5) AWS_REGION="ap-northeast-1"; break;;
            *) echo "Invalid choice. Please enter 1-5.";;
        esac
    done
    
    show_status "1" "Region selected: $AWS_REGION" "success"
    
    # Step 2: Email Input
    show_status "2" "Admin Configuration" "progress"
    echo ""
    while true; do
        read -p "Enter admin email for temporary password: " admin_email
        if [[ $admin_email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            break
        else
            echo "Invalid email format. Please try again."
        fi
    done
    
    show_status "2" "Admin email configured: $admin_email" "success"
    
    # Step 3: Generate Stack Name
    show_status "3" "Generating Stack Configuration" "progress"
    STACK_NAME="pca-stack-$(date +%Y%m%d%H%M)"
    
    # Update terraform.tfvars
    cat > terraform.tfvars << EOF
stack_name = "$STACK_NAME"
aws_region = "$AWS_REGION"
environment = "PROD"
enable_ui = true
admin_email = "$admin_email"
admin_username = "admin"
allowed_signup_domain = "*"
input_bucket_name = ""
output_bucket_name = ""
support_files_bucket_name = ""
bulk_upload_bucket_name = ""
retention_days = 365
transcribe_api_mode = "analytics"
transcribe_languages = "en-US"
max_speakers = "2"
speaker_separation_type = "channel"
speaker_names = "Customer | Agent"
call_summarization = "BEDROCK"
summarization_bedrock_model_id = "us.amazon.nova-pro-v1:0"
step_function_name = "PostCallAnalyticsWorkflow"
EOF
    
    show_status "3" "Stack name: $STACK_NAME" "success"
    
    # Step 4: Initialize Terraform
    show_status "4" "Initializing Terraform" "progress"
    export AWS_DEFAULT_REGION=$AWS_REGION
    export AWS_REGION=$AWS_REGION
    
    if terraform init > /dev/null 2>&1; then
        show_status "4" "Terraform initialized" "success"
    else
        show_status "4" "Terraform initialization failed" "error"
        exit 1
    fi
    
    # Step 5: Plan Deployment
    show_status "5" "Planning Deployment" "progress"
    if terraform plan -out=tfplan > /dev/null 2>&1; then
        show_status "5" "Deployment plan created" "success"
    else
        show_status "5" "Deployment planning failed" "error"
        exit 1
    fi
    
    # Step 6: Deploy Infrastructure
    show_status "6" "Deploying Infrastructure" "progress"
    echo ""
    echo -e "${YELLOW}⏳ This may take 10-15 minutes...${NC}"
    echo ""
    
    if terraform apply tfplan; then
        show_status "6" "Infrastructure deployed successfully" "success"
    else
        show_status "6" "Infrastructure deployment failed" "error"
        echo ""
        echo -e "${RED}🔥 Auto-destroying failed deployment...${NC}"
        chmod +x auto-destroy.sh
        ./auto-destroy.sh
        exit 1
    fi
    
    # Step 7: Update Callback URLs
    show_status "7" "Updating Cognito Callback URLs" "progress"
    
    # Wait a moment for CloudFront to be ready
    sleep 5
    
    # Run callback URL update script with region
    if [ -f "update-callback-urls.sh" ]; then
        chmod +x update-callback-urls.sh
        if ./update-callback-urls.sh; then
            show_status "7" "Callback URLs updated successfully" "success"
        else
            echo -e "${YELLOW}⚠️  Callback URL update failed - may need manual update${NC}"
            echo -e "${YELLOW}   You can run: ./update-callback-urls.sh${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Callback URL script not found${NC}"
    fi
    
    # Get outputs
    WEB_URI=$(terraform output -raw web_uri 2>/dev/null || echo "Not available")
    API_URI=$(terraform output -raw api_uri 2>/dev/null || echo "Not available")
    INPUT_BUCKET=$(terraform output -raw input_bucket_name 2>/dev/null || echo "Not available")
    OUTPUT_BUCKET=$(terraform output -raw output_bucket_name 2>/dev/null || echo "Not available")
    
    # Final Success Banner
    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                    🎉 DEPLOYMENT SUCCESSFUL! 🎉             ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo ""
    echo -e "${CYAN}📋 Deployment Details:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}Region:${NC}        $AWS_REGION"
    echo -e "${BLUE}Stack Name:${NC}    $STACK_NAME"
    echo -e "${BLUE}Admin Email:${NC}   $admin_email"
    echo ""
    echo -e "${CYAN}🌐 Access URLs:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}Web UI:${NC}        $WEB_URI"
    echo -e "${BLUE}API Endpoint:${NC}  $API_URI"
    echo ""
    echo -e "${CYAN}📦 S3 Buckets:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}Input Bucket:${NC}  $INPUT_BUCKET"
    echo -e "${BLUE}Output Bucket:${NC} $OUTPUT_BUCKET"
    echo ""
    echo -e "${CYAN}🔑 Next Steps:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "1. Check your email for temporary password"
    echo "2. Access the Web UI and change your password"
    echo "3. Upload audio files to test the solution"
    echo "4. Callback URLs are automatically configured for $AWS_REGION ✅"
    echo ""
    echo -e "${YELLOW}💡 Test with sample audio:${NC}"
    echo "aws s3 cp sample.wav s3://$INPUT_BUCKET/originalAudio/"
    echo ""
    
    # Clean up
    rm -f tfplan
}

# Check prerequisites
check_prerequisites() {
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}❌ Terraform not found. Please install Terraform first.${NC}"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI not found. Please install AWS CLI first.${NC}"
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}❌ AWS CLI not configured. Please run 'aws configure' first.${NC}"
        exit 1
    fi
}

# Run deployment
check_prerequisites
main