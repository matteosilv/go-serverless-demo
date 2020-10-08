package task

import (
	"encoding/json"
	"errors"
	"log"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
)

//Task represents a task
type Task struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

func getTask(name string, table string, db dynamodbiface.DynamoDBAPI) (*Task, error) {
	log.Printf("task.getTask: getting task with name %s from table %s", name, table)
	result, err := db.GetItem(&dynamodb.GetItemInput{
		Key: map[string]*dynamodb.AttributeValue{
			"name": {
				S: aws.String(name),
			},
		},
		TableName: aws.String(table),
	})
	if err != nil {
		return nil, errors.New("Failed to get user from db")

	}

	item := new(Task)
	err = dynamodbattribute.UnmarshalMap(result.Item, item)
	if err != nil {
		return nil, errors.New("Faile to unmarshal task")
	}
	return item, nil
}

//GetTasks get all tasks in the provided DynamoDB table
func GetTasks(req events.APIGatewayProxyRequest, table string, db dynamodbiface.DynamoDBAPI) (
	*[]Task,
	error,
) {
	log.Printf("task.GetTasks: listing tasks from table %s", table)
	result, err := db.Scan(&dynamodb.ScanInput{
		TableName: aws.String(table),
	})
	if err != nil {
		return nil, errors.New("Failed to get users from db")
	}
	item := new([]Task)
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, item)
	return item, nil
}

//CreateTask store the new task in the provided DynamoDB table
func CreateTask(req events.APIGatewayProxyRequest, table string, db dynamodbiface.DynamoDBAPI) (
	*Task,
	error,
) {
	var t Task
	if err := json.Unmarshal([]byte(req.Body), &t); err != nil {
		return nil, errors.New("Invalid task provided")
	}
	//replacing new lines with carriage returns, otherwise CloudWatch seems to store an event per line
	log.Printf("task.CreateTask: writing new task to table %s: %s", table, strings.Replace(req.Body, "\n", "\r", -1))

	// Check if tasks exists
	dbTask, _ := getTask(t.Name, table, db)
	if dbTask != nil && len(dbTask.Name) != 0 {
		return nil, errors.New("Task already exists")
	}

	// Save task
	newTask, err := dynamodbattribute.MarshalMap(t)
	if err != nil {
		return nil, errors.New("Cannot marshal task to be stored")
	}

	_, err = db.PutItem(&dynamodb.PutItemInput{
		Item:      newTask,
		TableName: aws.String(table),
	})
	if err != nil {
		return nil, errors.New("Cannot store new task")
	}
	return &t, nil
}
