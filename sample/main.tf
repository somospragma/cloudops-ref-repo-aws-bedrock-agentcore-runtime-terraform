# ============================================================================
# Sample Implementation - Amazon Bedrock AgentCore Runtime
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
      Sample    = "bedrock-agentcore"
    }
  }
}

# Bedrock AgentCore Runtime Module
module "bedrock_agentcore" {
  source = "../"

  client      = var.client
  project     = var.project
  environment = var.environment

  agent_runtimes = var.agent_runtimes

  enable_logging     = var.enable_logging
  log_retention_days = var.log_retention_days

  additional_tags = var.additional_tags

  providers = {
    aws.project = aws.project
  }
}
