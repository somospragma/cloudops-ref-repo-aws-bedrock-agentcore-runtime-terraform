# ============================================================================
# Amazon Bedrock AgentCore Runtime - Main Resources
# ============================================================================
# PC-IAC-023: Solo recursos intrínsecos al servicio AgentCore.
# Los roles IAM deben ser creados en el dominio de Seguridad e inyectados
# mediante la variable role_arn en cada entrada de agent_runtimes.
# ============================================================================

# Agent Runtime
resource "aws_bedrockagentcore_agent_runtime" "this" {
  for_each = var.agent_runtimes

  # PC-IAC-003: Nomenclatura estándar con replace por restricción de API AWS.
  # agentRuntimeName solo acepta [a-zA-Z][a-zA-Z0-9_]{0,47}
  agent_runtime_name = replace("${local.name_prefix}-agentcore-${each.key}", "-", "_")
  description        = each.value.description
  role_arn           = each.value.role_arn

  # Agent Runtime Artifact Configuration
  agent_runtime_artifact {
    dynamic "container_configuration" {
      for_each = each.value.container_uri != null ? [1] : []
      content {
        container_uri = each.value.container_uri
      }
    }

    dynamic "code_configuration" {
      for_each = each.value.code_configuration != null ? [each.value.code_configuration] : []
      content {
        entry_point = code_configuration.value.entry_point
        runtime     = code_configuration.value.runtime

        code {
          s3 {
            bucket     = code_configuration.value.s3_bucket
            prefix     = code_configuration.value.s3_prefix
            version_id = code_configuration.value.s3_version_id
          }
        }
      }
    }
  }

  # Network Configuration
  network_configuration {
    network_mode = each.value.network_mode

    dynamic "network_mode_config" {
      for_each = each.value.network_mode == "VPC" && each.value.vpc_config != null ? [each.value.vpc_config] : []
      content {
        security_groups = network_mode_config.value.security_groups
        subnets         = network_mode_config.value.subnets
      }
    }
  }

  # Environment Variables
  environment_variables = each.value.environment_variables

  # Authorization Configuration
  dynamic "authorizer_configuration" {
    for_each = each.value.jwt_authorizer != null ? [each.value.jwt_authorizer] : []
    content {
      custom_jwt_authorizer {
        discovery_url    = authorizer_configuration.value.discovery_url
        allowed_audience = authorizer_configuration.value.allowed_audience
        allowed_clients  = authorizer_configuration.value.allowed_clients
      }
    }
  }

  # Lifecycle Configuration
  lifecycle_configuration {
    idle_runtime_session_timeout = each.value.lifecycle_config.idle_timeout
    max_lifetime                 = each.value.lifecycle_config.max_lifetime
  }

  # Protocol Configuration
  dynamic "protocol_configuration" {
    for_each = each.value.protocol != null ? [1] : []
    content {
      server_protocol = each.value.protocol
    }
  }

  # Request Header Configuration
  dynamic "request_header_configuration" {
    for_each = each.value.allowed_headers != null ? [1] : []
    content {
      request_header_allowlist = each.value.allowed_headers
    }
  }

  # PC-IAC-004: Tag Name explícito + additional_tags.
  # Los tags transversales (Client, Project, Environment, ManagedBy) se
  # inyectan vía default_tags del provider desde el Root (PC-IAC-004 Sec. 2).
  tags = merge(
    { Name = "${local.name_prefix}-agentcore-${each.key}" },
    var.additional_tags
  )

  provider = aws.project
}

# Agent Runtime Endpoints
resource "aws_bedrockagentcore_agent_runtime_endpoint" "this" {
  for_each = {
    for key, config in var.agent_runtimes : key => config
    if config.create_endpoint
  }

  name                  = replace("${local.name_prefix}-endpoint-${each.key}", "-", "_")
  agent_runtime_id      = aws_bedrockagentcore_agent_runtime.this[each.key].agent_runtime_id
  agent_runtime_version = each.value.endpoint_version
  description           = "Endpoint for ${each.key} agent runtime"

  # PC-IAC-004: Tag Name explícito + additional_tags.
  tags = merge(
    { Name = "${local.name_prefix}-endpoint-${each.key}" },
    var.additional_tags
  )

  provider = aws.project
}
