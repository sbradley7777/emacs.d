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
- **Emacs 30.2+**: Required for this configuration
- **Git**: For version control and [`pre-commit`](https://github.com/pre-commit/pre-commit) hooks
- **Python 3**: Required for [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt) and [`pre-commit`](https://github.com/pre-commit/pre-commit)

**Code Quality Tools:**
```bash
# Install elisp-autofmt for automatic formatting
git clone https://github.com/emacsmirror/elisp-autofmt.git ~/github/elisp-autofmt

# Install pre-commit for quality assurance
pip install pre-commit  # https://github.com/pre-commit/pre-commit
pre-commit install
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
(require 'core-utils)
;; Add other dependencies as needed
(core-utils-with-load-timing
 "filename.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Section Title
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Configuration code here
 )
(provide 'filename)
```

**Note**: Add `(require ...)` statements for any modules your file depends on. Only `early-init.el`, `init.el`, `core-logging.el`, and `core-utils.el` are exempt from using `core-utils-with-load-timing` due to technical constraints (circular dependencies or loading before core-utils exists).

**Formatting Standards:**
- **Indentation**: 2 spaces per level (automatic via [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt))
- **Line length**: Maximum 127 characters
- **No tabs**: Use spaces only
- **Section separators**: Use consistent 127-character separators
- **Naming**: Use [`kebab-case`](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) for all identifiers

**Standardized Utilities** - Use centralized utilities for consistency:
- **User input**: `core-user-read-string`, `core-user-read-number`, `core-user-read-password` ([`core-user-interaction-utils.el`](core/core-user-interaction-utils.el))
- **Process execution**: `core-process-run-sync` ([`core-process-utils.el`](core/core-process-utils.el))
- **Message logging**: `core-message-*` functions ([`core-logging.el`](core/core-logging.el))

**Message Functions** - Use the standardized message utilities:
- `core-message-loading` - 🔄 Loading/In Progress
- `core-message-success` - ✅ Success/Completion
- `core-message-error` - ❌ Errors/Failures
- `core-message-warning` - ⚠️ Warnings
- `core-message-package` - 📦 Package Operations
- `core-message-info` - ℹ️ Information/Details
- `core-message-config` - ⚙️ Configuration Complete
- `core-message-plain` - Plain messages (no Unicode prefix)

### Automated Formatting

The configuration uses automated formatting tools:
- **[`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt)**: Automatically formats Emacs Lisp files on save
- **Pre-commit hooks**: Enforce quality standards before commits
- **Manual formatting**: Use `C-c C-f` in emacs-lisp-mode

## Module Structure

### Adding New Modules

When adding new functionality, follow the modular structure:

**Core Modules** ([`core/`](core/)): Essential functionality loaded first
- `package-system/` - Modular package management system
- `core-packages.el` - Package declarations and configurations
- `core-ui.el` - User interface settings
- `core-editing.el` - Text editing behavior
- `core-files.el` - File handling and backup settings
- `core-logging.el` - Message logging and log rotation system
- `core-user-interaction-utils.el` - Standardized user input collection utilities
- `core-process-utils.el` - Centralized process execution utility
- `core-diagnostics.el` - System information and configuration diagnostics

**Feature Modules** ([`features/`](features/)): Optional enhancements
- Can be disabled independently
- Should degrade gracefully if dependencies unavailable
- Include comprehensive error handling

**Language Modules** ([`lang/`](lang/)): Language-specific configurations
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

**For comprehensive testing documentation, including automated scripts and detailed procedures, see [`scripts/TESTING.md`](scripts/TESTING.md).**

### Manual Testing

**Basic Testing:**
1. **Clean restart**: Start Emacs with your changes
2. **Check Messages buffer**: Look for errors or warnings
3. **Test affected features**: Verify functionality works as expected
4. **Performance check**: Ensure no significant startup delay

**Comprehensive Testing:**
1. **Emacs 30.2+ verification**: Ensure proper functionality on target version
2. **Different environments**: Test with/without optional dependencies
3. **Error conditions**: Test error handling with missing packages
4. **Performance impact**: Monitor startup times and memory usage

### Emacs 30.2+ Testing

This configuration targets Emacs 30.2+ exclusively:
- **Target Platform**: Emacs 30.2+ with full modern feature utilization
- **Modern Design**: Built specifically for Emacs 30.2+ capabilities
- **Complete Feature Set**: Utilizes all available Emacs 30.2+ features

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
- **Requirements**: Emacs 30.2+ specific considerations
- **Breaking changes**: If any, with migration guidance
- **Related issues**: Reference any related issues or discussions

**Code Review Process:**
1. **Automated checks**: Ensure all [`pre-commit`](https://github.com/pre-commit/pre-commit) hooks pass
2. **Manual review**: Code style, logic, and best practices
3. **Testing verification**: Confirm reported testing was adequate
4. **Documentation review**: Ensure documentation is complete and accurate

## Package Management

### Adding New Packages

**Package Selection Criteria:**
- **Necessity**: Package provides significant value
- **Maintenance**: Package is actively maintained
- **Requirements**: Works with Emacs 30.2+
- **Security**: Package comes from trusted sources
- **Performance**: Minimal impact on startup time

**Package Addition Process:**
1. **Add to core-packages.el**: Include package declaration with configuration
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

**Version Pinning** ([`core/package-system/package-repositories.el`](core/package-system/package-repositories.el)):
- **[MELPA Stable](https://stable.melpa.org/)**: Priority 20 (preferred for stability)
- **[GNU ELPA](https://elpa.gnu.org/)**: Priority 15 (official packages)
- **[MELPA](https://melpa.org/)**: Priority 10 (latest packages)

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
- **[`README.md`](README.md)**: Update if installation or requirements change
- **[`FEATURES.md`](FEATURES.md)**: Document new features or capabilities
- **[`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)**: Add solutions for new potential issues
- **[`FAQ.md`](FAQ.md)**: Add answers for likely questions
- **[`STYLEGUIDE.md`](STYLEGUIDE.md)**: Update for any style guideline changes

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

The repository uses [`pre-commit`](https://github.com/pre-commit/pre-commit) hooks to maintain code quality:

**Enabled Hooks:**
- **[`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt)**: Automatic Emacs Lisp formatting
- **[`trailing-whitespace`](https://github.com/pre-commit/pre-commit-hooks#trailing-whitespace)**: Remove trailing whitespace
- **[`end-of-file-fixer`](https://github.com/pre-commit/pre-commit-hooks#end-of-file-fixer)**: Ensure files end with newlines
- **[`check-large-files`](https://github.com/pre-commit/pre-commit-hooks#check-large-files)**: Prevent accidentally large files
- **[`shellcheck`](https://github.com/koalaman/shellcheck)**: Shell script linting
- **[`codespell`](https://github.com/codespell-project/codespell)**: Spell checking

**Hook Configuration** ([`.pre-commit-config.yaml`](.pre-commit-config.yaml)):
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
- Update packages and test functionality
- Review and update documentation for accuracy
- Clean up any accumulated technical debt

## Getting Started with Contributions

1. **Set up development environment**: Follow the development setup instructions
2. **Familiarize yourself with the codebase**: Read through existing modules to understand patterns
3. **Start small**: Begin with small improvements or bug fixes
4. **Ask questions**: Don't hesitate to ask for clarification on any guidelines
5. **Follow the process**: Use the established workflow for quality and consistency


## Related Documentation

**Essential for Contributors:**
- [`STYLEGUIDE.md`](STYLEGUIDE.md) - Code formatting and style standards (required reading)
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Testing and debugging procedures

**Configuration Reference:**
- [`README.md`](README.md) - Project setup and requirements
