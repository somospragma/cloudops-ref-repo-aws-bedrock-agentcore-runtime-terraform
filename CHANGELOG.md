# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial module structure for Amazon Bedrock AgentCore Runtime
- Support for multiple agent runtime deployments
- Container-based and code-based deployment options
- VPC and public network mode support
- JWT-based custom authorization
- Lifecycle configuration for session management
- Protocol support for MCP, HTTP, and A2A
- Automatic IAM role creation with least-privilege policies
- CloudWatch logging integration
- KMS encryption support
- Enterprise tagging system (two-level)
- Comprehensive input validation
- Complete documentation and examples

### Changed
- **BREAKING**: `lifecycle_config` ahora siempre se aplica con valores por defecto (idle_timeout: 900s, max_lifetime: 28800s)
- Cambiado de bloque dinámico a bloque estático para `lifecycle_configuration` en main.tf
- Actualizada la definición de variable `lifecycle_config` para incluir valores por defecto explícitos
- Actualizada documentación para reflejar que lifecycle_config siempre está presente

### Fixed
- **IMPORTANTE**: Resuelto problema donde los cambios a `lifecycle_config` no se aplicaban cuando el runtime se creaba sin esta configuración inicialmente
- La API de AWS UpdateAgentRuntime ahora recibe correctamente el bloque lifecycle_configuration en todas las actualizaciones

### Deprecated
- N/A

### Removed
- N/A

### Security
- Encryption enabled by default for all resources
- Least-privilege IAM policies
- Network isolation options (VPC mode)
- JWT authorization support
- TLS 1.2+ for all communications

## [1.0.0] - 2025-01-15

### Added
- Initial release of Terraform AWS Bedrock AgentCore Runtime module
- Support for AWS Provider >= 6.24.0
- Complete enterprise-grade module structure
- Production-ready examples and documentation

[Unreleased]: https://github.com/org/terraform-aws-bedrock-agentcore-runtime/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/org/terraform-aws-bedrock-agentcore-runtime/releases/tag/v1.0.0
