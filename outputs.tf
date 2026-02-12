# ============================================================================
# Amazon Bedrock AgentCore Runtime - Outputs
# ============================================================================

output "agent_runtime_ids" {
  description = "Map of agent runtime names to their IDs. Use these IDs to reference the runtimes in other resources or modules"
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => runtime.agent_runtime_id
  }
}

output "agent_runtime_arns" {
  description = "Map of agent runtime names to their ARNs. Use these ARNs for IAM policies and cross-service references"
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => runtime.agent_runtime_arn
  }
}

output "agent_runtime_versions" {
  description = "Map of agent runtime names to their versions. Use for version tracking and deployment management"
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => runtime.agent_runtime_version
  }
}

output "endpoint_arns" {
  description = "Map of agent runtime names to their endpoint ARNs. Use for network access configuration and routing"
  value = {
    for key, endpoint in aws_bedrockagentcore_agent_runtime_endpoint.this : key => endpoint.agent_runtime_endpoint_arn
  }
}

output "workload_identity_arns" {
  description = "Map of agent runtime names to their workload identity ARNs. Use for cross-account access and identity federation"
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => try(runtime.workload_identity_details[0].workload_identity_arn, null)
  }
}

output "iam_role_arns" {
  description = "Map of agent runtime names to their IAM role ARNs. Use for permission management and policy attachment"
  value = {
    for key, role in aws_iam_role.agent_runtime : key => role.arn
  }
}

output "iam_role_names" {
  description = "Map of agent runtime names to their IAM role names. Use for role reference and policy management"
  value = {
    for key, role in aws_iam_role.agent_runtime : key => role.name
  }
}

output "agent_runtime_configurations" {
  description = <<-EOT
    Complete configuration summary for all created agent runtimes.
    Includes all relevant information for integration with other modules or resources.
    
    Structure:
    {
      runtime_key = {
        id                    = "runtime-id"
        arn                   = "runtime-arn"
        version               = "version"
        endpoint_arn          = "endpoint-arn"
        workload_identity_arn = "identity-arn"
        role_arn              = "role-arn"
        network_mode          = "PUBLIC/VPC"
        protocol              = "MCP/HTTP/A2A"
        tags                  = { tag_key = "tag_value" }
      }
    }
  EOT
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => {
      id                    = runtime.agent_runtime_id
      arn                   = runtime.agent_runtime_arn
      version               = runtime.agent_runtime_version
      endpoint_arn          = try(aws_bedrockagentcore_agent_runtime_endpoint.this[key].agent_runtime_endpoint_arn, null)
      workload_identity_arn = try(runtime.workload_identity_details[0].workload_identity_arn, null)
      role_arn              = runtime.role_arn
      network_mode          = var.agent_runtimes[key].network_mode
      protocol              = var.agent_runtimes[key].protocol
      tags                  = runtime.tags_all
    }
  }
}

output "log_group_names" {
  description = "Map of agent runtime names to their CloudWatch log group names. Use for log queries and monitoring"
  value = {
    for key, lg in aws_cloudwatch_log_group.agent_runtime : key => lg.name
  }
}

output "log_group_arns" {
  description = "Map of agent runtime names to their CloudWatch log group ARNs. Use for IAM policies and cross-service references"
  value = {
    for key, lg in aws_cloudwatch_log_group.agent_runtime : key => lg.arn
  }
}

output "log_delivery_ids" {
  description = "Map of agent runtime names to their log delivery IDs for application logs"
  value = {
    for key, ld in aws_cloudwatch_log_delivery.agent_runtime_application : key => ld.id
  }
}

output "xray_sampling_rule_arn" {
  description = "ARN of the X-Ray sampling rule for agent runtimes. Use for X-Ray configuration and monitoring"
  value       = try(aws_xray_sampling_rule.agent_runtime[0].arn, null)
}

output "observability_configuration" {
  description = <<-EOT
    Complete observability configuration for all agent runtimes.
    Includes log groups, delivery configurations, and tracing settings.
    
    Structure:
    {
      runtime_key = {
        log_group_name = "log-group-name"
        log_group_arn  = "log-group-arn"
        application_logs_enabled = true/false
        usage_logs_enabled = true/false
        tracing_enabled = true/false
      }
    }
  EOT
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => {
      log_group_name           = try(aws_cloudwatch_log_group.agent_runtime[key].name, null)
      log_group_arn            = try(aws_cloudwatch_log_group.agent_runtime[key].arn, null)
      application_logs_enabled = var.enable_logging && var.enable_application_logs
      usage_logs_enabled       = var.enable_logging && var.enable_usage_logs
      tracing_enabled          = var.enable_tracing
      xray_sampling_rate       = var.xray_sampling_rate
    }
  }
}
