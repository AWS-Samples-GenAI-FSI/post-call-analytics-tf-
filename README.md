# Post Call Analytics - Terraform Distribution

🚀 **One-command deployment** of Amazon Transcribe Post Call Analytics solution with interactive setup and beautiful progress tracking.

## 🚀 Quick Start

### One-Click Deployment (Recommended)
```bash
git clone https://github.com/AWS-Samples-GenAI-FSI/post-call-analytics-tf-.git
cd post-call-analytics-tf-
chmod +x one-click-deploy.sh
./one-click-deploy.sh
```

**Features:**
- ✨ Interactive region selection (5 supported regions)
- 📧 Email validation for admin access
- 🎨 Beautiful progress banner with 7-step deployment
- 🔄 Automatic Cognito callback URL configuration
- ✅ Complete success dashboard with all URLs

## 📋 Prerequisites

- **Terraform** >= 1.0 ([Install Guide](https://terraform.io))
- **AWS CLI** configured with admin permissions ([Install Guide](https://aws.amazon.com/cli/))
- **Valid AWS Account** with Call Analytics access

**Quick Setup:**
```bash
# Install AWS CLI and configure
aws configure

# Verify access
aws sts get-caller-identity
```

## 🌍 Supported Regions

The deployment script offers these Call Analytics supported regions:

1. **us-east-1** (N. Virginia) - **Recommended**
2. **us-west-2** (Oregon)  
3. **ap-southeast-2** (Sydney)
4. **eu-west-1** (Ireland)
5. **ap-northeast-1** (Tokyo)

## 🏗️ What This Deploys

### Core Infrastructure
- ✅ **S3 Buckets**: Auto-created with unique names (Input, Output, Support, Bulk)
- ✅ **DynamoDB Tables**: Job tracking and LLM templates  
- ✅ **IAM Roles**: Least-privilege security model
- ✅ **Lambda Functions**: 17 processing functions
- ✅ **Step Functions**: Complete workflow orchestration
- ✅ **EventBridge**: Transcribe job monitoring
- ✅ **Cognito**: User authentication with automatic callback URLs
- ✅ **CloudFront**: Web UI distribution
- ✅ **API Gateway**: REST API endpoints

### Key Features
- 🎯 **Audio Processing**: WAV, MP3, M4A support with FFmpeg
- 🎯 **Transcript Processing**: External transcript support
- 🎯 **Speaker Diarization**: Customer/Agent separation
- 🎯 **Sentiment Analysis**: Real-time sentiment tracking
- 🎯 **Entity Recognition**: PII detection and redaction
- 🎯 **Call Summarization**: Bedrock Nova Pro integration
- 🎯 **Web Interface**: React-based UI with authentication
- 🎯 **Multi-Region**: 5 supported regions

## 🎯 Usage After Deployment

### Access Web Interface
```bash
# URL provided in deployment success banner
https://your-cloudfront-url.cloudfront.net
```

### Upload Audio Files (CLI)
```bash
aws s3 cp your-call.wav s3://YOUR-INPUT-BUCKET/originalAudio/
```

### Upload Transcript Files (CLI)
```bash
aws s3 cp your-transcript.json s3://YOUR-INPUT-BUCKET/originalTranscripts/
```

### View Results (CLI)
```bash
aws s3 ls s3://YOUR-OUTPUT-BUCKET/parsedFiles/
```

### Monitor Processing
- **Step Functions**: AWS Console → Step Functions → PostCallAnalyticsWorkflow
- **CloudWatch Logs**: AWS Console → CloudWatch → Log Groups
- **Web Interface**: Real-time job monitoring and results

## 🏛️ Architecture

```
Audio/Transcript Files
        ↓
    S3 Input Bucket
        ↓
   Lambda Trigger
        ↓
   Step Functions Workflow
        ↓
┌─────────────────────────────────────┐
│  Transcribe → Comprehend → Bedrock  │
│     ↓            ↓          ↓       │
│  Speech-to-Text  Sentiment  Summary │
└─────────────────────────────────────┘
        ↓
   S3 Output Bucket
        ↓
   Web Interface Results
```

## ⚙️ Configuration

The deployment uses `terraform.tfvars` for configuration. Key settings:

```hcl
# Stack Configuration
stack_name = "pca-stack-202501271430"
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

## 🔧 Advanced Usage

### Manual Configuration
If you need to customize settings before deployment:

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

### Import Existing Resources
If you have existing PCA resources deployed outside Terraform:

```bash
# Use the import script (if available)
chmod +x import-existing-resources.sh
./import-existing-resources.sh
```

## 🧹 Clean Up

To remove all deployed resources:

```bash
terraform destroy -auto-approve
```

**Warning**: This will permanently delete all resources including S3 buckets and their contents.

## 🔒 Security

- **IAM**: All resources use least-privilege IAM roles
- **Encryption**: S3 buckets encrypted with AES256
- **PII Protection**: Automatic PII detection and redaction
- **Secrets**: Stored in AWS Secrets Manager
- **Authentication**: Cognito-based user authentication
- **Network**: VPC endpoints for secure communication

## 🚨 Troubleshooting

### Common Issues

**Terraform Init Fails**
```bash
# Clear cache and retry
rm -rf .terraform
terraform init
```

**AWS Permissions**
```bash
# Verify AWS access
aws sts get-caller-identity

# Check region
aws configure get region
```

**Deployment Fails**
```bash
# Check Terraform logs
terraform apply -auto-approve

# View detailed logs
export TF_LOG=DEBUG
terraform apply
```

**Web UI Not Accessible**
- Check CloudFront distribution status (takes 10-15 minutes)
- Verify Cognito callback URLs are updated
- Check admin email for temporary password

**Lambda Function Issues**
```bash
# Fix list and search functions
chmod +x fix-search-lambda.sh
./fix-search-lambda.sh
```

## 📊 Monitoring

### CloudWatch Dashboards
- Lambda function metrics
- Step Function execution status
- S3 bucket usage
- API Gateway performance

### Logs
- `/aws/lambda/pca-*`: Lambda function logs
- `/aws/stepfunctions/pca-*`: Step Function logs
- CloudFront access logs

## 🆘 Support

### Documentation
- [AWS Transcribe Call Analytics](https://docs.aws.amazon.com/transcribe/latest/dg/call-analytics.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Common Commands
```bash
# Check deployment status
terraform show

# View outputs
terraform output

# Refresh state
terraform refresh

# Validate configuration
terraform validate
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- AWS Transcribe team for Call Analytics capabilities
- AWS Bedrock team for Nova Pro model integration
- Community contributors and testers

---

## 🎉 Ready to Deploy?

Run the one-click deployment and follow the interactive prompts:

```bash
./one-click-deploy.sh
```

**What you'll get:**
- ✅ Complete Post Call Analytics solution
- ✅ Web interface with authentication
- ✅ API endpoints for integration
- ✅ Automated processing pipeline
- ✅ Real-time monitoring and results

**Deployment time**: 10-15 minutes

**Next steps**: Upload your first audio file and see the magic happen! 🎯

---

**Repository**: https://github.com/AWS-Samples-GenAI-FSI/post-call-analytics-tf-