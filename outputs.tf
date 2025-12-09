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
