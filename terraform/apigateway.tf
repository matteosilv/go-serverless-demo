resource "aws_api_gateway_rest_api" "tasks" {
  name        = "Tasks"
  description = "Tasks Application"
}

resource "aws_api_gateway_resource" "tasks" {
   rest_api_id = aws_api_gateway_rest_api.tasks.id
   parent_id   = aws_api_gateway_rest_api.tasks.root_resource_id
   path_part   = "tasks"
}

resource "aws_api_gateway_method" "tasks_post" {
   rest_api_id   = aws_api_gateway_rest_api.tasks.id
   resource_id   = aws_api_gateway_resource.tasks.id
   http_method   = "POST"
   authorization = "CUSTOM"
   authorizer_id = aws_api_gateway_authorizer.auth.id
}

resource "aws_api_gateway_integration" "tasks_get" {
   rest_api_id = aws_api_gateway_rest_api.tasks.id
   resource_id = aws_api_gateway_method.tasks_post.resource_id
   http_method = aws_api_gateway_method.tasks_post.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.tasks.invoke_arn
}

resource "aws_api_gateway_method" "tasks_get" {
   rest_api_id   = aws_api_gateway_rest_api.tasks.id
   resource_id   = aws_api_gateway_resource.tasks.id
   http_method   = "GET"
   authorization = "NONE"
}

resource "aws_api_gateway_integration" "tasks_post" {
   rest_api_id = aws_api_gateway_rest_api.tasks.id
   resource_id = aws_api_gateway_method.tasks_get.resource_id
   http_method = aws_api_gateway_method.tasks_get.http_method

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = aws_lambda_function.tasks.invoke_arn
}

resource "aws_api_gateway_deployment" "tasks" {
   depends_on = [
     aws_api_gateway_integration.tasks_get,
     aws_api_gateway_integration.tasks_post,
   ]

   rest_api_id = aws_api_gateway_rest_api.tasks.id
   stage_name  = "api"
}

resource "aws_lambda_permission" "apigw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.tasks.function_name
   principal     = "apigateway.amazonaws.com"

   source_arn = "${aws_api_gateway_rest_api.tasks.execution_arn}/*/*"
}