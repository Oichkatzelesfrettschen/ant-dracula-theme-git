# Contributing to Ant-Dracula Theme

Thank you for your interest in contributing to the Ant-Dracula theme package!

## How to Contribute

### Reporting Issues

When reporting issues, please include:
- Your Arch Linux version
- Inkscape version (`inkscape --version`)
- Complete build log if relevant
- Steps to reproduce the issue

### Code Contributions

1. **Fork the Repository**
   ```bash
   git clone https://github.com/Oichkatzelesfrettschen/ant-dracula-theme-git.git
   cd ant-dracula-theme-git
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Follow existing code style
   - Test your changes thoroughly
   - Update documentation as needed

4. **Validate Your Changes**
   ```bash
   # Validate PKGBUILD
   namcap PKGBUILD
   
   # Validate shell scripts
   shellcheck build-helpers.sh
   
   # Test build
   makepkg -sf
   
   # Test package
   namcap *.pkg.tar.*
   ```

5. **Update .SRCINFO**
   ```bash
   makepkg --printsrcinfo > .SRCINFO
   ```

6. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: descriptive commit message"
   ```

7. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## Commit Message Guidelines

Use conventional commit format:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add parallel asset rendering
fix: resolve inkscape compatibility issue
docs: update installation instructions
```

## Code Style

### Shell Scripts

- Use tabs for indentation (as per .editorconfig)
- Follow shellcheck recommendations
- Use descriptive variable names
- Add comments for complex logic
- Always use quotes around variables

### Python Scripts

- Follow PEP 8 style guide
- Use 4 spaces for indentation
- Add docstrings for functions
- Handle exceptions appropriately

### PKGBUILD

- Follow [Arch packaging standards](https://wiki.archlinux.org/title/Arch_package_guidelines)
- Use tabs for indentation
- Keep functions focused and modular
- Add comments for non-obvious operations

## Testing

Before submitting:

1. **Build Test**
   ```bash
   makepkg -sf --noconfirm
   ```

2. **Package Validation**
   ```bash
   namcap PKGBUILD
   namcap *.pkg.tar.*
   ```

3. **Installation Test**
   ```bash
   sudo pacman -U *.pkg.tar.*
   # Test theme in GTK applications
   ```

4. **Clean Build Test**
   ```bash
   makepkg -C  # Clean
   makepkg -sf
   ```

## Review Process

1. Automated CI tests run on all pull requests
2. Maintainer reviews code and tests
3. Address any feedback
4. Once approved, changes are merged

## Questions?

- Open an issue for questions
- Check existing issues and pull requests
- Review [DEVELOPMENT.md](DEVELOPMENT.md) for technical details

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on the code, not the person
- Help maintain a positive community

## License

By contributing, you agree that your contributions will be licensed under the GPL license.
