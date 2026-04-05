# ============================================================================
# Sample Implementation - Provider Configuration
# ============================================================================
# PC-IAC-005: Provider principal con alias, region, assume_role y default_tags.
# ============================================================================

provider "aws" {
  region = var.aws_region
  alias  = "principal"

  default_tags {
    tags = {
      Client      = var.client
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
