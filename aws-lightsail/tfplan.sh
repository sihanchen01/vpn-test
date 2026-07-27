#!/bin/bash

terraform workspace select $1 && terraform plan -var-file vars/$1.tfvars
