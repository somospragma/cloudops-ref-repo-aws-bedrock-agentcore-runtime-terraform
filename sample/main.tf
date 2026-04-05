# ============================================================================
# Sample Implementation - Module Invocation
# ============================================================================
# PC-IAC-026: main.tf solo contiene la invocación del módulo padre.
# PC-IAC-013: Orden obligatorio (source, providers, gobernanza, config).
# ============================================================================

module "bedrock_agentcore" {
  # A. Fuente del Módulo
  source = "../"

  # B. Providers (PC-IAC-005)
  providers = {
    aws.project = aws.principal
  }

  # C. Variables de Gobernanza (PC-IAC-003)
  client      = var.client
  project     = var.project
  environment = var.environment

  # E. Variables de Configuración - consumir local transformado (PC-IAC-026)
  agent_runtimes = local.agent_runtimes_transformed

  enable_logging     = var.enable_logging
  log_retention_days = var.log_retention_days
  additional_tags    = var.additional_tags
}
