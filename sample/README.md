# Sample Implementation - Bedrock AgentCore Runtime

## 📋 Overview

This sample demonstrates a production-ready implementation of Amazon Bedrock AgentCore Runtime with multiple agent configurations, comprehensive logging, and enterprise tagging.

## 🏗️ What This Sample Creates

- **Two Agent Runtimes**:
  - Customer Service Agent: Handles support inquiries with Claude 3 Sonnet
  - Data Analyst Agent: Performs advanced analytics with Claude 3 Opus
- **IAM Roles**: Automatically created with least-privilege policies
- **CloudWatch Logging**: 90-day retention for audit and debugging
- **Enterprise Tagging**: Cost center, owner, and compliance tags
- **Lifecycle Management**: Configurable session timeouts

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5.0 installed
- Docker for building and pushing container images
- AWS account with Bedrock AgentCore access
- ECR repositories created for agent containers

### Step 1: Prepare Your Agent Containers

```bash
# Build customer service agent
cd agents/customer-service
docker build -t customer-service-agent:v1.0 .

# Tag and push to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
docker tag customer-service-agent:v1.0 123456789012.dkr.ecr.us-east-1.amazonaws.com/customer-service-agent:v1.0
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/customer-service-agent:v1.0

# Repeat for data analyst agent
cd ../data-analyst
docker build -t data-analyst-agent:v1.0 .
docker tag data-analyst-agent:v1.0 123456789012.dkr.ecr.us-east-1.amazonaws.com/data-analyst-agent:v1.0
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/data-analyst-agent:v1.0
```

### Step 2: Deploy the Infrastructure

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

### Step 3: Test Your Agents

```bash
# Get agent runtime IDs
terraform output -json agent_runtime_ids

# Test customer service agent
aws bedrock-agentcore invoke-agent-runtime \
  --agent-runtime-arn "arn:aws:bedrock-agentcore:us-east-1:123456789012:agent-runtime/RUNTIME_ID" \
  --runtime-session-id "session-$(date +%s)" \
  --payload '{"prompt": "How can I reset my password?"}'

# Test data analyst agent
aws bedrock-agentcore invoke-agent-runtime \
  --agent-runtime-arn "arn:aws:bedrock-agentcore:us-east-1:123456789012:agent-runtime/RUNTIME_ID" \
  --runtime-session-id "session-$(date +%s)" \
  --payload '{"prompt": "Analyze the sales data for Q4 2024"}'
```

## ⚙️ Configuration

### Required Variables

```hcl
client      = "your-client-name"
project     = "your-project-name"
environment = "prod"  # or dev, staging
```

### Agent Runtimes Configuration

The sample includes two pre-configured agents:

1. **Customer Service Agent**
   - Model: Claude 3 Sonnet
   - Idle Timeout: 30 minutes
   - Max Lifetime: 4 hours
   - Use Case: Customer support inquiries

2. **Data Analyst Agent**
   - Model: Claude 3 Opus
   - Idle Timeout: 1 hour
   - Max Lifetime: 6 hours
   - Use Case: Advanced data analysis

### Environment Variables

Each agent can be configured with custom environment variables:

```hcl
environment_variables = {
  LOG_LEVEL        = "INFO"
  MODEL_ID         = "anthropic.claude-3-sonnet-20240229-v1:0"
  MAX_TOKENS       = "4096"
  TEMPERATURE      = "0.7"
  ENABLE_STREAMING = "true"
}
```

## 📊 Sample Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Applications                       │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
┌──────────────────┐    ┌──────────────────┐
│ Customer Service │    │  Data Analyst    │
│  Agent Runtime   │    │  Agent Runtime   │
│  (Claude Sonnet) │    │  (Claude Opus)   │
└────────┬─────────┘    └────────┬─────────┘
         │                       │
         └───────────┬───────────┘
                     ▼
         ┌───────────────────────┐
         │   CloudWatch Logs     │
         │   (90-day retention)  │
         └───────────────────────┘
```

## 🧪 Testing the Sample

### Test Customer Service Agent

```bash
# Interactive test
aws bedrock-agentcore invoke-agent-runtime \
  --agent-runtime-arn "$(terraform output -raw agent_runtime_arns | jq -r '.["customer-service"]')" \
  --runtime-session-id "test-$(uuidgen)" \
  --payload '{"prompt": "What are your business hours?"}'
```

### Test Data Analyst Agent

```bash
# Analytical query
aws bedrock-agentcore invoke-agent-runtime \
  --agent-runtime-arn "$(terraform output -raw agent_runtime_arns | jq -r '.["data-analyst"]')" \
  --runtime-session-id "test-$(uuidgen)" \
  --payload '{"prompt": "Calculate the average revenue per customer"}'
```

### Monitor Logs

```bash
# View CloudWatch logs
aws logs tail /aws/bedrock/agentcore/customer-service --follow

# View specific log stream
aws logs get-log-events \
  --log-group-name /aws/bedrock/agentcore/customer-service \
  --log-stream-name "stream-name"
```

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy

# Confirm destruction
# Type 'yes' when prompted
```

## 💰 Cost Estimation

This sample will incur costs for:

- **Bedrock AgentCore Runtime**: Consumption-based pricing
  - Estimated: $50-200/month depending on usage
- **CloudWatch Logs**: 90-day retention
  - Estimated: $5-20/month
- **ECR Storage**: Container images
  - Estimated: $1-5/month
- **Data Transfer**: Minimal for most use cases
  - Estimated: $1-10/month

**Total Estimated Monthly Cost**: $57-235

## 📚 Next Steps

- Customize agent configurations for your use case
- Add more agents for different purposes
- Implement VPC networking for private agents
- Add JWT authorization for secure access
- Integrate with your CI/CD pipeline
- Set up monitoring and alerting

## 🔗 Related Resources

- [Basic Example](../examples/basic/) - Simple deployment
- [Complete Example](../examples/complete/) - All features
- [Main Documentation](../README.md) - Full module documentation
- [AWS Bedrock AgentCore Docs](https://docs.aws.amazon.com/bedrock-agentcore/)
