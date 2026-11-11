# ============================================================================
# Amazon Bedrock AgentCore Runtime - Version Constraints
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # >= 6.68.0: añade el argumento platform_version (V1|V2) al recurso
      # aws_bedrockagentcore_agent_runtime.
      version               = ">= 6.68.0, < 7.0.0"
      configuration_aliases = [aws.project]
    }
  }
}
