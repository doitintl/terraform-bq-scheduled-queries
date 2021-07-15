.ONESHELL:
	SHELL := /bin/bash

TF_STATE_BUCKET=derrickq-tfstate

validate:
	@for i in $$(find . -type f -name "*.tf" -exec dirname {} \;); do \
		terraform validate "$$i"; \
		if [ $$? -ne 0 ]; then \
			echo "Failed Terraform file validation on file $${i}"; \
			echo; \
			exit 1; \
		fi; \
	done

init:
	@terraform init \
		-backend-config=bucket=$(TF_STATE_BUCKET) \
		-backend-config=prefix=$(ENV) \
		-reconfigure -get=false \
		-upgrade

show: init
	@terraform show 

plan: init
	terraform plan \
		-input=false \
		-var-file=$(ENV).tfvars

apply: init
	@terraform apply \
		-input=false \
		-var-file=$(ENV).tfvars \
		-auto-approve

destroy: init
	@terraform destroy \
		-input=false \
		-var-file=$(ENV).tfvars \
		-auto-approve

validate-sql:
	ENV=$(ENV) bash validate_scheduled_query.sh
