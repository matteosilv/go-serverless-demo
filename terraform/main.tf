provider "aws" {
  region = "eu-central-1"
}

output "base_url" {
  value = aws_api_gateway_deployment.tasks.invoke_url
}