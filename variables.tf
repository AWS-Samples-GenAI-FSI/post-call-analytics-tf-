variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "stack_name" {
  description = "Name of the stack"
  type        = string
}

variable "environment" {
  description = "Environment type"
  type        = string
  default     = "PROD"
  validation {
    condition     = contains(["DEV", "TEST", "PROD"], var.environment)
    error_message = "Environment must be DEV, TEST, or PROD."
  }
}

# UI Configuration
variable "enable_ui" {
  description = "Enable UI deployment"
  type        = bool
  default     = false
}

variable "admin_email" {
  description = "Admin email for UI access"
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "admin"
}

variable "allowed_signup_domain" {
  description = "Allowed signup email domain"
  type        = string
  default     = "*"
}

variable "retention_days" {
  description = "Retention days for S3 objects"
  type        = number
  default     = 365
  validation {
    condition     = contains([30, 60, 90, 180, 365, 730, 1460], var.retention_days)
    error_message = "Retention days must be one of: 30, 60, 90, 180, 365, 730, 1460."
  }
}

# S3 Bucket Names
variable "input_bucket_name" {
  description = "Input bucket name (leave empty to auto-create)"
  type        = string
  default     = ""
}

variable "output_bucket_name" {
  description = "Output bucket name (leave empty to auto-create)"
  type        = string
  default     = ""
}

variable "support_files_bucket_name" {
  description = "Support files bucket name (leave empty to auto-create)"
  type        = string
  default     = ""
}

variable "bulk_upload_bucket_name" {
  description = "Bulk upload bucket name (leave empty to auto-create)"
  type        = string
  default     = ""
}

# S3 Prefixes
variable "input_bucket_raw_audio" {
  description = "Prefix for raw audio files"
  type        = string
  default     = "originalAudio"
}

variable "input_bucket_orig_transcripts" {
  description = "Prefix for original transcripts"
  type        = string
  default     = "originalTranscripts"
}

variable "input_bucket_audio_playback" {
  description = "Prefix for audio playback files"
  type        = string
  default     = "playbackAudio"
}

variable "input_bucket_failed_transcriptions" {
  description = "Prefix for failed transcriptions"
  type        = string
  default     = "failedAudio"
}

variable "output_bucket_transcribe_results" {
  description = "Prefix for Transcribe results"
  type        = string
  default     = "transcribeResults"
}

variable "output_bucket_parsed_results" {
  description = "Prefix for parsed results"
  type        = string
  default     = "parsedFiles"
}

# Transcribe Configuration
variable "transcribe_languages" {
  description = "Languages for Transcribe (separated by ' | ')"
  type        = string
  default     = "en-US"
}

variable "transcribe_api_mode" {
  description = "Transcribe API mode"
  type        = string
  default     = "analytics"
  validation {
    condition     = contains(["standard", "analytics"], var.transcribe_api_mode)
    error_message = "Transcribe API mode must be 'standard' or 'analytics'."
  }
}

variable "max_speakers" {
  description = "Maximum number of speakers"
  type        = string
  default     = "2"
}

variable "speaker_separation_type" {
  description = "Speaker separation type"
  type        = string
  default     = "channel"
  validation {
    condition     = contains(["speaker", "channel"], var.speaker_separation_type)
    error_message = "Speaker separation type must be 'speaker' or 'channel'."
  }
}

variable "speaker_names" {
  description = "Speaker names (separated by ' | ')"
  type        = string
  default     = "Customer | Agent"
  validation {
    condition     = contains(["Customer | Agent", "Agent | Customer"], var.speaker_names)
    error_message = "Speaker names must be 'Customer | Agent' or 'Agent | Customer'."
  }
}

# Comprehend Configuration
variable "comprehend_languages" {
  description = "Languages supported by Comprehend (separated by ' | ')"
  type        = string
  default     = "de | en | es | it | pt | fr | ja | ko | hi | ar | zh | zh-TW"
}

variable "entity_types" {
  description = "Entity types for Comprehend (separated by ' | ')"
  type        = string
  default     = "PERSON | LOCATION | ORGANIZATION | COMMERCIAL_ITEM | EVENT | DATE | QUANTITY | TITLE"
}

variable "entity_threshold" {
  description = "Entity detection confidence threshold"
  type        = string
  default     = "0.6"
}

variable "entity_recognizer_endpoint" {
  description = "Custom entity recognizer endpoint"
  type        = string
  default     = "undefined"
}

variable "entity_string_map" {
  description = "Entity string mapping file"
  type        = string
  default     = "sample-entities.csv"
}

# Sentiment Configuration
variable "min_sentiment_negative" {
  description = "Minimum sentiment level for negative sentiment"
  type        = string
  default     = "2.0"
}

variable "min_sentiment_positive" {
  description = "Minimum sentiment level for positive sentiment"
  type        = string
  default     = "2.0"
}

# Vocabulary Configuration
variable "vocabulary_name" {
  description = "Custom vocabulary name"
  type        = string
  default     = "undefined"
}

variable "custom_lang_model_name" {
  description = "Custom language model name"
  type        = string
  default     = "undefined"
}

variable "vocab_filter_name" {
  description = "Vocabulary filter name"
  type        = string
  default     = "undefined"
}

variable "vocab_filter_mode" {
  description = "Vocabulary filter mode"
  type        = string
  default     = "mask"
  validation {
    condition     = contains(["mask", "remove"], var.vocab_filter_mode)
    error_message = "Vocabulary filter mode must be 'mask' or 'remove'."
  }
}

# Redaction Configuration
variable "call_redaction_transcript" {
  description = "Enable transcript redaction"
  type        = string
  default     = "true"
  validation {
    condition     = contains(["true", "false"], var.call_redaction_transcript)
    error_message = "Call redaction transcript must be 'true' or 'false'."
  }
}

variable "call_redaction_audio" {
  description = "Enable audio redaction"
  type        = string
  default     = "true"
  validation {
    condition     = contains(["true", "false"], var.call_redaction_audio)
    error_message = "Call redaction audio must be 'true' or 'false'."
  }
}

variable "content_redaction_languages" {
  description = "Languages supported by content redaction (separated by ' | ')"
  type        = string
  default     = "en-US"
}

# Step Functions
variable "step_function_name" {
  description = "Name of the main Step Function"
  type        = string
  default     = "PostCallAnalyticsWorkflow"
}

variable "bulk_upload_step_function_name" {
  description = "Name of the bulk upload Step Function"
  type        = string
  default     = "BulkUploadWorkflow"
}

# Bulk Upload Configuration
variable "bulk_upload_max_drip_rate" {
  description = "Maximum drip rate for bulk upload"
  type        = string
  default     = "25"
}

variable "bulk_upload_max_transcribe_jobs" {
  description = "Maximum concurrent Transcribe jobs for bulk upload"
  type        = string
  default     = "50"
}

# Telephony Configuration
variable "telephony_ctr_type" {
  description = "Telephony CTR type"
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "genesys"], var.telephony_ctr_type)
    error_message = "Telephony CTR type must be 'none' or 'genesys'."
  }
}

variable "telephony_ctr_file_suffix" {
  description = "Telephony CTR file suffixes (separated by ' | ')"
  type        = string
  default     = "_metadata.json | _call_metadata.json"
}

# Filename Parsing
variable "filename_datetime_regex" {
  description = "Regex for parsing datetime from filename"
  type        = string
  default     = "(\\\\d{4})-(\\\\d{2})-(\\\\d{2})T(\\\\d{2})-(\\\\d{2})-(\\\\d{2})"
}

variable "filename_datetime_field_map" {
  description = "Field map for datetime parsing"
  type        = string
  default     = "%Y %m %d %H %M %S"
}

variable "filename_guid_regex" {
  description = "Regex for parsing GUID from filename"
  type        = string
  default     = "_GUID_(.*?)_"
}

variable "filename_agent_regex" {
  description = "Regex for parsing agent from filename"
  type        = string
  default     = "_AGENT_(.*?)_"
}

variable "filename_cust_regex" {
  description = "Regex for parsing customer from filename"
  type        = string
  default     = "_CUST_(.*?)_"
}

# Miscellaneous
variable "conversation_location" {
  description = "Timezone location for conversations"
  type        = string
  default     = "America/New_York"
}

variable "ffmpeg_download_url" {
  description = "URL for FFMPEG download"
  type        = string
  default     = "http://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.4-amd64-static.tar.xz"
}

# Summarization Configuration
variable "call_summarization" {
  description = "Call summarization type"
  type        = string
  default     = "BEDROCK"
  validation {
    condition = contains([
      "DISABLED", "BEDROCK+TCA", "BEDROCK", "TCA-ONLY", 
      "SAGEMAKER", "ANTHROPIC", "LAMBDA"
    ], var.call_summarization)
    error_message = "Call summarization must be one of: DISABLED, BEDROCK+TCA, BEDROCK, TCA-ONLY, SAGEMAKER, ANTHROPIC, LAMBDA."
  }
}

variable "summarization_bedrock_model_id" {
  description = "Bedrock model ID for summarization"
  type        = string
  default     = "us.amazon.nova-pro-v1:0"
}

variable "summarization_sagemaker_initial_instance_count" {
  description = "Initial instance count for SageMaker summarization"
  type        = number
  default     = 1
}

variable "summarization_lambda_function_arn" {
  description = "Lambda function ARN for custom summarization"
  type        = string
  default     = ""
}

variable "summarization_llm_third_party_api_key" {
  description = "Third party LLM API key"
  type        = string
  default     = ""
  sensitive   = true
}