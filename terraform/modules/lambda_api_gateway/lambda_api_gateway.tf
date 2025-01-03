resource "aws_lambda_function" "register_user" {
  filename         = "${path.module}/register_verify_user.zip"
  function_name    = "registerUser"
  role             = var.lambda_role_arn
  handler          = "register_user.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("${path.module}/register_verify_user.zip")
  environment {
    variables = {
      DB_TABLE_NAME = "wei-1-tfstate-locks"
    }
  }
}
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.register_user.function_name}"
  retention_in_days = 14
}

resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "api-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.api_gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.register_user.invoke_arn
}

resource "aws_apigatewayv2_route" "register_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /register"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda_logs.arn
    format          = "$context.requestId $context.identity.sourceIp $context.identity.caller $context.identity.user $context.requestTime $context.httpMethod $context.resourcePath $context.status $context.protocol $context.responseLength"
  }
}
resource "aws_lambda_permission" "apigateway_invoke" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.register_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*"
}


output "api_gateway_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}