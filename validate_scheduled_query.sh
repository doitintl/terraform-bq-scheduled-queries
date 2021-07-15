#!/bin/bash

# Read tfvars file, remove space and set to environment variables
# https://gist.github.com/derrickqin/057e090c47b2550d7d1489756cea5a17
export $(cat ${ENV}.tfvars | sed '/^$/d;s/[[:blank:]]//g' | xargs)

bq query --dry_run --project_id ${project_id} --flagfile ${sql_file}
