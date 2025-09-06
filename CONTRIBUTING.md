# Contributing Guidelines

This document provides guidelines for contributing to this Emacs configuration, whether you're fixing bugs, adding features, or improving documentation.

## Table of Contents

- [Development Setup](#development-setup)
- [Code Style Requirements](#code-style-requirements)
- [Module Structure](#module-structure)
- [Testing Procedures](#testing-procedures)
- [Submission Process](#submission-process)
- [Package Management](#package-management)
- [Performance Considerations](#performance-considerations)
- [Documentation Standards](#documentation-standards)
- [Quality Assurance](#quality-assurance)
- [Related Documentation](#related-documentation)

## Development Setup

### Installation for Development

Use the development installation method to make changes immediately available for testing:

```bash
# Clone the repository
git clone <repository-url> ~/github/emacs.d

# Navigate to the repository
cd ~/github/emacs.d

# Run the development installer (creates symlinks)
chmod +x scripts/install.sh
./scripts/install.sh
```

This creates symlinks from `~/.emacs.d/` to your repository, allowing immediate testing of changes.

### Required Development Tools

**Core Requirements:**
- **Emacs 26.0.50+**: For testing configuration compatibility
- **Git**: For version control and pre-commit hooks
- **Python 3**: Required for elisp-autofmt and pre-commit

**Code Quality Tools:**
```bash
# Install elisp-autofmt for automatic formatting
git clone https://github.com/emacsmirror/elisp-autofmt.git ~/github/elisp-autofmt

# Install pre-commit for quality assurance
pip install pre-commit  # https://github.com/pre-commit/pre-commit
pre-commit install
```

**Python Development Tools** (for Python-related changes):
```bash
# Install LSP server and tools for testing Python features
pip install python-lsp-server pylsp-mypy python-lsp-ruff mypy ruff
```

### Development Workflow

1. **Create feature branch**: `git checkout -b feature/description`
2. **Make changes**: Edit configuration files using proper style
3. **Test thoroughly**: Restart Emacs and test affected functionality
4. **Commit changes**: Pre-commit hooks will automatically format and check code
5. **Submit for review**: Create pull request with detailed description

## Code Style Requirements

All contributions must follow the established coding standards documented in [`STYLEGUIDE.md`](STYLEGUIDE.md).

### Emacs Lisp Standards

**File Structure** - Every `.el` file must include:
```elisp
;;; filename.el --- Brief Description -*- lexical-binding: t -*-
;;; Commentary:
;;      Detailed description of file purpose.

(defvar config-load-start-time (current-time))
(message "=  Loading filename.el...")

;; Configuration code here

(provide 'filename)
(message "filename.el loaded (%.2fs)"
         (float-time (time-subtract (current-time) config-load-start-time)))
```

**Formatting Standards:**
- **Indentation**: 2 spaces per level (automatic via [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt))
- **Line length**: Maximum 127 characters
- **No tabs**: Use spaces only
- **Section separators**: Use consistent 127-character separators
- **Naming**: Use `kebab-case` for all identifiers

**Message Symbols** - Use the established symbol system:
- = Loading/In Progress
-  Success/Completion
- L Errors/Failures
- � Warnings
- =� Package Operations
- 9 Information/Details
- � Configuration Complete

### Automated Formatting

The configuration uses automated formatting tools:
- **elisp-autofmt**: Automatically formats Emacs Lisp files on save
- **Pre-commit hooks**: Enforce quality standards before commits
- **Manual formatting**: Use `C-c C-f` in emacs-lisp-mode

## Module Structure

### Adding New Modules

When adding new functionality, follow the modular structure:

**Core Modules** (`core/`): Essential functionality loaded first
- `package-system/` - Modular package management system
- `packages.el` - Package declarations and configurations
- `ui.el` - User interface settings
- `editing.el` - Text editing behavior
- `files.el` - File handling and backup settings
- `keybindings.el` - Global key bindings

**Feature Modules** (`features/`): Optional enhancements
- Can be disabled independently
- Should degrade gracefully if dependencies unavailable
- Include comprehensive error handling

**Language Modules** (`lang/`): Language-specific configurations
- Organized by language in subdirectories
- Include LSP configuration, tools, and language-specific settings
- Follow the Python module structure as a template

### Module Dependencies

**Loading Order** (defined in [`init.el`](init.el)):
1. Core constants and package management
2. Core UI and editing functionality
3. Feature enhancements
4. Language-specific configurations
5. User customizations

**Dependency Management:**
- Use `condition-case` for robust error handling
- Check feature availability before configuration
- Provide graceful fallbacks for missing dependencies

## Testing Procedures

### Manual Testing

**Basic Testing:**
1. **Clean restart**: Start Emacs with your changes
2. **Check Messages buffer**: Look for errors or warnings
3. **Test affected features**: Verify functionality works as expected
4. **Performance check**: Ensure no significant startup delay

**Comprehensive Testing:**
1. **Multiple Emacs versions**: Test on supported versions when possible
2. **Different environments**: Test with/without optional dependencies
3. **Error conditions**: Test error handling with missing packages
4. **Performance impact**: Monitor startup times and memory usage

### Version Compatibility Testing

Test with different Emacs versions to ensure proper version-aware behavior:
- **Modern (30.2+)**: Full feature set
- **Current (27.x)**: Feature compatibility
- **Stable (26.x)**: Core functionality
- **Legacy (24.x)**: Basic operation (when applicable)

### Python Development Testing

For Python-related changes:
1. **Virtual environment detection**: Test with various project structures
2. **LSP functionality**: Verify completion, diagnostics, and navigation
3. **Multiple Python versions**: Test with different Python versions
4. **Error handling**: Test with missing or corrupted virtual environments

## Submission Process

### Before Submitting

**Quality Checklist:**
- [ ] Code follows style guidelines in [`STYLEGUIDE.md`](STYLEGUIDE.md)
- [ ] All files include proper headers and documentation
- [ ] Changes are tested with a clean Emacs restart
- [ ] No errors in Messages buffer
- [ ] Performance impact is acceptable
- [ ] Documentation is updated if needed

**Pre-commit Verification:**
```bash
# Run pre-commit checks manually
pre-commit run --all-files

# Ensure clean commit
git status
git diff --cached
```

### Pull Request Guidelines

**PR Description Should Include:**
- **Purpose**: Clear description of what the change accomplishes
- **Testing**: Details of testing performed
- **Compatibility**: Any version-specific considerations
- **Breaking changes**: If any, with migration guidance
- **Related issues**: Reference any related issues or discussions

**Code Review Process:**
1. **Automated checks**: Ensure all pre-commit hooks pass
2. **Manual review**: Code style, logic, and best practices
3. **Testing verification**: Confirm reported testing was adequate
4. **Documentation review**: Ensure documentation is complete and accurate

## Package Management

### Adding New Packages

**Package Selection Criteria:**
- **Necessity**: Package provides significant value
- **Maintenance**: Package is actively maintained
- **Compatibility**: Works across supported Emacs versions
- **Security**: Package comes from trusted sources
- **Performance**: Minimal impact on startup time

**Package Addition Process:**
1. **Add to packages.el**: Include package declaration with configuration
2. **Update documentation**: Add to appropriate documentation files
3. **Test thoroughly**: Ensure package works and doesn't conflict
4. **Consider alternatives**: Evaluate if existing solutions could work

**Package Configuration Standards:**
```elisp
(use-package package-name
  :ensure t
  :defer t  ; When appropriate
  :config
  (setq option-1 value-1
        option-2 value-2)
  :hook (mode . function)
  :bind ("C-c k" . package-function))
```

### Managing Dependencies

**Version Pinning** ([`core/package-system/repositories.el`](core/package-system/repositories.el)):
- **MELPA Stable**: Priority 20 (preferred for stability)
- **GNU ELPA**: Priority 15 (official packages)
- **MELPA**: Priority 10 (latest development versions)

**Dependency Resolution:**
- Check for conflicting packages before adding new ones
- Use `:ensure t` for automatic installation
- Document any manual installation requirements

## Performance Considerations

### Startup Performance

**Optimization Strategies:**
- **Defer loading**: Use `:defer t` for non-essential packages
- **Autoloads**: Rely on package autoloads when possible
- **Conditional loading**: Load packages only when needed
- **Avoid expensive operations**: Defer computationally expensive setup

**Performance Monitoring:**
- **Load timing**: Every module reports load time
- **Startup measurement**: Monitor total startup time
- **Memory usage**: Avoid packages with excessive memory usage
- **GC optimization**: Consider impact on garbage collection

### Runtime Performance

**Memory Management:**
- **Use lexical binding**: Always include `lexical-binding: t`
- **Avoid global variables**: Use appropriate scoping
- **Clean up resources**: Remove hooks and timers when appropriate
- **Monitor GC**: Be aware of garbage collection impact

## Documentation Standards

### Documentation Requirements

**All changes must include appropriate documentation updates:**
- **README.md**: Update if installation or requirements change
- **FEATURES.md**: Document new features or capabilities
- **TROUBLESHOOTING.md**: Add solutions for new potential issues
- **FAQ.md**: Add answers for likely questions
- **STYLEGUIDE.md**: Update for any style guideline changes

### Documentation Style

**Writing Standards:**
- **Clear and concise**: Use simple, direct language
- **User-focused**: Write from the user's perspective
- **Complete**: Include all necessary information
- **Current**: Keep documentation synchronized with code changes
- **Linked**: Use internal links to connect related information

**Code Examples:**
- **Accurate**: Ensure all code examples work as shown
- **Complete**: Include sufficient context for understanding
- **Tested**: Verify examples work in practice
- **Formatted**: Use proper markdown code formatting

## Quality Assurance

### Pre-commit Hooks

The repository uses pre-commit hooks to maintain code quality:

**Enabled Hooks:**
- **elisp-autofmt**: Automatic Emacs Lisp formatting
- **trailing-whitespace**: Remove trailing whitespace
- **end-of-file-fixer**: Ensure files end with newlines
- **check-large-files**: Prevent accidentally large files
- **shellcheck**: Shell script linting
- **codespell**: Spell checking

**Hook Configuration** (`.pre-commit-config.yaml`):
```yaml
repos:
  - repo: local
    hooks:
      - id: elisp-autofmt
        name: elisp-autofmt
        description: "Format Emacs Lisp files"
        entry: scripts/elisp-autofmt-hook
        language: script
        files: \.el$
```

### Manual Quality Checks

**Before Each Commit:**
- Run `M-x checkdoc` on modified `.el` files
- Verify no byte-compilation warnings
- Check for unused variables or functions
- Ensure consistent error handling

**Periodic Reviews:**
- Review startup performance regularly
- Update package versions and test compatibility
- Review and update documentation for accuracy
- Clean up any accumulated technical debt

## Getting Started with Contributions

1. **Set up development environment**: Follow the development setup instructions
2. **Familiarize yourself with the codebase**: Read through existing modules to understand patterns
3. **Start small**: Begin with small improvements or bug fixes
4. **Ask questions**: Don't hesitate to ask for clarification on any guidelines
5. **Follow the process**: Use the established workflow for quality and consistency

Thank you for contributing to this Emacs configuration!

## Related Documentation

- [`FAQ.md`](FAQ.md) - Frequently asked questions about configuration and usage
- [`FEATURES.md`](FEATURES.md) - Detailed feature documentation, version-aware capabilities, and language support
- [`README.md`](README.md) - Main project documentation and setup instructions
- [`STYLEGUIDE.md`](STYLEGUIDE.md) - Code formatting and style standards
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Solutions for common issues and debugging guides
