# ============================================================================
# Sample Implementation - Outputs
# ============================================================================

output "agent_runtime_ids" {
  description = "Agent runtime IDs"
  value       = module.bedrock_agentcore.agent_runtime_ids
}

output "agent_runtime_arns" {
  description = "Agent runtime ARNs"
  value       = module.bedrock_agentcore.agent_runtime_arns
}

output "agent_runtime_versions" {
  description = "Agent runtime versions"
  value       = module.bedrock_agentcore.agent_runtime_versions
}

output "endpoint_arns" {
  description = "Agent runtime endpoint ARNs"
  value       = module.bedrock_agentcore.endpoint_arns
}

output "agent_runtime_configurations" {
  description = "Complete agent runtime configurations summary"
  value       = module.bedrock_agentcore.agent_runtime_configurations
}
