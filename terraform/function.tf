//Create the archive file for tasks lambda deployment
data "archive_file" "tasks_lambda" {
  type        = "zip"
  source_file = "build/tasks-lambda"
  output_path = "build/tasks-lambda.zip"
}

//Role for tasks lambda
resource "aws_iam_role" "tasks_lambda" {
  name = "tasks_lambda"

  assume_role_policy = local.assume_role_policy
}

//Policy to read/write DynamoDB tasks table
resource "aws_iam_role_policy" "tasks_table" {
  name        = "tasks_table"
  role        = aws_iam_role.tasks_lambda.id
  policy      = <<EOF
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

//Tasks lambda function
resource "aws_lambda_function" "tasks" {
  filename      = data.archive_file.tasks_lambda.output_path
  function_name = "Tasks"
  role          = aws_iam_role.tasks_lambda.arn
  handler       = "tasks-lambda" # must match the name of the binary
  source_code_hash = filebase64sha256(data.archive_file.tasks_lambda.output_path)
  runtime = "go1.x"
}

//Tasks DynamoDB table
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