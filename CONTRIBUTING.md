# Contributing to OpenBao Ansible Role

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/ansible-openbao-role.git`
3. Create a feature branch: `git checkout -b feature/my-new-feature`
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

### Prerequisites

- Python 3.9+
- Docker (for Molecule tests)
- Ansible 2.9+

### Install Development Dependencies

```bash
pip install -r requirements.txt
ansible-galaxy install -r requirements.yml
```

## Testing

### Linting

Run linting checks before committing:

```bash
# YAML linting
yamllint .

# Ansible linting
ansible-lint roles/openbao
```

### Unit Tests with Molecule

Test individual scenarios:

```bash
cd roles/openbao

# Test default scenario (token auth)
molecule test

# Test specific scenarios
molecule test -s userpass-auth
molecule test -s approle-auth
molecule test -s rotation
```

### Integration Tests

Run integration tests against a local OpenBao server:

```bash
# Start OpenBao in dev mode
docker run -d --name openbao-dev \
  -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID=test-root-token \
  openbao/openbao:latest

# Run integration tests
ansible-playbook tests/integration-test.yml

# Cleanup
docker stop openbao-dev && docker rm openbao-dev
```

## Code Style

### Ansible Style

- Use 2 spaces for indentation
- Name all tasks descriptively
- Use `ansible.builtin` module names
- Add `no_log: true` for sensitive operations
- Include comments for complex logic

### YAML Style

- Keep lines under 120 characters
- Use double quotes for strings with special characters
- Use single quotes for simple strings
- Consistent indentation (2 spaces)

## Adding New Features

### Adding a New Authentication Method

1. Create auth task file: `roles/openbao/tasks/auth/newmethod.yml`
2. Add validation for required variables
3. Implement authentication logic
4. Update `defaults/main.yml` with new variables
5. Create Molecule scenario: `molecule/newmethod-auth/`
6. Update README.md with usage examples
7. Add integration test

### Adding New Secret Types

1. Update `retrieve_secrets.yml` if needed
2. Add handling in `rotate_secrets.yml` if rotatable
3. Create test scenario
4. Document in README.md

## Documentation

- Update README.md for user-facing changes
- Add inline comments for complex logic
- Update example playbooks and group_vars
- Document new variables in defaults/main.yml

## Commit Messages

Use conventional commit format:

```none
type(scope): subject

body

footer
```

Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test changes
- `refactor`: Code refactoring
- `chore`: Maintenance tasks

Examples:

```none
feat(auth): add certificate authentication method

Add support for TLS certificate authentication including
certificate validation and role mapping.

Closes #123
```

## Pull Request Process

1. Update documentation for any changed functionality
2. Add tests for new features
3. Ensure all tests pass locally
4. Update CHANGELOG.md
5. Submit PR with clear description
6. Respond to review feedback

## Security

- Never commit secrets or tokens
- Use `no_log: true` for sensitive operations
- Report security issues privately to maintainers
- Follow secure coding practices

## Questions?

- Open an issue for bugs or feature requests
- Start a discussion for questions
- Check existing issues before creating new ones

## License

By contributing, you agree that your contributions will be licensed under the [GNU AFFERO GENERAL PUBLIC LICENSE Version 3](./LICENSE).
