clean:
	rm -rf build

build:
	GOOS=linux go build -o build/tasks-lambda tasks-lambda/main.go
	GOOS=linux go build -o build/auth-lambda  auth-lambda/main.go

init:
	terraform init terraform

plan:
	terraform plan terraform

apply:
	terraform apply --auto-approve terraform

destroy:
	terraform destroy --auto-approve terraform