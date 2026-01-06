#!/bin/bash
# Validation script for PKGBUILD and related files
# Run before committing changes

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0

log_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

log_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

# Check for required tools
log_header "Checking Required Tools"

check_tool() {
    if command -v "$1" &> /dev/null; then
        log_success "$1 is installed"
        return 0
    else
        log_error "$1 is not installed"
        return 1
    fi
}

check_tool "namcap" || true
check_tool "shellcheck" || true
check_tool "inkscape"
check_tool "optipng"

# Validate PKGBUILD
log_header "Validating PKGBUILD"

if [ -f "PKGBUILD" ]; then
    log_success "PKGBUILD exists"
    
    # Check required fields
    for field in pkgname pkgver pkgrel pkgdesc arch url license; do
        if grep -q "^${field}=" PKGBUILD; then
            log_success "$field is defined"
        else
            log_error "$field is missing"
        fi
    done
    
    # Check for source and checksums
    if grep -q "^source=" PKGBUILD; then
        log_success "source is defined"
    else
        log_error "source is missing"
    fi
    
    if grep -q "^sha256sums=" PKGBUILD; then
        log_success "sha256sums is defined"
    else
        log_warning "sha256sums is missing (use 'updpkgsums' to generate)"
    fi
    
    # Run namcap if available
    if command -v namcap &> /dev/null; then
        log_header "Running namcap on PKGBUILD"
        if namcap PKGBUILD > /tmp/namcap.log 2>&1; then
            log_success "namcap validation passed"
        else
            log_warning "namcap found issues:"
            cat /tmp/namcap.log | sed 's/^/  /'
        fi
        rm -f /tmp/namcap.log
    fi
else
    log_error "PKGBUILD not found"
fi

# Validate .SRCINFO
log_header "Validating .SRCINFO"

if [ -f ".SRCINFO" ]; then
    log_success ".SRCINFO exists"
    
    # Check if .SRCINFO is up to date
    if [ -f "PKGBUILD" ]; then
        if command -v makepkg &> /dev/null; then
            temp_srcinfo=$(mktemp)
            makepkg --printsrcinfo > "$temp_srcinfo" 2>/dev/null || true
            if diff -q .SRCINFO "$temp_srcinfo" > /dev/null 2>&1; then
                log_success ".SRCINFO is up to date"
            else
                log_warning ".SRCINFO is outdated (run 'makepkg --printsrcinfo > .SRCINFO')"
            fi
            rm -f "$temp_srcinfo"
        fi
    fi
else
    log_warning ".SRCINFO not found (generate with 'makepkg --printsrcinfo > .SRCINFO')"
fi

# Validate shell scripts
log_header "Validating Shell Scripts"

if command -v shellcheck &> /dev/null; then
    for script in build-helpers.sh; do
        if [ -f "$script" ]; then
            if shellcheck "$script" > /tmp/shellcheck.log 2>&1; then
                log_success "$script passes shellcheck"
            else
                log_warning "$script has shellcheck issues:"
                cat /tmp/shellcheck.log | sed 's/^/  /'
            fi
            rm -f /tmp/shellcheck.log
        fi
    done
else
    log_warning "shellcheck not available, skipping shell script validation"
fi

# Check file permissions
log_header "Checking File Permissions"

for script in build-helpers.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            log_success "$script is executable"
        else
            log_warning "$script is not executable (run 'chmod +x $script')"
        fi
    fi
done

# Check for common issues
log_header "Checking for Common Issues"

# Check for trailing whitespace
if grep -r '[[:space:]]$' --include="*.sh" --include="PKGBUILD" . > /dev/null 2>&1; then
    log_warning "Trailing whitespace found in some files"
else
    log_success "No trailing whitespace"
fi

# Check for tabs vs spaces consistency
if [ -f ".editorconfig" ]; then
    log_success ".editorconfig present for editor consistency"
else
    log_warning ".editorconfig missing"
fi

# Check for CI configuration
if [ -f ".github/workflows/build-test.yml" ]; then
    log_success "CI workflow configured"
else
    log_warning "CI workflow not found"
fi

# Summary
log_header "Validation Summary"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}Validation completed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    exit 1
fi
