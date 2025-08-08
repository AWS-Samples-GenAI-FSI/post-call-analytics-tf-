# Data sources for Lambda function code
data "archive_file" "tf_trigger_lambda_code" {
  type        = "zip"
  source_dir  = "${path.root}/pca"
  output_path = "${path.module}/trigger-lambda-code.zip"
}

# Upload Lambda code to S3
resource "aws_s3_object" "tf_trigger_lambda_code" {
  bucket = var.support_files_bucket_name
  key    = "trigger-lambda-code.zip"
  source = data.archive_file.tf_trigger_lambda_code.output_path
  etag   = data.archive_file.tf_trigger_lambda_code.output_md5
}

# File Drop Trigger Lambda
resource "aws_lambda_function" "tf_file_drop_trigger" {
  function_name = "tf-${var.stack_name}-file-drop-trigger"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_trigger_lambda_code.key
  handler       = "pca-aws-file-drop-trigger.lambda_handler"
  runtime       = "python3.13"
  timeout       = 15
  memory_size   = 128
  role          = var.file_drop_trigger_role_arn

  layers = ["${var.pyutils_layer_arn}"]

  environment {
    variables = {
      SUMMARIZE  = var.call_summarization != "DISABLED" ? "true" : "false"
      STACK_NAME = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_trigger_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-file-drop-trigger"
    Environment = var.environment
  }
}

# Lambda permission for S3 to invoke the function
resource "aws_lambda_permission" "tf_file_drop_trigger_permission" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_file_drop_trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.input_bucket_arn
}



# S3 bucket notification for raw audio files
resource "aws_s3_bucket_notification" "tf_input_bucket_notification" {
  bucket = var.input_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.tf_file_drop_trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "${var.input_bucket_raw_audio_prefix}/"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.tf_file_drop_trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "${var.input_bucket_orig_transcripts_prefix}/"
  }

  depends_on = [aws_lambda_permission.tf_file_drop_trigger_permission]
}

# Transcribe EventBridge Lambda
resource "aws_lambda_function" "tf_transcribe_eventbridge" {
  function_name = "tf-${var.stack_name}-transcribe-eventbridge"
  s3_bucket     = var.support_files_bucket_name
  s3_key        = aws_s3_object.tf_trigger_lambda_code.key
  handler       = "pca-transcribe-eventbridge.lambda_handler"
  runtime       = "python3.13"
  timeout       = 60
  memory_size   = 128
  role          = var.transcribe_eventbridge_role_arn

  environment {
    variables = {
      TableName     = var.dynamodb_table_name
      AWS_DATA_PATH = "/opt/models"
      STACK_NAME    = var.stack_name
    }
  }

  depends_on = [aws_s3_object.tf_trigger_lambda_code]

  tags = {
    Name        = "tf-${var.stack_name}-transcribe-eventbridge"
    Environment = var.environment
  }
}

# EventBridge Rules for Transcribe job state changes
resource "aws_cloudwatch_event_rule" "tf_transcribe_standard_rule" {
  name        = "tf-${var.stack_name}-transcribe-standard-rule"
  description = "Capture Transcribe Job State Changes"

  event_pattern = jsonencode({
    detail-type = ["Transcribe Job State Change"]
    source      = ["aws.transcribe"]
    detail = {
      TranscriptionJobStatus = ["FAILED", "COMPLETED"]
    }
  })

  tags = {
    Name        = "tf-${var.stack_name}-transcribe-standard-rule"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_event_rule" "tf_transcribe_analytics_rule" {
  name        = "tf-${var.stack_name}-transcribe-analytics-rule"
  description = "Capture Call Analytics Job State Changes"

  event_pattern = jsonencode({
    detail-type = ["Call Analytics Job State Change"]
    source      = ["aws.transcribe"]
    detail = {
      JobStatus = ["FAILED", "COMPLETED"]
    }
  })

  tags = {
    Name        = "tf-${var.stack_name}-transcribe-analytics-rule"
    Environment = var.environment
  }
}

# EventBridge Targets
resource "aws_cloudwatch_event_target" "tf_transcribe_standard_target" {
  rule      = aws_cloudwatch_event_rule.tf_transcribe_standard_rule.name
  target_id = "TranscribeStandardTarget"
  arn       = aws_lambda_function.tf_transcribe_eventbridge.arn
}

resource "aws_cloudwatch_event_target" "tf_transcribe_analytics_target" {
  rule      = aws_cloudwatch_event_rule.tf_transcribe_analytics_rule.name
  target_id = "TranscribeAnalyticsTarget"
  arn       = aws_lambda_function.tf_transcribe_eventbridge.arn
}

# Lambda permissions for EventBridge
resource "aws_lambda_permission" "tf_transcribe_eventbridge_standard_permission" {
  statement_id  = "AllowExecutionFromEventBridgeStandard"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_transcribe_eventbridge.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.tf_transcribe_standard_rule.arn
}

resource "aws_lambda_permission" "tf_transcribe_eventbridge_analytics_permission" {
  statement_id  = "AllowExecutionFromEventBridgeAnalytics"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf_transcribe_eventbridge.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.tf_transcribe_analytics_rule.arn
}