# Makefile for Ant-Dracula Theme Development
# Provides convenient shortcuts for common tasks

.PHONY: help build clean validate install test update-srcinfo check-deps

help:
	@echo "Ant-Dracula Theme Development Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  build         - Build the package"
	@echo "  clean         - Clean build artifacts"
	@echo "  validate      - Validate PKGBUILD and scripts"
	@echo "  install       - Build and install the package"
	@echo "  test          - Run validation and build tests"
	@echo "  update-srcinfo- Update .SRCINFO file"
	@echo "  check-deps    - Check for required dependencies"
	@echo "  help          - Show this help message"

check-deps:
	@echo "Checking for required dependencies..."
	@command -v makepkg >/dev/null 2>&1 || { echo "ERROR: makepkg not found"; exit 1; }
	@command -v inkscape >/dev/null 2>&1 || { echo "ERROR: inkscape not found"; exit 1; }
	@command -v optipng >/dev/null 2>&1 || { echo "ERROR: optipng not found"; exit 1; }
	@command -v namcap >/dev/null 2>&1 || echo "WARNING: namcap not found (optional)"
	@command -v shellcheck >/dev/null 2>&1 || echo "WARNING: shellcheck not found (optional)"
	@echo "Dependency check completed"

validate:
	@echo "Running validation..."
	@./validate.sh

update-srcinfo:
	@echo "Updating .SRCINFO..."
	@makepkg --printsrcinfo > .SRCINFO
	@echo ".SRCINFO updated successfully"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf src pkg Ant-Dracula *.pkg.tar.* *.log
	@echo "Clean completed"

build: check-deps
	@echo "Building package..."
	@makepkg -sf

install: build
	@echo "Installing package..."
	@sudo pacman -U *.pkg.tar.* --noconfirm

test: validate
	@echo "Running build test..."
	@makepkg -sf --noconfirm
	@echo "Testing package with namcap..."
	@namcap *.pkg.tar.* || true
	@echo "Test completed"

# Custom font build
build-custom-font:
	@echo "Building with custom font configuration..."
	@echo "THEME_FONT_FACE=$(THEME_FONT_FACE) THEME_FONT_SIZE=$(THEME_FONT_SIZE)"
	@THEME_FONT_FACE=$(THEME_FONT_FACE) THEME_FONT_SIZE=$(THEME_FONT_SIZE) makepkg -sf
