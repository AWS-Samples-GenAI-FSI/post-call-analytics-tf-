# Post Call Analytics - Terraform Distribution

🚀 **One-command deployment** of Amazon Transcribe Post Call Analytics solution with interactive setup and beautiful progress tracking.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Supported Regions](#supported-regions)
- [What This Deploys](#what-this-deploys)
- [Configuration](#configuration)
- [Usage After Deployment](#usage-after-deployment)
- [Advanced Usage](#advanced-usage)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Clean Up](#clean-up)
- [Support](#support)

## 🎯 Overview

This repository provides a complete Terraform-based deployment of AWS Post Call Analytics solution. It automatically provisions all necessary AWS resources to process audio files, generate transcripts, perform sentiment analysis, and create AI-powered summaries using Amazon Bedrock.

### Key Features
- ✨ **Interactive Setup**: Region selection and email validation
- 🎨 **Beautiful Progress Tracking**: 7-step deployment with visual feedback
- 🔄 **Automatic Configuration**: Cognito callback URLs and S3 bucket setup
- ✅ **Complete Dashboard**: All URLs and access information provided
- 🌍 **Multi-Region Support**: 5 AWS regions supported
- 🎯 **Audio Processing**: WAV, MP3, M4A support with FFmpeg
- 🤖 **AI Integration**: Bedrock Nova Pro for call summarization
- 🔐 **Secure by Default**: Least-privilege IAM and encryption

## 🏛️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Audio Files   │───▶│   S3 Input       │───▶│  Lambda Trigger │
│  (WAV/MP3/M4A)  │    │     Bucket       │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
                                                         ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web UI        │◀───│   CloudFront     │    │ Step Functions  │
│  (React App)    │    │  Distribution    │    │   Workflow      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         ▼                                               ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   API Gateway   │    │     Cognito      │    │   Transcribe    │
│   REST API      │    │ Authentication   │    │  Call Analytics │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
                                                         ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  S3 Output      │◀───│   Comprehend     │◀───│    Bedrock      │
│    Bucket       │    │   Sentiment      │    │ Nova Pro (LLM)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### Required Software
- **Terraform** >= 1.0 ([Install Guide](https://terraform.io))
- **AWS CLI** configured with admin permissions ([Install Guide](https://aws.amazon.com/cli/))
- **Git** with Git LFS support
- **Valid AWS Account** with Call Analytics access

### AWS Permissions Required
Your AWS credentials must have permissions for:
- S3 (buckets, objects, notifications)
- Lambda (functions, layers, permissions)
- IAM (roles, policies, attachments)
- DynamoDB (tables, items)
- Step Functions (state machines, executions)
- EventBridge (rules, targets)
- Cognito (user pools, clients)
- CloudFront (distributions)
- API Gateway (REST APIs, deployments)
- SSM (parameters)
- Transcribe (jobs, vocabularies)
- Comprehend (sentiment analysis)
- Bedrock (model access)

### Quick Setup
```bash
# Install AWS CLI and configure
aws configure

# Verify access and region
aws sts get-caller-identity
aws configure get region

# Verify Terraform installation
terraform version
```

## 🚀 Quick Start

### 1. Download and Extract
```bash
# Clone the repository
git clone https://github.com/AWS-Samples-GenAI-FSI/post-call-analytics-tf-.git
cd post-call-analytics-tf-

# Extract the distribution
unzip pca-terraform-dist.zip
cd pca-terraform-dist
```

### 2. One-Click Deployment
```bash
# Make script executable
chmod +x one-click-deploy.sh

# Run interactive deployment
./one-click-deploy.sh
```

The script will guide you through:
1. **Region Selection** (5 supported regions)
2. **Email Validation** (for admin access)
3. **Configuration Review**
4. **Terraform Deployment** (10-15 minutes)
5. **Success Dashboard** with all URLs

### 3. Access Your Solution
After deployment, you'll receive:
- **Web Interface URL**: `https://your-cloudfront-url.cloudfront.net`
- **API Gateway URL**: `https://your-api-id.execute-api.region.amazonaws.com/prod`
- **Admin Credentials**: Sent to your email
- **S3 Bucket Names**: For file uploads

## 🌍 Supported Regions

The deployment script offers these Call Analytics supported regions:

| Region | Location | Recommended |
|--------|----------|-------------|
| `us-east-1` | N. Virginia | ⭐ **Yes** |
| `us-west-2` | Oregon | ✅ |
| `ap-southeast-2` | Sydney | ✅ |
| `eu-west-1` | Ireland | ✅ |
| `ap-northeast-1` | Tokyo | ✅ |

> **Note**: `us-east-1` is recommended for best performance and feature availability.

## 🏗️ What This Deploys

### Core Infrastructure (17 Lambda Functions)
| Component | Purpose | Count |
|-----------|---------|-------|
| **S3 Buckets** | Input, Output, Support, Bulk upload | 4 |
| **Lambda Functions** | Processing pipeline | 17 |
| **DynamoDB Tables** | Job tracking, LLM templates | 2 |
| **Step Functions** | Workflow orchestration | 1 |
| **EventBridge Rules** | Transcribe job monitoring | 2 |
| **IAM Roles** | Least-privilege security | 8 |

### Web Interface Components
| Component | Purpose |
|-----------|---------|
| **Cognito User Pool** | Authentication |
| **CloudFront Distribution** | Web UI delivery |
| **API Gateway** | REST endpoints |
| **React Application** | User interface |

### AI/ML Services Integration
| Service | Purpose | Model |
|---------|---------|-------|
| **Amazon Transcribe** | Speech-to-text | Call Analytics API |
| **Amazon Comprehend** | Sentiment analysis | Built-in models |
| **Amazon Bedrock** | Call summarization | Nova Pro v1 |

## ⚙️ Configuration

### Default Configuration
The deployment uses sensible defaults in `terraform.tfvars`:

```hcl
# Stack Configuration
stack_name = "pca-stack-[timestamp]"
aws_region = "us-east-1"
environment = "PROD"

# UI Configuration
enable_ui = true
admin_email = "your-email@domain.com"
admin_username = "admin"

# Processing Configuration
transcribe_api_mode = "analytics"
transcribe_languages = "en-US"
max_speakers = "2"
speaker_separation_type = "channel"
speaker_names = "Customer | Agent"

# AI Configuration
call_summarization = "BEDROCK"
summarization_bedrock_model_id = "us.amazon.nova-pro-v1:0"

# Retention
retention_days = 365
```

### Custom Configuration
For advanced users who want to customize settings:

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars

# Deploy with custom settings
terraform init
terraform plan
terraform apply
```

### Key Configuration Options

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `transcribe_api_mode` | Transcribe API type | `analytics` | `analytics`, `standard` |
| `transcribe_languages` | Language codes | `en-US` | Any supported language |
| `max_speakers` | Maximum speakers | `2` | `2-10` |
| `speaker_separation_type` | Separation method | `channel` | `channel`, `speaker` |
| `call_summarization` | Summary provider | `BEDROCK` | `BEDROCK`, `DISABLED` |
| `retention_days` | Data retention | `365` | `1-2555` |

## 🎯 Usage After Deployment

### Web Interface Access
1. **Navigate** to your CloudFront URL
2. **Login** with admin credentials (sent to email)
3. **Upload** audio files through the interface
4. **Monitor** processing in real-time
5. **View** results and summaries

### CLI Upload Methods

#### Audio Files
```bash
# Upload to input bucket
aws s3 cp your-call.wav s3://YOUR-INPUT-BUCKET/originalAudio/
aws s3 cp your-call.mp3 s3://YOUR-INPUT-BUCKET/originalAudio/
aws s3 cp your-call.m4a s3://YOUR-INPUT-BUCKET/originalAudio/
```

#### External Transcripts
```bash
# Upload pre-existing transcripts
aws s3 cp your-transcript.json s3://YOUR-INPUT-BUCKET/originalTranscripts/
```

#### Bulk Upload
```bash
# Upload multiple files
aws s3 sync ./audio-files/ s3://YOUR-BULK-BUCKET/
```

### API Integration
```bash
# Get processing status
curl -H "Authorization: Bearer $TOKEN" \
  https://your-api-id.execute-api.region.amazonaws.com/prod/list

# Get specific result
curl -H "Authorization: Bearer $TOKEN" \
  https://your-api-id.execute-api.region.amazonaws.com/prod/get?jobId=your-job-id
```

### Output Structure
```
s3://your-output-bucket/
├── parsedFiles/
│   ├── job-id.json          # Complete analysis
│   ├── job-id-summary.json  # AI summary
│   └── job-id-entities.json # PII entities
└── transcribeResults/
    └── job-id.json          # Raw transcription
```

## 🔧 Advanced Usage

### Custom Language Models
```hcl
# In terraform.tfvars
custom_lang_model_name = "your-custom-model"
vocabulary_name = "your-vocabulary"
vocab_filter_name = "your-filter"
```

### PII Redaction
```hcl
# Enable content redaction
call_redaction_transcript = "true"
call_redaction_audio = "true"
content_redaction_languages = "en-US"
```

### Bulk Processing
```hcl
# Configure bulk upload limits
bulk_upload_max_transcribe_jobs = "10"
bulk_upload_max_drip_rate = "5"
```

### Custom Entity Recognition
```hcl
# Configure entity detection
entity_types = "PERSON,LOCATION,ORGANIZATION"
entity_threshold = "0.5"
entity_recognizer_endpoint = "your-endpoint"
```

## 📊 Monitoring

### CloudWatch Dashboards
Access pre-configured dashboards for:
- **Lambda Performance**: Function duration, errors, invocations
- **Step Function Metrics**: Execution status, success rate
- **S3 Usage**: Bucket size, request metrics
- **API Gateway**: Request count, latency, errors

### Log Groups
Monitor processing through CloudWatch logs:
```bash
# View Step Function logs
aws logs tail /aws/vendedlogs/pca-stack-*-PostCallAnalyticsWorkflow

# View Lambda function logs
aws logs tail /aws/lambda/pca-stack-*-transcribe

# View API Gateway logs
aws logs tail API-Gateway-Execution-Logs_*/prod
```

### Alarms and Notifications
Set up CloudWatch alarms for:
- Failed transcription jobs
- High error rates
- Processing delays
- Storage quotas

## 🚨 Troubleshooting

### Common Issues

#### Deployment Failures
```bash
# Clear Terraform cache
rm -rf .terraform
terraform init

# Check AWS permissions
aws sts get-caller-identity
aws iam get-user

# Validate configuration
terraform validate
terraform plan
```

#### Transcription Failures
```bash
# Check EventBridge rules
aws events list-rules --name-prefix pca-stack

# View failed jobs
aws transcribe list-transcription-jobs --status FAILED

# Check S3 permissions
aws s3api get-bucket-policy --bucket your-input-bucket
```

#### Web UI Issues
```bash
# Check CloudFront status
aws cloudfront get-distribution --id YOUR-DISTRIBUTION-ID

# Verify Cognito configuration
aws cognito-idp describe-user-pool --user-pool-id YOUR-POOL-ID

# Test API Gateway
curl -v https://your-api-id.execute-api.region.amazonaws.com/prod/health
```

#### Authentication Problems
1. **Check email** for temporary password
2. **Verify Cognito** callback URLs
3. **Clear browser** cache and cookies
4. **Try incognito** mode

### Debug Mode
Enable detailed logging:
```bash
export TF_LOG=DEBUG
terraform apply

# Or for specific components
export AWS_SDK_LOAD_CONFIG=1
export AWS_LOG_LEVEL=debug
```

### Performance Optimization
```bash
# Monitor processing times
aws stepfunctions describe-execution --execution-arn YOUR-EXECUTION-ARN

# Check Lambda concurrency
aws lambda get-function-concurrency --function-name YOUR-FUNCTION

# Optimize S3 transfer
aws configure set max_concurrent_requests 20
aws configure set max_bandwidth 100MB/s
```

## 🔒 Security

### Data Protection
- **Encryption at Rest**: All S3 buckets use AES-256 encryption
- **Encryption in Transit**: HTTPS/TLS for all communications
- **PII Detection**: Automatic identification and redaction
- **Access Logging**: CloudTrail integration for audit trails

### Network Security
- **VPC Endpoints**: Secure communication between services
- **Security Groups**: Restrictive ingress/egress rules
- **WAF Integration**: Web Application Firewall for API Gateway
- **CloudFront**: DDoS protection and geographic restrictions

### Identity and Access Management
- **Least Privilege**: Minimal required permissions
- **Role-Based Access**: Service-specific IAM roles
- **MFA Support**: Multi-factor authentication via Cognito
- **Session Management**: Configurable token expiration

### Compliance Features
- **Data Residency**: Region-specific deployment
- **Retention Policies**: Configurable data lifecycle
- **Audit Trails**: Comprehensive logging
- **GDPR Support**: Data deletion capabilities

## 🧹 Clean Up

### Complete Removal
```bash
# Destroy all resources
terraform destroy -auto-approve

# Or use the provided script
chmod +x auto-destroy.sh
./auto-destroy.sh
```

### Selective Cleanup
```bash
# Remove only specific components
terraform destroy -target=module.tf_ui
terraform destroy -target=module.tf_pca
```

### Manual Cleanup (if needed)
```bash
# Empty S3 buckets first
aws s3 rm s3://your-input-bucket --recursive
aws s3 rm s3://your-output-bucket --recursive
aws s3 rm s3://your-support-bucket --recursive

# Then run destroy
terraform destroy
```

### Cost Estimation
Before deployment, estimate costs:
- Visit [AWS Pricing Calculator](https://calculator.aws)
- Input your expected usage:
  - Audio files per month
  - Average file duration
  - Storage requirements
  - API calls

## 📞 Support

### Documentation
- [AWS Transcribe Call Analytics](https://docs.aws.amazon.com/transcribe/latest/dg/call-analytics.html)
- [Amazon Bedrock User Guide](https://docs.aws.amazon.com/bedrock/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Common Commands Reference
```bash
# Check deployment status
terraform show
terraform output

# View state
terraform state list
terraform state show aws_s3_bucket.input

# Refresh state
terraform refresh

# Import existing resources
terraform import aws_s3_bucket.example bucket-name

# Validate configuration
terraform validate
terraform fmt
```

### Getting Help
1. **Check logs** in CloudWatch
2. **Review Terraform** output for errors
3. **Verify AWS** service limits and quotas
4. **Test connectivity** between components
5. **Check IAM** permissions and policies

### Performance Tuning
```bash
# Optimize for high volume
max_speakers = "10"
bulk_upload_max_transcribe_jobs = "50"
bulk_upload_max_drip_rate = "10"

# Reduce costs
retention_days = 30
call_summarization = "DISABLED"
```

---

## 🎉 Ready to Deploy?

1. **Download** the distribution
2. **Extract** and navigate to folder
3. **Run** `./one-click-deploy.sh`
4. **Follow** interactive prompts
5. **Access** your solution in 10-15 minutes

**What you'll get:**
- ✅ Complete Post Call Analytics solution
- ✅ Web interface with authentication  
- ✅ API endpoints for integration
- ✅ Automated processing pipeline
- ✅ Real-time monitoring and results
- ✅ AI-powered insights and summaries

**Next steps**: Upload your first audio file and see the magic happen! 🎯

---

*This solution is provided as-is for demonstration purposes. Please review and adapt security settings for production use.*