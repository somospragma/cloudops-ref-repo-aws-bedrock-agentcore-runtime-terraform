# ============================================================================
# Basic Example - Outputs
# ============================================================================

output "agent_runtime_ids" {
  description = "Agent runtime IDs"
  value       = module.bedrock_agentcore.agent_runtime_ids
}

output "agent_runtime_arns" {
  description = "Agent runtime ARNs"
  value       = module.bedrock_agentcore.agent_runtime_arns
}

output "endpoint_arns" {
  description = "Agent runtime endpoint ARNs"
  value       = module.bedrock_agentcore.endpoint_arns
}

output "ecr_repository_url" {
  description = "ECR repository URL for agent container"
  value       = aws_ecr_repository.agent.repository_url
}
