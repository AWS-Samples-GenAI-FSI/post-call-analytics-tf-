resource "aws_ssm_parameter" "tf_bulk_upload_bucket" {
  name  = "${var.stack_name}-BulkUploadBucket"
  type  = "String"
  value = var.bulk_upload_bucket_name
}

resource "aws_ssm_parameter" "tf_bulk_upload_max_drip_rate" {
  name  = "${var.stack_name}-BulkUploadMaxDripRate"
  type  = "String"
  value = var.bulk_upload_max_drip_rate
}

resource "aws_ssm_parameter" "tf_bulk_upload_max_transcribe_jobs" {
  name  = "${var.stack_name}-BulkUploadMaxTranscribeJobs"
  type  = "String"
  value = var.bulk_upload_max_transcribe_jobs
}

resource "aws_ssm_parameter" "tf_call_summarization" {
  name  = "${var.stack_name}-CallSummarization"
  type  = "String"
  value = var.call_summarization
}

resource "aws_ssm_parameter" "tf_comprehend_languages" {
  name  = "${var.stack_name}-ComprehendLanguages"
  type  = "String"
  value = var.comprehend_languages
}

resource "aws_ssm_parameter" "tf_content_redaction_languages" {
  name  = "${var.stack_name}-ContentRedactionLanguages"
  type  = "String"
  value = var.content_redaction_languages
}

resource "aws_ssm_parameter" "tf_conversation_location" {
  name  = "${var.stack_name}-ConversationLocation"
  type  = "String"
  value = var.conversation_location
}

resource "aws_ssm_parameter" "tf_entity_recognizer_endpoint" {
  name  = "${var.stack_name}-EntityRecognizerEndpoint"
  type  = "String"
  value = var.entity_recognizer_endpoint
}

resource "aws_ssm_parameter" "tf_entity_string_map" {
  name  = "${var.stack_name}-EntityStringMap"
  type  = "String"
  value = var.entity_string_map
}

resource "aws_ssm_parameter" "tf_entity_threshold" {
  name  = "${var.stack_name}-EntityThreshold"
  type  = "String"
  value = var.entity_threshold
}

resource "aws_ssm_parameter" "tf_entity_types" {
  name  = "${var.stack_name}-EntityTypes"
  type  = "String"
  value = var.entity_types
}

resource "aws_ssm_parameter" "tf_input_bucket_audio_playback" {
  name  = "${var.stack_name}-InputBucketAudioPlayback"
  type  = "String"
  value = var.input_bucket_audio_playback
}

resource "aws_ssm_parameter" "tf_input_bucket_failed_transcriptions" {
  name  = "${var.stack_name}-InputBucketFailedTranscriptions"
  type  = "String"
  value = var.input_bucket_failed_transcriptions
}

resource "aws_ssm_parameter" "tf_input_bucket_name" {
  name  = "${var.stack_name}-InputBucketName"
  type  = "String"
  value = var.input_bucket_name
}

resource "aws_ssm_parameter" "tf_input_bucket_raw_audio" {
  name  = "${var.stack_name}-InputBucketRawAudio"
  type  = "String"
  value = var.input_bucket_raw_audio
}

resource "aws_ssm_parameter" "tf_input_bucket_orig_transcripts" {
  name  = "${var.stack_name}-InputBucketOrigTranscripts"
  type  = "String"
  value = var.input_bucket_orig_transcripts
}

resource "aws_ssm_parameter" "tf_max_speakers" {
  name  = "${var.stack_name}-MaxSpeakers"
  type  = "String"
  value = var.max_speakers
}

resource "aws_ssm_parameter" "tf_min_sentiment_negative" {
  name  = "${var.stack_name}-MinSentimentNegative"
  type  = "String"
  value = var.min_sentiment_negative
}

resource "aws_ssm_parameter" "tf_min_sentiment_positive" {
  name  = "${var.stack_name}-MinSentimentPositive"
  type  = "String"
  value = var.min_sentiment_positive
}

resource "aws_ssm_parameter" "tf_output_bucket_name" {
  name  = "${var.stack_name}-OutputBucketName"
  type  = "String"
  value = var.output_bucket_name
}

resource "aws_ssm_parameter" "tf_output_bucket_transcribe_results" {
  name  = "${var.stack_name}-OutputBucketTranscribeResults"
  type  = "String"
  value = var.output_bucket_transcribe_results
}

resource "aws_ssm_parameter" "tf_output_bucket_parsed_results" {
  name  = "${var.stack_name}-OutputBucketParsedResults"
  type  = "String"
  value = var.output_bucket_parsed_results
}

resource "aws_ssm_parameter" "tf_speaker_names" {
  name  = "${var.stack_name}-SpeakerNames"
  type  = "String"
  value = var.speaker_names
}

resource "aws_ssm_parameter" "tf_speaker_separation_type" {
  name  = "${var.stack_name}-SpeakerSeparationType"
  type  = "String"
  value = var.speaker_separation_type
}

resource "aws_ssm_parameter" "tf_step_function_name" {
  name  = "${var.stack_name}-StepFunctionName"
  type  = "String"
  value = "${var.stack_name}-${var.step_function_name}"
}

resource "aws_ssm_parameter" "tf_bulk_upload_step_function_name" {
  name  = "${var.stack_name}-BulkUploadStepFunctionName"
  type  = "String"
  value = "${var.stack_name}-${var.bulk_upload_step_function_name}"
}

resource "aws_ssm_parameter" "tf_support_files_bucket_name" {
  name  = "${var.stack_name}-SupportFilesBucketName"
  type  = "String"
  value = var.support_files_bucket_name
}

resource "aws_ssm_parameter" "tf_transcribe_api_mode" {
  name  = "${var.stack_name}-TranscribeApiMode"
  type  = "String"
  value = var.transcribe_api_mode
}

resource "aws_ssm_parameter" "tf_telephony_ctr_type" {
  name  = "${var.stack_name}-TelephonyCTRType"
  type  = "String"
  value = var.telephony_ctr_type
}

resource "aws_ssm_parameter" "tf_telephony_ctr_file_suffix" {
  name  = "${var.stack_name}-TelephonyCTRFileSuffix"
  type  = "String"
  value = var.telephony_ctr_file_suffix
}

resource "aws_ssm_parameter" "tf_call_redaction_transcript" {
  name  = "${var.stack_name}-CallRedactionTranscript"
  type  = "String"
  value = var.call_redaction_transcript
}

resource "aws_ssm_parameter" "tf_call_redaction_audio" {
  name  = "${var.stack_name}-CallRedactionAudio"
  type  = "String"
  value = var.call_redaction_audio
}

resource "aws_ssm_parameter" "tf_transcribe_languages" {
  name  = "${var.stack_name}-TranscribeLanguages"
  type  = "String"
  value = var.transcribe_languages
}

resource "aws_ssm_parameter" "tf_vocab_filter_mode" {
  name  = "${var.stack_name}-VocabFilterMode"
  type  = "String"
  value = var.vocab_filter_mode
}

resource "aws_ssm_parameter" "tf_vocab_filter_name" {
  name  = "${var.stack_name}-VocabFilterName"
  type  = "String"
  value = var.vocab_filter_name
}

resource "aws_ssm_parameter" "tf_vocabulary_name" {
  name  = "${var.stack_name}-VocabularyName"
  type  = "String"
  value = var.vocabulary_name
}

resource "aws_ssm_parameter" "tf_custom_lang_model_name" {
  name  = "${var.stack_name}-CustomLangModelName"
  type  = "String"
  value = var.custom_lang_model_name
}

resource "aws_ssm_parameter" "tf_filename_datetime_regex" {
  name  = "${var.stack_name}-FilenameDatetimeRegex"
  type  = "String"
  value = var.filename_datetime_regex
}

resource "aws_ssm_parameter" "tf_filename_datetime_field_map" {
  name  = "${var.stack_name}-FilenameDatetimeFieldMap"
  type  = "String"
  value = var.filename_datetime_field_map
}

resource "aws_ssm_parameter" "tf_filename_guid_regex" {
  name  = "${var.stack_name}-FilenameGUIDRegex"
  type  = "String"
  value = var.filename_guid_regex
}

resource "aws_ssm_parameter" "tf_filename_agent_regex" {
  name  = "${var.stack_name}-FilenameAgentRegex"
  type  = "String"
  value = var.filename_agent_regex
}

resource "aws_ssm_parameter" "tf_filename_cust_regex" {
  name  = "${var.stack_name}-FilenameCustRegex"
  type  = "String"
  value = var.filename_cust_regex
}

resource "aws_ssm_parameter" "tf_kendra_index_id" {
  name  = "${var.stack_name}-KendraIndexId"
  type  = "String"
  value = "None"
}