provider "aws" {
  region = "eu-central-1"
}

//The base url to contact the tasks api
output "tasks_api_url" {
  value = "${aws_api_gateway_deployment.tasks.invoke_url}/${aws_api_gateway_resource.tasks.path_part}"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

//Assume role policy for tasks and auth lambda functions
locals {
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

resource "aws_iam_policy_attachment" "lamba_basic_execution_role" {
  name       = "lamba_basic_execution_role"
  roles      = [aws_iam_role.auth_lambda.name, aws_iam_role.tasks_lambda.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}