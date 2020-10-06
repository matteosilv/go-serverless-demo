build:
	GOOS=linux go build -o build/tasks-app tasks-app/main.go
	GOOS=linux go build -o build/auth auth/main.go

init:
	terraform init terraform

plan:
	terraform plan terraform

apply:
	terraform apply --auto-approve terraform

destroy:
	terraform destroy --auto-approve terraform