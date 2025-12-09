# ============================================================================
# Amazon Bedrock AgentCore Runtime - Data Sources
# ============================================================================

# Current AWS Account Information
data "aws_caller_identity" "current" {
  provider = aws.project
}

# Current AWS Region
data "aws_region" "current" {
  provider = aws.project
}

# Current AWS Partition
data "aws_partition" "current" {
  provider = aws.project
}
