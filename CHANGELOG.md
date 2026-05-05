# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.1] - 2026-05-05

### Added

- Initial release of OpenBao Secrets Integration Ansible role
- Support for multiple authentication methods:
  - Token authentication
  - Username/Password authentication
  - AppRole authentication
  - Kubernetes authentication
  - LDAP authentication
  - JWT authentication
- Secret retrieval from OpenBao KV v2 secrets engine
- Secret rotation capability (enable/disable per run)
- Group variable configuration support
- Comprehensive test suite with Molecule:
  - Default scenario (token auth)
  - Userpass authentication scenario
  - AppRole authentication scenario
  - Secret rotation scenario
- Integration tests
- CI/CD pipeline with GitHub Actions
- Complete documentation:
  - README with usage examples
  - Example playbooks
  - Group variables examples
  - Contributing guidelines
- Security features:
  - TLS verification support
  - Custom CA certificate support
  - No-log for sensitive operations
  - Retry mechanism with configurable attempts
- Metadata tracking for retrieved secrets (version, created_time)

### Security

- All sensitive operations use `no_log: true` to prevent credential leakage
- Support for Ansible Vault integration
- Environment variable support for credentials

## Release Notes

### Version 0.0.1

This is the first release of the OpenBao Secrets Integration Ansible role. It provides comprehensive support for authenticating against OpenBao and retrieving secrets for use in Ansible playbooks.

**Key Features:**

- Six authentication methods supported
- Flexible secret retrieval with path specification
- Optional secret rotation
- Production-ready with comprehensive tests
- Full documentation and examples

**Compatibility:**

- Ansible 2.9+
- OpenBao 1.0+
- Python 3.9+
- hvac 2.1.0+

**Tested Platforms:**

- Ubuntu 20.04, 22.04
- Debian 11, 12
- RHEL/CentOS 8, 9
- Fedora 38, 39
