# Lambda Execution Role for most functions
resource "aws_iam_role" "tf_lambda_execution_role" {
  name = "tf-${var.stack_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonTranscribeReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/ComprehendFullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
  ]

  tags = {
    Name        = "tf-${var.stack_name}-lambda-execution-role"
    Environment = var.environment
  }
}

# Summarize Lambda Role with additional permissions
resource "aws_iam_role" "tf_summarize_lambda_role" {
  name = "tf-${var.stack_name}-summarize-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]

  tags = {
    Name        = "tf-${var.stack_name}-summarize-lambda-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "tf_summarize_lambda_invoke_policy" {
  name = "InvokeGetTranscript"
  role = aws_iam_role.tf_summarize_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvokeGetTranscript"
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = aws_lambda_function.tf_fetch_transcript.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_summarize_lambda_dynamodb_policy" {
  name = "DynamoDBAccess"
  role = aws_iam_role.tf_summarize_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.llm_table_name}",
          "arn:${data.aws_partition.current.partition}:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.llm_table_name}-simple"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_summarize_lambda_bedrock_policy" {
  name = "InvokeBedrock"
  role = aws_iam_role.tf_summarize_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvokeBedrock"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:Converse"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:bedrock:*::foundation-model/*",
          "arn:${data.aws_partition.current.partition}:bedrock:*:${data.aws_caller_identity.current.account_id}:custom-model/*",
          "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:inference-profile/*"
        ]
      },
      {
        Sid    = "BedrockGetInferenceProfile"
        Effect = "Allow"
        Action = [
          "bedrock:GetInferenceProfile"
        ]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:inference-profile/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_summarize_lambda_secrets_policy" {
  count = var.summarization_llm_third_party_api_key != "" ? 1 : 0
  name  = "SecretsManagerPolicy"
  role  = aws_iam_role.tf_summarize_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SecretsManagerPolicy"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = var.summarization_llm_third_party_api_key
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_summarize_lambda_sagemaker_policy" {
  count = var.call_summarization == "SAGEMAKER" ? 1 : 0
  name  = "InvokeSummarizer"
  role  = aws_iam_role.tf_summarize_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvokeSummarizer"
        Effect = "Allow"
        Action = [
          "sagemaker:InvokeEndpoint"
        ]
        Resource = var.summarization_sagemaker_endpoint_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_summarize_lambda_custom_lambda_policy" {
  count = var.call_summarization == "LAMBDA" ? 1 : 0
  name  = "SummarizationLambda"
  role  = aws_iam_role.tf_summarize_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SummarizationLambda"
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = var.summarization_lambda_function_arn
      }
    ]
  })
}

# Step Functions Role Policy Updates
resource "aws_iam_role_policy" "tf_step_functions_lambda_invoke_policy" {
  name = "AllowInvokeFunctions"
  role = var.step_functions_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = [
          aws_lambda_function.tf_extract_job_header.arn,
          aws_lambda_function.tf_extract_transcript_header.arn,
          aws_lambda_function.tf_process_turn_by_turn.arn,
          aws_lambda_function.tf_start_transcribe_job.arn,
          aws_lambda_function.tf_await_notification.arn,
          aws_lambda_function.tf_transcribe_failed.arn,
          aws_lambda_function.tf_final_processing.arn,
          aws_lambda_function.tf_ctr_genesys.arn,
          aws_lambda_function.tf_post_ctr_processing.arn,
          aws_lambda_function.tf_summarize.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_step_functions_cloudwatch_logs_policy" {
  name = "CloudWatchLogs"
  role = var.step_functions_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutResourcePolicy",
          "logs:DescribeResourcePolicies",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}