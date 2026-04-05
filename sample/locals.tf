# ============================================================================
# Sample Implementation - Local Values and Transformations
# ============================================================================
# PC-IAC-026: Transformaciones del ejemplo en locals.tf.
# PC-IAC-009: Inyección dinámica de IDs desde data sources.
# PC-IAC-025: Construcción de nomenclatura en el Root.
# ============================================================================

locals {
  # Prefijo de gobernanza (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Transformar configuración inyectando role_arn desde data source (PC-IAC-009)
  agent_runtimes_transformed = {
    for key, config in var.agent_runtimes : key => merge(config, {
      # Si role_arn está vacío, inyectar desde data source
      role_arn = length(config.role_arn) > 0 ? config.role_arn : data.aws_iam_role.agentcore.arn
    })
  }
}
