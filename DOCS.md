# Documentation Index

Complete documentation for the OpenBao Secrets Integration Ansible Role.

## Getting Started

- **[Quick Start Guide](QUICKSTART.md)** - Get up and running in minutes
- **[README](README.md)** - Complete role documentation

## User Guides

### Basic Usage

- [Quick Start Guide](QUICKSTART.md) - Basic installation and usage
- [Example Playbook](example-playbook.yml) - Complete playbook example
- [Group Variables Examples](examples/group_vars/) - Environment-specific configurations

### Configuration

- [Default Variables](roles/openbao_secrets_integration/defaults/main.yml) - All configurable options
- [Authentication Methods](#authentication-methods) - Supported auth methods
- [Secret Management](#secret-management) - Retrieving and rotating secrets

## Development

- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute to this project
- **[Testing Guide](TESTING.md)** - Comprehensive testing documentation
- **[Changelog](CHANGELOG.md)** - Version history and changes

## Reference

### Authentication Methods

#### Token Authentication

Most basic authentication method using a static token.

```yaml
openbao_secrets_integration_bao_auth_method: "token"
openbao_secrets_integration_bao_token: "hvs.CAESIJ..."
```

**Use Cases:**

- Development environments
- Quick testing
- Service accounts with long-lived tokens

**See:** [Token Auth Tasks](roles/openbao_secrets_integration/tasks/auth/token.yml)

#### AppRole Authentication

Recommended for automated workflows and CI/CD.

```yaml
openbao_secrets_integration_bao_auth_method: "approle"
openbao_secrets_integration_bao_role_id: "role-id-here"
openbao_secrets_integration_bao_secret_id: "secret-id-here"
```

**Use Cases:**

- Production deployments
- Automated systems
- CI/CD pipelines
- Applications

**See:** [AppRole Auth Tasks](roles/openbao_secrets_integration/tasks/auth/approle.yml)

#### Username/Password Authentication

Traditional username and password authentication.

```yaml
openbao_secrets_integration_bao_auth_method: "userpass"
openbao_secrets_integration_bao_username: "myuser"
openbao_secrets_integration_bao_password: "mypassword"
```

**Use Cases:**

- Human operators
- Development/testing
- Interactive sessions

**See:** [Userpass Auth Tasks](roles/openbao_secrets_integration/tasks/auth/userpass.yml)

#### Kubernetes Authentication

For applications running in Kubernetes clusters.

```yaml
openbao_secrets_integration_bao_auth_method: "kubernetes"
openbao_secrets_integration_k8s_role: "my-role"
```

**Use Cases:**

- Kubernetes deployments
- Pod-based authentication
- Container orchestration

**See:** [Kubernetes Auth Tasks](roles/openbao_secrets_integration/tasks/auth/kubernetes.yml)

#### LDAP Authentication

Integrate with existing LDAP/Active Directory.

```yaml
openbao_secrets_integration_bao_auth_method: "ldap"
openbao_secrets_integration_ldap_username: "ldapuser"
openbao_secrets_integration_ldap_password: "ldappassword"
```

**Use Cases:**

- Enterprise environments
- Existing LDAP infrastructure
- Centralized user management

**See:** [LDAP Auth Tasks](roles/openbao_secrets_integration/tasks/auth/ldap.yml)

#### JWT Authentication

Token-based authentication using JSON Web Tokens.

```yaml
openbao_secrets_integration_bao_auth_method: "jwt"
openbao_secrets_integration_jwt_role: "my-jwt-role"
openbao_secrets_integration_jwt_token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Use Cases:**

- OIDC providers
- External authentication systems
- Service mesh integration

**See:** [JWT Auth Tasks](roles/openbao_secrets_integration/tasks/auth/jwt.yml)

### Secret Management

#### Retrieving Secrets

Define secrets to retrieve:

```yaml
openbao_secrets_integration_bao_secrets:
  - path: "secret/data/myapp/config"
    key: "db_password"
    dest_var: "database_password"
  - path: "secret/data/myapp/api"
    key: "api_key"
    dest_var: "external_api_key"
```

After the role runs, secrets are available as variables:

```yaml
- name: Use secrets
  debug:
    msg: "DB Password: {{ database_password }}"
```

**See:** [Secret Retrieval Tasks](roles/openbao_secrets_integration/tasks/retrieve_secrets.yml)

#### Secret Rotation

Enable automatic secret rotation:

```yaml
openbao_secrets_integration_bao_rotate_secrets: true
```

When enabled, the role will attempt to rotate secrets on each run.

**See:** [Secret Rotation Tasks](roles/openbao_secrets_integration/tasks/rotate_secrets.yml)

#### Secret Metadata

The role stores metadata about retrieved secrets:

```yaml
openbao_secrets_integration_bao_secret_metadata:
  database_password:
    path: "secret/data/myapp/config"
    version: "3"
    created_time: "2026-05-05T10:30:00Z"
```

### Configuration Options

#### Connection Settings

```yaml
# Server address
openbao_secrets_integration_bao_addr: "https://openbao.example.com:8200"

# TLS verification
openbao_secrets_integration_bao_tls_verify: true
openbao_secrets_integration_ca_cert: "/path/to/ca.crt"

# Timeout and retries
openbao_secrets_integration_timeout: 30
openbao_secrets_integration_max_retries: 3
oopenbao_secrets_integration_retry_delay: 2

# Namespace (Enterprise)
openbao_secrets_integration_bao_namespace: "admin"
```

#### Dependency Management

```yaml
# Install hvac library automatically
openbao_secrets_integration_install_hvac: true
openbao_secrets_integration_hvac_version: "2.1.0"
```

## Testing

### Quick Test

```bash
make test
```

### Test Scenarios

1. **[Default Test](roles/openbao_secrets_integration/molecule/default/)** - Token authentication
2. **[Userpass Test](roles/openbao_secrets_integration/molecule/userpass-auth/)** - Username/password auth
3. **[AppRole Test](roles/openbao_secrets_integration/molecule/approle-auth/)** - AppRole auth
4. **[Rotation Test](roles/openbao_secrets_integration/molecule/rotation/)** - Secret rotation

### Running Tests

```bash
# Run all tests
make test-all

# Run specific scenario
make test-scenario SCENARIO=userpass-auth

# Run integration tests
make test-integration

# Run with test script
./run-tests.sh
```

**See:** [Testing Guide](TESTING.md)

## Examples

### Multi-Environment Setup

- [Production Config](examples/group_vars/production.yml)
- [Staging Config](examples/group_vars/staging.yml)
- [Development Config](examples/group_vars/development.yml)

### Use Cases

#### Web Application Deployment

```yaml
---
- hosts: webservers
  roles:
    - role: openbao_secrets_integration
      vars:
        openbao_secrets_integration_bao_secrets:
          - path: "secret/data/webapp/db"
            key: "password"
            dest_var: "db_password"
          - path: "secret/data/webapp/redis"
            key: "password"
            dest_var: "redis_password"

    - role: webapp
      vars:
        db_connection: "postgresql://user:{{ db_password }}@localhost/db"
        redis_url: "redis://:{{ redis_password }}@localhost:6379"
```

#### Database Configuration

```yaml
---
- hosts: databases
  vars:
    openbao_secrets_integration_bao_rotate_secrets: true
  roles:
    - role: openbao_secrets_integration
      vars:
        openbao_secrets_integration_bao_secrets:
          - path: "database/creds/admin"
            key: "password"
            dest_var: "db_admin_pass"

    - role: postgresql
      vars:
        admin_password: "{{ db_admin_pass }}"
```

#### CI/CD Pipeline

```yaml
---
- hosts: localhost
  connection: local
  vars:
    openbao_secrets_integration_bao_auth_method: "approle"
    openbao_secrets_integration_bao_role_id: "{{ lookup('env', 'CI_ROLE_ID') }}"
    openbao_secrets_integration_bao_secret_id: "{{ lookup('env', 'CI_SECRET_ID') }}"
  roles:
    - role: openbao_secrets_integration
      vars:
        openbao_secrets_integration_bao_secrets:
          - path: "secret/data/ci/docker"
            key: "registry_token"
            dest_var: "docker_token"

    - role: docker_deploy
```

## Troubleshooting

### Common Issues

#### Authentication Failed

- Verify credentials are correct
- Check OpenBao server is accessible
- Ensure auth method is enabled in OpenBao
- Verify token has required policies

#### Secret Not Found

- Confirm secret path is correct (KV v2 uses `secret/data/path`)
- Check token has read permissions
- Verify secret exists in OpenBao

#### Connection Timeout

- Check network connectivity
- Verify OpenBao address and port
- Increase timeout: `openbao_secrets_integration_timeout: 60`
- Check firewall rules

#### TLS Verification Failed

- For self-signed certs: `openbao_secrets_integration_bao_tls_verify: false` (dev only)
- Or provide CA cert: `openbao_secrets_integration_ca_cert: "/path/to/ca.crt"`
- Ensure hostname matches certificate

### Debug Mode

Enable verbose output:

```bash
ansible-playbook -vvv playbook.yml
```

Check what the role is doing:

```yaml
- name: Debug mode
  debug:
    var: openbao_secrets_integration_bao_secret_metadata
```

### Getting Help

1. Check [TESTING.md](TESTING.md) for testing issues
2. Review [CONTRIBUTING.md](CONTRIBUTING.md) for development help
3. Search existing GitHub issues
4. Open a new issue with:
   - Ansible version
   - OpenBao version
   - Error messages
   - Minimal reproduction steps

## API Reference

### Role Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `openbao_secrets_integration_bao_addr` | Yes | - | OpenBao server URL |
| `openbao_secrets_integration_bao_auth_method` | Yes | `token` | Authentication method |
| `openbao_secrets_integration_bao_secrets` | Yes | `[]` | List of secrets to retrieve |
| `openbao_secrets_integration_bao_rotate_secrets` | No | `false` | Enable secret rotation |
| `openbao_secrets_integration_bao_tls_verify` | No | `true` | Verify TLS certificates |
| `openbao_secrets_integration_timeout` | No | `30` | Connection timeout (seconds) |

**See:** [defaults/main.yml](roles/openbao_secrets_integration/defaults/main.yml) for complete list

### Task Files

- [main.yml](roles/openbao_secrets_integration/tasks/main.yml) - Main entry point
- [install.yml](roles/openbao_secrets_integration/tasks/install.yml) - Dependency installation
- [retrieve_secrets.yml](roles/openbao_secrets_integration/tasks/retrieve_secrets.yml) - Secret retrieval
- [rotate_secrets.yml](roles/openbao_secrets_integration/tasks/rotate_secrets.yml) - Secret rotation
- [auth/](roles/openbao_secrets_integration/tasks/auth/) - Authentication methods

## Additional Resources

### External Links

- [OpenBao Official Documentation](https://openbao.org/docs/)
- [Ansible Documentation](https://docs.ansible.com/)
- [hvac Library Documentation](https://hvac.readthedocs.io/)
- [Molecule Documentation](https://molecule.readthedocs.io/)

### Related Projects

- [OpenBao](https://github.com/openbao/openbao) - OpenBao server
- [hvac](https://github.com/hvac/hvac) - Python client for Vault/OpenBao
- [Ansible](https://github.com/ansible/ansible) - Automation platform

## License

This project is licensed under the [GNU AFFERO GENERAL PUBLIC LICENSE Version 3](./LICENSE) License - see the [LICENSE](./LICENSE) file for details.

## Support

- **Documentation**: This documentation index
- **Issues**: [GitHub Issues](https://github.com/yourusername/ansible-openbao-role/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/ansible-openbao-role/discussions)

---

**Last Updated**: 2026-05-05
**Version**: 0.0.1
