# ============================================================================
# Basic Example - Amazon Bedrock AgentCore Runtime
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.24.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "project"
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Example   = "basic"
    }
  }
}

# ECR Repository for Agent Container
resource "aws_ecr_repository" "agent" {
  name = "${var.client}-${var.project}-${var.environment}-agent-runtime"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.client}-${var.project}-${var.environment}-agent-runtime"
  }
}

# Bedrock AgentCore Runtime Module
module "bedrock_agentcore" {
  source = "../../"

  client      = var.client
  project     = var.project
  environment = var.environment

  agent_runtimes = var.agent_runtimes

  enable_logging     = true
  log_retention_days = 7

  providers = {
    aws.project = aws.project
  }
}
