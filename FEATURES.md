# Emacs Configuration Features

This document provides comprehensive details about all features available in this Emacs configuration, including version-aware capabilities and language-specific enhancements.

## Table of Contents

- [Version-Aware Capabilities](#version-aware-capabilities)
- [Performance Optimizations](#performance-optimizations)
- [Auto-Completion System](#auto-completion-system)
- [Language Support](#language-support)
  - [Python Development Environment](#python-development-environment)
  - [Lisp/Elisp Development](#lispellisp-development)
  - [YAML Configuration](#yaml-configuration)
- [Code Style and Standards](#code-style-and-standards)
- [User Interface Enhancements](#user-interface-enhancements)
- [Development Keybindings](#development-keybindings)
  - [Custom Function Key Shortcuts](#custom-function-key-shortcuts)
  - [Code Intelligence (LSP via Eglot)](#code-intelligence-lsp-via-eglot)
  - [Code Completion (Corfu)](#code-completion-corfu)
  - [Python Development](#python-development)
  - [Essential Emacs Operations](#essential-emacs-operations)
  - [Custom Navigation Shortcuts](#custom-navigation-shortcuts)
  - [YAML Development](#yaml-development)
  - [Virtual Environment Management](#virtual-environment-management)
  - [Code Formatting](#code-formatting)
  - [Diagnostic and Error Checking](#diagnostic-and-error-checking)
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
- **Smart TAB behavior** - completes when possible, indents otherwise
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
- **[SLIME](https://github.com/slime/slime) integration** for Common Lisp development (when available)
- **Enhanced evaluation** with inline result display
- **Auto-formatting** via [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt) integration

### YAML Configuration

Specialized handling for YAML files with structure-aware features:

**Features** ([`lang/yaml-config.el`](lang/yaml-config.el)):
- **Structure-aware completion** for YAML hierarchies
- **Indentation management** (2 spaces, YAML standard)
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
- **GNU Emacs Lisp conventions** for all configuration files
- **Consistent file organization** and naming conventions
- **Standardized file headers** and documentation format
- **Automated quality checks** via pre-commit hooks

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

## Development Keybindings

This section provides a comprehensive reference for all keybindings available in this Emacs configuration, covering both general Emacs operations and language-specific development features.

### How to Use These Keybindings

- **`C-`** means hold Ctrl key (e.g., `C-a` = Ctrl+a)
- **`M-`** means hold Alt/Meta key (e.g., `M-.` = Alt+.)
- **`S-`** means hold Shift key (e.g., `S-TAB` = Shift+Tab)
- **Multiple keys:** Press in sequence (e.g., `C-c` `TAB` = Ctrl+c, then Tab)
- **Context-dependent:** Some keys behave differently based on what's active
- **`-`** in "Key Binding" column represents no key binding for that function (use `M-x function-name` instead)
- **`-`** in "Context" column represents always available (no specific context required)

### Custom Function Key Shortcuts

These are configuration-specific shortcuts designed for quick access to common operations:

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| `F1`                 | `flymake-show-buffer-diagnostics`| Display syntax errors and warnings  | -                   |
| `F4`                 | `kill-this-buffer`               | Close current buffer                 | -                   |
| `F5`                 | `clipboard-kill-ring-save`       | Copy to system clipboard             | -                   |
| `F6`                 | `delete-trailing-whitespace`     | Clean up line endings                | -                   |
| `F7`                 | `previous-buffer`                | Switch to previous buffer            | -                   |
| `F8`                 | `next-buffer`                    | Switch to next buffer                | -                   |
| `F9`                 | `beginning-of-buffer`            | Jump to file start                   | -                   |
| `F10`                | `end-of-buffer`                  | Jump to file end                     | -                   |
| `F11`                | Smart scroll down                | Scroll with boundary handling        | -                   |
| `F12`                | Smart scroll up                  | Scroll with boundary handling        | -                   |

### Code Intelligence (LSP via Eglot)

Advanced code navigation and analysis powered by [Eglot](https://github.com/joaotavora/eglot):

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| `M-.`                | `xref-find-definitions`          | Jump to function/class/variable def  | LSP active          |
| `M-,`                | `xref-go-back`                   | Return from definition jump          | LSP active          |
| `M-?`                | `xref-find-references`           | Find all references to symbol        | LSP active          |
| `C-h` `.`            | `display-local-help`             | Show documentation in echo area      | LSP active          |
| `C-c` `C-r`          | `eglot-rename`                   | Rename symbol project-wide           | LSP active          |
| `C-c` `C-a`          | `eglot-code-actions`             | Show quick fixes and refactoring     | LSP active          |

### Code Completion (Corfu)

Intelligent auto-completion powered by [Corfu](https://github.com/minad/corfu):

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| `C-c` `TAB`          | `completion-at-point`            | Manually trigger completion          | Always              |
| `M-TAB`              | `completion-at-point`            | Alternative completion trigger       | Always              |
| `TAB`                | `corfu-next`                     | Navigate to next candidate           | Popup active        |
| `TAB`                | `python-indent-line-function`    | Auto-indent line                     | Normal editing      |
| `S-TAB`              | `corfu-previous`                 | Navigate to previous candidate       | Popup active        |
| `S-TAB`              | `python-dedent-line-function`    | Decrease indentation                 | Normal editing      |
| `RET`                | `corfu-insert`                   | Accept selected completion           | Popup active        |

### Python Development

Python-specific editing and REPL interaction using built-in Python-mode:

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| `C-c` `C-p`          | `run-python`                     | Start Python REPL in buffer         | Python files        |
| `C-c` `C-c`          | `python-shell-send-buffer`       | Execute entire file in REPL          | Python files        |
| `C-c` `C-r`          | `python-shell-send-region`       | Execute selected region in REPL      | Python files        |
| `C-M-a`              | `python-nav-backward-defun`      | Jump to previous function/class      | Python files        |
| `C-M-e`              | `python-nav-forward-defun`       | Jump to next function/class          | Python files        |
| `C-M-u`              | `python-nav-backward-up-list`    | Move up one indentation level        | Python files        |

### Essential Emacs Operations

Core Emacs commands for file management and text editing:

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| `C-x` `C-f`          | `find-file`                      | Open file browser to select file    | -                   |
| `C-x` `C-s`          | `save-buffer`                    | Save current file to disk            | -                   |
| `C-x` `b`            | `switch-to-buffer`               | Switch between open buffers          | -                   |
| `C-s`                | `isearch-forward`                | Interactive search forward           | -                   |
| `C-r`                | `isearch-backward`               | Interactive search backward          | -                   |
| `M-%`                | `query-replace`                  | Find and replace with confirmation   | -                   |
| `C-w`                | `kill-region`                    | Cut selected text                    | -                   |
| `M-w`                | `kill-ring-save`                 | Copy selected text                   | -                   |
| `C-y`                | `yank`                           | Paste text from kill ring            | -                   |
| `C-/`                | `undo`                           | Undo last action                     | -                   |

### Custom Navigation Shortcuts

Additional navigation commands for efficient code browsing:

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| `C-a`                | `smart-beginning-of-line`        | Jump to first non-whitespace/start  | -                   |
| `ESC` `←`            | `scroll-down`                    | Scroll buffer content down           | -                   |
| `ESC` `→`            | `scroll-up`                      | Scroll buffer content up             | -                   |

### YAML Development

YAML-specific keybindings for configuration file editing:

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| `C-m`                | `newline-and-indent`             | Insert newline with proper indent    | YAML files          |

### Virtual Environment Management

Python virtual environment commands for project isolation using [pyvenv](https://github.com/jorgenschaefer/pyvenv):

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| -                    | `pyvenv-activate`                | Manually activate virtual env       | -                   |
| -                    | `pyvenv-deactivate`              | Deactivate current virtual env       | -                   |
| -                    | `pyvenv-workon`                  | Switch to different virtual env      | -                   |

### Code Formatting

Automated code formatting commands using [elisp-autofmt](https://github.com/emacsmirror/elisp-autofmt):

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| `C-c` `C-f`          | `elisp-autofmt-buffer`           | Format Emacs Lisp buffer             | Emacs Lisp files    |

### Diagnostic and Error Checking

Built-in Emacs diagnostic tools (Flymake is built into Emacs):

| Key Binding          | Function                         | Description                      | Context             |
|----------------------|----------------------------------|----------------------------------|---------------------|
| `F1`                 | `flymake-show-buffer-diagnostics`| Show diagnostics in side window     | Flymake active      |
| `M-g` `n`            | `flymake-goto-next-error`        | Jump to next diagnostic              | Flymake active      |
| `M-g` `p`            | `flymake-goto-prev-error`        | Jump to previous diagnostic          | Flymake active      |
| `C-h` `.`            | `display-local-help`             | Show diagnostic details at point     | Flymake active      |

## Related Documentation

- **Installation**: See [README.md](README.md#installation) for setup instructions
- **Troubleshooting**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions
- **Development**: See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines
- **Style Guide**: See [STYLEGUIDE.md](STYLEGUIDE.md) for detailed formatting standards
- **Common Questions**: See [FAQ.md](FAQ.md) for frequently asked questions
