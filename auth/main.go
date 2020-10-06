package main

import (
	"errors"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func basicAuth(req events.APIGatewayCustomAuthorizerRequestTypeRequest) (events.APIGatewayCustomAuthorizerResponse, error) {
	mock := http.Request{
		Header: map[string][]string{
			"Authorization": {req.Headers["Authorization"]},
		},
	}
	username, password, ok := mock.BasicAuth()
	if !ok || username != "admin" || password != "admin" {
		return events.APIGatewayCustomAuthorizerResponse{}, errors.New("Unauthorized")
	}

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
