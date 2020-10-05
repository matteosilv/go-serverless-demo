package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
)

type Task struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

type GetTasksResponse struct {
	Tasks []Task `json:"tasks"`
}

func GetTasks(req events.APIGatewayProxyRequest) (
	*events.APIGatewayProxyResponse,
	error,
) {
	tasks := GetTasksResponse{
		Tasks: []Task{{
			Name:        "1",
			Description: "Task 1",
		}, {
			Name:        "2",
			Description: "Task 2",
		},
		},
	}
	return response(http.StatusOK, tasks)
}

func CreateTask(req events.APIGatewayProxyRequest) (
	*events.APIGatewayProxyResponse,
	error,
) {
	return response(http.StatusOK, Task{
		Name:        "1",
		Description: "Task 1",
	})
}

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
