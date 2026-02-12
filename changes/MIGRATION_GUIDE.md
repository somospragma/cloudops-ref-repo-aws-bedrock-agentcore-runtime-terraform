# Guía de Migración: Observabilidad v1.1.0

Esta guía te ayudará a migrar tu módulo de Bedrock AgentCore Runtime a la versión 1.1.0 que incluye capacidades completas de observabilidad.

## 📋 Pre-requisitos

- [x] Terraform >= 1.5.0
- [x] AWS Provider >= 6.24.0
- [x] Permisos IAM para crear recursos de CloudWatch y X-Ray
- [x] Backup del estado de Terraform

## 🔄 Proceso de Migración

### Paso 1: Backup del Estado Actual

```bash
# Backup del estado de Terraform
terraform state pull > terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)

# Backup de la configuración
cp -r . ../backup-$(date +%Y%m%d_%H%M%S)
```

### Paso 2: Actualizar el Módulo

```bash
# Si usas Git
git pull origin main

# Si usas módulo local
cp -r /path/to/new/module ./modules/bedrock-agentcore-runtime

# Si usas Terraform Registry
terraform init -upgrade
```

### Paso 3: Revisar Variables Nuevas

Las siguientes variables se han agregado con valores por defecto seguros:

```hcl
# En tu terraform.tfvars o variables
enable_application_logs = true   # Default: true
enable_usage_logs       = true   # Default: true
xray_sampling_rate      = 0.05   # Default: 0.05 (5%)
```

**No es necesario agregar estas variables** si los defaults son adecuados.

### Paso 4: Plan de Terraform

```bash
terraform plan -out=migration.tfplan
```

**Revisa cuidadosamente el plan**. Deberías ver:

✅ **Recursos a CREAR** (no modificar):
- `aws_cloudwatch_log_group.agent_runtime[*]`
- `aws_cloudwatch_log_delivery_destination.agent_runtime[*]`
- `aws_cloudwatch_log_delivery_source.agent_runtime_application[*]`
- `aws_cloudwatch_log_delivery_source.agent_runtime_usage[*]`
- `aws_cloudwatch_log_delivery.agent_runtime_application[*]`
- `aws_cloudwatch_log_delivery.agent_runtime_usage[*]`
- `aws_xray_sampling_rule.agent_runtime[0]`

❌ **NO deberías ver**:
- Recursos existentes siendo destruidos
- Cambios en `aws_bedrockagentcore_agent_runtime`
- Cambios en `aws_bedrockagentcore_agent_runtime_endpoint`
- Cambios en `aws_iam_role` o `aws_iam_role_policy`

### Paso 5: Aplicar Cambios

```bash
terraform apply migration.tfplan
```

**Tiempo estimado**: 2-5 minutos

### Paso 6: Verificar Recursos Creados

```bash
# Verificar log groups
aws logs describe-log-groups \
  --log-group-name-prefix /aws/bedrock-agentcore/runtimes/

# Verificar log delivery
aws logs describe-deliveries

# Verificar X-Ray sampling rule
aws xray get-sampling-rules \
  --query 'SamplingRuleRecords[?SamplingRule.RuleName==`<your-prefix>-agentcore-sampling`]'
```

### Paso 7: Validar Observabilidad

#### Generar Tráfico de Prueba

```bash
# Invocar el agent runtime para generar logs
aws bedrock-agentcore invoke-agent \
  --agent-runtime-id <runtime-id> \
  --input-text "Hello, test message"
```

#### Verificar Logs (esperar 1-2 minutos)

```bash
# Ver logs recientes
aws logs tail /aws/bedrock-agentcore/runtimes/<runtime-id>-<endpoint-name>/runtime-logs \
  --since 5m \
  --follow
```

#### Verificar Traces (esperar 2-3 minutos)

```bash
# Buscar traces recientes
aws xray get-trace-summaries \
  --start-time $(date -u -d '10 minutes ago' +%s) \
  --end-time $(date -u +%s) \
  --filter-expression 'service(id(name: "bedrock-agentcore"))'
```

## 🎛️ Configuraciones Opcionales

### Opción 1: Deshabilitar Observabilidad Temporalmente

Si necesitas deshabilitar la observabilidad sin eliminar recursos:

```hcl
module "bedrock_agentcore" {
  source = "./modules/bedrock-agentcore-runtime"

  # ... configuración existente ...

  # Deshabilitar logging
  enable_logging = false

  # Deshabilitar tracing
  enable_tracing = false
}
```

```bash
terraform apply
```

**Nota**: Esto NO elimina los log groups, solo detiene la entrega de nuevos logs.

### Opción 2: Configuración por Entorno

```hcl
locals {
  observability_config = {
    dev = {
      enable_application_logs = true
      enable_usage_logs       = false  # No necesario en dev
      log_retention_days      = 7
      xray_sampling_rate      = 1.0    # 100% en dev
    }
    staging = {
      enable_application_logs = true
      enable_usage_logs       = true
      log_retention_days      = 30
      xray_sampling_rate      = 0.2    # 20%
    }
    prod = {
      enable_application_logs = true
      enable_usage_logs       = true
      log_retention_days      = 365
      xray_sampling_rate      = 0.05   # 5%
    }
  }
}

module "bedrock_agentcore" {
  source = "./modules/bedrock-agentcore-runtime"

  # ... configuración existente ...

  enable_application_logs = local.observability_config[var.environment].enable_application_logs
  enable_usage_logs       = local.observability_config[var.environment].enable_usage_logs
  log_retention_days      = local.observability_config[var.environment].log_retention_days
  xray_sampling_rate      = local.observability_config[var.environment].xray_sampling_rate
}
```

### Opción 3: Cifrado con KMS

```hcl
# Crear KMS key para logs
resource "aws_kms_key" "logs" {
  description             = "KMS key for Bedrock AgentCore logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtimes/*"
          }
        }
      }
    ]
  })
}

module "bedrock_agentcore" {
  source = "./modules/bedrock-agentcore-runtime"

  # ... configuración existente ...

  kms_key_id = aws_kms_key.logs.id
}
```

## 🔧 Troubleshooting

### Problema 1: Error de Permisos IAM

**Síntoma**:
```
Error: creating CloudWatch Logs Delivery Source: AccessDeniedException
```

**Solución**:
```bash
# Verificar permisos del usuario/rol que ejecuta Terraform
aws iam get-user-policy --user-name <your-user> --policy-name <policy-name>

# Agregar permisos necesarios
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogGroup",
    "logs:CreateLogDelivery",
    "logs:PutDeliverySource",
    "logs:PutDeliveryDestination",
    "xray:PutSamplingRule"
  ],
  "Resource": "*"
}
```

### Problema 2: Log Group Ya Existe

**Síntoma**:
```
Error: creating CloudWatch Log Group: ResourceAlreadyExistsException
```

**Solución**:
```bash
# Importar log group existente
terraform import 'module.bedrock_agentcore.aws_cloudwatch_log_group.agent_runtime["agent-name"]' \
  /aws/bedrock-agentcore/runtimes/runtime-id-endpoint-name/runtime-logs
```

### Problema 3: Logs No Aparecen

**Diagnóstico**:
```bash
# 1. Verificar que el log group existe
aws logs describe-log-groups \
  --log-group-name-prefix /aws/bedrock-agentcore/runtimes/

# 2. Verificar log delivery
aws logs describe-deliveries

# 3. Verificar permisos del agent runtime role
aws iam get-role-policy \
  --role-name <agent-runtime-role-name> \
  --policy-name <policy-name>

# 4. Generar tráfico de prueba
aws bedrock-agentcore invoke-agent \
  --agent-runtime-id <runtime-id> \
  --input-text "Test message"

# 5. Esperar 2-3 minutos y verificar logs
aws logs tail /aws/bedrock-agentcore/runtimes/<runtime-id>-<endpoint-name>/runtime-logs \
  --since 5m
```

### Problema 4: Traces No Aparecen en X-Ray

**Diagnóstico**:
```bash
# 1. Verificar sampling rule
aws xray get-sampling-rules

# 2. Verificar permisos X-Ray en el role
aws iam get-role-policy \
  --role-name <agent-runtime-role-name> \
  --policy-name <policy-name> | \
  jq '.PolicyDocument.Statement[] | select(.Action[] | contains("xray"))'

# 3. Verificar que Transaction Search está habilitado
aws cloudwatch describe-transaction-search-status

# 4. Habilitar Transaction Search si es necesario
aws cloudwatch enable-transaction-search
```

### Problema 5: Costos Elevados

**Análisis**:
```bash
# Ver tamaño de logs
aws logs describe-log-groups \
  --log-group-name-prefix /aws/bedrock-agentcore/runtimes/ \
  --query 'logGroups[*].[logGroupName,storedBytes]' \
  --output table

# Ver número de traces
aws xray get-trace-summaries \
  --start-time $(date -u -d '1 day ago' +%s) \
  --end-time $(date -u +%s) \
  --query 'TraceSummaries | length(@)'
```

**Optimización**:
```hcl
# Reducir retención
log_retention_days = 7

# Reducir sampling
xray_sampling_rate = 0.01  # 1%

# Deshabilitar usage logs
enable_usage_logs = false
```

## 📊 Validación Post-Migración

### Checklist

- [ ] Terraform apply completado sin errores
- [ ] Log groups creados en CloudWatch
- [ ] Log delivery sources configurados
- [ ] Log delivery destinations configurados
- [ ] X-Ray sampling rule creada
- [ ] Logs aparecen en CloudWatch (después de generar tráfico)
- [ ] Traces aparecen en X-Ray (después de generar tráfico)
- [ ] Métricas aparecen en CloudWatch Metrics
- [ ] Alertas configuradas (opcional)
- [ ] Dashboard creado (opcional)
- [ ] Documentación actualizada
- [ ] Equipo notificado

### Métricas de Éxito

```bash
# Verificar que hay logs en las últimas 24 horas
aws logs filter-log-events \
  --log-group-name /aws/bedrock-agentcore/runtimes/<runtime-id>-<endpoint-name>/runtime-logs \
  --start-time $(date -u -d '24 hours ago' +%s)000 \
  --query 'events | length(@)'

# Verificar que hay traces en las últimas 24 horas
aws xray get-trace-summaries \
  --start-time $(date -u -d '24 hours ago' +%s) \
  --end-time $(date -u +%s) \
  --filter-expression 'service(id(name: "bedrock-agentcore"))' \
  --query 'TraceSummaries | length(@)'
```

## 🔙 Rollback

Si necesitas revertir los cambios:

### Opción 1: Deshabilitar sin Eliminar

```hcl
enable_logging = false
enable_tracing = false
```

```bash
terraform apply
```

### Opción 2: Eliminar Recursos de Observabilidad

```bash
# Eliminar solo recursos de observabilidad
terraform destroy \
  -target='module.bedrock_agentcore.aws_cloudwatch_log_group.agent_runtime' \
  -target='module.bedrock_agentcore.aws_cloudwatch_log_delivery_destination.agent_runtime' \
  -target='module.bedrock_agentcore.aws_cloudwatch_log_delivery_source.agent_runtime_application' \
  -target='module.bedrock_agentcore.aws_cloudwatch_log_delivery_source.agent_runtime_usage' \
  -target='module.bedrock_agentcore.aws_cloudwatch_log_delivery.agent_runtime_application' \
  -target='module.bedrock_agentcore.aws_cloudwatch_log_delivery.agent_runtime_usage' \
  -target='module.bedrock_agentcore.aws_xray_sampling_rule.agent_runtime'
```

### Opción 3: Rollback Completo

```bash
# Restaurar estado anterior
terraform state push terraform.tfstate.backup.<timestamp>

# Restaurar código anterior
git checkout <previous-commit>

# Aplicar estado anterior
terraform apply
```

## 📞 Soporte

Si encuentras problemas durante la migración:

1. **Revisar logs de Terraform**: `terraform.log`
2. **Consultar documentación**: `OBSERVABILITY_CHANGES.md`
3. **Revisar ejemplos**: `examples/observability/`
4. **Contactar soporte**: cloudops@somospragma.com
5. **Abrir issue**: [GitHub Issues](https://github.com/somospragma/terraform-aws-bedrock-agentcore-runtime/issues)

---

**Última actualización**: 2024-12-09  
**Versión**: 1.1.0  
**Mantenido por**: CloudOps Team - Pragma
