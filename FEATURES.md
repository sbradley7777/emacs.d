# Emacs Configuration Features

This document provides comprehensive details about all features available in this Emacs configuration, targeting Emacs 30.2+ exclusively with modern language-specific enhancements.

## Table of Contents

- [Modern Emacs 30.2+ Features](#modern-emacs-302-features)
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
  - [Navigation and Discovery](#navigation-and-discovery)
  - [Visual Improvements](#visual-improvements)
  - [Enhanced Diagnostics](#enhanced-diagnostics)
- [Related Documentation](#related-documentation)

## Modern Emacs 30.2+ Features

This configuration is designed exclusively for Emacs 30.2+ and utilizes specific modern features that are not available in earlier versions:

### Core Modern Dependencies

**Native Compilation Enhancements**:
- **Improved bytecode generation**: Faster package loading and runtime execution
- **Automatic optimization**: Transparent performance improvements for all loaded packages
- **Memory efficiency**: Reduced memory footprint through optimized compiled code
- **Startup acceleration**: Native compilation cache reduces initialization time

**Built-in Use-Package Integration**:
- **Modern lazy-loading**: Advanced deferred loading mechanisms not available in earlier versions
- **Enhanced error handling**: Improved package failure recovery and diagnostics
- **Configuration validation**: Built-in syntax checking for package declarations

### Performance Features

**Advanced Garbage Collection** ([`core/core-constants.el`](core/core-constants.el)):
- **Dynamic thresholds**: 8MB for normal operation, 200MB during long development sessions
- **Modern GC algorithms**: Leveraging Emacs 30.2+ garbage collection improvements
- **Session-aware tuning**: Automatic adjustment based on usage patterns
- **Memory pressure handling**: Intelligent collection scheduling during intensive operations

**LSP and Development Optimizations**:
- **Native JSON parsing**: Faster Eglot communication with Python LSP servers
- **Real-time diagnostics**: Improved Flymake integration with immediate error display
- **Process optimization**: Better subprocess management for development tools

### User Interface Enhancements

**Modern Display Features** ([`core/ui.el`](core/ui.el)):
- **Enhanced line numbers**: `global-display-line-numbers-mode` with visual line support and performance improvements
- **Advanced theming**: Native support for modern color schemes and visual elements
- **Window management**: Enhanced split-window behavior and display management

**Interactive Features**:
- **Advanced completion**: Native completion-at-point improvements for better responsiveness
- **Modern help system**: Enhanced documentation display and interactive help
- **Improved which-key**: Better keybinding discovery with modern display capabilities

### Why These Features Matter

**For Daily Development**:
- **Faster workflow**: Reduced latency in code completion, diagnostics, and navigation
- **Better reliability**: Improved error handling prevents configuration crashes
- **Enhanced productivity**: Modern UI features reduce cognitive load

**Legacy Compatibility Note**: These features are not available through compatibility layers or workarounds in earlier Emacs versions. The configuration leverages native implementations that require the modern Emacs architecture introduced in 30.2+.

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
- **Modern [Eglot](https://github.com/joaotavora/eglot) LSP integration** using [`python-lsp-server`](https://github.com/python-lsp/python-lsp-server) (pylsp) at `~/.local/bin/pylsp`
- **Automatic virtual environment detection and activation** using [pyvenv](https://github.com/jorgenschaefer/pyvenv) ([`lang/python/pyvenv-config.el`](lang/python/pyvenv-config.el))
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
- Uses hard-coded path `~/.local/bin/pylsp` for reliable user pip installations ([`lang/python/python-constants.el`](lang/python/python-constants.el))
- Clean, maintainable configuration without complex overrides
- Enhanced linting with [`ruff`](https://github.com/astral-sh/ruff) when available
- Static type checking with [`mypy`](https://github.com/python/mypy) integration

**Path Configuration:**
- LSP server path is defined in [`lang/python/python-constants.el`](lang/python/python-constants.el) for centralized configuration
- Uses `~/.local/bin/pylsp` which is the standard location for user pip installations
- This provides more predictable behavior than system-wide detection methods

**Required Dependencies:**
```bash
# Install LSP server with user pip (installs to ~/.local/bin/pylsp)
pip install --user python-lsp-server pylsp-mypy python-lsp-ruff mypy ruff
```

**If Python features don't work as expected, see [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md#python-lsp-server-problems) for detailed solutions.**

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
- **Enhanced evaluation** with inline result display for Emacs Lisp development
- **Auto-formatting** via [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt) integration

### Makefile Development

Professional [Makefile](https://www.gnu.org/software/make/manual/make.html) editing support with intelligent features:

**Features** ([`lang/makefile-config.el`](lang/makefile-config.el)):
- **Smart indentation** respecting Makefile tab requirements
- **Target completion** and navigation
- **Variable highlighting** and substitution awareness
- **Make command integration** for rapid build testing

### Markdown Support

Enhanced [Markdown](https://daringfireball.net/projects/markdown/) editing for documentation and content creation using [markdown-mode](https://github.com/jrblevin/markdown-mode):

**Features** ([`lang/markdown-config.el`](lang/markdown-config.el)):
- **Syntax highlighting** with [GitHub Flavored Markdown](https://github.github.com/gfm/) support
- **Live preview** capabilities (when markdown processors are available)
- **Table editing** assistance
- **Header navigation** and structure management

### TOML Configuration

Comprehensive [TOML](https://toml.io/) support for modern configuration management using [toml-mode](https://github.com/dryman/toml-mode.el):

**Features** ([`lang/toml-config.el`](lang/toml-config.el)):
- **Syntax highlighting** for TOML configuration files
- **Project integration** with `pyproject.toml` support
- **Structure validation** with error highlighting
- **Auto-completion** for common TOML keys and values

### YAML Configuration

Specialized handling for [YAML](https://yaml.org/) files with structure-aware features using [yaml-mode](https://github.com/yoshiki/yaml-mode):

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

### Navigation and Discovery
- **[Which-Key](https://github.com/justbur/emacs-which-key)** ([`core/packages.el`](core/packages.el)): Interactive keybinding discovery system that displays available key combinations in popup windows
  - **0.3-second delay** for faster response than default settings
  - **40 character descriptions** with improved readability
  - **Smart column padding** and arrow separators (" → ")
  - **Automatic mode detection** showing context-appropriate keybindings

- **[Imenu-List](https://github.com/bmag/imenu-list)** ([`features/imenu-list-config.el`](features/imenu-list-config.el)): Symbol navigation sidebar for code structure visualization
  - **Toggle sidebar** with `F2` or `C-c i l` for quick access
  - **Real-time symbol updates** showing functions, classes, and variables
  - **Interactive navigation** with dedicated sidebar keybindings
  - **Project structure overview** for large codebases
  - **Auto-refresh** when switching between files and buffers

### Visual Improvements
- **[Rainbow Delimiters](https://github.com/Fanael/rainbow-delimiters)** ([`features/rainbow-delimiters.el`](features/rainbow-delimiters.el)): Enhanced delimiter visibility with color coding
- **[Indent Guides](https://github.com/DarthFennec/highlight-indent-guides)** ([`features/indent-guides.el`](features/indent-guides.el)): Visual indentation guides for better code structure
- **Theme Support** ([`themes/themes.el`](themes/themes.el)): [Zenburn](https://github.com/bbatsov/zenburn-emacs) theme with custom black background

### Enhanced Diagnostics
- **[Flymake Integration](https://www.gnu.org/software/emacs/manual/html_mono/flymake.html)** ([`features/flymake-config.el`](features/flymake-config.el)): Real-time syntax checking and linting
- **LSP Diagnostics**: Comprehensive error reporting and code intelligence
- **Performance Monitoring**: Load time tracking for configuration modules

## Related Documentation

**For Using These Features:**
- [`KEYMAP.md`](KEYMAP.md) - Complete keybinding reference for all features
- [`FAQ.md`](FAQ.md) - Common questions about feature usage

**For Setup and Issues:**
- [`README.md`](README.md) - Installation and requirements
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Feature-specific troubleshooting
