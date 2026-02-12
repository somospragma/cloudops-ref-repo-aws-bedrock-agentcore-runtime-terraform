# ============================================================================
# Amazon Bedrock AgentCore Runtime - Main Resources
# ============================================================================

# Agent Runtime
resource "aws_bedrockagentcore_agent_runtime" "this" {
  for_each = var.agent_runtimes

  agent_runtime_name = replace("${local.name_prefix}-agentcore-${each.key}", "-", "_")
  description        = each.value.description
  role_arn           = each.value.role_arn != null ? each.value.role_arn : aws_iam_role.agent_runtime[each.key].arn

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
  dynamic "lifecycle_configuration" {
    for_each = each.value.lifecycle_config != null ? [each.value.lifecycle_config] : []
    content {
      idle_runtime_session_timeout = lifecycle_configuration.value.idle_timeout
      max_lifetime                 = lifecycle_configuration.value.max_lifetime
    }
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

  #tags = local.agent_runtime_tags[each.key]

  provider = aws.project
}

# Agent Runtime Endpoints
resource "aws_bedrockagentcore_agent_runtime_endpoint" "this" {
  for_each = {
    for key, config in var.agent_runtimes : key => config
    if config.create_endpoint
  }

  name                   = replace("${local.name_prefix}-endpoint-${each.key}", "-", "_")
  agent_runtime_id       = aws_bedrockagentcore_agent_runtime.this[each.key].agent_runtime_id
  agent_runtime_version  = each.value.endpoint_version
  description            = "Endpoint for ${each.key} agent runtime"

  #tags = local.agent_runtime_tags[each.key]

  provider = aws.project
}

# IAM Role for Agent Runtime
resource "aws_iam_role" "agent_runtime" {
  for_each = {
    for key, config in var.agent_runtimes : key => config
    if config.role_arn == null
  }

  name = "${local.name_prefix}-agentcore-role-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "bedrock-agentcore.amazonaws.com"
        }
      }
    ]
  })

  #tags = local.agent_runtime_tags[each.key]

  provider = aws.project
}

# IAM Policy for Agent Runtime
resource "aws_iam_role_policy" "agent_runtime" {
  for_each = {
    for key, config in var.agent_runtimes : key => config
    if config.role_arn == null
  }

  name = "${local.name_prefix}-agentcore-policy-${each.key}"
  role = aws_iam_role.agent_runtime[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "logs:DescribeLogStreams",
            "logs:CreateLogGroup"
          ]
          Resource = [
            "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtimes/*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "logs:DescribeLogGroups"
          ]
          Resource = [
            "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          ]
        },
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = [
            "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtimes/*:log-stream:*"
          ]
        },
        {
          Effect = "Allow"
          Resource = "*"
          Action = "cloudwatch:PutMetricData"
          Condition = {
            StringEquals = {
              "cloudwatch:namespace": "bedrock-agentcore"
            }
          }
        },
        {
          Effect = "Allow" 
          Action = [ 
            "xray:PutTraceSegments", 
            "xray:PutTelemetryRecords", 
            "xray:GetSamplingRules", 
            "xray:GetSamplingTargets"
          ]
          Resource = "*" 
        },
        {
          Effect = "Allow"
          Action = [
            "bedrock-agentcore:GetWorkloadAccessToken",
            "bedrock-agentcore:GetWorkloadAccessTokenForJWT",
            "bedrock-agentcore:GetWorkloadAccessTokenForUserId"
          ]
          Resource = [
            "arn:${data.aws_partition.current.partition}:bedrock-agentcore:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workload-identity-directory/default",
            "arn:${data.aws_partition.current.partition}:bedrock-agentcore:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:workload-identity-directory/default/workload-identity/agentName-*"
          ]
        },
        {
          Effect = "Allow" 
          Action = [ 
            "bedrock:InvokeModel", 
            "bedrock:InvokeModelWithResponseStream"
          ], 
          Resource = [
            "arn:${data.aws_partition.current.partition}:bedrock:*::foundation-model/*",
            "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          ]
        }
      ],
      (each.value.container_uri != null ? 
        [
          {
            Effect = "Allow"
            Action = [
              "ecr:GetAuthorizationToken"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "ecr:BatchGetImage",
              "ecr:GetDownloadUrlForLayer"
            ]
            Resource = "arn:${data.aws_partition.current.partition}:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
          }
        ] : 
        []),
      (each.value.code_configuration != null ? 
        [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:GetObjectVersion"
            ]
            Resource = "arn:${data.aws_partition.current.partition}:s3:::${each.value.code_configuration.s3_bucket}/${each.value.code_configuration.s3_prefix}"
          }
        ] : 
        [])
    )
  })

  provider = aws.project
}

# ============================================================================
# CloudWatch Log Groups for Agent Runtimes
# ============================================================================

resource "aws_cloudwatch_log_group" "agent_runtime" {
  for_each = var.enable_logging ? var.agent_runtimes : {}

  name              = "/aws/bedrock-agentcore/runtimes/${aws_bedrockagentcore_agent_runtime.this[each.key].agent_runtime_id}-${replace("${local.name_prefix}-endpoint-${each.key}", "-", "_")}/runtime-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_id

  provider = aws.project
}

# ============================================================================
# CloudWatch Log Delivery Configuration
# ============================================================================

# Log Delivery Destination for CloudWatch Logs
resource "aws_cloudwatch_log_delivery_destination" "agent_runtime" {
  for_each = var.enable_logging ? var.agent_runtimes : {}

  name = "${local.name_prefix}-agentcore-${each.key}-destination"

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.agent_runtime[each.key].arn
  }

  output_format = "json"

  provider = aws.project
}

# Log Delivery Source for Agent Runtime - Application Logs
resource "aws_cloudwatch_log_delivery_source" "agent_runtime_application" {
  for_each = var.enable_logging && var.enable_application_logs ? var.agent_runtimes : {}

  name         = "${local.name_prefix}-agentcore-${each.key}-app-logs"
  log_type     = "APPLICATION_LOGS"
  resource_arn = aws_bedrockagentcore_agent_runtime.this[each.key].agent_runtime_arn

  provider = aws.project
}

# Log Delivery Source for Agent Runtime - Usage Logs
resource "aws_cloudwatch_log_delivery_source" "agent_runtime_usage" {
  for_each = var.enable_logging && var.enable_usage_logs ? var.agent_runtimes : {}

  name         = "${local.name_prefix}-agentcore-${each.key}-usage-logs"
  log_type     = "USAGE_LOGS"
  resource_arn = aws_bedrockagentcore_agent_runtime.this[each.key].agent_runtime_arn

  provider = aws.project
}

# Log Delivery Connection - Application Logs
resource "aws_cloudwatch_log_delivery" "agent_runtime_application" {
  for_each = var.enable_logging && var.enable_application_logs ? var.agent_runtimes : {}

  delivery_source_name      = aws_cloudwatch_log_delivery_source.agent_runtime_application[each.key].name
  delivery_destination_arn  = aws_cloudwatch_log_delivery_destination.agent_runtime[each.key].arn

  provider = aws.project
}

# Log Delivery Connection - Usage Logs
resource "aws_cloudwatch_log_delivery" "agent_runtime_usage" {
  for_each = var.enable_logging && var.enable_usage_logs ? var.agent_runtimes : {}

  delivery_source_name      = aws_cloudwatch_log_delivery_source.agent_runtime_usage[each.key].name
  delivery_destination_arn  = aws_cloudwatch_log_delivery_destination.agent_runtime[each.key].arn

  provider = aws.project
}

# ============================================================================
# X-Ray Tracing Configuration
# ============================================================================

# X-Ray Sampling Rule for Agent Runtimes
resource "aws_xray_sampling_rule" "agent_runtime" {
  count = var.enable_tracing ? 1 : 0

  rule_name      = "${local.name_prefix}-agentcore-sampling"
  priority       = 1000
  version        = 1
  reservoir_size = 1
  fixed_rate     = var.xray_sampling_rate
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "bedrock-agentcore"
  resource_arn   = "*"

  provider = aws.project
}
