# Sample Implementation - Bedrock AgentCore Runtime

## Descripción

Este directorio contiene un ejemplo funcional de consumo del módulo de referencia Bedrock AgentCore Runtime, siguiendo el patrón de transformación PC-IAC-026.

## Flujo de Datos

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → ../
     (config)        (tipos)     (consulta)  (transform)  (invoca módulo padre)
```

## Prerequisitos

- Terraform >= 1.5.0
- AWS CLI configurado con credenciales apropiadas
- IAM Role para AgentCore creado previamente en el dominio de Seguridad
- Repositorios ECR con las imágenes de los agentes

## Ejecución

```bash
terraform init
terraform plan
terraform apply
```

## Archivos

| Archivo | Responsabilidad |
|---------|----------------|
| `terraform.tfvars` | Configuración declarativa sin IDs hardcodeados |
| `variables.tf` | Definición de tipos de variables |
| `data.tf` | Data sources para obtener IDs dinámicos |
| `locals.tf` | Transformaciones e inyección de IDs desde data sources |
| `main.tf` | Invocación del módulo padre (`source = "../"`) |
| `providers.tf` | Configuración del provider con alias y default_tags |
| `outputs.tf` | Outputs del ejemplo |
