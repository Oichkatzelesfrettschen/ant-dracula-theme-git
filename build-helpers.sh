#!/bin/bash
# Build helper functions for Ant-Dracula theme
# Provides modular, reusable build utilities with proper error handling

# Color codes for output
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_RESET='\033[0m'

# Logging functions
log_info() {
    echo -e "${COLOR_BLUE}[INFO]${COLOR_RESET} $*"
}

log_success() {
    echo -e "${COLOR_GREEN}[SUCCESS]${COLOR_RESET} $*"
}

log_warning() {
    echo -e "${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*"
}

log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

# Performance timer
declare -A TIMERS

start_timer() {
    local name="$1"
    TIMERS[$name]=$(date +%s)
}

end_timer() {
    local name="$1"
    local start=${TIMERS[$name]}
    local end=$(date +%s)
    local duration=$((end - start))
    log_info "$name completed in ${duration}s"
}

# Asset validation
validate_assets() {
    local asset_dir="$1"
    local asset_type="$2"
    
    if [ ! -d "$asset_dir" ]; then
        log_error "Asset directory not found: $asset_dir"
        return 1
    fi
    
    local count=$(find "$asset_dir" -name "*.png" -type f 2>/dev/null | wc -l)
    
    if [ "$count" -eq 0 ]; then
        log_error "No PNG assets found in $asset_dir"
        return 1
    fi
    
    log_success "Found $count $asset_type assets in $asset_dir"
    return 0
}

# Parallel asset rendering with job control
render_assets_parallel() {
    local render_script="$1"
    local description="$2"
    local max_jobs="${3:-$(nproc)}"
    
    if [ ! -x "$render_script" ]; then
        log_error "Render script not executable or not found: $render_script"
        return 1
    fi
    
    log_info "Rendering $description (using up to $max_jobs parallel jobs)..."
    start_timer "$description"
    
    # Run the render script
    if "$render_script"; then
        end_timer "$description"
        log_success "$description rendered successfully"
        return 0
    else
        log_error "Failed to render $description"
        return 1
    fi
}

# Inkscape version check
check_inkscape_version() {
    if ! command -v inkscape &> /dev/null; then
        log_error "Inkscape is not installed"
        return 1
    fi
    
    local version=$(inkscape --version 2>&1 | head -n1 | grep -oP '\d+\.\d+' | head -n1)
    log_info "Inkscape version: $version"
    
    # Check if version is < 1.0
    if [ -n "$version" ] && awk -v ver="$version" 'BEGIN { exit (ver < 1.0) ? 0 : 1 }'; then
        log_warning "Inkscape version $version may not support modern export flags"
        log_warning "Version 1.0+ is recommended for best compatibility"
    fi
    
    return 0
}

# Optipng check
check_optipng() {
    if ! command -v optipng &> /dev/null; then
        log_warning "optipng is not installed - PNG optimization will be skipped"
        return 1
    fi
    
    local version=$(optipng --version 2>&1 | head -n1 | grep -oP '\d+\.\d+\.\d+')
    log_info "optipng version: $version"
    return 0
}

# Directory safety check
ensure_safe_directory() {
    local dir="$1"
    
    # Prevent operations on dangerous paths
    case "$dir" in
        /|/usr|/usr/local|/etc|/var|/home|/root|"")
            log_error "Refusing to operate on protected directory: $dir"
            return 1
            ;;
    esac
    
    return 0
}

# Cleanup temporary files
cleanup_temp_files() {
    local dir="$1"
    
    if ! ensure_safe_directory "$dir"; then
        return 1
    fi
    
    log_info "Cleaning up temporary files in $dir..."
    find "$dir" -type f \( -name "*.pyc" -o -name "*.pyo" -o -name "__pycache__" \) -delete 2>/dev/null || true
    find "$dir" -type f -name ".DS_Store" -delete 2>/dev/null || true
    find "$dir" -type f -name "Thumbs.db" -delete 2>/dev/null || true
}

# Error handler for build steps
log_build_error() {
    local message="$1"
    log_error "$message" 2>/dev/null || error "$message"
}

# Note: Functions above are designed to be sourced into the PKGBUILD environment.
# They are not exported globally to avoid namespace pollution.
# Each PKGBUILD function (prepare, build, package) sources this file when needed.
