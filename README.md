# emacs.d

Personal Emacs configuration files and customizations.

## Table of Contents

- [Quick Start](#quick-start)
- [Configuration Structure](#configuration-structure)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Option 1: Development Installation (Symlinks)](#option-1-development-installation-symlinks)
  - [Option 2: Standard Installation (Copy)](#option-2-standard-installation-copy)
- [Usage](#usage)
- [Documentation](#documentation)
- [Quick Reference](#quick-reference)

## Quick Start

This Emacs configuration provides a professional development environment with intelligent completion, LSP integration, and version-aware optimizations.

**Key Features:**
- 🚀 **Fast startup** with version-aware performance optimizations
- 🧠 **Intelligent completion** powered by [Corfu](https://github.com/minad/corfu) across all file types
- 🐍 **Python development** with [Eglot](https://github.com/joaotavora/eglot) LSP and automatic virtual environment management
- 📏 **Code quality** with automated formatting via [elisp-autofmt](https://github.com/emacsmirror/elisp-autofmt)
- 🎯 **Version compatibility** from Emacs 26.0.50 to latest versions

**Get Started in 2 Steps:**
1. **Install**: Run the installation script (see [Installation](#installation))
2. **Restart Emacs**: Your configuration is ready to use!

For detailed feature information, see [FEATURES.md](FEATURES.md).

## Configuration Structure

- **[`init.el`](init.el)** - Main Emacs initialization file that loads all configuration modules
- **[`early-init.el`](early-init.el)** - Early initialization file for performance optimizations (Emacs 27+ feature)
- **`core/`** - Essential Emacs functionality (loaded first in dependency order)
  - [`package-manager.el`](core/package-manager.el) - Package management and setup
  - [`core-constants.el`](core/core-constants.el) - Version-aware constants and feature detection
  - [`package-cache.el`](core/package-cache.el) - Package caching for network resilience
  - [`package-network.el`](core/package-network.el) - Network connectivity management
  - [`packages.el`](core/packages.el) - Package declarations and configurations
  - [`ui.el`](core/ui.el) - Basic UI configuration
  - [`editing.el`](core/editing.el) - Editing preferences and behavior
  - [`files.el`](core/files.el) - File handling and backup settings
  - [`keybindings.el`](core/keybindings.el) - Global key bindings
- **`features/`** - Optional enhancements (can be disabled independently)
  - [`completion.el`](features/completion.el) - [Corfu](https://github.com/minad/corfu) auto-completion framework
  - [`lsp.el`](features/lsp.el) - General LSP client configuration
  - [`flymake-config.el`](features/flymake-config.el) - Flymake diagnostic display configuration
  - [`rainbow-delimiters.el`](features/rainbow-delimiters.el) - Enhanced delimiter visibility
  - [`indent-guides.el`](features/indent-guides.el) - Visual indentation guides
  - [`features-constants.el`](features/features-constants.el) - Feature-specific constants
- **`lang/`** - Language-specific configurations
  - [`lisp-config.el`](lang/lisp-config.el) - Lisp/Elisp development settings
  - [`yaml-config.el`](lang/yaml-config.el) - YAML file handling
  - **`python/`** - Python development environment
    - [`core.el`](lang/python/core.el) - Core Python development settings
    - [`pyvenv-config.el`](lang/python/pyvenv-config.el) - Virtual environment management with auto-detection
    - [`eglot-config.el`](lang/python/eglot-config.el) - Python-specific LSP server configuration
    - [`tools.el`](lang/python/tools.el) - Python development tools and packages
- **`themes/`** - Theme and appearance configuration
  - [`themes.el`](themes/themes.el) - [Zenburn](https://github.com/bbatsov/zenburn-emacs) theme configuration
- **`user/`** - Personal customizations
  - [`functions.el`](user/functions.el) - Custom helper functions
  - [`aliases.el`](user/aliases.el) - Custom command aliases
- **`scripts/`** - Installation and utility scripts
  - [`install.sh`](scripts/install.sh) - Automated installation script
  - [`README.md`](scripts/README.md) - Detailed installation guide

## Requirements

- **Emacs 26.0.50** or later (automatically detected)
- **Version-aware features**: Configuration automatically adapts based on your Emacs version
  - **Modern (30.2+)**: Full feature set with optimized performance and latest capabilities
  - **Current (27.x)**: Modern features with compatibility adjustments
  - **Stable (26.x)**: Core features with conservative settings
  - **Legacy (24.x)**: Basic functionality for older installations

### Optional Dependencies

**For Python Development:**
```bash
# Install LSP server and enhanced tools
pip install python-lsp-server pylsp-mypy python-lsp-ruff mypy ruff
```

**For Code Quality (Development):**
```bash
# Required for pre-commit formatting hooks
git clone https://github.com/emacsmirror/elisp-autofmt.git ~/github/elisp-autofmt

# Optional: automatic code quality enforcement
pip install pre-commit
pre-commit install  # Run in repository root after cloning
```

**Important**: Ensure your `~/.bash_profile` includes `$HOME/.local/bin` in your PATH:
```bash
# Add to ~/.bash_profile for user-installed Python packages
export PATH="$HOME/.local/bin:$PATH"
```

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

## Usage

After installation, simply restart Emacs. The configuration is ready to use!

**Development Installation Note**: If you used the development installation (symlinks), any changes you make to files in this repository will be immediately available in Emacs for testing and development purposes.

**Quick Start Tips:**
- **Auto-completion**: Use `TAB` for smart completion, `C-c TAB` for manual trigger
- **Python development**: Open any `.py` file to automatically activate virtual environments
- **Documentation**: See [FEATURES.md](FEATURES.md) for comprehensive feature documentation
- **Issues**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common problems and solutions

## Documentation

Comprehensive documentation is available in separate files:

- **[FEATURES.md](FEATURES.md)** - Detailed feature documentation, version-aware capabilities, and language support
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Solutions for common issues and debugging guides
- **[FAQ.md](FAQ.md)** - Frequently asked questions about configuration and usage
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guidelines for contributing to the configuration
- **[STYLEGUIDE.md](STYLEGUIDE.md)** - Code formatting and style standards
- **[scripts/README.md](scripts/README.md)** - Installation script documentation

## Quick Reference

### Essential Key Bindings
- **Auto-completion**: `TAB` (smart), `C-c TAB` (manual), `M-TAB`, `C-M-i`
- **Python LSP**: `M-.` (go to definition), `M-?` (find references), `C-c r` (rename), `C-c a` (code actions)
- **Virtual environments**: `M-x pyvenv-activate`, `M-x pyvenv-deactivate`, `M-x pyvenv-workon`
- **Code formatting**: `C-c C-f` (format buffer in emacs-lisp-mode)

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
