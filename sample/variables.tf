# ============================================================================
# Sample Implementation - Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "client" {
  description = "Client name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
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
      entry_point   = list(string)
      runtime       = string
      s3_bucket     = string
      s3_prefix     = string
      s3_version_id = optional(string)
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
}

variable "enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
