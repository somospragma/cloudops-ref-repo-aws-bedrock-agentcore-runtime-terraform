# Módulo Terraform: AWS Bedrock AgentCore Runtime

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Diagrama de Arquitectura](#-diagrama-de-arquitectura)
- [Características](#-características)
- [Estructura del Módulo](#-estructura-del-módulo)
- [Implementación y Configuración](#-implementación-y-configuración)
- [Parámetros](#-parámetros)
- [Outputs](#-outputs)
- [Ejemplos de Uso](#-ejemplos-de-uso)
- [Escenarios de Uso Comunes](#-escenarios-de-uso-comunes)
- [Seguridad y Cumplimiento](#-seguridad-y-cumplimiento)
- [Observaciones](#-observaciones)

---

## 📋 Descripción

Módulo Terraform de nivel empresarial para el despliegue y gestión de entornos de ejecución de Amazon Bedrock AgentCore Runtime. Este módulo proporciona un entorno de ejecución containerizado seguro, escalable y completamente administrado para agentes de IA con soporte para múltiples protocolos (MCP, HTTP, A2A), autenticación personalizada y redes VPC.

### ¿Qué es Amazon Bedrock AgentCore Runtime?

Amazon Bedrock AgentCore Runtime es un servicio serverless que proporciona un entorno de hosting seguro para desplegar agentes de IA con las siguientes capacidades:

- **Ejecución Containerizada**: Despliegue de agentes usando imágenes de contenedor ECR o código Python alojado en S3
- **Aislamiento de Sesiones**: Cada sesión de usuario se ejecuta en una microVM dedicada con recursos aislados
- **Soporte de Protocolos**: Soporte nativo para Model Context Protocol (MCP), HTTP y comunicación Agent-to-Agent (A2A)
- **Autenticación Integrada**: Autorización basada en JWT e integración con AWS IAM
- **Flexibilidad de Red**: Redes públicas o basadas en VPC con controles de security groups
- **Gestión del Ciclo de Vida**: Timeouts de sesión configurables y limpieza automática de recursos

### Casos de Uso

- Despliegue de agentes conversacionales de IA para atención al cliente
- Implementación de asistentes virtuales con acceso a recursos privados
- Creación de pipelines de procesamiento de IA con múltiples agentes
- Desarrollo de aplicaciones de IA con requisitos de seguridad estrictos
- Integración de modelos de Bedrock en arquitecturas empresariales

---

## 🏗️ Diagrama de Arquitectura

![Arquitectura AWS Bedrock AgentCore Runtime](./generated-diagrams/bedrock-agentcore-architecture.png)

### Componentes Principales

1. **Capa de Clientes**: Aplicaciones y usuarios que interactúan con los agentes
2. **Autenticación**: JWT/IAM para autorización y control de acceso
3. **Endpoints**: Puntos de acceso públicos o privados (VPC) para los agentes
4. **Agent Runtimes**: MicroVMs aisladas que ejecutan las sesiones de agentes
5. **Artefactos**: Imágenes de contenedor (ECR) o código Python (S3)
6. **Servicios AWS**: Bedrock Models, CloudWatch Logs, KMS
7. **VPC (Opcional)**: Red privada con security groups y subnets
8. **IAM Roles**: Permisos y políticas para los agentes

### Flujo de Datos

1. Los usuarios/aplicaciones envían solicitudes a través de los endpoints
2. La autenticación JWT/IAM valida las credenciales
3. El runtime crea una sesión aislada en una microVM
4. El agente carga el código desde ECR o S3
5. El agente invoca modelos de Bedrock según sea necesario
6. Los logs se envían a CloudWatch para monitoreo
7. Los datos se cifran usando KMS

---

## ✨ Características

### Funcionalidades Core

- ✅ **Soporte Multi-Runtime**: Despliegue múltiples agent runtimes con diferentes configuraciones
- ✅ **Despliegue de Contenedores y Código**: Soporte para contenedores ECR y código Python alojado en S3
- ✅ **Aislamiento de Red**: Redes públicas o VPC con controles de security groups
- ✅ **Autenticación Personalizada**: Autorización basada en JWT con descubrimiento OIDC
- ✅ **Flexibilidad de Protocolos**: Soporte para protocolos MCP, HTTP y A2A
- ✅ **Gestión del Ciclo de Vida**: Timeouts de sesión configurables y limpieza de recursos
- ✅ **Integración IAM**: Creación automática de roles IAM con políticas de mínimo privilegio
- ✅ **Etiquetado Empresarial**: Sistema de etiquetado de dos niveles para organización de recursos
- ✅ **Cifrado**: Soporte de cifrado KMS para datos en reposo
- ✅ **Logging**: Integración con CloudWatch para monitoreo y debugging

### Protocolos Soportados

| Protocolo | Descripción | Caso de Uso |
|-----------|-------------|-------------|
| **MCP** | Model Context Protocol | Comunicación estándar con modelos de IA |
| **HTTP** | Protocolo HTTP estándar | APIs REST y webhooks |
| **A2A** | Agent-to-Agent | Comunicación entre múltiples agentes |

### Modos de Red

| Modo | Descripción | Seguridad |
|------|-------------|-----------|
| **PUBLIC** | Accesible desde internet | JWT/IAM requerido |
| **VPC** | Aislado dentro de VPC | Security groups + JWT/IAM |

---

## 📁 Estructura del Módulo

```
terraform-aws-bedrock-agentcore-runtime/
├── main.tf                      # Recursos principales del módulo
├── variables.tf                 # Definición de variables de entrada
├── outputs.tf                   # Definición de outputs del módulo
├── locals.tf                    # Variables locales y lógica de nomenclatura
├── data.tf                      # Data sources de AWS
├── versions.tf                  # Versiones de Terraform y providers
├── providers.tf                 # Configuración de providers
├── README.md                    # Documentación principal
├── DOCUMENTATION.md             # Documentación detallada (este archivo)
├── CHANGELOG.md                 # Historial de cambios
├── .gitignore                   # Archivos ignorados por Git
│
├── examples/                    # Ejemplos de uso
│   ├── basic/                   # Ejemplo básico
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars.example
│   │   └── README.md
│   │
│   └── complete/                # Ejemplo completo con todas las opciones
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── terraform.tfvars.example
│       └── README.md
│
├── sample/                      # Implementación de muestra lista para producción
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── README.md
│
└── generated-diagrams/          # Diagramas de arquitectura generados
    └── bedrock-agentcore-architecture.png
```

### Descripción de Archivos

| Archivo | Propósito |
|---------|-----------|
| `main.tf` | Define los recursos principales: agent runtimes, endpoints, roles IAM |
| `variables.tf` | Variables de entrada con validaciones y valores por defecto |
| `outputs.tf` | Outputs del módulo para integración con otros módulos |
| `locals.tf` | Lógica de nomenclatura y etiquetado |
| `data.tf` | Data sources para obtener información de AWS |
| `versions.tf` | Restricciones de versión de Terraform y providers |

---

## 🚀 Implementación y Configuración

### Requisitos Previos

1. **Terraform**: >= 1.5.0
2. **AWS Provider**: >= 6.24.0, < 7.0.0
3. **Credenciales AWS**: Configuradas con permisos adecuados
4. **Región AWS**: Región donde Bedrock AgentCore está disponible

### Permisos IAM Requeridos

El usuario/rol que ejecuta Terraform necesita los siguientes permisos:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock-agentcore:*",
        "iam:CreateRole",
        "iam:PutRolePolicy",
        "iam:GetRole",
        "iam:DeleteRole",
        "iam:DeleteRolePolicy",
        "ecr:DescribeRepositories",
        "s3:GetObject",
        "kms:DescribeKey",
        "logs:CreateLogGroup",
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    }
  ]
}
```

### Instalación Básica

#### Paso 1: Clonar o Referenciar el Módulo

```hcl
module "bedrock_agentcore" {
  source = "git::https://github.com/somospragma/terraform-aws-bedrock-agentcore-runtime.git?ref=v1.0.0"
  
  # O usar ruta local
  # source = "./modules/terraform-aws-bedrock-agentcore-runtime"
  
  client      = "acme"
  project     = "ai-platform"
  environment = "prod"
  
  agent_runtimes = {
    # Configuración de agentes
  }
  
  providers = {
    aws.project = aws.project
  }
}
```

#### Paso 2: Configurar Provider

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "project"
  region = "us-east-1"
  
  default_tags {
    tags = {
      ManagedBy = "terraform"
      Project   = "ai-platform"
    }
  }
}
```

#### Paso 3: Inicializar y Aplicar

```bash
# Inicializar Terraform
terraform init

# Validar configuración
terraform validate

# Planificar cambios
terraform plan

# Aplicar cambios
terraform apply
```

### Configuración Avanzada

#### Configuración con VPC

```hcl
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"
  
  client      = "acme"
  project     = "ai-platform"
  environment = "prod"
  
  agent_runtimes = {
    private-agent = {
      description   = "Agente privado en VPC"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/agent:latest"
      network_mode  = "VPC"
      protocol      = "MCP"
      
      vpc_config = {
        security_groups = ["sg-0123456789abcdef0"]
        subnets         = ["subnet-abc123", "subnet-def456"]
      }
    }
  }
  
  providers = {
    aws.project = aws.project
  }
}
```

#### Configuración con JWT

```hcl
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"
  
  client      = "acme"
  project     = "ai-platform"
  environment = "prod"
  
  agent_runtimes = {
    secure-agent = {
      description   = "Agente con autenticación JWT"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/agent:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"
      
      jwt_authorizer = {
        discovery_url    = "https://accounts.google.com/.well-known/openid-configuration"
        allowed_audience = ["my-app"]
        allowed_clients  = ["client-123"]
      }
    }
  }
  
  providers = {
    aws.project = aws.project
  }
}
```

---
## 📊 Parámetros

### Variables Requeridas

| Variable | Tipo | Descripción | Validación |
|----------|------|-------------|------------|
| `client` | `string` | Nombre del cliente para nomenclatura y etiquetado | 2-20 caracteres, minúsculas, números y guiones |
| `project` | `string` | Nombre del proyecto para nomenclatura y etiquetado | 2-30 caracteres, minúsculas, números y guiones |
| `environment` | `string` | Nombre del entorno (dev, staging, prod) | Debe ser: dev, staging o prod |

### Variables de Configuración de Agentes

#### `agent_runtimes` (map(object))

Mapa de Bedrock AgentCore Runtimes a crear con opciones de configuración detalladas.

**Estructura del Objeto:**

```hcl
agent_runtimes = {
  agent-name = {
    # Configuración básica
    description      = string           # Descripción del agente
    container_uri    = string           # URI de imagen ECR (opcional)
    role_arn         = string           # ARN de rol IAM existente (opcional)
    network_mode     = string           # "PUBLIC" o "VPC" (default: "PUBLIC")
    protocol         = string           # "MCP", "HTTP" o "A2A" (default: "MCP")
    create_endpoint  = bool             # Crear endpoint (default: true)
    endpoint_version = string           # Versión del endpoint (opcional)
    
    # Configuración de código Python (alternativa a container_uri)
    code_configuration = {
      entry_point   = list(string)      # Punto de entrada ["main.py"]
      runtime       = string            # "PYTHON_3_10", "PYTHON_3_11", "PYTHON_3_12", "PYTHON_3_13"
      s3_bucket     = string            # Bucket S3 con el código
      s3_prefix     = string            # Ruta del archivo ZIP en S3
      s3_version_id = string            # ID de versión S3 (opcional)
    }
    
    # Configuración VPC (requerida si network_mode = "VPC")
    vpc_config = {
      security_groups = list(string)    # IDs de security groups
      subnets         = list(string)    # IDs de subnets
    }
    
    # Variables de entorno
    environment_variables = map(string) # Variables de entorno para el agente
    
    # Autenticación JWT (opcional)
    jwt_authorizer = {
      discovery_url    = string         # URL de descubrimiento OIDC
      allowed_audience = list(string)   # Audiencias permitidas (opcional)
      allowed_clients  = list(string)   # Clientes permitidos (opcional)
    }
    
    # Configuración del ciclo de vida (opcional)
    lifecycle_config = {
      idle_timeout = number             # Timeout de inactividad en segundos (60-28800)
      max_lifetime = number             # Tiempo máximo de vida en segundos (60-28800)
    }
    
    # Headers permitidos (opcional)
    allowed_headers = list(string)      # Lista de headers HTTP permitidos
  }
}
```

**Validaciones:**

- Las claves del mapa deben tener 3-63 caracteres (minúsculas, números, guiones)
- Cada agente debe tener `container_uri` O `code_configuration` (no ambos)
- `network_mode` debe ser "PUBLIC" o "VPC"
- `protocol` debe ser "HTTP", "MCP" o "A2A"
- Si `network_mode` es "VPC", `vpc_config` es requerido
- `code_configuration.runtime` debe ser una versión válida de Python
- Los timeouts del ciclo de vida deben estar entre 60 y 28800 segundos
- `idle_timeout` debe ser menor o igual a `max_lifetime`

**Ejemplo:**

```hcl
agent_runtimes = {
  customer-service = {
    description   = "Agente de servicio al cliente"
    container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/customer-service:latest"
    network_mode  = "PUBLIC"
    protocol      = "MCP"
    
    environment_variables = {
      LOG_LEVEL = "INFO"
      MODEL_ID  = "anthropic.claude-3-sonnet-20240229-v1:0"
    }
    
    lifecycle_config = {
      idle_timeout = 1800  # 30 minutos
      max_lifetime = 14400 # 4 horas
    }
  }
}
```

### Variables de Etiquetado

#### `additional_tags` (map(string))

Tags adicionales para aplicar a todos los recursos más allá de los tags base.

**Default:** `{}`

**Validaciones:**
- Las claves deben tener 1-128 caracteres
- Los valores deben tener 0-256 caracteres
- No se puede usar la clave "Name" (se gestiona automáticamente)

**Tags Base Automáticos:**

El módulo aplica automáticamente los siguientes tags a todos los recursos:

```hcl
{
  Client      = var.client
  Project     = var.project
  Environment = var.environment
  ManagedBy   = "terraform"
  Service     = "bedrock-agentcore"
  Name        = "{client}-{project}-{environment}-{resource}"
  Type        = "agent-runtime"
  NetworkMode = "PUBLIC/VPC"
  Protocol    = "MCP/HTTP/A2A"
}
```

**Ejemplo:**

```hcl
additional_tags = {
  CostCenter = "AI-Platform"
  Owner      = "AI-Team"
  Compliance = "SOC2"
}
```

### Variables de Cifrado

#### `enable_encryption` (bool)

Habilitar cifrado para todos los recursos.

**Default:** `true`

**Validación:** Debe ser `true` para cumplimiento de seguridad

#### `kms_key_id` (string)

ID de clave KMS para cifrado.

**Default:** `null` (usa clave administrada por AWS)

**Ejemplo:**

```hcl
kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
```

### Variables de Logging

#### `enable_logging` (bool)

Habilitar logging de CloudWatch para agent runtimes.

**Default:** `true`

#### `log_retention_days` (number)

Período de retención de logs de CloudWatch en días.

**Default:** `30`

**Valores Válidos:** 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0 (nunca expira)

---

## 📤 Outputs

### Outputs de Identificación

#### `agent_runtime_ids`

**Tipo:** `map(string)`

**Descripción:** Mapa de nombres de agent runtimes a sus IDs. Use estos IDs para referenciar los runtimes en otros recursos o módulos.

**Ejemplo de Valor:**

```hcl
{
  customer-service = "agentruntime-abc123def456"
  data-processor   = "agentruntime-xyz789ghi012"
}
```

**Uso:**

```hcl
# Referenciar en otro módulo
resource "aws_cloudwatch_metric_alarm" "agent_errors" {
  alarm_name  = "agent-errors"
  metric_name = "Errors"
  
  dimensions = {
    AgentRuntimeId = module.bedrock_agentcore.agent_runtime_ids["customer-service"]
  }
}
```

#### `agent_runtime_arns`

**Tipo:** `map(string)`

**Descripción:** Mapa de nombres de agent runtimes a sus ARNs. Use estos ARNs para políticas IAM y referencias entre servicios.

**Ejemplo de Valor:**

```hcl
{
  customer-service = "arn:aws:bedrock-agentcore:us-east-1:123456789012:agent-runtime/agentruntime-abc123"
}
```

#### `agent_runtime_versions`

**Tipo:** `map(string)`

**Descripción:** Mapa de nombres de agent runtimes a sus versiones. Use para seguimiento de versiones y gestión de despliegues.

**Ejemplo de Valor:**

```hcl
{
  customer-service = "1"
  data-processor   = "2"
}
```

### Outputs de Endpoints

#### `endpoint_arns`

**Tipo:** `map(string)`

**Descripción:** Mapa de nombres de agent runtimes a sus ARNs de endpoints. Use para configuración de acceso de red y enrutamiento.

**Ejemplo de Valor:**

```hcl
{
  customer-service = "arn:aws:bedrock-agentcore:us-east-1:123456789012:agent-runtime-endpoint/endpoint-abc123"
}
```

#### `workload_identity_arns`

**Tipo:** `map(string)`

**Descripción:** Mapa de nombres de agent runtimes a sus ARNs de identidad de carga de trabajo. Use para acceso entre cuentas y federación de identidades.

**Ejemplo de Valor:**

```hcl
{
  customer-service = "arn:aws:bedrock-agentcore:us-east-1:123456789012:workload-identity/identity-abc123"
}
```

### Outputs de IAM

#### `iam_role_arns`

**Tipo:** `map(string)`

**Descripción:** Mapa de nombres de agent runtimes a sus ARNs de roles IAM. Use para gestión de permisos y adjunción de políticas.

**Ejemplo de Valor:**

```hcl
{
  customer-service = "arn:aws:iam::123456789012:role/acme-ai-platform-prod-agentcore-role-customer-service"
}
```

**Uso:**

```hcl
# Adjuntar política adicional al rol
resource "aws_iam_role_policy_attachment" "additional" {
  role       = module.bedrock_agentcore.iam_role_names["customer-service"]
  policy_arn = aws_iam_policy.custom_policy.arn
}
```

#### `iam_role_names`

**Tipo:** `map(string)`

**Descripción:** Mapa de nombres de agent runtimes a sus nombres de roles IAM. Use para referencia de roles y gestión de políticas.

**Ejemplo de Valor:**

```hcl
{
  customer-service = "acme-ai-platform-prod-agentcore-role-customer-service"
}
```

### Output Consolidado

#### `agent_runtime_configurations`

**Tipo:** `map(object)`

**Descripción:** Resumen completo de configuración para todos los agent runtimes creados. Incluye toda la información relevante para integración con otros módulos o recursos.

**Estructura:**

```hcl
{
  runtime_key = {
    id                    = string  # ID del runtime
    arn                   = string  # ARN del runtime
    version               = string  # Versión del runtime
    endpoint_arn          = string  # ARN del endpoint
    workload_identity_arn = string  # ARN de identidad de carga de trabajo
    role_arn              = string  # ARN del rol IAM
    network_mode          = string  # Modo de red (PUBLIC/VPC)
    protocol              = string  # Protocolo (MCP/HTTP/A2A)
    tags                  = map     # Todos los tags aplicados
  }
}
```

**Ejemplo de Valor:**

```hcl
{
  customer-service = {
    id                    = "agentruntime-abc123def456"
    arn                   = "arn:aws:bedrock-agentcore:us-east-1:123456789012:agent-runtime/agentruntime-abc123"
    version               = "1"
    endpoint_arn          = "arn:aws:bedrock-agentcore:us-east-1:123456789012:agent-runtime-endpoint/endpoint-abc123"
    workload_identity_arn = "arn:aws:bedrock-agentcore:us-east-1:123456789012:workload-identity/identity-abc123"
    role_arn              = "arn:aws:iam::123456789012:role/acme-ai-platform-prod-agentcore-role-customer-service"
    network_mode          = "PUBLIC"
    protocol              = "MCP"
    tags = {
      Client      = "acme"
      Project     = "ai-platform"
      Environment = "prod"
      ManagedBy   = "terraform"
      Service     = "bedrock-agentcore"
      Name        = "acme-ai-platform-prod-agentcore-customer-service"
      Type        = "agent-runtime"
      NetworkMode = "PUBLIC"
      Protocol    = "MCP"
    }
  }
}
```

**Uso:**

```hcl
# Usar en otro módulo
module "monitoring" {
  source = "./monitoring"
  
  agent_configurations = module.bedrock_agentcore.agent_runtime_configurations
}

# Acceder a valores específicos
output "customer_service_endpoint" {
  value = module.bedrock_agentcore.agent_runtime_configurations["customer-service"].endpoint_arn
}
```

---
## 💡 Ejemplos de Uso

### Ejemplo 1: Despliegue Básico con Contenedor ECR

Despliegue simple de un agente usando una imagen de contenedor de ECR.

```hcl
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "acme"
  project     = "ai-platform"
  environment = "prod"

  agent_runtimes = {
    customer-service = {
      description   = "Agente de servicio al cliente"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/customer-service:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      environment_variables = {
        LOG_LEVEL = "INFO"
        MODEL_ID  = "anthropic.claude-3-sonnet-20240229-v1:0"
      }
    }
  }

  providers = {
    aws.project = aws.project
  }
}

# Outputs
output "agent_endpoint" {
  value = module.bedrock_agentcore.endpoint_arns["customer-service"]
}
```

### Ejemplo 2: Agente con Autenticación JWT

Despliegue de un agente con autenticación JWT usando Google como proveedor OIDC.

```hcl
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "acme"
  project     = "ai-platform"
  environment = "prod"

  agent_runtimes = {
    secure-agent = {
      description   = "Agente seguro con autenticación JWT"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/secure-agent:v1.0"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      jwt_authorizer = {
        discovery_url    = "https://accounts.google.com/.well-known/openid-configuration"
        allowed_audience = ["my-app", "mobile-app"]
        allowed_clients  = ["client-123", "client-456"]
      }

      lifecycle_config = {
        idle_timeout = 1800  # 30 minutos
        max_lifetime = 14400 # 4 horas
      }

      environment_variables = {
        LOG_LEVEL    = "DEBUG"
        ENVIRONMENT  = "production"
        FEATURE_FLAG = "enabled"
      }
    }
  }

  enable_logging     = true
  log_retention_days = 90

  additional_tags = {
    CostCenter = "AI-Platform"
    Owner      = "Security-Team"
  }

  providers = {
    aws.project = aws.project
  }
}
```

### Ejemplo 3: Agente Privado en VPC

Despliegue de un agente en una VPC privada con security groups.

```hcl
# Crear VPC y recursos de red
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "agentcore-vpc"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "agentcore-private-${count.index + 1}"
  }
}

resource "aws_security_group" "agentcore" {
  name_prefix = "agentcore-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for Bedrock AgentCore"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "agentcore-sg"
  }
}

# Desplegar agente en VPC
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "acme"
  project     = "ai-platform"
  environment = "prod"

  agent_runtimes = {
    private-agent = {
      description   = "Agente privado en VPC"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/private-agent:latest"
      network_mode  = "VPC"
      protocol      = "HTTP"

      vpc_config = {
        security_groups = [aws_security_group.agentcore.id]
        subnets         = aws_subnet.private[*].id
      }

      environment_variables = {
        DATABASE_ENDPOINT = "db.internal.example.com"
        CACHE_ENDPOINT    = "redis.internal.example.com"
      }
    }
  }

  providers = {
    aws.project = aws.project
  }
}
```

### Ejemplo 4: Despliegue de Código Python desde S3

Despliegue de un agente usando código Python alojado en S3.

```hcl
# Crear bucket S3 para código
resource "aws_s3_bucket" "agent_code" {
  bucket = "acme-ai-platform-prod-agent-code"

  tags = {
    Name = "agent-code-bucket"
  }
}

resource "aws_s3_bucket_versioning" "agent_code" {
  bucket = aws_s3_bucket.agent_code.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Subir código (asumiendo que existe agent-code.zip)
resource "aws_s3_object" "agent_code" {
  bucket = aws_s3_bucket.agent_code.id
  key    = "agents/python-agent-v1.0.zip"
  source = "./agent-code.zip"
  etag   = filemd5("./agent-code.zip")
}

# Desplegar agente con código Python
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "acme"
  project     = "ai-platform"
  environment = "dev"

  agent_runtimes = {
    python-agent = {
      description  = "Agente basado en Python"
      network_mode = "PUBLIC"
      protocol     = "MCP"

      code_configuration = {
        entry_point   = ["main.py"]
        runtime       = "PYTHON_3_13"
        s3_bucket     = aws_s3_bucket.agent_code.id
        s3_prefix     = aws_s3_object.agent_code.key
        s3_version_id = aws_s3_object.agent_code.version_id
      }

      environment_variables = {
        PYTHON_ENV = "production"
        LOG_LEVEL  = "INFO"
      }
    }
  }

  providers = {
    aws.project = aws.project
  }
}
```

### Ejemplo 5: Múltiples Agentes con Diferentes Configuraciones

Despliegue de múltiples agentes con diferentes configuraciones en un solo módulo.

```hcl
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "acme"
  project     = "ai-platform"
  environment = "prod"

  agent_runtimes = {
    # Agente público con MCP
    customer-service = {
      description   = "Agente de servicio al cliente"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/customer-service:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      environment_variables = {
        MODEL_ID = "anthropic.claude-3-sonnet-20240229-v1:0"
      }

      lifecycle_config = {
        idle_timeout = 900   # 15 minutos
        max_lifetime = 3600  # 1 hora
      }
    }

    # Agente privado con HTTP
    data-processor = {
      description   = "Procesador de datos interno"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/data-processor:latest"
      network_mode  = "VPC"
      protocol      = "HTTP"

      vpc_config = {
        security_groups = [aws_security_group.agentcore.id]
        subnets         = aws_subnet.private[*].id
      }

      environment_variables = {
        DATABASE_URL = "postgresql://db.internal:5432/data"
      }
    }

    # Agente con JWT y A2A
    orchestrator = {
      description   = "Orquestador de agentes"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/orchestrator:latest"
      network_mode  = "PUBLIC"
      protocol      = "A2A"

      jwt_authorizer = {
        discovery_url    = "https://auth.example.com/.well-known/openid-configuration"
        allowed_audience = ["orchestrator-api"]
      }

      environment_variables = {
        AGENT_ENDPOINTS = jsonencode({
          customer_service = module.bedrock_agentcore.endpoint_arns["customer-service"]
          data_processor   = module.bedrock_agentcore.endpoint_arns["data-processor"]
        })
      }

      allowed_headers = ["X-Request-ID", "X-Correlation-ID"]
    }

    # Agente Python desde S3
    analytics = {
      description  = "Agente de análisis"
      network_mode = "PUBLIC"
      protocol     = "MCP"

      code_configuration = {
        entry_point = ["analytics_agent.py"]
        runtime     = "PYTHON_3_13"
        s3_bucket   = aws_s3_bucket.agent_code.id
        s3_prefix   = "agents/analytics-v2.0.zip"
      }

      environment_variables = {
        ANALYTICS_MODE = "real-time"
      }
    }
  }

  enable_logging     = true
  log_retention_days = 90
  kms_key_id         = aws_kms_key.agentcore.id

  additional_tags = {
    CostCenter = "AI-Platform"
    Owner      = "AI-Team"
    Compliance = "SOC2"
  }

  providers = {
    aws.project = aws.project
  }
}

# Outputs para integración
output "all_agent_endpoints" {
  description = "Todos los endpoints de agentes"
  value       = module.bedrock_agentcore.endpoint_arns
}

output "all_agent_roles" {
  description = "Todos los roles IAM de agentes"
  value       = module.bedrock_agentcore.iam_role_arns
}
```

### Ejemplo 6: Integración con KMS y CloudWatch

Despliegue con cifrado KMS personalizado y configuración avanzada de logging.

```hcl
# Crear clave KMS
resource "aws_kms_key" "agentcore" {
  description             = "KMS key for Bedrock AgentCore encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "agentcore-kms-key"
  }
}

resource "aws_kms_alias" "agentcore" {
  name          = "alias/agentcore-encryption"
  target_key_id = aws_kms_key.agentcore.key_id
}

# Desplegar agente con KMS
module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "acme"
  project     = "ai-platform"
  environment = "prod"

  agent_runtimes = {
    secure-agent = {
      description   = "Agente con cifrado KMS"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/secure-agent:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      environment_variables = {
        ENCRYPTION_ENABLED = "true"
      }
    }
  }

  enable_logging     = true
  log_retention_days = 365  # 1 año para cumplimiento
  kms_key_id         = aws_kms_key.agentcore.id

  additional_tags = {
    Compliance = "HIPAA"
    DataClass  = "Sensitive"
  }

  providers = {
    aws.project = aws.project
  }
}

# Crear alarma de CloudWatch
resource "aws_cloudwatch_metric_alarm" "agent_errors" {
  alarm_name          = "agentcore-high-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/BedrockAgentCore"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Alert when agent errors exceed threshold"

  dimensions = {
    AgentRuntimeId = module.bedrock_agentcore.agent_runtime_ids["secure-agent"]
  }
}
```

---
## 🎯 Escenarios de Uso Comunes

### Escenario 1: Chatbot de Atención al Cliente

**Caso de Uso:** Implementar un chatbot de IA para atención al cliente 24/7 con acceso a modelos de Bedrock.

**Requisitos:**
- Acceso público desde aplicaciones web y móviles
- Autenticación de usuarios
- Sesiones de conversación con timeout
- Logging para análisis de calidad

**Implementación:**

```hcl
module "customer_chatbot" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "retail-corp"
  project     = "customer-support"
  environment = "prod"

  agent_runtimes = {
    chatbot = {
      description   = "Chatbot de atención al cliente"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/chatbot:latest"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      jwt_authorizer = {
        discovery_url    = "https://auth.retail-corp.com/.well-known/openid-configuration"
        allowed_audience = ["customer-portal", "mobile-app"]
      }

      lifecycle_config = {
        idle_timeout = 1800  # 30 minutos de inactividad
        max_lifetime = 7200  # 2 horas máximo
      }

      environment_variables = {
        MODEL_ID           = "anthropic.claude-3-sonnet-20240229-v1:0"
        MAX_TOKENS         = "2048"
        TEMPERATURE        = "0.7"
        KNOWLEDGE_BASE_ID  = "kb-123456"
        CONVERSATION_MODE  = "customer-service"
      }
    }
  }

  enable_logging     = true
  log_retention_days = 90

  additional_tags = {
    Application = "CustomerSupport"
    CostCenter  = "CustomerService"
  }

  providers = {
    aws.project = aws.project
  }
}
```

### Escenario 2: Procesamiento de Datos Sensibles en VPC

**Caso de Uso:** Agente de IA que procesa datos sensibles con acceso a bases de datos internas.

**Requisitos:**
- Aislamiento completo en VPC privada
- Acceso a bases de datos internas
- Cifrado con KMS
- Sin acceso público

**Implementación:**

```hcl
# Infraestructura VPC
resource "aws_vpc" "data_processing" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.data_processing.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_security_group" "data_agent" {
  name_prefix = "data-agent-"
  vpc_id      = aws_vpc.data_processing.id

  # Permitir acceso a RDS
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "PostgreSQL access"
  }

  # Permitir acceso a Bedrock
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for Bedrock API"
  }
}

# KMS para cifrado
resource "aws_kms_key" "data_encryption" {
  description             = "Data processing encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

# Agente de procesamiento
module "data_processor" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "healthcare-corp"
  project     = "data-analytics"
  environment = "prod"

  agent_runtimes = {
    data-processor = {
      description   = "Procesador de datos sensibles"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/data-processor:latest"
      network_mode  = "VPC"
      protocol      = "HTTP"

      vpc_config = {
        security_groups = [aws_security_group.data_agent.id]
        subnets         = aws_subnet.private[*].id
      }

      environment_variables = {
        DATABASE_HOST     = "rds.internal.healthcare-corp.com"
        DATABASE_PORT     = "5432"
        DATABASE_NAME     = "patient_data"
        ENCRYPTION_MODE   = "AES256"
        COMPLIANCE_MODE   = "HIPAA"
      }

      lifecycle_config = {
        idle_timeout = 300   # 5 minutos
        max_lifetime = 3600  # 1 hora
      }
    }
  }

  enable_logging     = true
  log_retention_days = 2557  # 7 años para HIPAA
  kms_key_id         = aws_kms_key.data_encryption.id

  additional_tags = {
    Compliance  = "HIPAA"
    DataClass   = "PHI"
    Environment = "Production"
  }

  providers = {
    aws.project = aws.project
  }
}
```

### Escenario 3: Arquitectura Multi-Agente (Agent-to-Agent)

**Caso de Uso:** Sistema de múltiples agentes especializados que se comunican entre sí.

**Requisitos:**
- Agente orquestador que coordina otros agentes
- Agentes especializados (análisis, generación, validación)
- Comunicación A2A entre agentes
- Trazabilidad completa

**Implementación:**

```hcl
module "multi_agent_system" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "fintech-corp"
  project     = "ai-platform"
  environment = "prod"

  agent_runtimes = {
    # Agente orquestador
    orchestrator = {
      description   = "Orquestador principal"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/orchestrator:latest"
      network_mode  = "PUBLIC"
      protocol      = "A2A"

      environment_variables = {
        ROLE              = "orchestrator"
        AGENT_DISCOVERY   = "enabled"
        TRACING_ENABLED   = "true"
      }

      allowed_headers = ["X-Request-ID", "X-Correlation-ID", "X-Agent-Chain"]
    }

    # Agente de análisis
    analyzer = {
      description   = "Agente de análisis de datos"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/analyzer:latest"
      network_mode  = "PUBLIC"
      protocol      = "A2A"

      environment_variables = {
        ROLE            = "analyzer"
        MODEL_ID        = "anthropic.claude-3-sonnet-20240229-v1:0"
        ANALYSIS_DEPTH  = "comprehensive"
      }
    }

    # Agente generador
    generator = {
      description   = "Agente generador de contenido"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/generator:latest"
      network_mode  = "PUBLIC"
      protocol      = "A2A"

      environment_variables = {
        ROLE         = "generator"
        MODEL_ID     = "anthropic.claude-3-opus-20240229-v1:0"
        OUTPUT_FORMAT = "structured"
      }
    }

    # Agente validador
    validator = {
      description   = "Agente validador de resultados"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/validator:latest"
      network_mode  = "PUBLIC"
      protocol      = "A2A"

      environment_variables = {
        ROLE              = "validator"
        VALIDATION_RULES  = "strict"
        QUALITY_THRESHOLD = "0.95"
      }
    }
  }

  enable_logging     = true
  log_retention_days = 90

  additional_tags = {
    Architecture = "MultiAgent"
    Pattern      = "Orchestration"
  }

  providers = {
    aws.project = aws.project
  }
}

# Configurar comunicación entre agentes
resource "aws_iam_role_policy" "agent_communication" {
  for_each = module.multi_agent_system.iam_role_names

  name = "agent-communication-policy"
  role = each.value

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock-agentcore:InvokeAgent",
          "bedrock-agentcore:InvokeAgentWithResponseStream"
        ]
        Resource = values(module.multi_agent_system.agent_runtime_arns)
      }
    ]
  })
}
```

### Escenario 4: Desarrollo y Testing con Múltiples Entornos

**Caso de Uso:** Despliegue del mismo agente en múltiples entornos (dev, staging, prod).

**Requisitos:**
- Configuraciones diferentes por entorno
- Costos optimizados en dev
- Seguridad máxima en prod
- Facilidad de promoción entre entornos

**Implementación:**

```hcl
# variables.tf
variable "environment_configs" {
  type = map(object({
    log_retention_days = number
    idle_timeout       = number
    max_lifetime       = number
    model_id           = string
    enable_kms         = bool
  }))

  default = {
    dev = {
      log_retention_days = 7
      idle_timeout       = 300   # 5 minutos
      max_lifetime       = 1800  # 30 minutos
      model_id           = "anthropic.claude-3-haiku-20240307-v1:0"  # Modelo más económico
      enable_kms         = false
    }
    staging = {
      log_retention_days = 30
      idle_timeout       = 900   # 15 minutos
      max_lifetime       = 3600  # 1 hora
      model_id           = "anthropic.claude-3-sonnet-20240229-v1:0"
      enable_kms         = true
    }
    prod = {
      log_retention_days = 365
      idle_timeout       = 1800  # 30 minutos
      max_lifetime       = 14400 # 4 horas
      model_id           = "anthropic.claude-3-opus-20240229-v1:0"  # Modelo más potente
      enable_kms         = true
    }
  }
}

# main.tf
locals {
  env_config = var.environment_configs[var.environment]
}

module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "startup-corp"
  project     = "ai-assistant"
  environment = var.environment

  agent_runtimes = {
    assistant = {
      description   = "AI Assistant - ${upper(var.environment)}"
      container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/assistant:${var.image_tag}"
      network_mode  = "PUBLIC"
      protocol      = "MCP"

      lifecycle_config = {
        idle_timeout = local.env_config.idle_timeout
        max_lifetime = local.env_config.max_lifetime
      }

      environment_variables = {
        ENVIRONMENT = var.environment
        MODEL_ID    = local.env_config.model_id
        LOG_LEVEL   = var.environment == "prod" ? "INFO" : "DEBUG"
      }
    }
  }

  enable_logging     = true
  log_retention_days = local.env_config.log_retention_days
  kms_key_id         = local.env_config.enable_kms ? aws_kms_key.agentcore[0].id : null

  additional_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  providers = {
    aws.project = aws.project
  }
}

# KMS solo para staging y prod
resource "aws_kms_key" "agentcore" {
  count = local.env_config.enable_kms ? 1 : 0

  description             = "AgentCore encryption key - ${var.environment}"
  deletion_window_in_days = var.environment == "prod" ? 30 : 7
  enable_key_rotation     = var.environment == "prod"
}
```

### Escenario 5: Agente con Código Python Actualizable

**Caso de Uso:** Agente Python que se actualiza frecuentemente sin reconstruir contenedores.

**Requisitos:**
- Despliegue rápido de cambios de código
- Versionado de código
- Rollback fácil
- CI/CD integrado

**Implementación:**

```hcl
# S3 bucket para código
resource "aws_s3_bucket" "agent_code" {
  bucket = "mycompany-agent-code-${var.environment}"
}

resource "aws_s3_bucket_versioning" "agent_code" {
  bucket = aws_s3_bucket.agent_code.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Subir código con versionado
resource "aws_s3_object" "agent_code" {
  bucket = aws_s3_bucket.agent_code.id
  key    = "agents/my-agent-${var.code_version}.zip"
  source = "./dist/agent-${var.code_version}.zip"
  etag   = filemd5("./dist/agent-${var.code_version}.zip")

  lifecycle {
    create_before_destroy = true
  }
}

# Desplegar agente
module "python_agent" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  client      = "mycompany"
  project     = "python-agents"
  environment = var.environment

  agent_runtimes = {
    data-analyzer = {
      description  = "Python Data Analyzer - v${var.code_version}"
      network_mode = "PUBLIC"
      protocol     = "MCP"

      code_configuration = {
        entry_point   = ["main.py"]
        runtime       = "PYTHON_3_13"
        s3_bucket     = aws_s3_bucket.agent_code.id
        s3_prefix     = aws_s3_object.agent_code.key
        s3_version_id = aws_s3_object.agent_code.version_id
      }

      environment_variables = {
        CODE_VERSION = var.code_version
        ENVIRONMENT  = var.environment
        LOG_LEVEL    = "INFO"
      }
    }
  }

  providers = {
    aws.project = aws.project
  }
}

# Output para CI/CD
output "deployed_code_version" {
  value = var.code_version
}

output "agent_endpoint" {
  value = module.python_agent.endpoint_arns["data-analyzer"]
}
```

---

## 🔒 Seguridad y Cumplimiento

### Principios de Seguridad

#### 1. Defensa en Profundidad

El módulo implementa múltiples capas de seguridad:

- **Capa de Red**: VPC, security groups, subnets privadas
- **Capa de Autenticación**: JWT, IAM, OIDC
- **Capa de Autorización**: Políticas IAM de mínimo privilegio
- **Capa de Cifrado**: KMS para datos en reposo, TLS para datos en tránsito
- **Capa de Auditoría**: CloudWatch Logs, AWS CloudTrail

#### 2. Principio de Mínimo Privilegio

Las políticas IAM creadas automáticamente incluyen solo los permisos necesarios:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": [
        "arn:aws:bedrock:*::foundation-model/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:region:account:log-group:/aws/bedrock-agentcore/runtimes/*:log-stream:*"
      ]
    }
  ]
}
```

#### 3. Aislamiento de Sesiones

Cada sesión de usuario se ejecuta en una microVM aislada:

- Recursos de CPU y memoria dedicados
- Sistema de archivos efímero
- Sin persistencia entre sesiones
- Limpieza automática al finalizar

### Cifrado

#### Datos en Reposo

- **Imágenes ECR**: Cifradas con KMS o AWS managed keys
- **Código S3**: Cifrado SSE-KMS o SSE-S3
- **Logs CloudWatch**: Cifrados con KMS (opcional)
- **Variables de Entorno**: Cifradas en tránsito y en reposo

**Configuración de KMS:**

```hcl
resource "aws_kms_key" "agentcore" {
  description             = "Bedrock AgentCore encryption key"
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
        Sid    = "Allow Bedrock AgentCore"
        Effect = "Allow"
        Principal = {
          Service = "bedrock-agentcore.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}

module "bedrock_agentcore" {
  source = "./terraform-aws-bedrock-agentcore-runtime"
  
  # ... otras configuraciones ...
  
  kms_key_id = aws_kms_key.agentcore.id
}
```

#### Datos en Tránsito

- **TLS 1.2+**: Todas las comunicaciones usan TLS 1.2 o superior
- **Certificados**: Gestionados automáticamente por AWS
- **VPC Endpoints**: Tráfico privado sin salir de la red AWS

### Autenticación y Autorización

#### JWT (JSON Web Tokens)

Configuración con proveedor OIDC:

```hcl
agent_runtimes = {
  secure-agent = {
    jwt_authorizer = {
      discovery_url    = "https://auth.example.com/.well-known/openid-configuration"
      allowed_audience = ["api-gateway", "mobile-app"]
      allowed_clients  = ["client-id-123", "client-id-456"]
    }
  }
}
```

**Flujo de Autenticación:**

1. Cliente obtiene JWT del proveedor OIDC
2. Cliente envía JWT en header `Authorization: Bearer <token>`
3. AgentCore valida el JWT contra el discovery URL
4. AgentCore verifica audience y client ID
5. Si es válido, procesa la solicitud

#### IAM

Para comunicación service-to-service:

```hcl
# Política para invocar agente desde Lambda
resource "aws_iam_role_policy" "lambda_invoke_agent" {
  name = "invoke-agent-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock-agentcore:InvokeAgent",
          "bedrock-agentcore:InvokeAgentWithResponseStream"
        ]
        Resource = module.bedrock_agentcore.agent_runtime_arns["my-agent"]
      }
    ]
  })
}
```

### Seguridad de Red

#### Modo Público

- Accesible desde internet
- **Requiere** autenticación JWT o IAM
- Protegido por AWS Shield Standard
- Logs de acceso en CloudWatch

**Recomendaciones:**
- Siempre usar JWT authorizer
- Implementar rate limiting en API Gateway
- Monitorear patrones de acceso anómalos

#### Modo VPC

- Aislado en VPC privada
- Control con security groups
- Sin acceso directo desde internet
- Acceso a recursos internos

**Configuración Segura:**

```hcl
# Security group restrictivo
resource "aws_security_group" "agentcore" {
  name_prefix = "agentcore-"
  vpc_id      = aws_vpc.main.id

  # Sin ingress rules (solo outbound)
  
  # Egress solo a servicios necesarios
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for AWS APIs"
  }

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds.id]
    description     = "PostgreSQL access"
  }
}

agent_runtimes = {
  private-agent = {
    network_mode = "VPC"
    vpc_config = {
      security_groups = [aws_security_group.agentcore.id]
      subnets         = aws_subnet.private[*].id  # Solo subnets privadas
    }
  }
}
```

### Cumplimiento Normativo

#### HIPAA (Health Insurance Portability and Accountability Act)

**Requisitos:**
- Cifrado de datos en reposo y en tránsito ✅
- Logs de auditoría ✅
- Controles de acceso ✅
- Retención de logs (mínimo 6 años) ✅

**Configuración:**

```hcl
module "hipaa_compliant_agent" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  agent_runtimes = {
    healthcare-agent = {
      description   = "HIPAA compliant healthcare agent"
      container_uri = "..."
      network_mode  = "VPC"  # Requerido para HIPAA
      
      vpc_config = {
        security_groups = [aws_security_group.hipaa.id]
        subnets         = aws_subnet.private[*].id
      }
    }
  }

  enable_logging     = true
  log_retention_days = 2557  # 7 años
  kms_key_id         = aws_kms_key.hipaa.id  # KMS requerido

  additional_tags = {
    Compliance = "HIPAA"
    DataClass  = "PHI"
  }
}
```

#### SOC 2 (Service Organization Control 2)

**Requisitos:**
- Controles de acceso ✅
- Monitoreo y alertas ✅
- Gestión de cambios ✅
- Respaldo y recuperación ✅

**Configuración:**

```hcl
module "soc2_compliant_agent" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  agent_runtimes = {
    secure-agent = {
      jwt_authorizer = {
        discovery_url = "..."  # Autenticación requerida
      }
    }
  }

  enable_logging     = true
  log_retention_days = 365  # Mínimo 1 año

  additional_tags = {
    Compliance = "SOC2"
    Owner      = "security-team@example.com"
    ChangeControl = "terraform"
  }
}

# Alertas de seguridad
resource "aws_cloudwatch_metric_alarm" "unauthorized_access" {
  alarm_name          = "agentcore-unauthorized-access"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAccess"
  namespace           = "AWS/BedrockAgentCore"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}
```

#### GDPR (General Data Protection Regulation)

**Requisitos:**
- Derecho al olvido ✅ (sesiones efímeras)
- Minimización de datos ✅
- Cifrado ✅
- Logs de acceso ✅

**Configuración:**

```hcl
module "gdpr_compliant_agent" {
  source = "./terraform-aws-bedrock-agentcore-runtime"

  agent_runtimes = {
    eu-agent = {
      description  = "GDPR compliant agent"
      network_mode = "VPC"
      
      lifecycle_config = {
        idle_timeout = 900   # Sesiones cortas
        max_lifetime = 3600  # Máximo 1 hora
      }
      
      environment_variables = {
        DATA_RETENTION_POLICY = "minimal"
        ANONYMIZATION_ENABLED = "true"
        REGION                = "eu-west-1"
      }
    }
  }

  enable_logging     = true
  log_retention_days = 90  # Retención limitada

  additional_tags = {
    Compliance  = "GDPR"
    DataRegion  = "EU"
    DataClass   = "PersonalData"
  }
}
```

### Mejores Prácticas de Seguridad

#### 1. Gestión de Secretos

**NO hacer:**
```hcl
# ❌ No incluir secretos en variables de entorno
environment_variables = {
  API_KEY      = "sk-1234567890abcdef"  # ❌ MAL
  DB_PASSWORD  = "mypassword123"        # ❌ MAL
}
```

**Hacer:**
```hcl
# ✅ Usar AWS Secrets Manager
resource "aws_secretsmanager_secret" "api_key" {
  name = "agentcore/api-key"
}

# ✅ Dar permisos al rol del agente
resource "aws_iam_role_policy" "secrets_access" {
  role = module.bedrock_agentcore.iam_role_names["my-agent"]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.api_key.arn
      }
    ]
  })
}

# ✅ Referenciar en código del agente
environment_variables = {
  SECRET_ARN = aws_secretsmanager_secret.api_key.arn
}
```

#### 2. Rotación de Credenciales

```hcl
# Rotación automática de secretos
resource "aws_secretsmanager_secret_rotation" "api_key" {
  secret_id           = aws_secretsmanager_secret.api_key.id
  rotation_lambda_arn = aws_lambda_function.rotate_secret.arn

  rotation_rules {
    automatically_after_days = 30
  }
}
```

#### 3. Monitoreo de Seguridad

```hcl
# CloudWatch Logs Insights para detectar patrones sospechosos
resource "aws_cloudwatch_log_metric_filter" "failed_auth" {
  name           = "failed-authentication-attempts"
  log_group_name = "/aws/bedrock-agentcore/runtimes/*"
  pattern        = "[time, request_id, event_type = AuthenticationFailed, ...]"

  metric_transformation {
    name      = "FailedAuthAttempts"
    namespace = "Security/AgentCore"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "auth_failures" {
  alarm_name          = "high-failed-auth-attempts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedAuthAttempts"
  namespace           = "Security/AgentCore"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
}
```

#### 4. Auditoría con CloudTrail

```hcl
# Habilitar CloudTrail para auditoría
resource "aws_cloudtrail" "agentcore_audit" {
  name                          = "agentcore-audit-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::BedrockAgentCore::AgentRuntime"
      values = ["arn:aws:bedrock-agentcore:*:${data.aws_caller_identity.current.account_id}:agent-runtime/*"]
    }
  }
}
```

---
## 📝 Observaciones

### Limitaciones Conocidas

#### 1. Disponibilidad Regional

Amazon Bedrock AgentCore Runtime no está disponible en todas las regiones de AWS. Verifique la disponibilidad antes del despliegue:

```bash
# Verificar disponibilidad en una región
aws bedrock-agentcore list-agent-runtimes --region us-east-1

# Regiones comúnmente soportadas (verificar documentación oficial):
# - us-east-1 (N. Virginia)
# - us-west-2 (Oregon)
# - eu-west-1 (Ireland)
# - ap-southeast-1 (Singapore)
```

**Solución:** Desplegar en una región soportada o usar multi-región con failover.

#### 2. Límites de Servicio

| Recurso | Límite por Defecto | Ajustable |
|---------|-------------------|-----------|
| Agent Runtimes por cuenta | 50 | Sí (Service Quotas) |
| Sesiones concurrentes por runtime | 100 | Sí |
| Tamaño máximo de imagen ECR | 10 GB | No |
| Tamaño máximo de código S3 | 250 MB | No |
| Variables de entorno | 100 | No |
| Timeout máximo de sesión | 28800 segundos (8 horas) | No |

**Solicitar aumento de límites:**

```bash
aws service-quotas request-service-quota-increase \
  --service-code bedrock-agentcore \
  --quota-code L-XXXXXXXX \
  --desired-value 100
```

#### 3. Restricciones de Nomenclatura

- **Agent Runtime Names**: Deben usar guiones bajos (_) en lugar de guiones (-)
- **Longitud**: 3-63 caracteres
- **Caracteres**: Solo minúsculas, números y guiones bajos

**El módulo maneja esto automáticamente:**

```hcl
# Input del usuario
agent_runtimes = {
  "customer-service" = { ... }  # Con guiones
}

# El módulo convierte automáticamente
agent_runtime_name = "acme_ai_platform_prod_agentcore_customer_service"  # Con guiones bajos
```

#### 4. Actualizaciones de Contenedores

Los cambios en `container_uri` requieren recreación del runtime:

```hcl
# Esto causará recreación
agent_runtimes = {
  my-agent = {
    container_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/agent:v2.0"  # Cambio de versión
  }
}
```

**Estrategia de actualización sin downtime:**

```hcl
# 1. Crear nuevo runtime con nueva versión
agent_runtimes = {
  my-agent-v1 = {
    container_uri = "...agent:v1.0"
  }
  my-agent-v2 = {
    container_uri = "...agent:v2.0"
  }
}

# 2. Migrar tráfico gradualmente
# 3. Eliminar versión antigua
```

### Consideraciones de Costos

#### Modelo de Precios

Amazon Bedrock AgentCore Runtime cobra por:

1. **Tiempo de Ejecución**: Por segundo de sesión activa
2. **Invocaciones de Modelos**: Según el modelo de Bedrock usado
3. **Transferencia de Datos**: Salida de datos desde el runtime
4. **Almacenamiento**: Logs en CloudWatch, imágenes en ECR

**Estimación de costos:**

```hcl
# Ejemplo de cálculo mensual (aproximado)
# - 1000 sesiones/día
# - Duración promedio: 5 minutos
# - Modelo: Claude 3 Sonnet
# - Región: us-east-1

# Runtime: 1000 * 5 * 60 * 30 = 9,000,000 segundos/mes
# Costo runtime: ~$0.0001/segundo = $900/mes

# Invocaciones Bedrock: Variable según uso
# Logs CloudWatch: ~$0.50/GB = $10-50/mes

# Total estimado: $1000-1500/mes
```

#### Optimización de Costos

**1. Ajustar Timeouts:**

```hcl
lifecycle_config = {
  idle_timeout = 300   # Terminar sesiones inactivas rápidamente
  max_lifetime = 1800  # Limitar duración máxima
}
```

**2. Usar Modelos Apropiados:**

```hcl
# Desarrollo: Usar modelos más económicos
environment_variables = {
  MODEL_ID = var.environment == "prod" ? 
    "anthropic.claude-3-opus-20240229-v1:0" :    # Prod: Mejor calidad
    "anthropic.claude-3-haiku-20240307-v1:0"     # Dev: Más económico
}
```

**3. Optimizar Logs:**

```hcl
log_retention_days = var.environment == "prod" ? 90 : 7  # Menos retención en dev
```

**4. Monitorear Uso:**

```hcl
resource "aws_cloudwatch_metric_alarm" "high_costs" {
  alarm_name          = "agentcore-high-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SessionDuration"
  namespace           = "AWS/BedrockAgentCore"
  period              = 86400  # Diario
  statistic           = "Sum"
  threshold           = 3600000  # 1000 horas/día
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]
}
```

### Troubleshooting

#### Problema 1: Error de Permisos IAM

**Síntoma:**
```
Error: AccessDeniedException: User is not authorized to perform: bedrock-agentcore:CreateAgentRuntime
```

**Solución:**

```hcl
# Verificar permisos del usuario/rol que ejecuta Terraform
data "aws_iam_policy_document" "terraform_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "bedrock-agentcore:*",
      "iam:CreateRole",
      "iam:PutRolePolicy",
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
}
```

#### Problema 2: Imagen ECR No Encontrada

**Síntoma:**
```
Error: Container image not found: 123456789012.dkr.ecr.us-east-1.amazonaws.com/agent:latest
```

**Solución:**

```bash
# Verificar que la imagen existe
aws ecr describe-images \
  --repository-name agent \
  --image-ids imageTag=latest \
  --region us-east-1

# Verificar permisos del rol del agente
aws ecr get-repository-policy \
  --repository-name agent \
  --region us-east-1
```

#### Problema 3: Timeout de Sesión

**Síntoma:**
```
SessionTimeoutException: Session exceeded maximum lifetime
```

**Solución:**

```hcl
# Aumentar timeouts
lifecycle_config = {
  idle_timeout = 3600   # 1 hora
  max_lifetime = 14400  # 4 horas (máximo permitido)
}
```

#### Problema 4: Error de VPC

**Síntoma:**
```
Error: InvalidSubnetID: The subnet ID 'subnet-xxx' does not exist
```

**Solución:**

```hcl
# Verificar que las subnets existen y están en la región correcta
data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

# Usar data source para validación
vpc_config = {
  subnets = [for s in data.aws_subnet.selected : s.id]
}
```

### Mejores Prácticas

#### 1. Gestión de Estado de Terraform

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "bedrock-agentcore/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/..."
  }
}
```

#### 2. Uso de Workspaces

```bash
# Crear workspaces por entorno
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Usar workspace en configuración
locals {
  environment = terraform.workspace
}
```

#### 3. Validación Pre-Deploy

```bash
# Script de validación
#!/bin/bash

echo "Validando configuración..."

# Validar sintaxis
terraform fmt -check
terraform validate

# Verificar disponibilidad regional
aws bedrock-agentcore list-agent-runtimes --region $AWS_REGION

# Verificar límites de servicio
aws service-quotas get-service-quota \
  --service-code bedrock-agentcore \
  --quota-code L-XXXXXXXX

# Verificar imágenes ECR
for image in $(terraform output -json | jq -r '.container_uris.value[]'); do
  echo "Verificando $image..."
  aws ecr describe-images --repository-name $(echo $image | cut -d'/' -f2 | cut -d':' -f1)
done

echo "Validación completada"
```

#### 4. Testing

```hcl
# test/main_test.go
package test

import (
  "testing"
  "github.com/gruntwork-io/terratest/modules/terraform"
  "github.com/stretchr/testify/assert"
)

func TestBedrockAgentCoreModule(t *testing.T) {
  terraformOptions := &terraform.Options{
    TerraformDir: "../examples/basic",
    Vars: map[string]interface{}{
      "client":      "test",
      "project":     "terratest",
      "environment": "dev",
    },
  }

  defer terraform.Destroy(t, terraformOptions)
  terraform.InitAndApply(t, terraformOptions)

  // Verificar outputs
  agentRuntimeIds := terraform.OutputMap(t, terraformOptions, "agent_runtime_ids")
  assert.NotEmpty(t, agentRuntimeIds)
}
```

#### 5. CI/CD Pipeline

```yaml
# .github/workflows/terraform.yml
name: Terraform CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Format
        run: terraform fmt -check
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Validate
        run: terraform validate
      
      - name: Terraform Plan
        run: terraform plan -out=tfplan
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
```

### Recursos Adicionales

#### Documentación Oficial

- [AWS Bedrock AgentCore Documentation](https://docs.aws.amazon.com/bedrock-agentcore/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon Bedrock Models](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)

#### Herramientas Recomendadas

- **Terraform**: >= 1.5.0
- **AWS CLI**: >= 2.0
- **Docker**: Para construir imágenes de contenedor
- **Terratest**: Para testing de infraestructura
- **tflint**: Para linting de código Terraform
- **checkov**: Para escaneo de seguridad

#### Comunidad y Soporte

- **GitHub Issues**: Para reportar bugs o solicitar features
- **AWS Support**: Para problemas con servicios de AWS
- **Terraform Community**: Para preguntas sobre Terraform

### Changelog

Ver [CHANGELOG.md](./CHANGELOG.md) para el historial completo de cambios.

#### Versión 1.0.0 (2024-12-03)

**Características Iniciales:**
- ✅ Soporte para múltiples agent runtimes
- ✅ Despliegue con contenedores ECR
- ✅ Despliegue con código Python desde S3
- ✅ Configuración de red (PUBLIC/VPC)
- ✅ Autenticación JWT
- ✅ Gestión de ciclo de vida
- ✅ Integración con IAM
- ✅ Cifrado con KMS
- ✅ Logging en CloudWatch
- ✅ Sistema de etiquetado empresarial

### Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/amazing-feature`)
3. Commit tus cambios (`git commit -m 'Add amazing feature'`)
4. Push a la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

**Guías de Contribución:**

- Seguir las convenciones de código de Terraform
- Incluir validaciones en variables
- Actualizar documentación
- Agregar ejemplos funcionales
- Incluir tests cuando sea posible

### Licencia

Este módulo está licenciado bajo Apache 2.0 License. Ver [LICENSE](./LICENSE) para más detalles.

### Contacto

Para preguntas, issues o contribuciones:

- **Email**: cloudops@somospragma.com
- **GitHub**: [https://github.com/somospragma/terraform-aws-bedrock-agentcore-runtime](https://github.com/somospragma/terraform-aws-bedrock-agentcore-runtime)
- **Documentación**: [README.md](./README.md)

---

## 📚 Apéndices

### Apéndice A: Referencia Rápida de Comandos

```bash
# Inicialización
terraform init
terraform workspace new prod

# Validación
terraform fmt -recursive
terraform validate
terraform plan

# Despliegue
terraform apply
terraform apply -auto-approve

# Consulta
terraform output
terraform output agent_runtime_ids
terraform show

# Limpieza
terraform destroy
terraform destroy -target=module.bedrock_agentcore.aws_bedrockagentcore_agent_runtime.this["agent-name"]

# Estado
terraform state list
terraform state show module.bedrock_agentcore.aws_bedrockagentcore_agent_runtime.this["agent-name"]

# Importación
terraform import module.bedrock_agentcore.aws_bedrockagentcore_agent_runtime.this["agent-name"] agentruntime-abc123
```

### Apéndice B: Variables de Entorno Comunes

```bash
# AWS
export AWS_REGION=us-east-1
export AWS_PROFILE=default
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Terraform
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
export TF_VAR_client=acme
export TF_VAR_project=ai-platform
export TF_VAR_environment=prod
```

### Apéndice C: Ejemplos de Políticas IAM

#### Política para Desarrolladores

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock-agentcore:List*",
        "bedrock-agentcore:Describe*",
        "bedrock-agentcore:Get*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "bedrock-agentcore:InvokeAgent"
      ],
      "Resource": "arn:aws:bedrock-agentcore:*:*:agent-runtime/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    }
  ]
}
```

#### Política para Administradores

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "bedrock-agentcore:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:PutRolePolicy",
        "iam:AttachRolePolicy",
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::*:role/*agentcore*"
    }
  ]
}
```

### Apéndice D: Glosario

| Término | Definición |
|---------|------------|
| **Agent Runtime** | Entorno de ejecución containerizado para agentes de IA |
| **MicroVM** | Máquina virtual ligera que proporciona aislamiento de sesiones |
| **MCP** | Model Context Protocol - Protocolo estándar para comunicación con modelos de IA |
| **A2A** | Agent-to-Agent - Protocolo para comunicación entre agentes |
| **JWT** | JSON Web Token - Estándar para tokens de autenticación |
| **OIDC** | OpenID Connect - Protocolo de autenticación sobre OAuth 2.0 |
| **KMS** | Key Management Service - Servicio de gestión de claves de AWS |
| **ECR** | Elastic Container Registry - Registro de contenedores de AWS |
| **VPC** | Virtual Private Cloud - Red privada virtual en AWS |
| **IAM** | Identity and Access Management - Gestión de identidades y accesos |

---

**Última actualización:** 09-12-2025

**Versión del documento:** 1.0.0

**Mantenido por:** Pragma - CloudOps Team

---

> Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción.