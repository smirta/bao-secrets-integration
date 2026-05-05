#!/bin/bash
#
# Test Runner Script for OpenBao Secrets Integration Ansible Role
# Run comprehensive tests with detailed reporting
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Print colored message
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print section header
print_header() {
    echo ""
    print_message "$BLUE" "=========================================="
    print_message "$BLUE" "$1"
    print_message "$BLUE" "=========================================="
    echo ""
}

# Run a test and track results
run_test() {
    local test_name=$1
    local test_command=$2

    print_message "$YELLOW" "Running: $test_name"

    if eval "$test_command"; then
        print_message "$GREEN" "✓ PASSED: $test_name"
        ((PASSED_TESTS++))
        return 0
    else
        print_message "$RED" "✗ FAILED: $test_name"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"

    local missing_deps=0

    # Check Python
    if command -v python3 &> /dev/null; then
        print_message "$GREEN" "✓ Python3 installed: $(python3 --version)"
    else
        print_message "$RED" "✗ Python3 not found"
        ((missing_deps++))
    fi

    # Check Ansible
    if command -v ansible &> /dev/null; then
        print_message "$GREEN" "✓ Ansible installed: $(ansible --version | head -n1)"
    else
        print_message "$RED" "✗ Ansible not found"
        ((missing_deps++))
    fi

    # Check Docker
    if command -v docker &> /dev/null; then
        print_message "$GREEN" "✓ Docker installed: $(docker --version)"
    else
        print_message "$RED" "✗ Docker not found"
        ((missing_deps++))
    fi

    # Check Molecule
    if command -v molecule &> /dev/null; then
        print_message "$GREEN" "✓ Molecule installed: $(molecule --version)"
    else
        print_message "$YELLOW" "⚠ Molecule not found (install with: pip install molecule molecule-docker)"
        ((missing_deps++))
    fi

    if [ $missing_deps -gt 0 ]; then
        print_message "$RED" "Missing $missing_deps required dependencies"
        print_message "$YELLOW" "Install with: make install"
        exit 1
    fi

    print_message "$GREEN" "All prerequisites satisfied!"
}

# Run linting tests
run_linting() {
    print_header "Running Linting Tests"

    # YAML linting
    if command -v yamllint &> /dev/null; then
        run_test "YAML Lint" "yamllint ." || true
    else
        print_message "$YELLOW" "⚠ SKIPPED: yamllint (not installed)"
        ((SKIPPED_TESTS++))
    fi

    # Ansible linting
    if command -v ansible-lint &> /dev/null; then
        run_test "Ansible Lint" "ansible-lint roles/openbao_secrets_integration" || true
    else
        print_message "$YELLOW" "⚠ SKIPPED: ansible-lint (not installed)"
        ((SKIPPED_TESTS++))
    fi
}

# Run Molecule tests
run_molecule_tests() {
    print_header "Running Molecule Tests"

    if ! command -v molecule &> /dev/null; then
        print_message "$YELLOW" "⚠ SKIPPED: Molecule tests (molecule not installed)"
        ((SKIPPED_TESTS+=4))
        return
    fi

    cd roles/openbao_secrets_integration

    # Default scenario
    run_test "Molecule - Default (Token Auth)" "molecule test -s default" || true

    # Userpass scenario
    run_test "Molecule - Userpass Auth" "molecule test -s userpass-auth" || true

    # AppRole scenario
    run_test "Molecule - AppRole Auth" "molecule test -s approle-auth" || true

    # Rotation scenario
    run_test "Molecule - Secret Rotation" "molecule test -s rotation" || true

    cd ../..
}

# Run integration tests
run_integration_tests() {
    print_header "Running Integration Tests"

    # Check if OpenBao is running
    if curl -s http://localhost:8200/v1/sys/health > /dev/null 2>&1; then
        print_message "$GREEN" "OpenBao server detected at localhost:8200"
        run_test "Integration Tests" "ansible-playbook tests/integration-test.yml" || true
    else
        print_message "$YELLOW" "⚠ SKIPPED: Integration tests (OpenBao not running)"
        print_message "$YELLOW" "   Start with: make dev-openbao"
        ((SKIPPED_TESTS++))
    fi
}

# Print test summary
print_summary() {
    print_header "Test Summary"

    local total_tests=$((PASSED_TESTS + FAILED_TESTS + SKIPPED_TESTS))

    print_message "$BLUE" "Total Tests:   $total_tests"
    print_message "$GREEN" "Passed:        $PASSED_TESTS"
    print_message "$RED" "Failed:        $FAILED_TESTS"
    print_message "$YELLOW" "Skipped:       $SKIPPED_TESTS"

    echo ""

    if [ $FAILED_TESTS -eq 0 ]; then
        print_message "$GREEN" "=========================================="
        print_message "$GREEN" "  ALL TESTS PASSED! ✓"
        print_message "$GREEN" "=========================================="
        return 0
    else
        print_message "$RED" "=========================================="
        print_message "$RED" "  SOME TESTS FAILED! ✗"
        print_message "$RED" "=========================================="
        return 1
    fi
}

# Main execution
main() {
    local start_time=$(date +%s)

    print_header "OpenBao Ansible Role Test Suite"
    print_message "$BLUE" "Started at: $(date)"

    # Parse arguments
    RUN_LINT=true
    RUN_MOLECULE=true
    RUN_INTEGRATION=true

    while [[ $# -gt 0 ]]; do
        case $1 in
            --lint-only)
                RUN_MOLECULE=false
                RUN_INTEGRATION=false
                shift
                ;;
            --molecule-only)
                RUN_LINT=false
                RUN_INTEGRATION=false
                shift
                ;;
            --integration-only)
                RUN_LINT=false
                RUN_MOLECULE=false
                shift
                ;;
            --skip-lint)
                RUN_LINT=false
                shift
                ;;
            --skip-molecule)
                RUN_MOLECULE=false
                shift
                ;;
            --skip-integration)
                RUN_INTEGRATION=false
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --lint-only           Run only linting tests"
                echo "  --molecule-only       Run only Molecule tests"
                echo "  --integration-only    Run only integration tests"
                echo "  --skip-lint          Skip linting tests"
                echo "  --skip-molecule      Skip Molecule tests"
                echo "  --skip-integration   Skip integration tests"
                echo "  -h, --help           Show this help message"
                exit 0
                ;;
            *)
                print_message "$RED" "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Run test suites
    check_prerequisites

    if [ "$RUN_LINT" = true ]; then
        run_linting
    fi

    if [ "$RUN_MOLECULE" = true ]; then
        run_molecule_tests
    fi

    if [ "$RUN_INTEGRATION" = true ]; then
        run_integration_tests
    fi

    # Calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    print_message "$BLUE" "Completed at: $(date)"
    print_message "$BLUE" "Duration: ${duration}s"

    # Print summary and exit with appropriate code
    print_summary
}

# Run main function
main "$@"
