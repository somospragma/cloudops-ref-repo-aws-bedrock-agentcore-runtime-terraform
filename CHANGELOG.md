# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **BREAKING**: `role_arn` es ahora obligatorio en `agent_runtimes` (PC-IAC-023). Los roles IAM deben crearse en el dominio de Seguridad.
- **BREAKING**: Eliminada creación automática de roles IAM (`aws_iam_role`, `aws_iam_role_policy`) del módulo.
- **BREAKING**: Eliminados outputs `iam_role_arns` e `iam_role_names`.
- **BREAKING**: `environment` ahora acepta `dev`, `qa`, `pdn` en lugar de `dev`, `staging`, `prod`.
- Agregado `configuration_aliases = [aws.project]` en `versions.tf` (PC-IAC-005).
- Activados tags en todos los recursos con `merge()` y `Name` explícito (PC-IAC-004).
- Agregadas validaciones faltantes en `kms_key_id`, `enable_logging` (PC-IAC-002).
- Descomentada validación de keys de `agent_runtimes`.
- Simplificado output `agent_runtime_configurations` para exponer solo IDs, ARNs y versions (PC-IAC-007).
- Reestructurado `sample/` con patrón de transformación PC-IAC-026.
- Eliminado directorio `examples/` (PC-IAC-001 solo permite `sample/`).

### Added
- `sample/locals.tf` con transformaciones e inyección dinámica de role_arn.
- `sample/data.tf` con data source para obtener IAM role por nomenclatura.
- `sample/providers.tf` con configuración de provider separada.
- Comentarios de referencia PC-IAC en todos los archivos.

### Removed
- `aws_iam_role.agent_runtime` resource.
- `aws_iam_role_policy.agent_runtime` resource.
- Data sources `aws_caller_identity`, `aws_region`, `aws_partition` (ya no necesarios).
- Directorio `examples/`.
- Outputs `iam_role_arns`, `iam_role_names`.

## [1.0.0] - 2025-01-15

### Added
- Initial release of Terraform AWS Bedrock AgentCore Runtime module
- Support for AWS Provider >= 6.24.0
- Complete enterprise-grade module structure
- Production-ready examples and documentation

[Unreleased]: https://github.com/org/terraform-aws-bedrock-agentcore-runtime/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/org/terraform-aws-bedrock-agentcore-runtime/releases/tag/v1.0.0
