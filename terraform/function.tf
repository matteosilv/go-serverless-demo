data "archive_file" "app_zip" {
  type        = "zip"
  source_file = "build/main"
  output_path = "build/main.zip"
}

resource "aws_iam_role" "app_exec" {
  name = "tasks_app_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "tasks" {
  filename      = data.archive_file.app_zip.output_path
  function_name = "Tasks"
  role          = aws_iam_role.app_exec.arn
  handler       = "main" # must match the name of the binary
  source_code_hash = filebase64sha256(data.archive_file.app_zip.output_path)
  runtime = "go1.x"
}