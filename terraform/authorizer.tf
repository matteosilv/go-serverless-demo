//Create the archive file for auth lambda deployment
data "archive_file" "auth_lambda" {
  type        = "zip"
  source_file = "build/auth-lambda"
  output_path = "build/auth-lambda.zip"
}

//Role for auth lambda
resource "aws_iam_role" "auth_lambda" {
  name = "auth_lambda"

  assume_role_policy = local.assume_role_policy
}

resource "aws_lambda_function" "auth" {
  filename      = data.archive_file.auth_lambda.output_path
  function_name = "Auth"
  role          = aws_iam_role.auth_lambda.arn
  handler       = "auth-lambda" # must match the name of the binary
  source_code_hash = filebase64sha256(data.archive_file.auth_lambda.output_path)
  runtime = "go1.x"
}

resource "aws_api_gateway_authorizer" "auth" {
  name                   = "auth"
  rest_api_id            = aws_api_gateway_rest_api.tasks.id
  authorizer_uri         = aws_lambda_function.auth.invoke_arn
  authorizer_credentials = aws_iam_role.auth.arn
}

//Role for authorizer
resource "aws_iam_role" "auth" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

//Policy to invoke auth lambda function
resource "aws_iam_role_policy" "auth" {
  name = "default"
  role = aws_iam_role.auth.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.auth.arn}"
    }
  ]
}
EOF
}