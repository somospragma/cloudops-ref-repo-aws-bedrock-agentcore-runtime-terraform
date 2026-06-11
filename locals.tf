# ============================================================================
# Amazon Bedrock AgentCore Runtime - Local Values
# ============================================================================
# PC-IAC-003: Construcción centralizada de nomenclatura.
# PC-IAC-012: Bloque locals único con prefijo de gobernanza reutilizable.
# ============================================================================

locals {
  # Prefijo de gobernanza (PC-IAC-003 Sec. 3.1)
  name_prefix = "${var.client}-${var.project}-${var.environment}"

  # Prefijo de ruta para log groups de AgentCore Runtime
  log_group_prefix = "/aws/bedrock-agentcore/runtimes"

  # Nombres de endpoints con transformación requerida por API AWS
  # agentRuntimeEndpoint name solo acepta [a-zA-Z][a-zA-Z0-9_]{0,47}
  endpoint_names = {
    for key, config in var.agent_runtimes : key => replace("${local.name_prefix}-endpoint-${key}", "-", "_")
  }
}
