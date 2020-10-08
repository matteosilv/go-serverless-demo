package main

import (
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
	"github.com/matteosilv/go-serverless-demo/tasks-lambda/handlers"
)

var (
	db dynamodbiface.DynamoDBAPI
)

const table = "tasks"

func main() {
	awsSession, err := session.NewSession(&aws.Config{
		Region: aws.String(os.Getenv("AWS_REGION"))},
	)
	if err != nil {
		return
	}
	db = dynamodb.New(awsSession)
	lambda.Start(handler)
}

func handler(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	switch req.HTTPMethod {
	case "GET":
		return handlers.GetTasks(req, table, db)
	case "POST":
		return handlers.CreateTask(req, table, db)
	default:
		return handlers.MethodNotAllowed()
	}
}
