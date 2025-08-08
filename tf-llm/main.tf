resource "aws_dynamodb_table" "tf_llm_table" {
  name           = "tf-${var.stack_name}-llm-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "tf-${var.stack_name}-llm-table"
    Environment = var.environment
  }
}

# Default LLM prompt templates
resource "aws_dynamodb_table_item" "tf_llm_prompt_summary_template" {
  table_name = aws_dynamodb_table.tf_llm_table.name
  hash_key   = aws_dynamodb_table.tf_llm_table.hash_key
  range_key  = aws_dynamodb_table.tf_llm_table.range_key

  item = jsonencode({
    PK = {
      S = "LLMPromptSummaryTemplate"
    }
    SK = {
      S = "LLMPromptSummaryTemplate"
    }
    prompt = {
      S = "Please provide a concise summary of the following call transcript:\n\n{transcript}\n\nSummary:"
    }
  })
}

resource "aws_dynamodb_table_item" "tf_llm_prompt_query_template" {
  table_name = aws_dynamodb_table.tf_llm_table.name
  hash_key   = aws_dynamodb_table.tf_llm_table.hash_key
  range_key  = aws_dynamodb_table.tf_llm_table.range_key

  item = jsonencode({
    PK = {
      S = "LLMPromptQueryTemplate"
    }
    SK = {
      S = "LLMPromptQueryTemplate"
    }
    prompt = {
      S = "Based on the following call transcript, please answer this question: {query}\n\nTranscript:\n{transcript}\n\nAnswer:"
    }
  })
}