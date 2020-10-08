package handlers

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
	"github.com/matteosilv/go-serverless-demo/tasks-lambda/task"
)

//GetTasksResponse represents a list of tasks
type GetTasksResponse struct {
	Tasks []task.Task `json:"tasks"`
}

type errorBody struct {
	ErrorMsg *string `json:"error,omitempty"`
}

//GetTasks lists all stored tasks
func GetTasks(req events.APIGatewayProxyRequest, table string, db dynamodbiface.DynamoDBAPI) (
	*events.APIGatewayProxyResponse,
	error,
) {
	log.Printf("handlers.GetTasks: listing tasks from table %s", table)
	result, err := task.GetTasks(req, table, db)
	if err != nil {
		log.Printf("handlers.GetTasks: error listing tasks from table %s: %s", table, err.Error())
		return response(http.StatusBadRequest, errorBody{
			aws.String(err.Error()),
		})
	}
	return response(http.StatusOK, GetTasksResponse{
		Tasks: *result,
	})
}

//CreateTask stores a new task
func CreateTask(req events.APIGatewayProxyRequest, table string, db dynamodbiface.DynamoDBAPI) (
	*events.APIGatewayProxyResponse,
	error,
) {
	log.Printf("handlers.CreateTask: writing new task to table %s", table)
	result, err := task.CreateTask(req, table, db)
	if err != nil {
		log.Printf("handlers.CreateTask: error writing new task to table %s: %s", table, err.Error())
		return response(http.StatusBadRequest, errorBody{
			aws.String(err.Error()),
		})
	}
	return response(http.StatusOK, result)
}

//MethodNotAllowed is invoked when the HTTP method is not supported
func MethodNotAllowed() (*events.APIGatewayProxyResponse, error) {
	return response(http.StatusMethodNotAllowed, "method not allowed")
}

func response(status int, body interface{}) (*events.APIGatewayProxyResponse, error) {
	resp := events.APIGatewayProxyResponse{Headers: map[string]string{"Content-Type": "application/json"}}
	resp.StatusCode = status

	bodyStr, _ := json.Marshal(body)
	resp.Body = string(bodyStr)
	return &resp, nil
}
