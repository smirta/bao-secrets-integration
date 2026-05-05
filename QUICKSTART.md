# Quick Start Guide

Get up and running with the OpenBao Secrets Integration Ansible role in minutes!

## Prerequisites

- Ansible 2.9 or higher
- Python 3.9 or higher
- Access to an OpenBao server
- Python `hvac` library (installed automatically by the role)

## Installation

### Option 1: Ansible Galaxy (Recommended)

```bash
ansible-galaxy role install openbao_secrets_integration
```

### Option 2: Git Clone

```bash
git clone https://github.com/smirta/bao-secrets-integration.git
cd ansible-openbao-role
```

### Option 3: Requirements File

Add to `requirements.yml`:

```yaml
---
roles:
  - name: openbao_secrets_integration
    src: https://github.com/smirta/bao-secrets-integration.git
    version: main
```

Install:

```bash
ansible-galaxy install -r requirements.yml
```

## Basic Usage

### Step 1: Start OpenBao (for testing)

```bash
# Start OpenBao dev server in Docker
docker run -d --name openbao-dev \
  -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID=my-root-token \
  openbao/openbao:latest
```

### Step 2: Create Secrets

```bash
export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='my-root-token'

# Install OpenBao CLI (optional, for manual testing)
# Download from: https://github.com/openbao/openbao/releases

# Or use curl
curl -X POST \
  -H "X-Vault-Token: my-root-token" \
  -H "Content-Type: application/json" \
  -d '{"data":{"password":"secret123"}}' \
  http://localhost:8200/v1/secret/data/myapp/db
```

### Step 3: Create a Playbook

Create `playbook.yml`:

```yaml
---
- name: Get secrets from OpenBao
  hosts: localhost
  connection: local

  vars:
    openbao_secrets_integration_bao_addr: "http://localhost:8200"
    openbao_secrets_integration_bao_auth_method: "token"
    openbao_secrets_integration_bao_token: "my-root-token"
    openbao_secrets_integration_bao_tls_verify: false
    openbao_secrets_integration_bao_secrets:
      - path: "secret/data/myapp/db"
        key: "password"
        dest_var: "database_password"

  roles:
    - role: openbao_secrets_integration

  tasks:
    - name: Use the secret
      debug:
        msg: "Database password retrieved: {{ database_password }}"
```

### Step 4: Run the Playbook

```bash
ansible-playbook playbook.yml
```

**Expected Output:**

```bash
TASK [openbao_secrets_integration : Authenticate to OpenBao] ***************
ok: [localhost]

TASK [openbao_secrets_integration : Retrieve secrets] **********************
ok: [localhost]

TASK [Use the secret] ***********************************
ok: [localhost] => {
    "msg": "Database password retrieved: secret123"
}
```

## Common Scenarios

### Scenario 1: Production with AppRole

**Group Variables** (`group_vars/production.yml`):

```yaml
openbao_secrets_integration_bao_addr: "https://openbao.prod.example.com:8200"
openbao_secrets_integration_bao_auth_method: "approle"
openbao_secrets_integration_bao_role_id: "{{ lookup('env', 'OPENBAO_ROLE_ID') }}"
openbao_secrets_integration_bao_secret_id: "{{ lookup('env', 'OPENBAO_SECRET_ID') }}"
openbao_secrets_integration_bao_tls_verify: true
openbao_secrets_integration_bao_secrets:
  - path: "secret/data/prod/webapp/db"
    key: "password"
    dest_var: "prod_db_password"
```

**Playbook:**

```yaml
---
- hosts: webservers
  roles:
    - openbao_secrets_integration
    - deploy_app
```

**Run:**

```bash
export OPENBAO_ROLE_ID="your-role-id"
export OPENBAO_SECRET_ID="your-secret-id"
ansible-playbook -i production deploy.yml
```

### Scenario 2: Multiple Environments

**Directory Structure:**

```none
.
├── group_vars/
│   ├── production.yml
│   ├── staging.yml
│   └── development.yml
├── inventory/
│   ├── production
│   ├── staging
│   └── development
└── deploy.yml
```

**Run for different environments:**

```bash
# Development
ansible-playbook -i inventory/development deploy.yml

# Staging
ansible-playbook -i inventory/staging deploy.yml

# Production
ansible-playbook -i inventory/production deploy.yml
```

### Scenario 3: Secret Rotation Enabled

```yaml
---
- hosts: databases
  vars:
    openbao_secrets_integration_bao_rotate_secrets: true  # Enable rotation
    openbao_secrets_integration_bao_secrets:
      - path: "database/creds/readonly"
        key: "password"
        dest_var: "db_ro_password"

  roles:
    - openbao_secrets_integration

  tasks:
    - name: Update database connection
      # The password will be rotated on each run
      postgresql_user:
        name: readonly
        password: "{{ db_ro_password }}"
```

## Authentication Methods

### Token (Simplest)

```yaml
openbao_secrets_integration_bao_auth_method: "token"
openbao_secrets_integration_bao_token: "{{ lookup('env', 'OPENBAO_TOKEN') }}"
```

### AppRole (Recommended for Automation)

```yaml
openbao_secrets_integration_bao_auth_method: "approle"
openbao_secrets_integration_bao_role_id: "{{ lookup('env', 'OPENBAO_ROLE_ID') }}"
openbao_secrets_integration_bao_secret_id: "{{ lookup('env', 'OPENBAO_SECRET_ID') }}"
```

### Username/Password

```yaml
openbao_secrets_integration_bao_auth_method: "userpass"
openbao_secrets_integration_bao_username: "ansible-user"
openbao_secrets_integration_bao_password: "{{ lookup('env', 'OPENBAO_PASSWORD') }}"
```

### Kubernetes (for K8s deployments)

```yaml
openbao_secrets_integration_bao_auth_method: "kubernetes"
openbao_secrets_integration_k8s_role: "my-app-role"
```

## Next Steps

1. **Security**: Use Ansible Vault for storing credentials

   ```bash
   ansible-vault create secrets.yml
   ```

2. **Production Setup**: Configure TLS and proper authentication

   ```yaml
   openbao_secrets_integration_bao_tls_verify: true
   openbao_secrets_integration_ca_cert: "/etc/ssl/certs/ca.crt"
   ```

3. **Multiple Secrets**: Retrieve multiple secrets in one run

   ```yaml
   openbao_secrets_integration_bao_secrets:
     - path: "secret/data/app/db"
       key: "password"
       dest_var: "db_pass"
     - path: "secret/data/app/api"
       key: "token"
       dest_var: "api_token"
     - path: "secret/data/app/tls"
       key: "cert"
       dest_var: "tls_cert"
   ```

4. **Testing**: Run the test suite

   ```bash
   make install
   make test
   ```

## Troubleshooting

### Connection Issues

```bash
# Test OpenBao connectivity
curl -k https://openbao.example.com:8200/v1/sys/health

# Check authentication
export VAULT_ADDR='https://openbao.example.com:8200'
export VAULT_TOKEN='your-token'
vault status
```

### Secret Not Found

```bash
# Verify secret path
vault kv get secret/myapp/db

# List secrets
vault kv list secret/
```

### Permission Denied

```bash
# Check token policies
vault token lookup

# Check policy capabilities
vault token capabilities secret/data/myapp/db
```

## Help & Resources

- **Documentation**: See [README.md](README.md) for full documentation
- **Testing**: See [TESTING.md](TESTING.md) for testing guide
- **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- **Issues**: Report bugs on GitHub Issues
- **OpenBao Docs**: [https://openbao.org/docs/](https://openbao.org/docs/)

## Examples Repository

Check the `examples/` directory for more:

- Multi-environment setups
- Different authentication methods
- Complex secret hierarchies
- Integration with other roles

## Quick Reference

```bash
# Install
ansible-galaxy install openbao_secrets_integration

# Run playbook
ansible-playbook playbook.yml

# Run with verbose output
ansible-playbook -vv playbook.yml

# Check mode (dry run)
ansible-playbook --check playbook.yml

# Use Ansible Vault
ansible-playbook --ask-vault-pass playbook.yml

# Test the role
cd roles/openbao_secrets_integration && molecule test
```

Happy automating! 🚀
