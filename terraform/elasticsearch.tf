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

//Role for tasks lambda
resource "aws_iam_role" "elasticsearch_lambda" {
  name = "elasticsearch_lambda"

  assume_role_policy = local.assume_role_policy
}

//Policy to read/write DynamoDB tasks table
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
        "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${aws_elasticsearch_domain.lambda.domain_name}/*"
    }
  ]
}
EOF
}