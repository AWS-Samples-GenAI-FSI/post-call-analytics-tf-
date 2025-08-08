# Transcribe Service Role
resource "aws_iam_role" "tf_transcribe_role" {
  name = "tf-${var.stack_name}-transcribe-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "transcribe.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonTranscribeFullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]

  tags = {
    Name        = "tf-${var.stack_name}-transcribe-role"
    Environment = var.environment
  }
}

# Transcribe Lambda Role
resource "aws_iam_role" "tf_transcribe_lambda_role" {
  name = "tf-${var.stack_name}-transcribe-lambda-role"

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
    "arn:aws:iam::aws:policy/AmazonTranscribeFullAccess"
  ]

  tags = {
    Name        = "tf-${var.stack_name}-transcribe-lambda-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "tf_transcribe_lambda_pass_role" {
  name = "PassRoleToTranscribe"
  role = aws_iam_role.tf_transcribe_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.tf_transcribe_role.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_transcribe_lambda_s3_policy" {
  name = "S3BucketReadWritePolicy"
  role = aws_iam_role.tf_transcribe_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          var.input_bucket_arn,
          "${var.input_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_transcribe_lambda_ssm_policy" {
  name = "SSMGetParameterPolicy"
  role = aws_iam_role.tf_transcribe_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/*"
      }
    ]
  })
}

# Step Functions Role
resource "aws_iam_role" "tf_step_functions_role" {
  name = "tf-${var.stack_name}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "tf-${var.stack_name}-step-functions-role"
    Environment = var.environment
  }
}

# File Drop Trigger Role
resource "aws_iam_role" "tf_file_drop_trigger_role" {
  name = "tf-${var.stack_name}-file-drop-trigger-role"

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
    "arn:aws:iam::aws:policy/AmazonTranscribeReadOnlyAccess"
  ]

  tags = {
    Name        = "tf-${var.stack_name}-file-drop-trigger-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "tf_file_drop_trigger_s3_policy" {
  name = "S3BucketReadPolicy"
  role = aws_iam_role.tf_file_drop_trigger_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3BucketReadPolicy"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          var.input_bucket_arn,
          "${var.input_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_file_drop_trigger_ssm_policy" {
  name = "SSMGetParameterPolicy"
  role = aws_iam_role.tf_file_drop_trigger_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMGetParameterPolicy"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_file_drop_trigger_step_functions_policy" {
  name = "StartExecutionPolicy"
  role = aws_iam_role.tf_file_drop_trigger_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListStatemachinesPolicy"
        Effect = "Allow"
        Action = "states:ListStateMachines"
        Resource = "*"
      },
      {
        Sid    = "StartExecutionPolicy"
        Effect = "Allow"
        Action = "states:StartExecution"
        Resource = "arn:aws:states:${var.aws_region}:${var.aws_account_id}:stateMachine:tf-${var.stack_name}-*"
      }
    ]
  })
}

# Configure Bucket Role
resource "aws_iam_role" "tf_configure_bucket_role" {
  name = "tf-${var.stack_name}-configure-bucket-role"

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
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  tags = {
    Name        = "tf-${var.stack_name}-configure-bucket-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "tf_configure_bucket_s3_policy" {
  name = "allow-s3-notification-config"
  role = aws_iam_role.tf_configure_bucket_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketNotification",
          "s3:PutBucketNotification"
        ]
        Resource = var.input_bucket_arn
      }
    ]
  })
}

# Transcribe EventBridge Role
resource "aws_iam_role" "tf_transcribe_eventbridge_role" {
  name = "tf-${var.stack_name}-transcribe-eventbridge-role"

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
    "arn:aws:iam::aws:policy/AmazonTranscribeReadOnlyAccess"
  ]

  tags = {
    Name        = "tf-${var.stack_name}-transcribe-eventbridge-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "tf_transcribe_eventbridge_step_functions_policy" {
  name = "SendTaskSuccessPolicy"
  role = aws_iam_role.tf_transcribe_eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:SendTaskSuccess"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "tf_transcribe_eventbridge_dynamodb_policy" {
  name = "DynamoDBReadWriteAccess"
  role = aws_iam_role.tf_transcribe_eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DeleteItem",
          "dynamodb:GetItem"
        ]
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}