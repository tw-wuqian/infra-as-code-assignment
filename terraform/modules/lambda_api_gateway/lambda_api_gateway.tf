resource "aws_lambda_function" "register_user" {
  filename         = "path/to/lambda.zip"
  function_name    = "registerUser"
  role             = var.lambda_role_arn
  handler          = "register_user.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("path/to/lambda.zip")
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
  route_key = "GET /register"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "default"
  auto_deploy = true
}

output "api_gateway_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}