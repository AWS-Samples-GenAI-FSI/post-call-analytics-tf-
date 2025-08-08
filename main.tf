data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# S3 Buckets Module
module "tf_s3" {
  source = "./tf-s3"

  stack_name                  = var.stack_name
  environment                 = var.environment
  retention_days              = var.retention_days
  input_bucket_name           = var.input_bucket_name
  output_bucket_name          = var.output_bucket_name
  support_files_bucket_name   = var.support_files_bucket_name
  bulk_upload_bucket_name     = var.bulk_upload_bucket_name
}

# DynamoDB Table Module
module "tf_ddb" {
  source = "./tf-ddb"

  stack_name  = var.stack_name
  environment = var.environment
}

# IAM Roles Module
module "tf_iam" {
  source = "./tf-iam"

  stack_name                = var.stack_name
  environment               = var.environment
  aws_region                = data.aws_region.current.name
  aws_account_id            = data.aws_caller_identity.current.account_id
  input_bucket_arn          = module.tf_s3.input_bucket_arn
  output_bucket_arn         = module.tf_s3.output_bucket_arn
  support_files_bucket_arn  = module.tf_s3.support_files_bucket_arn
  dynamodb_table_arn        = module.tf_ddb.table_arn
}

# SSM Parameters Module
module "tf_ssm" {
  source = "./tf-ssm"

  stack_name                              = var.stack_name
  input_bucket_name                       = module.tf_s3.input_bucket_name
  output_bucket_name                      = module.tf_s3.output_bucket_name
  support_files_bucket_name               = module.tf_s3.support_files_bucket_name
  bulk_upload_bucket_name                 = module.tf_s3.bulk_upload_bucket_name
  input_bucket_raw_audio                  = var.input_bucket_raw_audio
  input_bucket_orig_transcripts           = var.input_bucket_orig_transcripts
  input_bucket_audio_playback             = var.input_bucket_audio_playback
  input_bucket_failed_transcriptions      = var.input_bucket_failed_transcriptions
  output_bucket_transcribe_results        = var.output_bucket_transcribe_results
  output_bucket_parsed_results            = var.output_bucket_parsed_results
  transcribe_languages                    = var.transcribe_languages
  transcribe_api_mode                     = var.transcribe_api_mode
  max_speakers                            = var.max_speakers
  speaker_separation_type                 = var.speaker_separation_type
  speaker_names                           = var.speaker_names
  comprehend_languages                    = var.comprehend_languages
  entity_types                            = var.entity_types
  entity_threshold                        = var.entity_threshold
  entity_recognizer_endpoint              = var.entity_recognizer_endpoint
  entity_string_map                       = var.entity_string_map
  min_sentiment_negative                  = var.min_sentiment_negative
  min_sentiment_positive                  = var.min_sentiment_positive
  vocabulary_name                         = var.vocabulary_name
  custom_lang_model_name                  = var.custom_lang_model_name
  vocab_filter_name                       = var.vocab_filter_name
  vocab_filter_mode                       = var.vocab_filter_mode
  call_redaction_transcript               = var.call_redaction_transcript
  call_redaction_audio                    = var.call_redaction_audio
  content_redaction_languages            = var.content_redaction_languages
  step_function_name                      = var.step_function_name
  bulk_upload_step_function_name          = var.bulk_upload_step_function_name
  bulk_upload_max_drip_rate               = var.bulk_upload_max_drip_rate
  bulk_upload_max_transcribe_jobs         = var.bulk_upload_max_transcribe_jobs
  telephony_ctr_type                      = var.telephony_ctr_type
  telephony_ctr_file_suffix               = var.telephony_ctr_file_suffix
  filename_datetime_regex                 = var.filename_datetime_regex
  filename_datetime_field_map             = var.filename_datetime_field_map
  filename_guid_regex                     = var.filename_guid_regex
  filename_agent_regex                    = var.filename_agent_regex
  filename_cust_regex                     = var.filename_cust_regex
  conversation_location                   = var.conversation_location
  call_summarization                      = var.call_summarization

  depends_on = [module.tf_s3]
}

# PyUtils Layer Module
module "tf_pyutils" {
  source = "./tf-pyutils"

  stack_name                = var.stack_name
  support_files_bucket_name = module.tf_s3.support_files_bucket_name

  depends_on = [module.tf_s3, module.tf_ssm]
}

# FFMPEG Layer Module
module "tf_ffmpeg" {
  source = "./tf-ffmpeg"

  stack_name                = var.stack_name
  support_files_bucket_name = module.tf_s3.support_files_bucket_name
  ffmpeg_download_url       = var.ffmpeg_download_url

  depends_on = [module.tf_s3, module.tf_ssm]
}

# LLM Table Module
module "tf_llm" {
  source = "./tf-llm"

  stack_name  = var.stack_name
  environment = var.environment
}

# Simple LLM Table Module for GenAI
module "tf_llm_simple" {
  source = "./tf-llm-simple"

  llm_table_name = module.tf_llm.table_name
  environment = var.environment
}

# PCA Core Module
module "tf_pca" {
  source = "./tf-pca"

  stack_name                              = var.stack_name
  environment                             = var.environment
  support_files_bucket_name               = module.tf_s3.support_files_bucket_name
  dynamodb_table_name                     = module.tf_ddb.table_name
  transcribe_role_arn                     = module.tf_iam.transcribe_role_arn
  transcribe_lambda_role_arn              = module.tf_iam.transcribe_lambda_role_arn
  step_functions_role_arn                 = module.tf_iam.step_functions_role_arn
  step_functions_role_name                = split("/", module.tf_iam.step_functions_role_arn)[1]
  ffmpeg_layer_arn                        = module.tf_ffmpeg.layer_arn
  pyutils_layer_arn                       = module.tf_pyutils.layer_arn
  step_function_name                      = var.step_function_name
  call_summarization                      = var.call_summarization
  summarization_bedrock_model_id          = var.summarization_bedrock_model_id
  summarization_sagemaker_endpoint_name   = var.summarization_sagemaker_initial_instance_count > 0 ? "" : ""
  summarization_sagemaker_endpoint_arn    = ""
  summarization_llm_third_party_api_key   = var.summarization_llm_third_party_api_key
  summarization_lambda_function_arn       = var.summarization_lambda_function_arn
  llm_table_name                          = module.tf_llm.table_name
  output_bucket_name                      = module.tf_s3.output_bucket_name
  output_bucket_arn                       = module.tf_s3.output_bucket_arn

  depends_on = [module.tf_s3, module.tf_ddb, module.tf_iam, module.tf_ssm, module.tf_pyutils, module.tf_ffmpeg, module.tf_llm, module.tf_llm_simple]
}

# Trigger Module
module "tf_trigger" {
  source = "./tf-trigger"

  stack_name                            = var.stack_name
  environment                           = var.environment
  support_files_bucket_name             = module.tf_s3.support_files_bucket_name
  input_bucket_name                     = module.tf_s3.input_bucket_name
  input_bucket_arn                      = module.tf_s3.input_bucket_arn
  input_bucket_raw_audio_prefix         = var.input_bucket_raw_audio
  input_bucket_orig_transcripts_prefix  = var.input_bucket_orig_transcripts
  dynamodb_table_name                   = module.tf_ddb.table_name
  file_drop_trigger_role_arn            = module.tf_iam.file_drop_trigger_role_arn

  transcribe_eventbridge_role_arn       = module.tf_iam.transcribe_eventbridge_role_arn
  pyutils_layer_arn                     = module.tf_pyutils.layer_arn
  call_summarization                    = var.call_summarization

  depends_on = [module.tf_s3, module.tf_iam, module.tf_ddb, module.tf_pyutils, module.tf_pca]
}

# UI Module (Conditional)
module "tf_ui" {
  count  = var.enable_ui ? 1 : 0
  source = "./tf-ui"

  stack_name                              = var.stack_name
  admin_email                             = var.admin_email
  admin_username                          = var.admin_username
  allowed_signup_domain                   = var.allowed_signup_domain
  table_name                              = module.tf_ddb.table_name
  audio_bucket_name                       = module.tf_s3.input_bucket_name
  data_bucket_name                        = module.tf_s3.output_bucket_name
  audio_bucket_prefix                     = var.input_bucket_raw_audio
  pyutils_layer_arn                       = module.tf_pyutils.layer_arn
  llm_table_name                          = module.tf_llm.table_name
  fetch_transcript_arn                    = module.tf_pca.fetch_transcript_lambda_arn
  summarizer_arn                          = module.tf_pca.summarizer_lambda_arn
  call_summarization                      = var.call_summarization
  summarization_bedrock_model_id          = var.summarization_bedrock_model_id
  summarization_llm_third_party_api_key   = var.summarization_llm_third_party_api_key

  depends_on = [module.tf_pca, module.tf_llm, module.tf_llm_simple, module.tf_pyutils]
}