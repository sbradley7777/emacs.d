# Emacs Configuration Features

This document provides comprehensive details about all features available in this Emacs configuration, including version-aware capabilities and language-specific enhancements.

## Table of Contents

- [Version-Aware Capabilities](#version-aware-capabilities)
- [Performance Optimizations](#performance-optimizations)
- [Auto-Completion System](#auto-completion-system)
- [Language Support](#language-support)
  - [Python Development Environment](#python-development-environment)
  - [Lisp/Elisp Development](#lispellisp-development)
  - [Makefile Development](#makefile-development)
  - [Markdown Support](#markdown-support)
  - [TOML Configuration](#toml-configuration)
  - [YAML Configuration](#yaml-configuration)
- [Code Style and Standards](#code-style-and-standards)
- [User Interface Enhancements](#user-interface-enhancements)
- [Related Documentation](#related-documentation)

## Version-Aware Capabilities

The configuration automatically adapts based on your Emacs version, providing optimized features and performance for each version tier:

### Feature Tiers

| Tier | Emacs Version | Capabilities |
|------|---------------|-------------|
| **Modern** | 30.2+ | Full feature set with maximum performance optimizations |
| **Current** | 27.x | Modern features with compatibility adjustments |
| **Stable** | 26.x | Core features with conservative settings |
| **Legacy** | 24.x | Basic functionality for older installations |

### Version-Specific Optimizations

**Performance Tuning** ([`core/core-constants.el`](core/core-constants.el)):
- **Garbage Collection**: Dynamically adjusted thresholds (8MB for modern, 1MB for legacy)
- **Memory Management**: Version-aware heap optimization for long-running sessions
- **Loading Performance**: Optimized startup sequences based on version capabilities

**UI Features** ([`core/ui.el`](core/ui.el)):
- **Line Numbers**: Native `display-line-numbers-mode` for Emacs 26+, fallback for older versions
- **Native Compilation**: Automatic detection and utilization when available (Emacs 28+)
- **Advanced Display**: Enhanced visual features for modern Emacs versions

## Performance Optimizations

### Startup Performance
- **Early initialization** ([`early-init.el`](early-init.el)): Loaded before package.el and GUI initialization
- **Garbage collection tuning**: Temporarily disabled during startup for faster loading
- **Package management**: Controlled package loading and initialization order
- **File handler optimization**: Temporary disabling of file name handlers during startup

### Runtime Performance
- **Intelligent GC management**: Automatic threshold adjustment based on session length
- **Deferred loading**: Optional packages loaded only when needed
- **Native compilation support**: Automatic utilization when available

## Auto-Completion System

### Universal Completion Framework
Powered by [Corfu](https://github.com/minad/corfu) for comprehensive auto-completion across all file types:

**Features:**
- **Automatic completion** appears after typing 1 character (200ms delay)
- **Smart `TAB` behavior** - completes when possible, indents otherwise
- **Multiple trigger options**:
  - `TAB` - Smart completion/indentation
  - `C-c TAB` - Manual completion trigger (reliable in all environments)
  - `M-TAB` - Traditional Alt+TAB completion
  - `C-M-i` - Traditional Ctrl+Alt+i completion

**Completion Sources:**
- LSP servers for intelligent code completion
- Built-in Emacs completion functions
- Mode-specific completion backends
- Context-aware suggestions based on file type

## Language Support

### Python Development Environment

Comprehensive Python development setup with intelligent environment management:

#### Core Features
- **[Eglot](https://github.com/joaotavora/eglot) LSP integration** using [`python-lsp-server`](https://github.com/python-lsp/python-lsp-server) (pylsp)
- **Automatic virtual environment detection and activation** ([`lang/python/pyvenv-config.el`](lang/python/pyvenv-config.el))
- **Enhanced modeline display** showing active virtual environment and Python version
- **Project-aware environment switching** with automatic detection

#### Virtual Environment Management
**Automatic Detection** ([`lang/python/pyvenv-config.el`](lang/python/pyvenv-config.el)):
- Detects `venv/` directories in project roots
- Project root determined by `.git/`, `pyproject.toml`, or `requirements.txt`
- Automatic activation when opening Python files
- Python version detection and display

**Manual Control:**
- `M-x pyvenv-activate` - Manually activate a virtual environment
- `M-x pyvenv-deactivate` - Deactivate current virtual environment
- `M-x pyvenv-workon` - Switch to a different virtual environment

#### LSP Configuration
**Default Setup** ([`lang/python/eglot-config.el`](lang/python/eglot-config.el)):
- Clean, maintainable configuration without complex overrides
- Automatic tool detection and prioritization
- Enhanced linting with [`ruff`](https://github.com/astral-sh/ruff) when available
- Static type checking with [`mypy`](https://github.com/python/mypy) integration

**Required Dependencies:**
```bash
# Core LSP server and enhanced tools
pip install python-lsp-server pylsp-mypy python-lsp-ruff mypy ruff
```

**Tool Hierarchy:**
1. **[Ruff](https://github.com/astral-sh/ruff)**: Fast linting and formatting (overrides built-in pycodestyle, pyflakes)
2. **[MyPy](https://github.com/python/mypy)**: Static type checking (enhanced type analysis)
3. **Built-in linters**: Fallback when external tools unavailable

#### Development Tools
- **Real-time diagnostics** via [Flymake](https://www.gnu.org/software/emacs/manual/html_mono/flymake.html) integration
- **Go to definition** - `M-.` to jump to function/class definitions
- **Find references** - `M-?` to find all references to a symbol
- **Symbol renaming** - `C-c r` to rename symbols across the project
- **Code actions** - `C-c a` for available code fixes and refactoring

### Lisp/Elisp Development

Enhanced support for Lisp programming with comprehensive development tools:

**Features** ([`lang/lisp-config.el`](lang/lisp-config.el)):
- **Intelligent completion** for functions, variables, and macros
- **[SLIME](https://github.com/slime/slime) integration** for [Common Lisp](https://common-lisp.net/) development (when available)
- **Enhanced evaluation** with inline result display
- **Auto-formatting** via [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt) integration

### Makefile Development

Professional [Makefile](https://www.gnu.org/software/make/manual/make.html) editing support with intelligent features:

**Features** ([`lang/makefile-config.el`](lang/makefile-config.el)):
- **Smart indentation** respecting Makefile tab requirements
- **Target completion** and navigation
- **Variable highlighting** and substitution awareness
- **Make command integration** for rapid build testing

### Markdown Support

Enhanced [Markdown](https://daringfireball.net/projects/markdown/) editing for documentation and content creation:

**Features** ([`lang/markdown-config.el`](lang/markdown-config.el)):
- **Syntax highlighting** with [GitHub Flavored Markdown](https://github.github.com/gfm/) support
- **Live preview** capabilities (when markdown processors are available)
- **Table editing** assistance
- **Header navigation** and structure management

### TOML Configuration

Comprehensive [TOML](https://toml.io/) support for modern configuration management:

**Features** ([`lang/toml-config.el`](lang/toml-config.el)):
- **Syntax highlighting** for TOML configuration files
- **Project integration** with `pyproject.toml` support
- **Structure validation** with error highlighting
- **Auto-completion** for common TOML keys and values

### YAML Configuration

Specialized handling for [YAML](https://yaml.org/) files with structure-aware features:

**Features** ([`lang/yaml-config.el`](lang/yaml-config.el)):
- **Structure-aware completion** for YAML hierarchies
- **Indentation management** (2 spaces, [YAML standard](https://yaml.org/))
- **Syntax highlighting** with nested structure visualization
- **Auto-indent on newline** for consistent formatting

## Code Style and Standards

### Automated Formatting
This configuration enforces consistent code style through automated tools:

**[elisp-autofmt](https://github.com/emacsmirror/elisp-autofmt) Integration:**
- **Automatic formatting on save** for Emacs Lisp files
- **Manual formatting** via `C-c C-f` keybinding
- **Native Emacs style** using built-in indentation rules
- **Pre-commit integration** for quality assurance

**Standards Compliance:**
- **[GNU Emacs Lisp conventions](https://www.gnu.org/software/emacs/manual/html_node/elisp/Tips.html)** for all configuration files
- **Consistent file organization** and naming conventions
- **Standardized file headers** and documentation format
- **Automated quality checks** via [`pre-commit`](https://github.com/pre-commit/pre-commit) hooks

For detailed style guidelines, see [`STYLEGUIDE.md`](STYLEGUIDE.md).

## User Interface Enhancements

### Visual Improvements
- **[Rainbow Delimiters](https://github.com/Fanael/rainbow-delimiters)** ([`features/rainbow-delimiters.el`](features/rainbow-delimiters.el)): Enhanced delimiter visibility with color coding
- **[Indent Guides](https://github.com/DarthFennec/highlight-indent-guides)** ([`features/indent-guides.el`](features/indent-guides.el)): Visual indentation guides for better code structure
- **Theme Support** ([`themes/themes.el`](themes/themes.el)): [Zenburn](https://github.com/bbatsov/zenburn-emacs) theme with custom black background

### Enhanced Diagnostics
- **[Flymake Integration](https://www.gnu.org/software/emacs/manual/html_mono/flymake.html)** ([`features/flymake-config.el`](features/flymake-config.el)): Real-time syntax checking and linting
- **LSP Diagnostics**: Comprehensive error reporting and code intelligence
- **Performance Monitoring**: Load time tracking for configuration modules

## Related Documentation

- [`CONTRIBUTING.md`](CONTRIBUTING.md) - Guidelines for contributing to the configuration
- [`FAQ.md`](FAQ.md) - Frequently asked questions about configuration and usage
- [`KEYMAP.md`](KEYMAP.md) - Comprehensive keybinding reference and command documentation
- [`README.md`](README.md) - Main project documentation and setup instructions
- [`STYLEGUIDE.md`](STYLEGUIDE.md) - Code formatting and style standards
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Solutions for common issues and debugging guides
