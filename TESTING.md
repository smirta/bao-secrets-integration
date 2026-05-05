# Testing Guide

This document provides comprehensive information about testing the OpenBao Secrets Integration Ansible role.

## Table of Contents

- [Quick Start](#quick-start)
- [Test Types](#test-types)
- [Running Tests](#running-tests)
- [Test Scenarios](#test-scenarios)
- [Troubleshooting](#troubleshooting)

## Quick Start

### Prerequisites

```bash
# Install dependencies
make install

# Start OpenBao dev server
make dev-openbao
```

### Run All Tests

```bash
# Run linting and all test scenarios
make ci
```

## Test Types

### 1. Linting

Validates YAML syntax and Ansible best practices.

```bash
# YAML linting
yamllint .

# Ansible linting
ansible-lint roles/openbao

# Or use make
make lint
```

### 2. Molecule Tests

Molecule tests use Docker to create isolated test environments.

#### Available Scenarios

1. **default** - Token authentication
2. **userpass-auth** - Username/password authentication
3. **approle-auth** - AppRole authentication
4. **rotation** - Secret rotation testing

### 3. Integration Tests

Integration tests run against a real OpenBao server.

```bash
# Start OpenBao dev server
docker run -d --name openbao-dev \
  -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID=test-root-token \
  openbao/openbao:latest

# Run integration tests
ansible-playbook tests/integration-test.yml

# Cleanup
docker stop openbao-dev && docker rm openbao-dev
```

## Running Tests

### Using Make

```bash
# Run default test
make test

# Run all scenarios
make test-all

# Run specific scenario
make test-scenario SCENARIO=userpass-auth

# Run integration tests
make test-integration
```

### Using Molecule Directly

```bash
cd roles/openbao

# Full test cycle
molecule test

# Individual steps
molecule create          # Create test environment
molecule converge        # Run the role
molecule verify          # Run verifier
molecule destroy         # Cleanup

# Test specific scenario
molecule test -s userpass-auth
```

### Using Ansible Directly

```bash
# Run example playbook
ansible-playbook example-playbook.yml

# Run with specific inventory
ansible-playbook -i inventory/production example-playbook.yml

# Check mode (dry run)
ansible-playbook --check example-playbook.yml
```

## Test Scenarios

### Scenario 1: Token Authentication

Tests basic token authentication and secret retrieval.

```bash
cd roles/openbao
molecule test -s default
```

**What it tests:**

- Token authentication
- Basic secret retrieval
- Multiple secrets
- Secret metadata storage

### Scenario 2: Userpass Authentication

Tests username/password authentication.

```bash
cd roles/openbao
molecule test -s userpass-auth
```

**What it tests:**

- Userpass auth method setup
- User creation and authentication
- Secret retrieval with userpass token

### Scenario 3: AppRole Authentication

Tests AppRole authentication for automated workflows.

```bash
cd roles/openbao
molecule test -s approle-auth
```

**What it tests:**

- AppRole auth method setup
- Role ID and Secret ID generation
- AppRole authentication
- Secret retrieval with AppRole token

### Scenario 4: Secret Rotation

Tests secret rotation functionality.

```bash
cd roles/openbao
molecule test -s rotation
```

**What it tests:**

- Initial secret retrieval
- Secret rotation flag behavior
- Re-retrieval after rotation
- Metadata updates

## Writing New Tests

### Adding a New Molecule Scenario

1. Create scenario directory:

    ```bash
    mkdir -p roles/openbao/molecule/new-scenario
    ```

2. Create `molecule.yml`:

    ```yaml
    ---
    dependency:
      name: galaxy
    driver:
      name: docker
    platforms:
      - name: test-instance
        image: geerlingguy/docker-ubuntu2204-ansible:latest
        # ... configuration ...
    provisioner:
      name: ansible
    verifier:
      name: ansible
    scenario:
      name: new-scenario
    ```

3. Create `converge.yml`:

    ```yaml
    ---
    - name: Converge
      hosts: all
      tasks:
        - name: Include role
          include_role:
            name: openbao
    ```

4. Create `verify.yml`:

    ```yaml
    ---
    - name: Verify
      hosts: all
      tasks:
        - name: Check result
          assert:
            that:
              - some_condition
    ```

5. Run the test:

    ```bash
    molecule test -s new-scenario
    ```

### Adding Integration Tests

Add new test plays to `tests/integration-test.yml`:

```yaml
- name: Test New Feature
  hosts: localhost
  vars:
    openbao_addr: "http://localhost:8200"
    # ... other vars ...
  
  pre_tasks:
    - name: Setup
      # ... setup tasks ...
  
  roles:
    - role: openbao
  
  post_tasks:
    - name: Verify
      assert:
        that:
          - condition
```

## Debugging Tests

### Interactive Debugging

```bash
# Create and converge without destroying
cd roles/openbao
molecule converge

# Login to test instance
molecule login

# Manually test commands inside container
ansible --version
cat /etc/os-release

# Destroy when done
molecule destroy
```

### Verbose Output

```bash
# Ansible verbose mode
molecule test -- -vvv

# Show all output
molecule test --debug
```

### Check Logs

```bash
# View Docker logs
docker logs <container_id>

# View Ansible logs
export ANSIBLE_LOG_PATH=ansible.log
molecule test
cat ansible.log
```

## Continuous Integration

### GitHub Actions

Tests run automatically on:

- Push to main/develop
- Pull requests
- Weekly schedule

View workflow: `.github/workflows/ci.yml`

### Local CI Simulation

```bash
# Run full CI pipeline locally
make ci
```

## Troubleshooting

### Common Issues

#### Docker Connection Issues

```bash
# Check Docker is running
docker ps

# Restart Docker service
sudo systemctl restart docker
```

#### OpenBao Connection Issues

```bash
# Check OpenBao is accessible
curl http://localhost:8200/v1/sys/health

# Check container logs
docker logs openbao-dev
```

#### Permission Issues

```bash
# Ensure user is in docker group
sudo usermod -aG docker $USER

# Re-login or restart terminal
```

#### Molecule Cache Issues

```bash
# Clean molecule cache
rm -rf .molecule .cache

# Destroy and recreate
molecule destroy
molecule test
```

### Getting Help

1. Check the logs with verbose output
2. Review the specific scenario's documentation
3. Check OpenBao server logs
4. Open an issue on GitHub with:
   - Test command used
   - Full error output
   - Environment details (OS, Ansible version, etc.)

## Test Coverage

Current test coverage:

- ✅ Token authentication
- ✅ Userpass authentication
- ✅ AppRole authentication
- ✅ Secret retrieval (KV v2)
- ✅ Multiple secrets
- ✅ Secret rotation
- ✅ Metadata storage
- ✅ Error handling
- ⬜ Kubernetes authentication (requires K8s cluster)
- ⬜ LDAP authentication (requires LDAP server)
- ⬜ JWT authentication (requires JWT provider)

## Performance Testing

For performance testing:

```bash
# Run with timing
cd roles/openbao
time molecule test

# Enable profiling
export ANSIBLE_CALLBACK_WHITELIST=profile_tasks
molecule test
```

## Best Practices

1. **Always run linting before tests**: `make lint`
2. **Test on clean environment**: Use `molecule destroy` between tests
3. **Use specific scenarios**: Test only what changed
4. **Check logs**: Enable verbose mode for debugging
5. **Keep tests fast**: Mock external dependencies when possible
6. **Test edge cases**: Include failure scenarios
7. **Document tests**: Add comments explaining what's being tested

## References

- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Ansible Testing Guide](https://docs.ansible.com/ansible/latest/dev_guide/testing.html)
- [OpenBao Documentation](https://openbao.org/docs/)
