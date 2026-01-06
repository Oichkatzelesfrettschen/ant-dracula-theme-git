# Ant-Dracula Theme (Patched for Modern Inkscape)

This is a patched AUR package build for the **Ant-Dracula** GTK theme with architectural improvements, enhanced build system, and comprehensive documentation.

## Features

### Core Improvements

1.  **Inkscape 1.4+ Compatibility:** 
    - Replaced deprecated `-e` (export-png) and `-i` (export-id) flags with `--export-filename` and `--export-id`.
    - Removed reliance on the fragile `--shell` mode in Python scripts, switching to direct `subprocess` calls.
    - Fixes `InkscapeApplication::parse_actions: could not find action` errors during build.

2.  **Full Asset Generation:**
    - Explicitly enabled asset rendering for **GTK 4.0**, which was missing in previous versions (fixing `gtk_css_section_get_bytes` assertion crashes).
    - Ensures correct path navigation (`gtk-3.20/assets`, `gtk-4.0/assets`) so generated PNGs end up in the package, not lost in the source root.

3.  **Robust Error Handling:**
    - Added `set -e -o pipefail` to build steps.
    - Added verification steps to ensure PNG assets are actually created before packaging.
    - Comprehensive logging with colored output for easy debugging.

### Architectural Enhancements

4.  **Modular Build System:**
    - Separated build logic into reusable `build-helpers.sh` module.
    - Timer functions to track build performance.
    - Validation utilities for assets and dependencies.
    - Centralized logging and error handling.

5.  **Development Tooling:**
    - `validate.sh` script for pre-commit validation.
    - `Makefile` with convenient development targets.
    - `.editorconfig` for consistent code style.
    - Comprehensive CI/CD pipeline with GitHub Actions.

6.  **Enhanced Package Quality:**
    - Proper separation of documentation files (LICENSE, README).
    - Cleanup of development artifacts from final package.
    - Removal of build scripts from installed theme.
    - Improved file organization and permissions.

7.  **Comprehensive Documentation:**
    - [DEVELOPMENT.md](DEVELOPMENT.md): Full development guide.
    - [CONTRIBUTING.md](CONTRIBUTING.md): Contribution guidelines.
    - Inline code documentation and comments.

## Installation

### Standard Installation

```bash
git clone https://github.com/Oichkatzelesfrettschen/ant-dracula-theme-git.git
cd ant-dracula-theme-git
makepkg -si
```

### Using Make (Recommended for Development)

```bash
# Install dependencies and build
make build

# Build and install
make install

# Run validation before building
make test
```

### Custom Font Configuration

```bash
THEME_FONT_FACE="Ubuntu" THEME_FONT_SIZE="11" makepkg -si

# Or using Make
make build-custom-font THEME_FONT_FACE="Ubuntu" THEME_FONT_SIZE="11"
```

## Dependencies

### Build Dependencies
- `git` - Version control
- `inkscape` - SVG to PNG rendering (1.0+ recommended)
- `optipng` - PNG optimization
- `base-devel` - Build tools

### Runtime Dependencies
- `gtk-engine-murrine` - GTK2 theme engine

### Optional Dependencies
- `gtk-engines` - GTK2 pixmap engine
- `ttf-roboto` - Default font
- `ttf-ubuntu-font-family` - Alternative font
- `cantarell-fonts` - Tertiary font option

## Development

### Quick Start

```bash
# Validate everything
make validate

# Build package
make build

# Run full test suite
make test

# Clean artifacts
make clean
```

### Project Structure

```
.
├── PKGBUILD              # Main package build script
├── .SRCINFO              # Package metadata
├── build-helpers.sh      # Modular build utilities
├── validate.sh           # Pre-commit validation
├── Makefile              # Development shortcuts
├── .editorconfig         # Editor configuration
├── .github/
│   └── workflows/
│       └── build-test.yml # CI/CD pipeline
├── DEVELOPMENT.md        # Developer documentation
├── CONTRIBUTING.md       # Contribution guide
└── README.md            # This file
```

### Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

For detailed development information, see [DEVELOPMENT.md](DEVELOPMENT.md).

## Validation

Before committing changes:

```bash
# Run validation script
./validate.sh

# Update .SRCINFO if PKGBUILD changed
makepkg --printsrcinfo > .SRCINFO
```

## Continuous Integration

This project uses GitHub Actions for automated testing. Every push and pull request triggers:

1. PKGBUILD validation with `namcap`
2. Full package build in clean Arch Linux container
3. Package content validation
4. Artifact upload for manual testing

## Troubleshooting

### Inkscape Errors

If you encounter Inkscape-related errors:

```bash
# Check Inkscape version
inkscape --version

# Ensure version is 1.0+
# Update if necessary: sudo pacman -S inkscape
```

### Build Failures

```bash
# Clean build with verbose output
make clean
makepkg -sf 2>&1 | tee build.log

# Check logs for specific errors
grep -i error build.log
```

### Asset Generation Issues

The build system validates asset generation. If assets fail to generate:

1. Check Inkscape is properly installed
2. Verify Python scripts have `subprocess` import
3. Check directory permissions
4. Review build log for specific errors

## Performance

The improved build system includes performance tracking:

- Individual phase timing
- Total build time monitoring
- Parallel asset rendering support
- Optimized file operations

Example build output:
```
[INFO] GTK2 assets completed in 15s
[INFO] GTK 3.20 assets completed in 23s
[INFO] GTK 4.0 assets completed in 22s
[INFO] WM assets completed in 8s
[INFO] Total build completed in 68s
```

## Technical Details

### Build Phases

1. **prepare()**: Patches rendering scripts for modern Inkscape
2. **build()**: Renders all theme assets (GTK2, GTK3, GTK4, WM)
3. **package()**: Installs theme with proper file organization

### Asset Pipeline

- **GTK2**: Shell-based rendering
- **GTK 3.20**: Python with normal and HiDPI variants
- **GTK 4.0**: Same as GTK 3.20 for compatibility
- **Window Manager**: Dedicated WM asset rendering

### Modern Inkscape Flags

```bash
--export-id=<object>      # Select specific object
--export-id-only          # Export only selected object
--export-filename=<file>  # Output file path
--export-dpi=180          # HiDPI rendering
--export-background-opacity=0  # Transparent background
```

## License

This package configuration is GPL licensed. The Ant-Dracula theme itself maintains its original license from the upstream project.

## Credits

- **Original Theme**: [EliverLara/Ant-Dracula](https://github.com/EliverLara/Ant-Dracula)
- **Package Maintainer**: Tony Lambiris <tony@libpcap.net>
- **Architectural Improvements**: Community contributions

## Related Projects

- [Ant Theme](https://github.com/EliverLara/Ant) - Original Ant theme
- [Dracula Theme](https://draculatheme.com/) - Official Dracula theme
- [GTK Theme Guide](https://wiki.gnome.org/Projects/GnomeShell/Development)

## Support

- **Issues**: [GitHub Issues](https://github.com/Oichkatzelesfrettschen/ant-dracula-theme-git/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Oichkatzelesfrettschen/ant-dracula-theme-git/discussions)
- **Upstream**: [Ant-Dracula Project](https://github.com/EliverLara/Ant-Dracula)

