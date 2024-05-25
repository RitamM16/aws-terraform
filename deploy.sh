#!/bin/bash

# Initialize Terraform
terraform init

# Apply the Terraform configuration
terraform apply -auto-approve

# Fetch the ALB DNS name and echo it
ALB_DNS_NAME=$(terraform output -raw alb-dns-name)

echo "The Web service is available at: http://$ALB_DNS_NAME"