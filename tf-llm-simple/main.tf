# Simple LLM Table for GenAI functions
resource "aws_dynamodb_table" "llm_simple_table" {
  name           = "${var.llm_table_name}-simple"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LLMPromptTemplateId"

  attribute {
    name = "LLMPromptTemplateId"
    type = "S"
  }

  tags = {
    Name        = "${var.llm_table_name}-simple"
    Environment = var.environment
  }
}

# Add default templates
resource "aws_dynamodb_table_item" "summary_template" {
  table_name = aws_dynamodb_table.llm_simple_table.name
  hash_key   = aws_dynamodb_table.llm_simple_table.hash_key

  item = jsonencode({
    LLMPromptTemplateId = {
      S = "LLMPromptSummaryTemplate"
    }
    "LLMPromptTemplateValue#Summary" = {
      S = "Please provide a concise summary of the following call transcript:<br><br>Transcript:<br>{transcript}<br><br>Summary:"
    }
  })
}

resource "aws_dynamodb_table_item" "query_template" {
  table_name = aws_dynamodb_table.llm_simple_table.name
  hash_key   = aws_dynamodb_table.llm_simple_table.hash_key

  item = jsonencode({
    LLMPromptTemplateId = {
      S = "LLMPromptQueryTemplate"
    }
    LLMPromptTemplateValue = {
      S = "Based on the following call transcript, please answer this question: {question}<br><br>Transcript:<br>{transcript}<br><br>Answer:"
    }
  })
}