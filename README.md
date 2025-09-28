# emacs.d

Personal Emacs configuration files and customizations.

## Table of Contents

- [Overview](#overview)
- [Configuration Structure](#configuration-structure)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Option 1: Development Installation (Symlinks)](#option-1-development-installation-symlinks)
  - [Option 2: Standard Installation (Copy)](#option-2-standard-installation-copy)
- [Testing](#testing)
- [Usage](#usage)
- [Documentation](#documentation)
- [Quick Reference](#quick-reference)

## Overview

This Emacs configuration provides a professional development environment with intelligent completion, LSP integration, and modern Emacs 30.2+ optimizations.

**Key Features:**
- **Fast startup** with modern performance optimizations
- **Intelligent completion** powered by [Corfu](https://github.com/minad/corfu) across all file types
- **Python development** with automatic virtual environment management
- **Remote development** with seamless [TRAMP](https://www.gnu.org/software/emacs/manual/html_node/tramp/) integration for SSH-based Python projects
- **Project navigation** with [Treemacs](https://github.com/Alexander-Miller/treemacs) file tree sidebar and project management
- **Automatic font management** for icon packages with system-wide font installation
- **Message logging** with automatic log rotation and session history
- **Multi-language support** including Python, Lisp, YAML, Markdown, TOML, and Makefile modes
- **Code quality** with automated formatting via [elisp-autofmt](https://github.com/emacsmirror/elisp-autofmt)
- **Modern Emacs 30.2+** - Exclusively optimized for the latest Emacs features

For detailed feature information, see [`FEATURES.md`](FEATURES.md). For installation instructions, see the [Installation](#installation) section below.

## Configuration Structure

- **[`init.el`](init.el)** - Main Emacs initialization file that loads all configuration modules
- **[`early-init.el`](early-init.el)** - Early initialization for performance optimizations and directory setup
- **[`core/`](core/)** - Essential Emacs functionality (loaded first in dependency order)
  - **[`package-system/`](core/package-system/)** - Modular package management system
    - [`manager.el`](core/package-system/manager.el) - Package system orchestration and module loading
    - [`bootstrap.el`](core/package-system/bootstrap.el) - Use-package installation and configuration
    - [`cache.el`](core/package-system/cache.el) - Package state caching system (stores cache in `~/.emacs.d/local/package-metadata.el`)
    - [`network.el`](core/package-system/network.el) - Network-aware package operations
    - [`repositories.el`](core/package-system/repositories.el) - Repository configuration and security
    - [`maintenance.el`](core/package-system/maintenance.el) - Package upgrade and cleanup utilities
  - [`core-constants.el`](core/core-constants.el) - Modern Emacs 30.2+ constants and configuration values
  - [`core-packages.el`](core/core-packages.el) - Package declarations and configurations
  - [`core-fonts.el`](core/core-fonts.el) - Automatic font management for icon packages
  - [`core-utils.el`](core/core-utils.el) - Utility functions and load timing system
  - [`ui.el`](core/ui.el) - Basic UI configuration
  - [`editing.el`](core/editing.el) - Editing preferences and behavior
  - [`core-files.el`](core/core-files.el) - File handling and backup settings
  - [`tramp-config.el`](core/tramp-config.el) - TRAMP remote file access with Python support
  - [`tramp-utils.el`](core/tramp-utils.el) - TRAMP utility functions for remote development
  - [`logging.el`](core/logging.el) - Message logging and log rotation system
  - [`diagnostics.el`](core/diagnostics.el) - System information and configuration diagnostics
  - [`keybindings.el`](core/keybindings.el) - Global key bindings
- **[`features/`](features/)** - Optional enhancements (can be disabled independently)
  - [`completion-config.el`](features/completion-config.el) - [Corfu](https://github.com/minad/corfu) auto-completion framework
  - [`flymake-config.el`](features/flymake-config.el) - Flymake diagnostic display configuration
  - [`imenu-list-config.el`](features/imenu-list-config.el) - Symbol navigation sidebar for code structure
  - [`rainbow-delimiters-config.el`](features/rainbow-delimiters-config.el) - Enhanced delimiter visibility
  - [`indent-guides.el`](features/indent-guides.el) - Visual indentation guides
  - [`treemacs-config.el`](features/treemacs-config.el) - File tree navigation and project management
  - [`features-constants.el`](features/features-constants.el) - Feature-specific constants
- **[`lang/`](lang/)** - Language-specific configurations
  - [`lisp-config.el`](lang/lisp-config.el) - Lisp/Elisp development settings
  - [`makefile-config.el`](lang/makefile-config.el) - Makefile development settings
  - [`markdown-config.el`](lang/markdown-config.el) - Markdown mode support and configuration
  - [`toml-config.el`](lang/toml-config.el) - TOML mode support for configuration files
  - [`yaml-config.el`](lang/yaml-config.el) - YAML file handling
  - **[`python/`](lang/python/)** - Python development environment
    - [`python-core.el`](lang/python/python-core.el) - Core Python development settings
    - [`python-constants.el`](lang/python/python-constants.el) - Python configuration constants (LSP paths, etc.)
    - [`pyvenv-config.el`](lang/python/pyvenv-config.el) - Virtual environment management with auto-detection
    - [`pyvenv-utils.el`](lang/python/pyvenv-utils.el) - Python virtual environment utilities
    - [`pyvenv-remote.el`](lang/python/pyvenv-remote.el) - TRAMP-aware virtual environment support
    - [`flymake-ruff-config.el`](lang/python/flymake-ruff-config.el) - Advanced Python linting with Ruff integration
- **[`themes/`](themes/)** - Theme and appearance configuration
  - [`themes-config.el`](themes/themes-config.el) - [Doom Themes](https://github.com/doomemacs/themes) configuration with terminal compatibility
  - [`theme-utils.el`](themes/theme-utils.el) - Theme utilities and helper functions
- **[`user/`](user/)** - Personal customizations
  - [`functions.el`](user/functions.el) - Custom helper functions
  - [`aliases.el`](user/aliases.el) - Custom command aliases
- **[`scripts/`](scripts/)** - Installation and utility scripts
  - [`install.sh`](scripts/install.sh) - Automated installation script
  - [`test-config.sh`](scripts/test-config.sh) - Configuration testing script
  - [`README.md`](scripts/README.md) - Script overview and installation guide
  - [`TESTING.md`](scripts/TESTING.md) - Comprehensive testing documentation
- **[`configs/`](configs/)** - Configuration template files for local customization
  - [`local.el`](configs/local.el) - Template for user-specific, non-versioned configuration
  - [`dev.el`](configs/dev.el) - Template for temporary development and testing configuration
  - [`custom.el`](configs/custom.el) - Template for Emacs customize system output
  - [`README.md`](configs/README.md) - Detailed guide for local configuration

## Load Path Auto-Detection

The configuration uses an intelligent auto-detection system in [`init.el`](init.el) that automatically discovers and adds configuration directories to Emacs' load-path. This eliminates the need to manually maintain directory lists when adding new modules.

### How It Works

1. **Scans** all directories in `~/.emacs.d/` for `.el` files
2. **Includes** nested directories (e.g., `lang/python/`, `core/package-system/`)
3. **Excludes** runtime directories that shouldn't be in load-path
4. **Adds** discovered directories automatically

### Excluded Directories

The following directories are **not** added to load-path:

- **`~/.emacs.d/configs/`** - Template configuration files, not active modules
- **`~/.emacs.d/local/`** - Runtime data (package cache, recentf, auto-save files, etc.)
- **`<emacs-local-dir>/log/`** - Runtime log files from the message logging system

These exclusions prevent runtime data and template files from interfering with module loading while ensuring all actual configuration modules are automatically discovered.

## Requirements

- **Emacs 30.2 or later** (required)

> **⚠️ Important:** This configuration requires Emacs 30.2+ and will not work with earlier versions.

### Why Emacs 30.2+ is Required

This configuration leverages specific improvements and features only available in Emacs 30.2+:

- **Native compilation enhancements**: Improved bytecode compilation for faster package loading and runtime performance
- **Modern use-package integration**: Built-in use-package with advanced lazy-loading and configuration features
- **Enhanced UI capabilities**: Advanced `global-display-line-numbers-mode` with improved visual line support
- **Memory management improvements**: Modern garbage collection tuning for efficient long-running development sessions
- **Flymake integration**: Enhanced diagnostic display and real-time error reporting capabilities

**Performance Benefits:**
- **Faster startup times**: Leveraging modern initialization and package loading optimizations
- **Reduced memory usage**: Efficient heap management during extended coding sessions
- **Real-time responsiveness**: Optimized diagnostic updates

### Optional Dependencies

**For Code Quality (Development):**
```bash
# Required for pre-commit formatting hooks
git clone https://github.com/emacsmirror/elisp-autofmt.git ~/github/elisp-autofmt

# Optional: automatic code quality enforcement
pip install pre-commit  # https://github.com/pre-commit/pre-commit
pre-commit install  # Run in repository root after cloning
```

**Important**: Ensure your `~/.bash_profile` includes `$HOME/.local/bin` in your PATH, if you plan on using user-local packages.

## Installation

There are two ways to install this Emacs configuration, depending on your use case:

### Option 1: Development Installation (Symlinks)

**Use this method if you want to modify and develop the configuration itself.**

```bash
# Clone this repository
$ git clone <your-repository-url> ~/github/emacs.d

# Navigate to the repository directory
$ cd ~/github/emacs.d

# Run the installer script
$ chmod +x scripts/install.sh
$ ./scripts/install.sh
```

The installer creates symlinks from `~/.emacs.d/` to this repository, allowing you to:
- Keep your configuration in version control
- Make changes immediately available in Emacs for testing
- Easily test configuration modifications and see errors in real-time

For detailed installation options, troubleshooting, and manual setup instructions, see [`scripts/README.md`](scripts/README.md).

### Option 2: Standard Installation (Copy)

**Use this method for regular daily use without modifying the configuration.**

```bash
# Clone this repository
$ git clone <your-repository-url> ~/github/emacs.d

# Copy the configuration to your Emacs directory
$ cp -r ~/github/emacs.d ~/.emacs.d

# Optional: Remove the cloned repository if you don't need it
$ rm -rf ~/github/emacs.d
```

With this method, the configuration files are copied directly to `~/.emacs.d/` and work independently of the repository.

## Testing

After installation, verify your configuration is working correctly:

```bash
# Quick configuration test
~/github/emacs.d/scripts/test-config.sh
```

The test script validates that all modules load successfully and provides comprehensive diagnostics including timing information and modern Emacs 30.2+ feature verification.

For detailed testing documentation, troubleshooting, and limitations, see [`scripts/TESTING.md`](scripts/TESTING.md).

## Usage

After installation, simply restart Emacs. The configuration is ready to use!

**Development Installation Note**: If you used the development installation (symlinks), any changes you make to files in this repository will be immediately available in Emacs for testing and development purposes. If you plan to modify or contribute to the configuration, see [`CONTRIBUTING.md`](CONTRIBUTING.md) for development guidelines and best practices.

**Quick Start Tips:**
- **Auto-completion**: Use `TAB` for smart completion, `C-c TAB` for manual trigger
- **Python development**: Open any `.py` file to automatically activate virtual environments
- **Documentation**: See [`FEATURES.md`](FEATURES.md) for comprehensive feature documentation
- **Issues**: Check [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) for common problems and solutions

## Quick Reference

### Project Structure Detection
The configuration automatically detects project roots by searching for:
- `.git/` directory (Git repository)
- `pyproject.toml` file (Python projects)
- `requirements.txt` file (Python dependencies)

### Virtual Environment Requirements
For automatic Python virtual environment detection:
- Virtual environment must be named `venv` in project root
- Project must contain one of the project markers above
- Python files opened within the project will automatically activate the environment

## Limitations

This configuration has some intentional design limitations:

**Python Virtual Environment Management:**
- **Single-project approach**: Only one Python project can be active per Emacs session
- **Auto-detect once behavior**: The first Python file with a virtual environment sets the global project
- **Modeline behavior**: Files outside the detected project show "inactive" status

For detailed information about these limitations, rationale, and workarounds, see the [FAQ](FAQ.md#q-are-there-limitations-with-python-virtual-environment-management).

## Documentation

**Essential References:**
- [`FAQ.md`](FAQ.md) - Frequently asked questions about features and usage
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Solutions for common issues and debugging
- [`FEATURES.md`](FEATURES.md) - Complete feature documentation and capabilities

**Additional Resources:**
- [`KEYMAP.md`](KEYMAP.md) - Comprehensive keybinding reference
- [`CONTRIBUTING.md`](CONTRIBUTING.md) - Development and contribution guidelines
- [`STYLEGUIDE.md`](STYLEGUIDE.md) - Code formatting standards
