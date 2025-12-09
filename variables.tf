# ============================================================================
# Amazon Bedrock AgentCore Runtime - Variables
# ============================================================================

# Required Variables
variable "client" {
  description = "Client name for resource naming and tagging. Used as part of the naming convention: {client}-{project}-{environment}-{resource}"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.client))
    error_message = "Client name must be 2-20 characters, lowercase letters, numbers, and hyphens only."
  }

  validation {
    condition     = !can(regex("^-|-$", var.client))
    error_message = "Client name cannot start or end with a hyphen."
  }
}

variable "project" {
  description = "Project name for resource naming and tagging. Used as part of the naming convention: {client}-{project}-{environment}-{resource}"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,30}$", var.project))
    error_message = "Project name must be 2-30 characters, lowercase letters, numbers, and hyphens only."
  }

  validation {
    condition = !contains([
      "aws", "amazon", "bedrock", "agentcore", "runtime"
    ], var.project)
    error_message = "Project name cannot be a reserved AWS service name."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod). Used for resource naming, tagging, and environment-specific configurations"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# Agent Runtimes Configuration
variable "agent_runtimes" {
  description = "Map of Bedrock AgentCore Runtimes to create with detailed configuration options"
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
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.agent_runtimes : can(regex("^[a-z0-9-]{3,63}$", k))
    ])
    error_message = "Agent runtime keys must be 3-63 characters, lowercase letters, numbers, and hyphens only."
  }

  validation {
    condition = alltrue([
      for k, v in var.agent_runtimes :
      v.container_uri != null || v.code_configuration != null
    ])
    error_message = "Each agent runtime must have either container_uri or code_configuration specified."
  }

  validation {
    condition = alltrue([
      for k, v in var.agent_runtimes :
      contains(["PUBLIC", "VPC"], v.network_mode)
    ])
    error_message = "Network mode must be either PUBLIC or VPC."
  }

  validation {
    condition = alltrue([
      for k, v in var.agent_runtimes :
      v.protocol == null || contains(["HTTP", "MCP", "A2A"], v.protocol)
    ])
    error_message = "Protocol must be one of: HTTP, MCP, A2A."
  }

  validation {
    condition = alltrue([
      for k, v in var.agent_runtimes :
      v.network_mode != "VPC" || v.vpc_config != null
    ])
    error_message = "VPC configuration is required when network_mode is VPC."
  }

  validation {
    condition = alltrue([
      for k, v in var.agent_runtimes :
      v.code_configuration == null || contains(["PYTHON_3_10", "PYTHON_3_11", "PYTHON_3_12", "PYTHON_3_13"], v.code_configuration.runtime)
    ])
    error_message = "Code runtime must be one of: PYTHON_3_10, PYTHON_3_11, PYTHON_3_12, PYTHON_3_13."
  }

  validation {
    condition = alltrue([
      for k, v in var.agent_runtimes :
      v.lifecycle_config == null || (
        v.lifecycle_config.idle_timeout >= 60 &&
        v.lifecycle_config.idle_timeout <= 28800 &&
        v.lifecycle_config.max_lifetime >= 60 &&
        v.lifecycle_config.max_lifetime <= 28800 &&
        v.lifecycle_config.idle_timeout <= v.lifecycle_config.max_lifetime
      )
    ])
    error_message = "Lifecycle timeouts must be between 60 and 28800 seconds, and idle_timeout must be <= max_lifetime."
  }
}

# Additional Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources beyond the base tags"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.additional_tags : can(regex("^[A-Za-z0-9+\\-=._:/@]{1,128}$", k))
    ])
    error_message = "Tag keys must be 1-128 characters and contain only valid characters."
  }

  validation {
    condition = alltrue([
      for k, v in var.additional_tags : can(regex("^[A-Za-z0-9+\\-=._:/@\\s]{0,256}$", v))
    ])
    error_message = "Tag values must be 0-256 characters and contain only valid characters."
  }

  validation {
    condition = !contains(keys(var.additional_tags), "Name")
    error_message = "Name tag is automatically managed and cannot be overridden."
  }
}

# Encryption Configuration
variable "enable_encryption" {
  description = "Enable encryption for all resources (always true for security compliance)"
  type        = bool
  default     = true

  validation {
    condition     = var.enable_encryption == true
    error_message = "Encryption must be enabled for security compliance."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (optional, uses AWS managed key if not provided)"
  type        = string
  default     = null
}

# Logging Configuration
variable "enable_logging" {
  description = "Enable CloudWatch logging for agent runtimes"
  type        = bool
  default     = true
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
