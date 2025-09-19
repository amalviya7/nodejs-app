# NodeJs Application Deployment

## Overview
This project is a secure deployment of a Node.js/Express microservice with a MongoDB backend. It includes Docker hardening, CI/CD pipeline security, secrets management, infrastructure as code (Terraform), runtime security, and a security report.

## Prerequisites
- Docker and Docker Compose installed
- Node.js (for local development)
- Terraform (for infrastructure provisioning)
- AWS CLI configured (if deploying infrastructure)
- GitHub repository with secrets configured for CI/CD

## Setup Instructions

### Local Development
1. Copy `.env.example` to `.env` and update environment variables.
2. Install dependencies:
   ```
   npm install
   ```
3. Start MongoDB (locally or via Docker).
4. Run the app:
   ```
   npm start
   ```
5. Access the app at `http://localhost:3000`.

### Docker
1. Build the Docker image:
   ```
   docker build -t secure-microservice .
   ```
2. Run with Docker Compose:
   ```
   docker-compose up
   ```
3. The app will be available at `http://localhost:3000`.

### CI/CD Pipeline
1. The GitHub Actions workflow `.github/workflows/ci.yml` runs static code analysis (Semgrep), container scanning (Trivy), builds the Docker image, pushes it to AWS ECR, and deploys the app to AWS ECS.
2. Set the following GitHub secrets for the workflow:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `MONGODB_URI`
3. The pipeline triggers on pull requests to `main` and pushes to `main` and `feature/**` branches.

### Infrastructure Provisioning
1. Terraform configuration is in `terraform/main.tf`.
2. Set the `mongodb_uri` variable for the MongoDB connection.
3. Run:
   ```
   terraform init
   terraform apply
   ```
4. This provisions AWS ECS cluster, ECR repository, task, and service with least-privilege IAM roles.

### Deploying to ECR
1. Ensure AWS CLI is configured with appropriate permissions.
2. Run the deployment script:
   ```
   chmod +x deploy.sh
   ./deploy.sh
   ```
3. This builds the Docker image and pushes it to the ECR repository created by Terraform.
4. After pushing, run `terraform apply` again to update the ECS service with the new image.

### Runtime Security
- Seccomp profile is defined in `seccomp.json` for container runtime restrictions.

## Notes
- Secrets are managed via environment variables; no secrets are hardcoded.
- The Dockerfile uses multi-stage builds and runs as a non-root user.
- Health checks are included for container monitoring.

## Report
See `report.md` for a detailed summary of security risks, implementations, and recommendations.
