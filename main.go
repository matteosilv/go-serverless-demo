package main

import (
	"tasks-app/handlers"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(handler)
}

func handler(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	switch req.HTTPMethod {
	case "GET":
		return handlers.GetTasks(req)
	case "POST":
		return handlers.CreateTask(req)
	default:
		return handlers.MethodNotAllowed()
	}
}
