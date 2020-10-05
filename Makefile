build:
	GOOS=linux go build -o build/main main.go

init:
	terraform init terraform

plan:
	terraform plan terraform

apply:
	terraform apply --auto-approve terraform

destroy:
	terraform destroy --auto-approve terraform