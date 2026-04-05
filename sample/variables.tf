# ============================================================================
# Sample Implementation - Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.aws_region))
    error_message = "aws_region must be a valid AWS region format."
  }
}

variable "client" {
  description = "Client name for resource naming and tagging"
  type        = string

  validation {
    condition     = length(var.client) > 0
    error_message = "Client name must not be empty."
  }
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string

  validation {
    condition     = length(var.project) > 0
    error_message = "Project name must not be empty."
  }
}

variable "environment" {
  description = "Environment name (dev, qa, pdn)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "Environment must be one of: dev, qa, pdn."
  }
}

variable "agent_runtimes" {
  description = "Agent runtimes configuration. role_arn can be empty to be injected from data source."
  type = map(object({
    description      = optional(string, "Bedrock AgentCore Runtime")
    container_uri    = optional(string)
    role_arn         = optional(string, "")
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

    allowed_headers  = optional(list(string))
    additional_tags  = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for k, v in var.agent_runtimes :
      v.container_uri != null || v.code_configuration != null
    ])
    error_message = "Each agent runtime must have either container_uri or code_configuration."
  }
}

variable "enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true

  validation {
    condition     = var.enable_logging == true || var.enable_logging == false
    error_message = "enable_logging must be a boolean value."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731,
      1096, 1827, 2192, 2557, 2922, 3288, 3653, 0
    ], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch logs retention period."
  }
}

variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}

  validation {
    condition = !contains(keys(var.additional_tags), "Name")
    error_message = "Name tag is automatically managed."
  }
}
