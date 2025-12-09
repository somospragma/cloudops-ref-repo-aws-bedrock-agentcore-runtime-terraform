# ============================================================================
# Complete Example - Amazon Bedrock AgentCore Runtime
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
      Example   = "complete"
    }
  }
}

# KMS Key for Encryption
resource "aws_kms_key" "agentcore" {
  description             = "KMS key for Bedrock AgentCore encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "${var.client}-${var.project}-${var.environment}-agentcore-key"
  }
}

resource "aws_kms_alias" "agentcore" {
  name          = "alias/${var.client}-${var.project}-${var.environment}-agentcore"
  target_key_id = aws_kms_key.agentcore.key_id
}

# VPC for Private Agent Runtime
resource "aws_vpc" "agentcore" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.client}-${var.project}-${var.environment}-agentcore-vpc"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.agentcore.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.client}-${var.project}-${var.environment}-private-${count.index + 1}"
    Type = "private"
  }
}

resource "aws_security_group" "agentcore" {
  name_prefix = "${var.client}-${var.project}-${var.environment}-agentcore-"
  vpc_id      = aws_vpc.agentcore.id
  description = "Security group for Bedrock AgentCore Runtime"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.client}-${var.project}-${var.environment}-agentcore-sg"
  }
}

# ECR Repositories
resource "aws_ecr_repository" "agents" {
  for_each = toset(["public-agent", "private-agent", "secure-agent"])

  name = "${var.client}-${var.project}-${var.environment}-${each.key}"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.agentcore.arn
  }

  tags = {
    Name = "${var.client}-${var.project}-${var.environment}-${each.key}"
  }
}

# S3 Bucket for Code Deployment
resource "aws_s3_bucket" "agent_code" {
  bucket = "${var.client}-${var.project}-${var.environment}-agent-code"

  tags = {
    Name = "${var.client}-${var.project}-${var.environment}-agent-code"
  }
}

resource "aws_s3_bucket_versioning" "agent_code" {
  bucket = aws_s3_bucket.agent_code.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "agent_code" {
  bucket = aws_s3_bucket.agent_code.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.agentcore.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "agent_code" {
  bucket = aws_s3_bucket.agent_code.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bedrock AgentCore Runtime Module
module "bedrock_agentcore" {
  source = "../../"

  client      = var.client
  project     = var.project
  environment = var.environment

  agent_runtimes = {
    public-agent = {
      description   = "Public-facing AI agent with MCP protocol"
      container_uri = "${aws_ecr_repository.agents["public-agent"].repository_url}:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      environment_variables = {
        LOG_LEVEL   = "INFO"
        ENVIRONMENT = "production"
        MODEL_ID    = "anthropic.claude-3-sonnet-20240229-v1:0"
      }

      lifecycle_config = {
        idle_timeout = 1800  # 30 minutes
        max_lifetime = 14400 # 4 hours
      }
    }

    private-agent = {
      description  = "Private AI agent in VPC"
      container_uri = "${aws_ecr_repository.agents["private-agent"].repository_url}:latest"
      network_mode = "VPC"
      protocol     = "HTTP"

      vpc_config = {
        security_groups = [aws_security_group.agentcore.id]
        subnets         = aws_subnet.private[*].id
      }

      environment_variables = {
        LOG_LEVEL        = "DEBUG"
        DATABASE_ENABLED = "true"
      }
    }

    secure-agent = {
      description   = "Secure AI agent with JWT authorization"
      container_uri = "${aws_ecr_repository.agents["secure-agent"].repository_url}:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      jwt_authorizer = {
        discovery_url    = var.jwt_discovery_url
        allowed_audience = var.jwt_allowed_audience
        allowed_clients  = var.jwt_allowed_clients
      }

      environment_variables = {
        LOG_LEVEL    = "INFO"
        AUTH_ENABLED = "true"
      }

      allowed_headers = ["X-Custom-Header", "X-Request-ID"]
    }

    python-agent = {
      description  = "Python-based AI agent from S3"
      network_mode = "PUBLIC"
      protocol     = "MCP"

      code_configuration = {
        entry_point   = ["main.py"]
        runtime       = "PYTHON_3_13"
        s3_bucket     = aws_s3_bucket.agent_code.id
        s3_prefix     = "agents/python-agent.zip"
      }

      environment_variables = {
        PYTHON_ENV = "production"
      }
    }
  }

  enable_logging     = true
  log_retention_days = 90
  kms_key_id         = aws_kms_key.agentcore.id

  additional_tags = {
    CostCenter  = "AI-Platform"
    Owner       = "AI-Team"
    Compliance  = "SOC2"
    Environment = var.environment
  }

  providers = {
    aws.project = aws.project
  }
}

# Data Sources
data "aws_availability_zones" "available" {
  state = "available"
}
