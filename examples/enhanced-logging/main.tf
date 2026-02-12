# Example: Enhanced Logging, Tracing, and Resource Policies

module "bedrock_agentcore_enhanced" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "acme"
  project     = "ai-platform"
  environment = "prod"

  # Agent configuration
  agent_runtimes = {
    customer-service = {
      description   = "Customer service agent with enhanced observability"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/agent:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"
    }
  }

  # Enhanced logging
  enable_logging     = true
  log_retention_days = 90
  
  log_destinations = {
    s3_bucket_arn       = "arn:aws:s3:::my-logs-bucket"
    firehose_stream_arn = "arn:aws:firehose:us-east-1:123456789012:deliverystream/my-stream"
  }

  # Tracing
  enable_tracing = true

  # Resource policies
  resource_policy_statements = [
    {
      sid    = "AllowCrossAccountAccess"
      effect = "Allow"
      actions = [
        "bedrock-agentcore:InvokeAgent"
      ]
      principals = {
        type        = "AWS"
        identifiers = ["arn:aws:iam::999999999999:root"]
      }
      conditions = [
        {
          test     = "StringEquals"
          variable = "aws:PrincipalOrgID"
          values   = ["o-xxxxxxxxxx"]
        }
      ]
    }
  ]

  providers = {
    aws.project = aws.project
  }
}
