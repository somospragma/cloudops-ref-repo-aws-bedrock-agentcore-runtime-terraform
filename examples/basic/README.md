# Basic Example - Bedrock AgentCore Runtime

This example demonstrates a basic deployment of Amazon Bedrock AgentCore Runtime with minimal configuration.

## What This Example Creates

- Single agent runtime with container-based deployment
- Public network access
- MCP protocol support
- ECR repository for container images
- IAM roles with necessary permissions
- CloudWatch logging (7-day retention)

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5.0 installed
- Docker for building and pushing container images
- AWS account with Bedrock AgentCore access

## Quick Start

### 1. Prepare Your Container

```bash
# Build your agent container
docker build -t my-agent:latest .

# Tag for ECR
docker tag my-agent:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-agent:latest

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Push to ECR
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-agent:latest
```

### 2. Deploy the Infrastructure

```bash
# Initialize Terraform
terraform init

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. Test Your Agent

```bash
# Get the agent runtime ID
RUNTIME_ID=$(terraform output -raw agent_runtime_ids | jq -r '.["customer-service"]')

# Invoke the agent using AWS CLI
aws bedrock-agentcore invoke-agent-runtime \
  --agent-runtime-arn "arn:aws:bedrock-agentcore:us-east-1:123456789012:agent-runtime/${RUNTIME_ID}" \
  --runtime-session-id "test-session-$(date +%s)" \
  --payload '{"prompt": "Hello, how can you help me?"}'
```

## Configuration

### Required Variables

```hcl
client      = "your-client-name"
project     = "your-project-name"
environment = "dev"  # or staging, prod
```

### Agent Runtime Configuration

```hcl
agent_runtimes = {
  my-agent = {
    description   = "My AI agent"
    container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-agent:latest"
    network_mode  = "PUBLIC"
    protocol      = "MCP"

    environment_variables = {
      LOG_LEVEL = "INFO"
    }
  }
}
```

## Outputs

- `agent_runtime_ids` - Map of agent runtime names to IDs
- `agent_runtime_arns` - Map of agent runtime names to ARNs
- `endpoint_arns` - Map of endpoint ARNs
- `ecr_repository_url` - ECR repository URL

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

## Next Steps

- Review the [complete example](../complete/) for advanced features
- Check the [sample implementation](../../sample/) for production patterns
- Read the [main documentation](../../README.md) for detailed information

## Cost Estimation

This basic example will incur costs for:
- Bedrock AgentCore Runtime (consumption-based)
- ECR storage (minimal)
- CloudWatch Logs (7-day retention)

Estimated monthly cost: $10-50 depending on usage
