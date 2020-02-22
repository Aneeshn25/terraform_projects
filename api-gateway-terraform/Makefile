init:
	terraform init
create-workspace-otest:
	terraform workspace new onica-test
get-otest:
	terraform workspace select onica-test
	terraform get
plan-otest: get-otest
	terraform plan 
apply-otest: get-otest
	terraform apply
