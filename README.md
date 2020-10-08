# Golang serverless demo 

A demo of a serverless application backed by an [AWS Lambda](https://aws.amazon.com/it/lambda/) function written in Go.

The **Tasks** lambda function consists of two endpoints:

- **GET**: list created tasks
- **POST**: create new tasks

An example of task record is:

```json
{
    "name": "task",
    "description": "a task"
}
```

Tasks are stored in a [AWS DynamoDB](https://aws.amazon.com/dynamodb/) table.

The lambda function is served via [AWS API Gateway](https://aws.amazon.com/it/api-gateway/) and the POST endpoint is
authorized via the **Auth** [Custom Authorizer](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html) written in Go
that recognizes only the hardcoded user *admin* via HTTP Basic Authentication.

Logs are stored in [CloudWatch](https://aws.amazon.com/it/cloudwatch/) and streamed to an [AWS ElasticSearch](https://aws.amazon.com/it/elasticsearch-service/) domain through a
[Subscription Filter](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/SubscriptionFilters.html#LambdaFunctionExample).

The whole infrastructure can be deployed using Terraform.


- [Prerequisites](#prerequisites)
- [Usage](#usage)

## Prerequisites

### Terraform and Go

Install [Terraform](https://www.terraform.io/), [Go](https://golang.org/), and the [AWS Command Line Interface](https://aws.amazon.com/it/cli/). 

On macOS you can use [Homebrew](https://brew.sh/):

```console
$ brew install go terraform awscli
```

### AWS credentials

Use `aws configure` command or just create a configuration file `~/.aws/credentials`:

```
[default]
aws_access_key_id = KEY
aws_secret_access_key = KEY
```

You will need to create the access key id and the secret access key in the AWS console.

## Usage

### Clean

Clean generated lambda functions go binaries

```shell
make clean
```

### Build

Generate lambda functions go binaries

```shell
make build
```

### Initialize terraform

Initialize terraform

```shell
make init
```

### Review terraform plan

Review terraform changes that will be applied to the infrastructure

```shell
make plan
```

### Create the infrastructure

Deploy the infrastructure to your aws account

```shell
make apply
```

### Destroy the infrastructure

Destroy the infrastructure

```shell
make destroy
```

### Test the api

Use the URL in the `tasks_api_url` terraform output to test your api

### Browse elastic search index

Use the URLs in the `elasticsearch_kibana_url` and `elasticsearch_url` to
search logs streamed to elasticsearch domain via [Kibana](https://www.elastic.co/kibana) or ElasticSearch APIs.

Your public ip should be authorized to access via HTTP ElasticSearch and Kibana thanks to an access policy deployed through Terraform.

