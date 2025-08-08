# Lambda Functions for UI API
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda.zip"
  excludes    = ["jest", "*.test.js", "testfile.json"]
}

data "archive_file" "genai_zip" {
  type        = "zip"
  source_dir  = "${path.module}/genai"
  output_path = "${path.module}/genai.zip"
}

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${var.stack_name}-ui-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.stack_name}-ui-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          "arn:aws:dynamodb:*:*:table/${var.table_name}",
          "arn:aws:dynamodb:*:*:table/${var.table_name}/index/*",
          "arn:aws:dynamodb:*:*:table/${var.llm_table_name}",
          "arn:aws:dynamodb:*:*:table/${var.llm_table_name}/index/*",
          "arn:aws:dynamodb:*:*:table/${var.llm_table_name}-simple",
          "arn:aws:dynamodb:*:*:table/${var.llm_table_name}-simple/index/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.audio_bucket_name}/*",
          "arn:aws:s3:::${var.data_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/amazon.titan-text-express-v1"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          var.fetch_transcript_arn,
          var.summarizer_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Functions
resource "aws_lambda_function" "head" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.stack_name}-ui-head"
  role            = aws_iam_role.lambda_role.arn
  handler         = "src/head.handler"
  runtime         = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TableName = var.table_name
    }
  }
}

resource "aws_lambda_function" "get" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.stack_name}-ui-get"
  role            = aws_iam_role.lambda_role.arn
  handler         = "src/get.handler"
  runtime         = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DataBucket  = var.data_bucket_name
      AudioBucket = var.audio_bucket_name
    }
  }
}

resource "aws_lambda_function" "list" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.stack_name}-ui-list"
  role            = aws_iam_role.lambda_role.arn
  handler         = "src/list.handler"
  runtime         = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TableName = var.table_name
    }
  }
}

resource "aws_lambda_function" "search" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.stack_name}-ui-search"
  role            = aws_iam_role.lambda_role.arn
  handler         = "src/search.handler"
  runtime         = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TableName = var.table_name
    }
  }
}

resource "aws_lambda_function" "entities" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.stack_name}-ui-entities"
  role            = aws_iam_role.lambda_role.arn
  handler         = "src/entities.handler"
  runtime         = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TableName = var.table_name
    }
  }
}

resource "aws_lambda_function" "languages" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.stack_name}-ui-languages"
  role            = aws_iam_role.lambda_role.arn
  handler         = "src/languages.handler"
  runtime         = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TableName = var.table_name
    }
  }
}

resource "aws_lambda_function" "swap" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.stack_name}-ui-swap"
  role            = aws_iam_role.lambda_role.arn
  handler         = "src/swap.handler"
  runtime         = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TableName  = var.table_name
      DataBucket = var.data_bucket_name
    }
  }
}

resource "aws_lambda_function" "presign" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.stack_name}-ui-presign"
  role            = aws_iam_role.lambda_role.arn
  handler         = "src/presign.handler"
  runtime         = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      AudioBucket       = var.audio_bucket_name
      AudioBucketPrefix = var.audio_bucket_prefix
    }
  }
}

resource "aws_lambda_function" "genai_query" {
  filename         = data.archive_file.genai_zip.output_path
  function_name    = "${var.stack_name}-ui-genai-query"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.lambda_handler"
  runtime         = "python3.13"
  timeout         = 900
  source_code_hash = data.archive_file.genai_zip.output_base64sha256
  layers          = [var.pyutils_layer_arn]

  environment {
    variables = {
      QUERY_TYPE                    = "BEDROCK"
      BEDROCK_MODEL_ID             = var.summarization_bedrock_model_id
      FETCH_TRANSCRIPT_LAMBDA_ARN   = var.fetch_transcript_arn
      LLM_TABLE_NAME               = "${var.llm_table_name}-simple"
      ANTHROPIC_API_KEY            = var.summarization_llm_third_party_api_key
    }
  }
}

resource "aws_lambda_function" "genai_refresh" {
  filename         = data.archive_file.genai_zip.output_path
  function_name    = "${var.stack_name}-ui-genai-refresh"
  role            = aws_iam_role.lambda_role.arn
  handler         = "refresh_summary.lambda_handler"
  runtime         = "python3.13"
  timeout         = 900
  source_code_hash = data.archive_file.genai_zip.output_base64sha256
  layers          = [var.pyutils_layer_arn]

  environment {
    variables = {
      SUMMARIZER_ARN = var.summarizer_arn
    }
  }
}