# ============================================================================
# Amazon Bedrock AgentCore Runtime - Outputs
# ============================================================================
# PC-IAC-007: Outputs granulares (IDs, ARNs) con description obligatorio.
# PC-IAC-014: Uso de for expressions para extracción de colecciones.
# ============================================================================

output "agent_runtime_ids" {
  description = "Map of agent runtime names to their IDs."
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => runtime.agent_runtime_id
  }
}

output "agent_runtime_arns" {
  description = "Map of agent runtime names to their ARNs."
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => runtime.agent_runtime_arn
  }
}

output "agent_runtime_versions" {
  description = "Map of agent runtime names to their versions."
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => runtime.agent_runtime_version
  }
}

output "endpoint_arns" {
  description = "Map of agent runtime names to their endpoint ARNs."
  value = {
    for key, endpoint in aws_bedrockagentcore_agent_runtime_endpoint.this : key => endpoint.agent_runtime_endpoint_arn
  }
}

output "workload_identity_arns" {
  description = "Map of agent runtime names to their workload identity ARNs."
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => try(runtime.workload_identity_details[0].workload_identity_arn, null)
  }
}

output "agent_runtime_configurations" {
  description = "Summary map of agent runtime IDs, ARNs, versions, and endpoint ARNs."
  value = {
    for key, runtime in aws_bedrockagentcore_agent_runtime.this : key => {
      id           = runtime.agent_runtime_id
      arn          = runtime.agent_runtime_arn
      version      = runtime.agent_runtime_version
      endpoint_arn = try(aws_bedrockagentcore_agent_runtime_endpoint.this[key].agent_runtime_endpoint_arn, null)
    }
  }
}
