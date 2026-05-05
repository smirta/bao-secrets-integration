# OpenBao Secrets Integration with Ansible

An Ansible role for authenticating against OpenBao and retrieving secrets using various authentication methods.

## Features

- Multiple authentication methods support (token, userpass, approle, kubernetes, ldap, jwt)
- Flexible secret retrieval with path specification
- Optional secret rotation on each run
- Group variable configuration
- Comprehensive test coverage with Molecule

## Requirements

- Ansible 2.9+
- Python `hvac` library (installed automatically)
- OpenBao server accessible from target hosts

## Role Variables

### Required Variables

```yaml
# OpenBao server URL
openbao_secrets_integration_bao_addr: "https://openbao.example.com:8200"

# Authentication method: token, userpass, approle, kubernetes, ldap, jwt
openbao_secrets_integration_bao_auth_method: "token"

# Secrets to retrieve (list of dictionaries)
openbao_secrets_integration_bao_secrets:
  - path: "secret/data/myapp/config"
    key: "db_password"
    dest_var: "database_password"
  - path: "secret/data/myapp/api"
    key: "api_key"
    dest_var: "api_key"
```

### Authentication Method Specific Variables

#### Token Authentication

```yaml
openbao_secrets_integration_bao_token: "hvs.CAESIJ..."
```

#### Userpass Authentication

```yaml
openbao_secrets_integration_bao_username: "myuser"
openbao_secrets_integration_bao_password: "mypassword"
```

#### AppRole Authentication

```yaml
openbao_secrets_integration_bao_role_id: "role-id-here"
openbao_secrets_integration_bao_secret_id: "secret-id-here"
```

#### Kubernetes Authentication

```yaml
openbao_secrets_integration_k8s_role: "my-role"
openbao_secrets_integration_k8s_jwt_path: "/var/run/secrets/kubernetes.io/serviceaccount/token"
```

#### LDAP Authentication

```yaml
openbao_secrets_integration_ldap_username: "ldapuser"
openbao_secrets_integration_ldap_password: "ldappassword"
```

#### JWT Authentication

```yaml
openbao_secrets_integration_jwt_role: "my-jwt-role"
openbao_secrets_integration_jwt_token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Optional Variables

```yaml
# Enable/disable secret rotation on each run (default: false)
openbao_secrets_integration_bao_rotate_secrets: false

# OpenBao API version (default: v1)
openbao_secrets_integration_bao_api_version: "v1"

# TLS verification (default: true)
openbao_secrets_integration_bao_tls_verify: true

# Custom CA certificate path
openbao_secrets_integration_ca_cert: "/path/to/ca.crt"

# Namespace (for OpenBao Enterprise)
openbao_secrets_integration_bao_namespace: "admin"
```

## Dependencies

None

## Example Playbook

```yaml
---
- hosts: webservers
  roles:
    - role: openbao_secrets_integration
      vars:
        openbao_secrets_integration_bao_addr: "https://openbao.example.com:8200"
        openbao_secrets_integration_bao_auth_method: "approle"
        openbao_secrets_integration_bao_role_id: "{{ lookup('env', 'OPENBAO_ROLE_ID') }}"
        openbao_secrets_integration_bao_secret_id: "{{ lookup('env', 'OPENBAO_SECRET_ID') }}"
        openbao_secrets_integration_bao_rotate_secrets: false
        openbao_secrets_integration_bao_secrets:
          - path: "secret/data/webapp/db"
            key: "password"
            dest_var: "db_password"
          - path: "secret/data/webapp/api"
            key: "token"
            dest_var: "api_token"

    - role: deploy_app
      # The secrets are now available as variables
      # {{ db_password }} and {{ api_token }}
```

### Group Variables Example

In `group_vars/production.yml`:

```yaml
openbao_secrets_integration_bao_addr: "https://openbao-prod.example.com:8200"
openbao_secrets_integration_bao_auth_method: "approle"
openbao_secrets_integration_bao_role_id: "prod-role-id"
openbao_secrets_integration_bao_secret_id: "{{ lookup('env', 'OPENBAO_SECRET_ID') }}"
openbao_secrets_integration_bao_rotate_secrets: true
openbao_secrets_integration_bao_secrets:
  - path: "secret/data/production/database"
    key: "password"
    dest_var: "prod_db_password"
```

In `group_vars/staging.yml`:

```yaml
openbao_secrets_integration_bao_addr: "https://openbao-staging.example.com:8200"
openbao_secrets_integration_bao_auth_method: "token"
openbao_secrets_integration_bao_token: "{{ lookup('env', 'OPENBAO_TOKEN') }}"
openbao_secrets_integration_bao_rotate_secrets: false
openbao_secrets_integration_bao_secrets:
  - path: "secret/data/staging/database"
    key: "password"
    dest_var: "staging_db_password"
```

## Testing

This role includes comprehensive tests using Molecule with Docker.

### Running Tests

```bash
# Install test dependencies
pip install molecule molecule-docker ansible-lint yamllint

# Run all tests
cd roles/openbao_secrets_integration
molecule test

# Run specific scenarios
molecule test -s token-auth
molecule test -s userpass-auth
molecule test -s approle-auth
```

### Available Test Scenarios

- `default`: Basic token authentication
- `token-auth`: Token authentication method
- `userpass-auth`: Username/password authentication
- `approle-auth`: AppRole authentication
- `rotation`: Secret rotation testing

## Security Considerations

1. **Never commit secrets**: This role should never use any secrets in production
2. **Use TLS**: Always enable TLS verification in production
3. **Rotate secrets**: Enable `openbao_secrets_integration_bao_rotate_secrets` for sensitive environments
4. **Least privilege**: Use authentication methods with minimal required permissions
5. **Audit logs**: Monitor OpenBao audit logs for unauthorized access

## License

[GNU AFFERO GENERAL PUBLIC LICENSE Version 3](./LICENSE)

## Author Information

Created for OpenBao integration with Ansible.
