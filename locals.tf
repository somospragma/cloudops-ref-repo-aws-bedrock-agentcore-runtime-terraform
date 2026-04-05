# ============================================================================
# Amazon Bedrock AgentCore Runtime - Local Values
# ============================================================================
# PC-IAC-003: Construcción centralizada de nomenclatura.
# PC-IAC-012: Bloque locals único con prefijo de gobernanza reutilizable.
# ============================================================================

locals {
  # Prefijo de gobernanza (PC-IAC-003 Sec. 3.1)
  name_prefix = "${var.client}-${var.project}-${var.environment}"

  # Tags base del módulo (PC-IAC-004 Sec. 3.2)
  base_tags = {
    Client      = var.client
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Service     = "bedrock-agentcore"
  }
}
