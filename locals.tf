# ============================================================================
# Amazon Bedrock AgentCore Runtime - Local Values
# ============================================================================

locals {
  # Nomenclatura dinámica enterprise
  name_prefix = "${var.client}-${var.project}-${var.environment}"

  # Tags base obligatorios (Nivel 1)
  base_tags = {
    Client      = var.client
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Service     = "bedrock-agentcore"
  }

  # Tags específicos por agent runtime (Nivel 2)
  agent_runtime_tags = {
    for key, config in var.agent_runtimes : key => merge(
      local.base_tags,
      {
        Name        = "${local.name_prefix}-agentcore-${key}"
        Type        = "agent-runtime"
        NetworkMode = config.network_mode
        Protocol    = config.protocol
      },
      var.additional_tags
    )
  }
}
