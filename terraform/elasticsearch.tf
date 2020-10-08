resource "aws_elasticsearch_domain" "lambda" {
  domain_name           = "lambda"
  elasticsearch_version = "7.7"

  cluster_config {
    instance_type = "t2.small.elasticsearch"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
}

data "http" "public_ip" {
  url = "https://icanhazip.com/"
}

resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.lambda.domain_name

  access_policies = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "es:ESHttp*"
            ],
            "Principal": {
                "AWS": "*"
            },
            "Effect": "Allow",
            "Condition": {
                "IpAddress": { 
                    "aws:SourceIp": "${chomp(data.http.public_ip.body)}"
                }
            },
            "Resource": "${aws_elasticsearch_domain.lambda.arn}/*"
        }
    ]
}
EOF
}

//Role for elasticsearch lambda
resource "aws_iam_role" "elasticsearch_lambda" {
  name = "elasticsearch_lambda"

  assume_role_policy = local.assume_role_policy
}

//Policy to push logs to elasticsearch
resource "aws_iam_role_policy" "elasticsearch_lambda" {
  name        = "elasticsearch_lambda"
  role        = aws_iam_role.elasticsearch_lambda.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": [
            "es:*"
        ],
        "Effect": "Allow",
        "Resource": "${aws_elasticsearch_domain.lambda.arn}/*"
    }
  ]
}
EOF
}

//Create the archive file for tasks lambda deployment
data "archive_file" "elasticsearch_lambda" {
  type        = "zip"
  source_file = "elastic-lambda/index.js"
  output_path = "build/elastic-lambda.zip"
}

resource "aws_lambda_function" "elasticsearch" {
  filename      = data.archive_file.elasticsearch_lambda.output_path
  function_name = "Elasticsearch"
  role          = aws_iam_role.elasticsearch_lambda.arn
  handler       = "index.handler"

  source_code_hash = filebase64sha256(data.archive_file.elasticsearch_lambda.output_path)

  runtime = "nodejs12.x"

  environment {
    variables = {
      es_endpoint = aws_elasticsearch_domain.lambda.endpoint
    }
  }
}

//CloudWatch subscription filter to push Tasks lambda logs to ElasticSearch
resource "aws_cloudwatch_log_subscription_filter" "tasks_elasticsearch_logfilter" {
  depends_on = [aws_lambda_permission.tasks_elasticsearch_lambda_permission]
  name            = "tasks_elasticsearch_logfilter"
  log_group_name  = "/aws/lambda/${aws_lambda_function.tasks.function_name}"
  filter_pattern  = ""
  destination_arn = aws_lambda_function.elasticsearch.arn
}

//CloudWatch subscription filter to push Auth lambda logs to ElasticSearch
resource "aws_cloudwatch_log_subscription_filter" "auth_elasticsearch_logfilter" {
  depends_on = [aws_lambda_permission.auth_elasticsearch_lambda_permission]
  name            = "auth_elasticsearch_logfilter"
  log_group_name  = "/aws/lambda/${aws_lambda_function.auth.function_name}"
  filter_pattern  = ""
  destination_arn = aws_lambda_function.elasticsearch.arn
}

//Lambda Permission to allow CloudWatch subscription filter to push Tasks lambda logs to ElasticSearch
resource "aws_lambda_permission" "tasks_elasticsearch_lambda_permission" {
   statement_id  = "PushTasksLogsGroupToElasticSearchFromCloudWatch"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.elasticsearch.function_name
   principal     = "logs.${data.aws_region.current.name}.amazonaws.com"

   source_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.tasks.function_name}:*"
}

//Lambda Permission to allow CloudWatch subscription filter to push Auth lambda logs to ElasticSearch
resource "aws_lambda_permission" "auth_elasticsearch_lambda_permission" {
   statement_id  = "PushAuthLogsGroupToElasticSearchFromCloudWatch"
   action        = "lambda:InvokeFunction"
   function_name = aws_lambda_function.elasticsearch.function_name
   principal     = "logs.${data.aws_region.current.name}.amazonaws.com"

   source_arn = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.auth.function_name}:*"
}