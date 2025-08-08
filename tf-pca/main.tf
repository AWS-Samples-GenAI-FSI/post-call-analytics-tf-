# Data sources for Lambda function code
data "archive_file" "tf_pca_lambda_code" {
  type        = "zip"
  source_dir  = "${path.root}/pca"
  output_path = "${path.module}/pca-lambda-code.zip"
}

# Upload Lambda code to S3
resource "aws_s3_object" "tf_pca_lambda_code" {
  bucket = var.support_files_bucket_name
  key    = "pca-lambda-code.zip"
  source = data.archive_file.tf_pca_lambda_code.output_path
  etag   = data.archive_file.tf_pca_lambda_code.output_md5
}

# Step Functions Log Group
resource "aws_cloudwatch_log_group" "tf_step_functions_log_group" {
  name              = "/aws/vendedlogs/tf-${var.stack_name}-${var.step_function_name}"
  retention_in_days = 90

  tags = {
    Name        = "tf-${var.stack_name}-step-functions-logs"
    Environment = var.environment
  }
}

# Lambda Functions
resource "aws_lambda_function" "tf_start_transcribe_job" {
  function_name = "tf-${var.stack_name}-start-transcribe-job"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-start-transcribe-job.lambda_handler"
  runtime       = "python3.13"
  timeout       = 300
  memory_size   = 1024
  role          = var.transcribe_lambda_role_arn

  ephemeral_storage {
    size = 4096
  }

  layers = ["${var.ffmpeg_layer_arn}"]

  environment {
    variables = {
      RoleArn       = var.transcribe_role_arn
      AWS_DATA_PATH = "/opt/models"
      STACK_NAME    = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-start-transcribe-job"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_extract_job_header" {
  function_name = "tf-${var.stack_name}-extract-job-header"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-extract-job-header.lambda_handler"
  runtime       = "python3.13"
  timeout       = 900
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  environment {
    variables = {
      AWS_DATA_PATH = "/opt/models"
      STACK_NAME    = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-extract-job-header"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_extract_transcript_header" {
  function_name = "tf-${var.stack_name}-extract-transcript-header"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-extract-transcript-header.lambda_handler"
  runtime       = "python3.13"
  timeout       = 900
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  layers = ["${var.ffmpeg_layer_arn}"]

  environment {
    variables = {
      AWS_DATA_PATH = "/opt/models"
      STACK_NAME    = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-extract-transcript-header"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_process_turn_by_turn" {
  function_name = "tf-${var.stack_name}-process-turn-by-turn"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-process-turn-by-turn.lambda_handler"
  runtime       = "python3.13"
  timeout       = 900
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  layers = ["${var.ffmpeg_layer_arn}"]

  environment {
    variables = {
      AWS_DATA_PATH = "/opt/models"
      STACK_NAME    = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-process-turn-by-turn"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_final_processing" {
  function_name = "tf-${var.stack_name}-final-processing"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-post-processing.lambda_handler"
  runtime       = "python3.13"
  timeout       = 60
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  environment {
    variables = {
      AWS_DATA_PATH = "/opt/models"
      STACK_NAME    = var.stack_name
      TableName     = var.dynamodb_table_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-final-processing"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_ctr_genesys" {
  function_name = "tf-${var.stack_name}-ctr-genesys"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-ctr-genesys.lambda_handler"
  runtime       = "python3.13"
  timeout       = 60
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  environment {
    variables = {
      AWS_DATA_PATH = "/opt/models"
      STACK_NAME    = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-ctr-genesys"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_post_ctr_processing" {
  function_name = "tf-${var.stack_name}-post-ctr-processing"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-post-ctr-processing.lambda_handler"
  runtime       = "python3.13"
  timeout       = 60
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  environment {
    variables = {
      AWS_DATA_PATH = "/opt/models"
      STACK_NAME    = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-post-ctr-processing"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_fetch_transcript" {
  function_name = "tf-${var.stack_name}-fetch-transcript"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-fetch-transcript.lambda_handler"
  runtime       = "python3.13"
  timeout       = 900
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  environment {
    variables = {
      STACK_NAME = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-fetch-transcript"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_summarize" {
  function_name = "tf-${var.stack_name}-summarize"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-summarize.lambda_handler"
  runtime       = "python3.13"
  timeout       = 900
  memory_size   = 1024
  role          = aws_iam_role.tf_summarize_lambda_role.arn

  layers = ["${var.pyutils_layer_arn}"]

  environment {
    variables = {
      STACK_NAME                    = var.stack_name
      AWS_DATA_PATH                = "/opt/models"
      FETCH_TRANSCRIPT_LAMBDA_ARN   = aws_lambda_function.tf_fetch_transcript.arn
      BEDROCK_MODEL_ID             = "amazon.titan-text-express-v1"
      LLM_TABLE_NAME               = var.llm_table_name
      SUMMARY_TYPE                 = var.call_summarization
      SUMMARY_SAGEMAKER_ENDPOINT   = var.summarization_sagemaker_endpoint_name
      ANTHROPIC_API_KEY            = var.summarization_llm_third_party_api_key
      SUMMARY_LAMBDA_ARN           = var.summarization_lambda_function_arn
      ANTHROPIC_MODEL_IDENTIFIER   = "claude-v1.3-100k"
      ANTHROPIC_ENDPOINT_URL       = "https://api.anthropic.com/v1/complete"
      TOKEN_COUNT                  = var.call_summarization == "SAGEMAKER" ? "1024" : "0"
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-summarize"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_await_notification" {
  function_name = "tf-${var.stack_name}-await-notification"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-wait-for-transcribe-notification.lambda_handler"
  runtime       = "python3.13"
  timeout       = 60
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  environment {
    variables = {
      TableName  = var.dynamodb_table_name
      STACK_NAME = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-await-notification"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_transcribe_failed" {
  function_name = "tf-${var.stack_name}-transcribe-failed"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-sf-transcribe-failed.lambda_handler"
  runtime       = "python3.13"
  timeout       = 60
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  environment {
    variables = {
      RoleArn    = var.transcribe_role_arn
      STACK_NAME = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-transcribe-failed"
    Environment = var.environment
  }
}

resource "aws_lambda_function" "tf_output_trigger" {
  function_name = "tf-${var.stack_name}-output-trigger"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_pca_lambda_code.key
  handler       = "pca-aws-output-trigger.lambda_handler"
  runtime       = "python3.13"
  timeout       = 60
  memory_size   = 1024
  role          = aws_iam_role.tf_lambda_execution_role.arn

  environment {
    variables = {
      TableName  = var.dynamodb_table_name
      STACK_NAME = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_pca_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-output-trigger"
    Environment = var.environment
  }
}

resource "aws_lambda_permission" "tf_output_trigger_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_output_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.output_bucket_arn
}

resource "aws_s3_bucket_notification" "tf_output_bucket_notification" {
  bucket = var.output_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.tf_output_trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "parsedFiles/"
    id                  = "tf-output-trigger-notification"
  }

  depends_on = [aws_lambda_permission.tf_output_trigger_s3]
}