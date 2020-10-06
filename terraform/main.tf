provider "aws" {
  region = "eu-central-1"
}

output "base_url" {
  value = aws_api_gateway_deployment.tasks.invoke_url
}

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