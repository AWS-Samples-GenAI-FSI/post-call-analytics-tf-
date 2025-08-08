variable "stack_name" {
  description = "Name of the stack"
  type        = string
}

variable "input_bucket_name" {
  description = "Input bucket name"
  type        = string
}

variable "output_bucket_name" {
  description = "Output bucket name"
  type        = string
}

variable "support_files_bucket_name" {
  description = "Support files bucket name"
  type        = string
}

variable "bulk_upload_bucket_name" {
  description = "Bulk upload bucket name"
  type        = string
}

variable "input_bucket_raw_audio" {
  description = "Prefix for raw audio files"
  type        = string
}

variable "input_bucket_orig_transcripts" {
  description = "Prefix for original transcripts"
  type        = string
}

variable "input_bucket_audio_playback" {
  description = "Prefix for audio playback files"
  type        = string
}

variable "input_bucket_failed_transcriptions" {
  description = "Prefix for failed transcriptions"
  type        = string
}

variable "output_bucket_transcribe_results" {
  description = "Prefix for Transcribe results"
  type        = string
}

variable "output_bucket_parsed_results" {
  description = "Prefix for parsed results"
  type        = string
}

variable "transcribe_languages" {
  description = "Languages for Transcribe"
  type        = string
}

variable "transcribe_api_mode" {
  description = "Transcribe API mode"
  type        = string
}

variable "max_speakers" {
  description = "Maximum number of speakers"
  type        = string
}

variable "speaker_separation_type" {
  description = "Speaker separation type"
  type        = string
}

variable "speaker_names" {
  description = "Speaker names"
  type        = string
}

variable "comprehend_languages" {
  description = "Languages supported by Comprehend"
  type        = string
}

variable "entity_types" {
  description = "Entity types for Comprehend"
  type        = string
}

variable "entity_threshold" {
  description = "Entity detection confidence threshold"
  type        = string
}

variable "entity_recognizer_endpoint" {
  description = "Custom entity recognizer endpoint"
  type        = string
}

variable "entity_string_map" {
  description = "Entity string mapping file"
  type        = string
}

variable "min_sentiment_negative" {
  description = "Minimum sentiment level for negative sentiment"
  type        = string
}

variable "min_sentiment_positive" {
  description = "Minimum sentiment level for positive sentiment"
  type        = string
}

variable "vocabulary_name" {
  description = "Custom vocabulary name"
  type        = string
}

variable "custom_lang_model_name" {
  description = "Custom language model name"
  type        = string
}

variable "vocab_filter_name" {
  description = "Vocabulary filter name"
  type        = string
}

variable "vocab_filter_mode" {
  description = "Vocabulary filter mode"
  type        = string
}

variable "call_redaction_transcript" {
  description = "Enable transcript redaction"
  type        = string
}

variable "call_redaction_audio" {
  description = "Enable audio redaction"
  type        = string
}

variable "content_redaction_languages" {
  description = "Languages supported by content redaction"
  type        = string
}

variable "step_function_name" {
  description = "Name of the main Step Function"
  type        = string
}

variable "bulk_upload_step_function_name" {
  description = "Name of the bulk upload Step Function"
  type        = string
}

variable "bulk_upload_max_drip_rate" {
  description = "Maximum drip rate for bulk upload"
  type        = string
}

variable "bulk_upload_max_transcribe_jobs" {
  description = "Maximum concurrent Transcribe jobs for bulk upload"
  type        = string
}

variable "telephony_ctr_type" {
  description = "Telephony CTR type"
  type        = string
}

variable "telephony_ctr_file_suffix" {
  description = "Telephony CTR file suffixes"
  type        = string
}

variable "filename_datetime_regex" {
  description = "Regex for parsing datetime from filename"
  type        = string
}

variable "filename_datetime_field_map" {
  description = "Field map for datetime parsing"
  type        = string
}

variable "filename_guid_regex" {
  description = "Regex for parsing GUID from filename"
  type        = string
}

variable "filename_agent_regex" {
  description = "Regex for parsing agent from filename"
  type        = string
}

variable "filename_cust_regex" {
  description = "Regex for parsing customer from filename"
  type        = string
}

variable "conversation_location" {
  description = "Timezone location for conversations"
  type        = string
}

variable "call_summarization" {
  description = "Call summarization type"
  type        = string
}