# Manage BigQuery scheduled queries with Terraform, Cloud Build and CI/CD
This is a demo project to use Terraform to manage [BigQuery scheduled queries](https://cloud.google.com/bigquery/docs/scheduling-queries).
All the CI/CD tasks are run on Google Cloud Build.

## Architecture diagram
![image](https://user-images.githubusercontent.com/3038111/125615532-dcfa90c4-f211-4b79-8b15-a2f6f2a069ed.png)

## CI
### Cloud Build Triggers
Dev
```
name: tf-dev-plan
description: Run Terraform plan for Dev environment
filename: .cloudbuild/dev-plan.yaml
github:
  name: terraform-bq-scheduled-queries
  owner: derrickqin
  push:
    branch: .*
```
Prod
```
name: tf-prod-plan
description: Run Terraform plan for Prod environment
filename: .cloudbuild/prod-plan.yaml
github:
  name: terraform-bq-scheduled-queries
  owner: derrickqin
  push:
    branch: .*
```

### CI tasks
Any new code commit will trigger a Cloud Build build to run the CI process.
It contains two steps:
1. Validate BigQuery SQL query using bq cli with [dry-run](https://cloud.google.com/bigquery/docs/dry-run-queries) parameters.
2. Terraform plan to validate and show new changes.

## CD
### Cloud Build Triggers
Dev
```
name: tf-dev-apply
description: Run Terraform apply for Dev environment
filename: .cloudbuild/dev-apply.yaml
github:
  name: terraform-bq-scheduled-queries
  owner: derrickqin
  push:
    tag: dev.*
```
Prod
```
name: tf-prod-apply
description: Run Terraform apply for Dev environment
filename: .cloudbuild/prod-apply.yaml
github:
  name: terraform-bq-scheduled-queries
  owner: derrickqin
  push:
    tag: prod.*
```

### CD task
Any tag pushed to Github that matches the regexes will trigger a CloudBuild task to run Terraform apply

To create a tag and push to Github:

For Dev: `git tag dev-1.0 && git push origin --tags`
For Prod: `git tag prod-1.0 && git push origin --tags`


## How to run

1. Update GCP project IDs in `dev.tfvars` and `prod.tfvars`
2. Initialize TF states by running
   - `ENV=dev make init`
   - `ENV=prod make init`
3. Fork this repo on Github
4. Connect Github repo on Cloud Build follow this [guide](https://cloud.google.com/build/docs/automating-builds/create-github-app-triggers#installaing_gcb_app)
5. Create CloudBuild triggers as per information in #CI and #CD sessions
6. Trigger the CI process with `git commit --allow-empty -m "Trigger Build" && git push`
7. Trigger the CD process with `git tag dev-1.0 && git push origin --tags`
