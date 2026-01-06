# Maintainer: Tony Lambiris <tony@libpcap.net>

pkgname=ant-dracula-theme-git
_pkgname=Ant-Dracula
pkgver=4.0.0.r137.gfccbc2e
pkgrel=1
pkgdesc="Dracula variant of the Ant theme"
arch=("any")
url="https://github.com/EliverLara/${_pkgname}"
license=('GPL')
depends=('gtk-engine-murrine')
makedepends=('git' 'inkscape' 'optipng')
optdepends=('gtk-engines: for GTK2 pixmap engine'
			'ttf-roboto: primary font face defined'
			'ttf-ubuntu-font-family: secondary font face defined'
			'cantarell-fonts: tertiary font face defined')
conflicts=('ant-dracula-gtk-theme')
provides=('ant-dracula-gtk-theme')
source=("${_pkgname}::git+https://github.com/EliverLara/${_pkgname}.git")
sha256sums=('SKIP')

prepare() {
	set -e -o pipefail
  	cd "${srcdir}/${_pkgname}"

	# Source build helpers if available
	if [ -f "${startdir}/build-helpers.sh" ]; then
		source "${startdir}/build-helpers.sh"
		check_inkscape_version
		check_optipng
	fi

	msg2 "Patching rendering scripts for modern Inkscape compatibility..."
	# Patch standard rendering scripts
	find . -name "*.py" ! -name "*-hidpi.py" -exec sed -i '/def inkscape_render_rect/,/optimize_png(output_file)/c\def inkscape_render_rect(icon_file, rect, output_file):\n    subprocess.run([INKSCAPE, "--export-id=" + rect, "--export-id-only", "--export-background-opacity=0", "--export-filename=" + output_file, icon_file], check=True)\n    optimize_png(output_file)' {} +
	# Patch HiDPI rendering scripts
	find . -name "*-hidpi.py" -exec sed -i '/def inkscape_render_rect/,/optimize_png(output_file)/c\def inkscape_render_rect(icon_file, rect, output_file):\n    subprocess.run([INKSCAPE, "--export-dpi=180", "--export-id=" + rect, "--export-id-only", "--export-background-opacity=0", "--export-filename=" + output_file, icon_file], check=True)\n    optimize_png(output_file)' {} +
	
	msg2 "Validating Python scripts..."
	# Verify subprocess import exists in render scripts
	for py_file in $(find . -name "render-*.py" -type f); do
		if ! grep -q "import subprocess" "$py_file"; then
			sed -i '1a import subprocess' "$py_file"
		fi
	done
}

pkgver() {
  	cd "${srcdir}/${_pkgname}"

	git describe --long --tags | sed 's/\([^-]*-g\)/r\1/;s/-/./g;s/^v//g'
}

build() {
	set -e -o pipefail
  	cd "${srcdir}/${_pkgname}"

	# Source build helpers if available
	if [ -f "${startdir}/build-helpers.sh" ]; then
		source "${startdir}/build-helpers.sh"
	fi

	export THEME_FONT_FACE="${THEME_FONT_FACE:-Roboto}"
	export THEME_FONT_SIZE="${THEME_FONT_SIZE:-10}"

	msg2 "To customize the font and size for gnome-shell, build this package"
	msg2 "with the variables below set to the desired font family and size"
	msg2 "- THEME_FONT_FACE (default font family is Roboto)"
	msg2 "- THEME_FONT_SIZE (default font point size is 10)"
	msg2 ""
	msg2 "Continuing build in 5 seconds..."; sleep 5

	# Start total build timer
	start_timer "Total build" 2>/dev/null || true

	# GTK2 assets
	msg2 "Rendering GTK2 assets..."
	start_timer "GTK2 assets" 2>/dev/null || true
	(cd gtk-2.0 && ./render-assets.sh) || {
		log_error "GTK2 asset rendering failed" 2>/dev/null || error "GTK2 asset rendering failed"
		exit 1
	}
	end_timer "GTK2 assets" 2>/dev/null || true

	# GTK 3.20 assets
	msg2 "Rendering GTK 3.20 assets..."
	start_timer "GTK 3.20 assets" 2>/dev/null || true
	(cd gtk-3.20/assets && ./render-gtk3-assets.py && ./render-gtk3-assets-hidpi.py) || {
		log_error "GTK 3.20 asset rendering failed" 2>/dev/null || error "GTK 3.20 asset rendering failed"
		exit 1
	}
	validate_assets "gtk-3.20/assets" "GTK 3.20" 2>/dev/null || true
	end_timer "GTK 3.20 assets" 2>/dev/null || true

	# GTK 4.0 assets
	msg2 "Rendering GTK 4.0 assets..."
	start_timer "GTK 4.0 assets" 2>/dev/null || true
	(cd gtk-4.0/assets && ./render-gtk3-assets.py && ./render-gtk3-assets-hidpi.py) || {
		log_error "GTK 4.0 asset rendering failed" 2>/dev/null || error "GTK 4.0 asset rendering failed"
		exit 1
	}
	validate_assets "gtk-4.0/assets" "GTK 4.0" 2>/dev/null || true
	end_timer "GTK 4.0 assets" 2>/dev/null || true

	# WM assets
	msg2 "Rendering WM assets..."
	start_timer "WM assets" 2>/dev/null || true
	(cd src && ./render-wm-assets.py && ./render-wm-assets-hidpi.py) || {
		log_error "WM asset rendering failed" 2>/dev/null || error "WM asset rendering failed"
		exit 1
	}
	end_timer "WM assets" 2>/dev/null || true
	
	# Final verification
	msg2 "Verifying asset generation..."
	if [ ! -d "assets" ] || [ -z "$(ls -A assets/*.png 2>/dev/null)" ]; then
		error "No PNG assets were generated in the assets/ directory! Rendering failed."
		exit 1
	fi
	msg2 "Assets rendered and verified successfully!"

	# Font customization
	msg2 "Setting gnome-shell font face to ${THEME_FONT_FACE}"
	msg2 "Setting gnome-shell font size to ${THEME_FONT_SIZE}"

	if [ "${THEME_FONT_FACE}" != "Roboto" ]; then
		sed -i -re "s/font-family: (.*);/font-family: ${THEME_FONT_FACE}, \1;/" \
			"${srcdir}/${_pkgname}/gnome-shell/gnome-shell.css"
	fi

	if [ "${THEME_FONT_SIZE}" != "10" ]; then
		sed -i -re "s/font-size: (.*);/font-size: ${THEME_FONT_SIZE}pt;/" \
			"${srcdir}/${_pkgname}/gnome-shell/gnome-shell.css"
	fi

	# Cleanup temporary files
	cleanup_temp_files "${srcdir}/${_pkgname}" 2>/dev/null || true
	
	end_timer "Total build" 2>/dev/null || true
}

package() {
  	cd "${srcdir}/${_pkgname}"

	# Source build helpers if available
	if [ -f "${startdir}/build-helpers.sh" ]; then
		source "${startdir}/build-helpers.sh"
	fi

	msg2 "Installing theme to ${pkgdir}/usr/share/themes/${_pkgname}"
	mkdir -p "${pkgdir}/usr/share/themes/${_pkgname}"
	
	# Copy theme files, excluding development artifacts
	find "${srcdir}/${_pkgname}" -mindepth 1 -maxdepth 1 \
		! -name '.git' \
		! -name '.github' \
		! -name '*.md' \
		! -name 'LICENSE' \
		-exec cp -a {} "${pkgdir}/usr/share/themes/${_pkgname}/" \;
	
	# Copy documentation files to proper location
	if [ -f "${srcdir}/${_pkgname}/LICENSE" ]; then
		install -Dm644 "${srcdir}/${_pkgname}/LICENSE" \
			"${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
	fi
	
	if [ -f "${srcdir}/${_pkgname}/README.md" ]; then
		install -Dm644 "${srcdir}/${_pkgname}/README.md" \
			"${pkgdir}/usr/share/doc/${pkgname}/README.md"
	fi

	# Final cleanup of installed files
	log_info "Cleaning up development artifacts from package..." 2>/dev/null || msg2 "Cleaning up development artifacts..."
	cleanup_temp_files "${pkgdir}/usr/share/themes/${_pkgname}" 2>/dev/null || {
		find "${pkgdir}" -type f \( -name "*.pyc" -o -name "*.pyo" \) -delete 2>/dev/null || true
	}
	
	# Remove render scripts from final package
	find "${pkgdir}/usr/share/themes/${_pkgname}" -type f -name "render-*.py" -delete 2>/dev/null || true
	find "${pkgdir}/usr/share/themes/${_pkgname}" -type f -name "render-*.sh" -delete 2>/dev/null || true
	
	log_success "Theme installation completed" 2>/dev/null || msg2 "Installation completed successfully"
}
