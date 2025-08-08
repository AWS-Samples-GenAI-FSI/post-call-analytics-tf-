# Step Functions State Machine
resource "aws_sfn_state_machine" "tf_pca_state_machine" {
  name     = "tf-${var.stack_name}-${var.step_function_name}"
  role_arn = var.step_functions_role_arn

  definition = templatefile("${path.module}/pca-definition.json", {
    SFExtractJobHeaderArn       = aws_lambda_function.tf_extract_job_header.arn
    SFExtractTranscriptHeaderArn = aws_lambda_function.tf_extract_transcript_header.arn
    SFProcessTurnArn           = aws_lambda_function.tf_process_turn_by_turn.arn
    SFStartTranscribeJobArn    = aws_lambda_function.tf_start_transcribe_job.arn
    SFAwaitNotificationArn     = aws_lambda_function.tf_await_notification.arn
    SFTranscribeFailedArn      = aws_lambda_function.tf_transcribe_failed.arn
    SFFinalProcessingArn       = aws_lambda_function.tf_final_processing.arn
    SFCTRGenesysArn           = aws_lambda_function.tf_ctr_genesys.arn
    SFPostCTRProcessingArn    = aws_lambda_function.tf_post_ctr_processing.arn
    SFSummarizeArn            = aws_lambda_function.tf_summarize.arn
  })

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.tf_step_functions_log_group.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }

  tags = {
    Name        = "tf-${var.stack_name}-pca-state-machine"
    Environment = var.environment
  }
}