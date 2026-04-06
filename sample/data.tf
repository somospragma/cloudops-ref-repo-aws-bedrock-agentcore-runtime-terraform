# ============================================================================
# Sample Implementation - Data Sources
# ============================================================================
# PC-IAC-011: Data sources para obtener IDs dinámicos de recursos existentes.
# PC-IAC-017: Búsqueda por tags de nomenclatura estándar.
# ============================================================================

# Obtener IAM Role para AgentCore por nomenclatura estándar
data "aws_iam_role" "agentcore" {
  provider = aws.principal
  name     = "${var.client}-${var.project}-${var.environment}-agentcore-role"
}
