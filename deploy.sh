#!/bin/bash
# Script to build and push Docker image to AWS ECR

set -e

AWS_REGION="us-east-1"
ECR_REPO_NAME="node-js-app-repository"

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# ECR repository URI
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI

echo "Building Docker image..."
docker build -t $ECR_REPO_NAME .

echo "Tagging Docker image..."
docker tag $ECR_REPO_NAME:latest $ECR_URI:latest

echo "Pushing Docker image to ECR..."
docker push $ECR_URI:latest

echo "Docker image pushed to $ECR_URI:latest"
