data "archive_file" "app_zip" {
  type        = "zip"
  source_file = "build/tasks-app"
  output_path = "build/tasks-app.zip"
}

resource "aws_iam_role" "app_exec" {
  name = "tasks_app_lambda"

  assume_role_policy = local.assume_role_policy
}

resource "aws_iam_policy" "tasks_table" {
  name        = "tasks_table"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ReadWriteTable",
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.tasks.name}"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "tasks_table" {
  name       = "tasks_table"
  roles      = [aws_iam_role.app_exec.name]
  policy_arn = aws_iam_policy.tasks_table.arn
} 

resource "aws_lambda_function" "tasks" {
  filename      = data.archive_file.app_zip.output_path
  function_name = "Tasks"
  role          = aws_iam_role.app_exec.arn
  handler       = "tasks-app" # must match the name of the binary
  source_code_hash = filebase64sha256(data.archive_file.app_zip.output_path)
  runtime = "go1.x"
}

resource "aws_dynamodb_table" "tasks" {
  name              = "tasks"
  read_capacity     = 5
  write_capacity    = 5
  hash_key          = "name"

  attribute {
    name = "name"
    type = "S"
  }
}