# ============================================================================
# Basic Example - Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "client" {
  description = "Client name"
  type        = string
  default     = "acme"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ai-platform"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "agent_runtimes" {
  description = "Agent runtimes configuration"
  type = map(object({
    description      = optional(string, "Bedrock AgentCore Runtime")
    container_uri    = optional(string)
    role_arn         = optional(string)
    network_mode     = optional(string, "PUBLIC")
    protocol         = optional(string, "MCP")
    create_endpoint  = optional(bool, true)
    endpoint_version = optional(string)

    code_configuration = optional(object({
      entry_point    = list(string)
      runtime        = string
      s3_bucket      = string
      s3_prefix      = string
      s3_version_id  = optional(string)
    }))

    vpc_config = optional(object({
      security_groups = list(string)
      subnets         = list(string)
    }))

    environment_variables = optional(map(string), {})

    jwt_authorizer = optional(object({
      discovery_url    = string
      allowed_audience = optional(list(string))
      allowed_clients  = optional(list(string))
    }))

    lifecycle_config = optional(object({
      idle_timeout = optional(number, 900)
      max_lifetime = optional(number, 28800)
    }))

    allowed_headers = optional(list(string))
  }))
  default = {
    basic-agent = {
      description   = "Basic AI agent runtime"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/agent:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      environment_variables = {
        LOG_LEVEL = "INFO"
      }
    }
  }
}
