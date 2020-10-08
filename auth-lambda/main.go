package main

import (
	"errors"
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func basicAuth(req events.APIGatewayCustomAuthorizerRequest) (events.APIGatewayCustomAuthorizerResponse, error) {
	log.Printf("main.basicAuth: Authorization token provided: %s", req.AuthorizationToken)
	mock := http.Request{
		Header: map[string][]string{
			"Authorization": {req.AuthorizationToken},
		},
	}
	username, password, ok := mock.BasicAuth()
	if !ok || username != "admin" || password != "admin" {
		log.Printf("main.basicAuth: User unauthorized")
		return events.APIGatewayCustomAuthorizerResponse{}, errors.New("Unauthorized")
	}
	log.Printf("main.basicAuth: Authorized user: %s", username)

	return events.APIGatewayCustomAuthorizerResponse{
		PrincipalID: "admin",
		PolicyDocument: events.APIGatewayCustomAuthorizerPolicy{
			Version: "2012-10-17",
			Statement: []events.IAMPolicyStatement{
				{
					Action:   []string{"execute-api:Invoke"},
					Effect:   "Allow",
					Resource: []string{req.MethodArn},
				},
			},
		},
	}, nil
}

func main() {
	lambda.Start(basicAuth)
}
