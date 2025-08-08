output "lambda_functions" {
  value = {
    head         = aws_lambda_function.head.arn
    get          = aws_lambda_function.get.arn
    list         = aws_lambda_function.list.arn
    search       = aws_lambda_function.search.arn
    entities     = aws_lambda_function.entities.arn
    languages    = aws_lambda_function.languages.arn
    swap         = aws_lambda_function.swap.arn
    presign      = aws_lambda_function.presign.arn
    genai_query  = aws_lambda_function.genai_query.arn
    genai_refresh = aws_lambda_function.genai_refresh.arn
  }
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}