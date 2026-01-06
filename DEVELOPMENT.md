# Development Guide for Ant-Dracula Theme

## Overview

This document provides comprehensive guidance for developers working on the Ant-Dracula theme package for Arch Linux.

## Architecture

### Build System Components

1. **PKGBUILD**: Main package build script following Arch Linux standards
2. **build-helpers.sh**: Modular build utilities with error handling and logging
3. **CI/CD**: Automated testing via GitHub Actions

### Build Flow

```
prepare() → build() → package()
    ↓           ↓           ↓
  Patch    Render      Install
  Scripts   Assets      Theme
```

## Prerequisites

### Required Tools

```bash
sudo pacman -S base-devel git inkscape optipng gtk-engine-murrine namcap
```

### Optional Tools

- `namcap`: PKGBUILD linting
- `shellcheck`: Shell script validation
- `python-pylint`: Python script validation

## Building the Package

### Standard Build

```bash
makepkg -sf
```

### Custom Font Configuration

```bash
THEME_FONT_FACE="Ubuntu" THEME_FONT_SIZE="11" makepkg -sf
```

### Clean Build (Recommended)

```bash
makepkg -C  # Clean build directory
makepkg -sf --noconfirm
```

## Development Workflow

### 1. Making Changes

```bash
# Clone the repository
git clone https://github.com/Oichkatzelesfrettschen/ant-dracula-theme-git.git
cd ant-dracula-theme-git

# Make your changes to PKGBUILD or build scripts

# Validate changes
namcap PKGBUILD
shellcheck build-helpers.sh
```

### 2. Testing

```bash
# Build the package
makepkg -sf

# Test with namcap
namcap *.pkg.tar.*

# Install and test
sudo pacman -U *.pkg.tar.*
```

### 3. Debugging Build Issues

The build system includes comprehensive logging:

```bash
# Build with verbose output
makepkg -sf 2>&1 | tee build.log

# Check for specific errors
grep -i error build.log
grep -i warning build.log
```

## Code Standards

### Shell Scripts

- Use `set -e -o pipefail` for error handling
- Validate all paths before operations
- Use proper quoting for variables
- Follow ShellCheck recommendations

### Python Scripts

- Ensure `subprocess` module is imported
- Use modern Inkscape export flags
- Handle errors with proper exit codes
- Follow PEP 8 style guide

### PKGBUILD

- Follow [Arch package guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines)
- Use standard variables (prefix custom vars with `_`)
- Declare explicit dependencies
- Provide checksums for sources

## Modular Components

### build-helpers.sh

Provides reusable functions:

- **Logging**: `log_info`, `log_success`, `log_warning`, `log_error`
- **Timing**: `start_timer`, `end_timer`
- **Validation**: `validate_assets`, `check_inkscape_version`
- **Cleanup**: `cleanup_temp_files`

Example usage in PKGBUILD:

```bash
source "${startdir}/build-helpers.sh"
start_timer "Asset rendering"
render_assets_parallel "./render.py" "GTK3 assets"
end_timer "Asset rendering"
```

## Asset Generation

### GTK Asset Pipeline

1. **GTK2**: Shell-based rendering (`render-assets.sh`)
2. **GTK 3.20**: Python-based rendering with normal and HiDPI variants
3. **GTK 4.0**: Same as GTK 3.20 (compatibility)
4. **Window Manager**: Dedicated WM asset rendering

### Inkscape Integration

Modern flags used (Inkscape 1.0+):

```bash
inkscape \
  --export-id=<object-id> \
  --export-id-only \
  --export-background-opacity=0 \
  --export-filename=<output.png> \
  <input.svg>
```

### HiDPI Assets

HiDPI variants use `--export-dpi=180` for 2x scaling.

## Performance Optimization

### Parallel Builds

The build system supports parallel asset generation:

```bash
# Uses all available CPU cores by default
render_assets_parallel "./render.py" "description" $(nproc)
```

### Build Time Monitoring

Built-in timers track each build phase:

```
[INFO] GTK2 assets completed in 15s
[INFO] GTK 3.20 assets completed in 23s
[INFO] GTK 4.0 assets completed in 22s
[INFO] WM assets completed in 8s
[INFO] Total build completed in 68s
```

## Continuous Integration

### GitHub Actions Workflow

The CI pipeline:

1. Sets up Arch Linux container
2. Installs dependencies
3. Validates PKGBUILD with namcap
4. Builds package
5. Tests package contents
6. Uploads artifacts

### Running CI Locally

```bash
# Using Docker
docker run --rm -v "$PWD:/build" -w /build archlinux:latest bash -c "
  pacman -Syu --noconfirm
  pacman -S --noconfirm base-devel git inkscape optipng namcap
  useradd -m builduser
  chown -R builduser:builduser /build
  sudo -u builduser makepkg -sf
"
```

## Troubleshooting

### Common Issues

#### Inkscape Errors

```
Error: InkscapeApplication::parse_actions: could not find action
```

**Solution**: Ensure patches are applied correctly in `prepare()`.

#### Missing Assets

```
Error: No PNG assets were generated
```

**Solution**: Check Inkscape version and permissions on asset directories.

#### Subprocess Import Missing

```
NameError: name 'subprocess' is not defined
```

**Solution**: The prepare() function automatically adds subprocess imports.

### Debug Mode

Enable verbose logging:

```bash
export BUILDHELPERS_DEBUG=1
makepkg -sf
```

## Contributing

### Submission Checklist

- [ ] Code follows style guidelines
- [ ] PKGBUILD validates with namcap
- [ ] Build completes successfully
- [ ] Package installs correctly
- [ ] Theme works in GNOME/GTK applications
- [ ] CI tests pass
- [ ] Documentation updated

### Version Updates

Update `.SRCINFO` after PKGBUILD changes:

```bash
makepkg --printsrcinfo > .SRCINFO
```

## Security Considerations

### Path Safety

All file operations validate paths to prevent:
- Operations on system directories
- Symbolic link attacks
- Directory traversal

### Checksum Verification

Source integrity is verified via SHA256:

```bash
updpkgsums  # Update checksums automatically
```

### Secrets Management

Never commit:
- Personal credentials
- API keys
- Private keys

## Additional Resources

- [Arch Package Guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines)
- [PKGBUILD Manual](https://man.archlinux.org/man/PKGBUILD.5)
- [Inkscape Command Line](https://wiki.inkscape.org/wiki/index.php/Using_the_Command_Line)
- [GTK Theme Development](https://wiki.gnome.org/Projects/GnomeShell/Development)

## Support

For issues and questions:
- GitHub Issues: https://github.com/Oichkatzelesfrettschen/ant-dracula-theme-git/issues
- Upstream Project: https://github.com/EliverLara/Ant-Dracula
