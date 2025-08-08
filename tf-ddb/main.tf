resource "aws_dynamodb_table" "tf_pca_table" {
  name           = "tf-${var.stack_name}-pca-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PKJobId"
  range_key      = "SKApiMode"

  attribute {
    name = "PKJobId"
    type = "S"
  }

  attribute {
    name = "SKApiMode"
    type = "S"
  }

  attribute {
    name = "GSI1PK"
    type = "S"
  }

  attribute {
    name = "GSI1SK"
    type = "S"
  }

  global_secondary_index {
    name     = "GSI1"
    hash_key = "GSI1PK"
    range_key = "GSI1SK"
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "tf-${var.stack_name}-pca-table"
    Environment = var.environment
  }
}