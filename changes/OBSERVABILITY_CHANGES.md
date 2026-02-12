# Cambios de Observabilidad - Bedrock AgentCore Runtime

## 📋 Resumen

Se han agregado capacidades completas de **log delivery** y **tracing** a CloudWatch para el módulo de Terraform de Amazon Bedrock AgentCore Runtime.

## 🎯 Objetivos

1. **Log Delivery**: Configurar entrega automática de logs de aplicación y uso a CloudWatch
2. **Tracing**: Habilitar AWS X-Ray para trazabilidad distribuida
3. **Observabilidad**: Proporcionar visibilidad completa del comportamiento de los agentes

## 🔧 Cambios Implementados

### 1. CloudWatch Log Groups

**Archivo**: `main.tf`

```hcl
resource "aws_cloudwatch_log_group" "agent_runtime" {
  for_each = var.enable_logging ? var.agent_runtimes : {}

  name              = "/aws/bedrock-agentcore/runtimes/${agent_runtime_id}-${endpoint_name}/runtime-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_id
}
```

**Características**:
- Log group por cada agent runtime
- Retención configurable (default: 30 días)
- Cifrado con KMS opcional
- Nomenclatura estándar de AWS

### 2. CloudWatch Log Delivery

**Componentes**:

#### a) Log Delivery Destination
```hcl
resource "aws_cloudwatch_log_delivery_destination" "agent_runtime"
```
- Define el destino de logs (CloudWatch Logs)
- Formato JSON para logs estructurados

#### b) Log Delivery Sources
```hcl
resource "aws_cloudwatch_log_delivery_source" "agent_runtime_application"
resource "aws_cloudwatch_log_delivery_source" "agent_runtime_usage"
```
- **APPLICATION_LOGS**: Logs de invocaciones y consumo de recursos
- **USAGE_LOGS**: Métricas de uso con granularidad de 1 segundo

#### c) Log Delivery Connections
```hcl
resource "aws_cloudwatch_log_delivery" "agent_runtime_application"
resource "aws_cloudwatch_log_delivery" "agent_runtime_usage"
```
- Conecta sources con destinations
- Configuración independiente por tipo de log

### 3. X-Ray Tracing

**Archivo**: `main.tf`

```hcl
resource "aws_xray_sampling_rule" "agent_runtime" {
  rule_name      = "${name_prefix}-agentcore-sampling"
  fixed_rate     = var.xray_sampling_rate
  service_name   = "bedrock-agentcore"
}
```

**Características**:
- Sampling rate configurable (default: 5%)
- Regla de muestreo específica para AgentCore
- Prioridad 1000 para evitar conflictos

### 4. Variables Nuevas

**Archivo**: `variables.tf`

| Variable | Tipo | Default | Descripción |
|----------|------|---------|-------------|
| `enable_application_logs` | bool | true | Habilita logs de aplicación |
| `enable_usage_logs` | bool | true | Habilita logs de uso |
| `xray_sampling_rate` | number | 0.05 | Tasa de muestreo X-Ray (0.0-1.0) |

### 5. Outputs Nuevos

**Archivo**: `outputs.tf`

| Output | Descripción |
|--------|-------------|
| `log_group_names` | Nombres de log groups por runtime |
| `log_group_arns` | ARNs de log groups por runtime |
| `log_delivery_ids` | IDs de log delivery por runtime |
| `xray_sampling_rule_arn` | ARN de la regla de sampling X-Ray |
| `observability_configuration` | Configuración completa de observabilidad |

## 📊 Tipos de Logs Disponibles

### APPLICATION_LOGS

**Contenido**:
- Invocaciones de agent runtime
- Consumo de recursos a nivel de sesión
- Logs de stdout/stderr del contenedor
- Logs estructurados OTEL

**Ubicación**: `/aws/bedrock-agentcore/runtimes/<agent_id>-<endpoint_name>/runtime-logs`

**Formato**:
```json
{
  "timestamp": "2024-12-09T15:00:00Z",
  "resource_arn": "arn:aws:bedrock-agentcore:...",
  "event_timestamp": "2024-12-09T15:00:00Z",
  "account_id": "123456789012",
  "request_id": "req-123",
  "session_id": "session-456",
  "trace_id": "trace-789",
  "span_id": "span-012",
  "service_name": "bedrock-agentcore",
  "operation": "InvokeAgent",
  "request_payload": {...},
  "response_payload": {...}
}
```

### USAGE_LOGS

**Contenido**:
- Telemetría de uso a nivel de sesión
- Granularidad de 1 segundo
- Consumo de CPU y memoria
- Métricas de recursos

**Formato**:
```json
{
  "event_timestamp": "2024-12-09T15:00:00Z",
  "resource_arn": "arn:aws:bedrock-agentcore:...",
  "service_name": "bedrock-agentcore",
  "cloud_provider": "aws",
  "cloud_region": "us-east-1",
  "account_id": "123456789012",
  "region": "us-east-1",
  "resource_id": "runtime-123",
  "session_id": "session-456",
  "elapsed_time_seconds": 1,
  "vcpu_hours_used": 0.0002777,
  "gb_hours_used": 0.0005555
}
```

## 🔍 X-Ray Tracing

### Spans Disponibles

**Ubicación**: `/aws/spans/default`

**Operaciones Trazadas**:
- `InvokeAgent`
- `CreateSession`
- `DeleteSession`
- Model invocations (Bedrock)
- Custom spans del código del agente

**Atributos de Span**:
```json
{
  "operation_name": "InvokeAgent",
  "span_attributes": {
    "agent_runtime_id": "runtime-123",
    "session_id": "session-456",
    "model_id": "anthropic.claude-3-sonnet",
    "input_tokens": 100,
    "output_tokens": 200,
    "latency_ms": 1500
  }
}
```

## 📈 Métricas en CloudWatch

### Namespace: `bedrock-agentcore`

**Métricas Automáticas**:
- `Invocations`: Número de invocaciones
- `Latency`: Latencia de invocaciones
- `Errors`: Errores del sistema y usuario
- `Throttles`: Solicitudes limitadas
- `SessionCount`: Sesiones activas
- `TokenUsage`: Tokens consumidos

**Dimensiones**:
- `AgentRuntimeId`
- `AgentRuntimeEndpoint`
- `Operation`
- `ModelId`

## 🚀 Uso

### Configuración Básica

```hcl
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "acme"
  project     = "ai-platform"
  environment = "prod"

  # Configuración de logging (habilitado por defecto)
  enable_logging          = true
  enable_application_logs = true
  enable_usage_logs       = true
  log_retention_days      = 90

  # Configuración de tracing (habilitado por defecto)
  enable_tracing      = true
  xray_sampling_rate  = 0.1  # 10% de requests

  agent_runtimes = {
    customer-service = {
      description   = "Customer service agent"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/agent:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"
    }
  }
}
```

### Configuración Avanzada

```hcl
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  # ... configuración básica ...

  # Logs solo de aplicación (sin usage logs)
  enable_application_logs = true
  enable_usage_logs       = false

  # Retención extendida para compliance
  log_retention_days = 2557  # 7 años (HIPAA)

  # Cifrado con KMS
  kms_key_id = aws_kms_key.agentcore.id

  # Tracing completo (100%)
  enable_tracing     = true
  xray_sampling_rate = 1.0
}
```

### Deshabilitar Observabilidad

```hcl
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  # ... configuración básica ...

  # Deshabilitar logging
  enable_logging = false

  # Deshabilitar tracing
  enable_tracing = false
}
```

## 📊 Consultas de Logs

### CloudWatch Logs Insights

#### Errores en las últimas 24 horas
```
fields @timestamp, request_id, session_id, operation, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100
```

#### Latencia promedio por operación
```
fields operation, latency_ms
| stats avg(latency_ms) as avg_latency by operation
| sort avg_latency desc
```

#### Consumo de tokens por sesión
```
fields session_id, input_tokens, output_tokens
| stats sum(input_tokens) as total_input, sum(output_tokens) as total_output by session_id
| sort total_input desc
```

#### Uso de recursos (CPU/Memoria)
```
fields @timestamp, session_id, vcpu_hours_used, gb_hours_used
| stats sum(vcpu_hours_used) as total_cpu, sum(gb_hours_used) as total_memory by session_id
| sort total_cpu desc
```

## 🔐 Permisos IAM Requeridos

Los roles IAM de los agent runtimes ya incluyen los permisos necesarios:

```json
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "logs:CreateLogGroup",
    "logs:DescribeLogStreams",
    "logs:DescribeLogGroups"
  ],
  "Resource": "arn:aws:logs:*:*:log-group:/aws/bedrock-agentcore/runtimes/*"
}
```

```json
{
  "Effect": "Allow",
  "Action": [
    "xray:PutTraceSegments",
    "xray:PutTelemetryRecords",
    "xray:GetSamplingRules",
    "xray:GetSamplingTargets"
  ],
  "Resource": "*"
}
```

## 💰 Consideraciones de Costos

### CloudWatch Logs

**Ingesta**: ~$0.50/GB
**Almacenamiento**: ~$0.03/GB/mes
**Consultas**: Incluidas en el precio

**Estimación mensual** (1 agent runtime, 1000 invocaciones/día):
- Logs: ~5 GB/mes = $2.50 ingesta + $0.15 almacenamiento = **$2.65/mes**

### X-Ray

**Traces**: $5.00 por millón de traces
**Sampling 5%**: 1000 invocaciones/día × 30 días × 0.05 = 1,500 traces/mes = **$0.0075/mes**

**Total estimado**: ~$2.66/mes por agent runtime

### Optimización

1. **Ajustar retención**: Reducir `log_retention_days` para dev/staging
2. **Sampling rate**: Usar 1-5% en producción, 100% solo para debugging
3. **Filtrar logs**: Deshabilitar `usage_logs` si no se necesitan métricas detalladas

## 🎯 Mejores Prácticas

### 1. Retención de Logs

```hcl
log_retention_days = var.environment == "prod" ? 365 : 30
```

### 2. Sampling Dinámico

```hcl
xray_sampling_rate = var.environment == "prod" ? 0.05 : 1.0
```

### 3. Cifrado

```hcl
kms_key_id = var.environment == "prod" ? aws_kms_key.prod.id : null
```

### 4. Alertas

```hcl
resource "aws_cloudwatch_metric_alarm" "high_errors" {
  alarm_name          = "agentcore-high-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "bedrock-agentcore"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  
  dimensions = {
    AgentRuntimeId = module.bedrock_agentcore.agent_runtime_ids["my-agent"]
  }
}
```

## 📚 Referencias

- [AWS Bedrock AgentCore Observability](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/observability.html)
- [CloudWatch Log Delivery](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch-Logs-Delivery.html)
- [AWS X-Ray](https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html)
- [OpenTelemetry](https://opentelemetry.io/)

## 🔄 Migración

### Desde versión anterior (sin observabilidad)

1. **Actualizar módulo**: Pull de los cambios
2. **Revisar variables**: Las nuevas variables tienen defaults seguros
3. **Plan**: `terraform plan` para revisar cambios
4. **Apply**: `terraform apply` para crear recursos de observabilidad

**Nota**: Los recursos existentes NO se modifican, solo se agregan nuevos recursos de logging y tracing.

### Rollback

Para deshabilitar temporalmente:

```hcl
enable_logging = false
enable_tracing = false
```

Esto NO elimina los log groups existentes, solo detiene la entrega de nuevos logs.

## ✅ Checklist de Implementación

- [x] CloudWatch Log Groups creados
- [x] Log Delivery Sources configurados (APPLICATION_LOGS, USAGE_LOGS)
- [x] Log Delivery Destinations configurados
- [x] Log Delivery Connections establecidas
- [x] X-Ray Sampling Rule configurada
- [x] Permisos IAM actualizados
- [x] Variables de configuración agregadas
- [x] Outputs de observabilidad agregados
- [x] Documentación actualizada

## 🐛 Troubleshooting

### Logs no aparecen en CloudWatch

1. Verificar que `enable_logging = true`
2. Verificar permisos IAM del agent runtime
3. Revisar CloudWatch Logs Insights para errores de entrega
4. Verificar que el log group existe

### Traces no aparecen en X-Ray

1. Verificar que `enable_tracing = true`
2. Verificar permisos IAM (xray:PutTraceSegments)
3. Revisar sampling rate (puede ser muy bajo)
4. Verificar que Transaction Search está habilitado en CloudWatch

### Costos elevados

1. Reducir `log_retention_days`
2. Reducir `xray_sampling_rate`
3. Deshabilitar `enable_usage_logs` si no se necesita
4. Implementar filtros de logs

---

**Fecha**: 2024-12-09  
**Versión**: 1.1.0  
**Autor**: CloudOps Team - Pragma
