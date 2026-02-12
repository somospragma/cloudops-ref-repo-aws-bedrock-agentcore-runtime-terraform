# Ejemplo: Agent Runtime con Observabilidad Completa

Este ejemplo demuestra cómo desplegar un Bedrock AgentCore Runtime con observabilidad completa habilitada, incluyendo log delivery y tracing a CloudWatch.

## Características

- ✅ CloudWatch Logs para APPLICATION_LOGS y USAGE_LOGS
- ✅ AWS X-Ray tracing distribuido
- ✅ Cifrado con KMS
- ✅ Retención de logs configurable
- ✅ Sampling rate ajustable

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Bedrock AgentCore Runtime                │
│                                                             │
│  ┌──────────────┐         ┌──────────────┐                │
│  │   Agent      │────────▶│   Endpoint   │                │
│  │   Runtime    │         │              │                │
│  └──────┬───────┘         └──────────────┘                │
│         │                                                   │
│         │ Logs & Traces                                    │
│         ▼                                                   │
└─────────┼───────────────────────────────────────────────────┘
          │
          ├──────────────────────────────────────────────────┐
          │                                                  │
          ▼                                                  ▼
┌─────────────────────┐                          ┌──────────────────┐
│  CloudWatch Logs    │                          │   AWS X-Ray      │
│                     │                          │                  │
│  ┌───────────────┐  │                          │  ┌─────────────┐ │
│  │ Application   │  │                          │  │   Traces    │ │
│  │     Logs      │  │                          │  │             │ │
│  └───────────────┘  │                          │  └─────────────┘ │
│                     │                          │                  │
│  ┌───────────────┐  │                          │  ┌─────────────┐ │
│  │  Usage Logs   │  │                          │  │   Spans     │ │
│  │               │  │                          │  │             │ │
│  └───────────────┘  │                          │  └─────────────┘ │
└─────────────────────┘                          └──────────────────┘
```

## Uso

### 1. Configuración Básica

```hcl
module "bedrock_agentcore_observability" {
  source = "../../"

  client      = "acme"
  project     = "ai-platform"
  environment = "prod"

  # Configuración de Logging
  enable_logging          = true
  enable_application_logs = true
  enable_usage_logs       = true
  log_retention_days      = 90

  # Configuración de Tracing
  enable_tracing     = true
  xray_sampling_rate = 0.1  # 10% de requests

  # Cifrado
  kms_key_id = aws_kms_key.agentcore.id

  agent_runtimes = {
    customer-service = {
      description   = "Customer service agent with full observability"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/customer-service:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      environment_variables = {
        LOG_LEVEL = "INFO"
        MODEL_ID  = "anthropic.claude-3-sonnet-20240229-v1:0"
      }

      lifecycle_config = {
        idle_timeout = 1800  # 30 minutos
        max_lifetime = 7200  # 2 horas
      }
    }
  }

  providers = {
    aws.project = aws.project
  }
}
```

### 2. Outputs de Observabilidad

```hcl
# Log Groups
output "log_groups" {
  description = "CloudWatch Log Groups para cada agent runtime"
  value       = module.bedrock_agentcore_observability.log_group_names
}

# Configuración de Observabilidad
output "observability_config" {
  description = "Configuración completa de observabilidad"
  value       = module.bedrock_agentcore_observability.observability_configuration
}

# X-Ray Sampling Rule
output "xray_rule" {
  description = "ARN de la regla de sampling de X-Ray"
  value       = module.bedrock_agentcore_observability.xray_sampling_rule_arn
}
```

### 3. Consultas de Logs

#### Ver logs de aplicación

```bash
# Usando AWS CLI
aws logs tail /aws/bedrock-agentcore/runtimes/runtime-123-endpoint-name/runtime-logs --follow

# Últimos 100 logs
aws logs tail /aws/bedrock-agentcore/runtimes/runtime-123-endpoint-name/runtime-logs --since 1h
```

#### CloudWatch Logs Insights

```sql
-- Errores en las últimas 24 horas
fields @timestamp, request_id, session_id, operation, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100

-- Latencia promedio por operación
fields operation, latency_ms
| stats avg(latency_ms) as avg_latency by operation
| sort avg_latency desc

-- Top 10 sesiones por consumo de tokens
fields session_id, input_tokens, output_tokens
| stats sum(input_tokens) as total_input, sum(output_tokens) as total_output by session_id
| sort total_input desc
| limit 10
```

### 4. Visualización de Traces

#### Consola de X-Ray

1. Ir a AWS X-Ray Console
2. Seleccionar "Service Map"
3. Filtrar por service name: `bedrock-agentcore`
4. Ver traces individuales en "Traces"

#### AWS CLI

```bash
# Obtener traces de las últimas 6 horas
aws xray get-trace-summaries \
  --start-time $(date -u -d '6 hours ago' +%s) \
  --end-time $(date -u +%s) \
  --filter-expression 'service(id(name: "bedrock-agentcore"))'

# Obtener detalles de un trace específico
aws xray batch-get-traces --trace-ids trace-id-123
```

### 5. Alertas de CloudWatch

```hcl
# Alerta de errores elevados
resource "aws_cloudwatch_metric_alarm" "high_errors" {
  alarm_name          = "agentcore-high-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "bedrock-agentcore"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alert when agent errors exceed threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AgentRuntimeId = module.bedrock_agentcore_observability.agent_runtime_ids["customer-service"]
  }
}

# Alerta de latencia alta
resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "agentcore-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "Latency"
  namespace           = "bedrock-agentcore"
  period              = 300
  statistic           = "Average"
  threshold           = 5000  # 5 segundos
  alarm_description   = "Alert when average latency exceeds 5 seconds"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AgentRuntimeId = module.bedrock_agentcore_observability.agent_runtime_ids["customer-service"]
  }
}

# Alerta de throttling
resource "aws_cloudwatch_metric_alarm" "throttling" {
  alarm_name          = "agentcore-throttling"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "bedrock-agentcore"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when throttling occurs"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AgentRuntimeId = module.bedrock_agentcore_observability.agent_runtime_ids["customer-service"]
  }
}
```

### 6. Dashboard de CloudWatch

```hcl
resource "aws_cloudwatch_dashboard" "agentcore" {
  dashboard_name = "bedrock-agentcore-observability"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["bedrock-agentcore", "Invocations", { stat = "Sum" }],
            [".", "Errors", { stat = "Sum" }],
            [".", "Throttles", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
          title  = "Agent Runtime Metrics"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["bedrock-agentcore", "Latency", { stat = "Average" }],
            ["...", { stat = "p99" }]
          ]
          period = 300
          region = "us-east-1"
          title  = "Latency"
        }
      },
      {
        type = "log"
        properties = {
          query   = "SOURCE '/aws/bedrock-agentcore/runtimes/*' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20"
          region  = "us-east-1"
          title   = "Recent Errors"
        }
      }
    ]
  })
}
```

## Configuraciones por Entorno

### Desarrollo

```hcl
module "bedrock_agentcore_dev" {
  source = "../../"

  environment = "dev"

  # Logging mínimo
  enable_logging          = true
  enable_application_logs = true
  enable_usage_logs       = false  # No necesario en dev
  log_retention_days      = 7      # Retención corta

  # Tracing completo para debugging
  enable_tracing     = true
  xray_sampling_rate = 1.0  # 100% en dev

  # Sin cifrado KMS (más económico)
  kms_key_id = null

  # ... resto de configuración ...
}
```

### Staging

```hcl
module "bedrock_agentcore_staging" {
  source = "../../"

  environment = "staging"

  # Logging completo
  enable_logging          = true
  enable_application_logs = true
  enable_usage_logs       = true
  log_retention_days      = 30

  # Tracing moderado
  enable_tracing     = true
  xray_sampling_rate = 0.2  # 20%

  # Cifrado con KMS
  kms_key_id = aws_kms_key.staging.id

  # ... resto de configuración ...
}
```

### Producción

```hcl
module "bedrock_agentcore_prod" {
  source = "../../"

  environment = "prod"

  # Logging completo con retención extendida
  enable_logging          = true
  enable_application_logs = true
  enable_usage_logs       = true
  log_retention_days      = 365  # 1 año para compliance

  # Tracing optimizado
  enable_tracing     = true
  xray_sampling_rate = 0.05  # 5% para balance costo/visibilidad

  # Cifrado obligatorio
  kms_key_id = aws_kms_key.prod.id

  # ... resto de configuración ...
}
```

## Costos Estimados

### Por Agent Runtime (1000 invocaciones/día)

| Componente | Costo Mensual |
|------------|---------------|
| CloudWatch Logs (5 GB) | $2.65 |
| X-Ray Traces (5% sampling) | $0.01 |
| KMS (opcional) | $1.00 |
| **Total** | **$3.66/mes** |

### Optimización de Costos

1. **Reducir retención en dev/staging**: `log_retention_days = 7`
2. **Ajustar sampling**: `xray_sampling_rate = 0.01` (1%)
3. **Deshabilitar usage logs**: `enable_usage_logs = false`
4. **Sin KMS en dev**: `kms_key_id = null`

**Ahorro potencial**: ~60% ($1.50/mes por runtime)

## Troubleshooting

### Logs no aparecen

```bash
# Verificar que el log group existe
aws logs describe-log-groups --log-group-name-prefix /aws/bedrock-agentcore/runtimes/

# Verificar log streams
aws logs describe-log-streams \
  --log-group-name /aws/bedrock-agentcore/runtimes/runtime-123-endpoint-name/runtime-logs

# Verificar permisos IAM
aws iam get-role-policy \
  --role-name acme-ai-platform-prod-agentcore-role-customer-service \
  --policy-name acme-ai-platform-prod-agentcore-policy-customer-service
```

### Traces no aparecen en X-Ray

```bash
# Verificar sampling rule
aws xray get-sampling-rules

# Verificar permisos
aws iam get-role-policy \
  --role-name acme-ai-platform-prod-agentcore-role-customer-service \
  --policy-name acme-ai-platform-prod-agentcore-policy-customer-service | \
  jq '.PolicyDocument.Statement[] | select(.Action[] | contains("xray"))'

# Verificar que Transaction Search está habilitado
aws cloudwatch describe-transaction-search-status
```

## Referencias

- [AWS Bedrock AgentCore Observability](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/observability.html)
- [CloudWatch Logs Insights Query Syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)
- [AWS X-Ray Developer Guide](https://docs.aws.amazon.com/xray/latest/devguide/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)

---

**Nota**: Este ejemplo asume que ya tienes configurado:
- AWS Provider
- KMS Key (si usas cifrado)
- SNS Topic (para alertas)
- Permisos IAM adecuados
