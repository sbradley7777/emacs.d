# emacs.d

Personal Emacs configuration files and customizations.

## Table of Contents

- [Configuration Structure](#configuration-structure)
- [Features](#features)
  - [Performance Optimizations](#performance-optimizations)
  - [Language Support](#language-support)
  - [Code Style and Standards](#code-style-and-standards)
- [Usage](#usage)
- [Installation](#installation)
  - [Option 1: Development Installation (Symlinks)](#option-1-development-installation-symlinks)
  - [Option 2: Standard Installation (Copy)](#option-2-standard-installation-copy)
- [Python Development Setup](#python-development-setup)
  - [Prerequisites](#prerequisites)
  - [Virtual Environment Configuration](#virtual-environment-configuration)
    - [Automatic Detection](#automatic-detection)
    - [Project Setup Example](#project-setup-example)
    - [Manual Virtual Environment Control](#manual-virtual-environment-control)
    - [LSP Configuration with pyproject.toml](#lsp-configuration-with-pyprojecttoml)
  - [Features and Debugging](#features-and-debugging)
    - [Available Features](#available-features)
    - [Debugging LSP Issues](#debugging-lsp-issues)

## Configuration Structure

- `init.el` - Main Emacs initialization file that loads all configuration modules
- `early-init.el` - Early initialization file for performance optimizations (Emacs 27+ feature, loaded before `init.el` and package.el)
- `config/` - Core configuration modules
  - [`core-package-manager.el`](config/core-package-manager.el) - Package management and setup
  - [`core-packages.el`](config/core-packages.el)        - Package declarations and configurations
  - [`core-ui.el`](config/core-ui.el)              - Basic UI configuration
  - [`core-editing.el`](config/core-editing.el)         - Editing preferences and behavior
  - [`core-files.el`](config/core-files.el)           - File handling and backup settings
  - [`core-keybindings.el`](config/core-keybindings.el)     - Global key bindings
- `lang/`   - Language-specific configurations
  - [`lang-python-core.el`](lang/lang-python-core.el)  - Core Python development settings
  - [`lang-python-tools.el`](lang/lang-python-tools.el) - Python development tools and packages
  - [`lang-python-eglot.el`](lang/lang-python-eglot.el) - Eglot LSP configuration for Python development
  - [`lang-python-venv.el`](lang/lang-python-venv.el)  - Python virtual environment management with auto-detection
  - [`lang-lisp.el`](lang/lang-lisp.el)         - Lisp/Elisp development settings
  - [`lang-yaml.el`](lang/lang-yaml.el)         - YAML file handling
- `themes/` - Theme and appearance configuration
  - [`theme-config.el`](themes/theme-config.el) - Theme setup and customization
- `custom/` - Custom functions and utilities
  - [`functions.el`](custom/functions.el) - Custom helper functions
  - [`aliases.el`](custom/aliases.el)   - Custom command aliases
- `scripts/` - Installation and utility scripts
  - [`install.sh`](scripts/install.sh) - Automated installation script
  - [`README.md`](scripts/README.md) - Detailed installation guide

## Features

### Performance Optimizations

The configuration includes several performance enhancements:

- **Early initialization** (`early-init.el`): Loaded before package.el and GUI initialization for faster startup
- **Garbage collection tuning**: Optimized GC settings during startup
- **Package management**: Controlled package loading and initialization
- **File handler optimization**: Temporary disabling of file name handlers during startup

### Language Support

- **Python Development**: Full-featured Python development environment with:
  - **Eglot LSP integration** using `python-lsp-server` (pylsp) for intelligent code completion, diagnostics, and navigation
  - **Automatic virtual environment detection and activation** with project-aware switching
  - **Flymake integration** for real-time syntax checking and linting
  - **Enhanced modeline display** showing active virtual environment and project name
- **Lisp/Elisp Development**: Enhanced support for Lisp programming
- **YAML Configuration**: Specialized handling for YAML files

### Code Style and Standards

This configuration follows consistent formatting standards documented in [`STYLEGUIDE.md`](STYLEGUIDE.md):

- Uses [`elisp-autofmt`](https://github.com/purcell/elisp-autofmt) for automated code formatting
- Follows GNU Emacs Lisp conventions
- Consistent file organization and naming
- Standardized file headers and documentation

## Usage

After installation, simply restart Emacs or reload your configuration with `M-x eval-buffer` while viewing the [`init.el`](init.el) file.

**Note**: If you used the development installation (symlinks), any changes you make to files in this repository will be immediately available in Emacs for testing and development purposes.

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

For detailed installation options, troubleshooting, and manual setup instructions, see [`scripts/README.md`](scripts/README.md).

## Python Development Setup

This configuration provides comprehensive Python development support through Eglot LSP integration and automatic virtual environment management.

### Prerequisites

To use the full Python development features, you'll need to install the following packages in your Python environment:

```bash
# Core Language Server Protocol support
pip install python-lsp-server

# Essential pylsp plugins for enhanced functionality
pip install pylsp-mypy              # MyPy type checking integration
pip install pylsp-ruff              # Ruff linting and formatting
```

### Virtual Environment Configuration

The configuration automatically detects and activates virtual environments in your projects:

#### Automatic Detection

Virtual environments are automatically detected when you open Python files if **both** conditions are met:
1. A `venv/` directory exists in your project root.
2. Your project root is determined by traversing upward from the opened file's directory, searching for **any** of these files:
   - `.git/` directory (Git repository)
   - `pyproject.toml` file
   - `requirements.txt` file

The system starts from the directory containing your Python file and walks up the directory tree (parent by parent) until it finds one of these project markers, which defines the project root.

#### Project Setup Example

```bash
# Create a new Python project
mkdir my-python-project
cd my-python-project

# Create virtual environment
python -m venv venv

# Activate it manually (first time)
source venv/bin/activate

# Install development dependencies
pip install python-lsp-server pylsp-mypy pylsp-ruff

# Create a project file to test
echo "def hello_world():" > main.py
echo "    print('Hello, World!')" >> main.py

# Open in Emacs - virtual environment will auto-activate
emacs main.py
```

#### Manual Virtual Environment Control

You can also manually control virtual environments within Emacs:

- `M-x pyvenv-activate` - Manually activate a virtual environment
- `M-x pyvenv-deactivate` - Deactivate current virtual environment
- `M-x pyvenv-workon` - Switch to a different virtual environment

#### LSP Configuration with pyproject.toml

The Eglot configuration supports project-specific settings through `pyproject.toml`. The [`lang-python-eglot.el`](lang/lang-python-eglot.el) file configures pylsp to read from `pyproject.toml` automatically:

```toml
# Python LSP Server (pylsp) Configuration
# Controls which linters and tools are enabled when using pylsp via editors like Emacs with eglot
[tool.pylsp.plugins]
# Disable built-in linters that conflict with our preferred tools
pycodestyle = {enabled = false}
pyflakes = {enabled = false}
autopep8 = {enabled = false}
yapf = {enabled = false}
mccabe = {enabled = false}
pylint = {enabled = false}
flake8 = {enabled = false}
# Enable our preferred linters (they will use existing tool configurations above)
ruff = {enabled = true}
mypy = {enabled = true}
```

### Features and Debugging

#### Available Features

- **Code completion** - Intelligent completion based on context and type hints
- **Real-time diagnostics** - Syntax errors, type checking, and linting displayed in-buffer
- **Go to definition** - `M-.` to jump to function/class definitions
- **Find references** - `M-?` to find all references to a symbol
- **Symbol renaming** - `C-c r` to rename symbols across the project
- **Code actions** - `C-c a` for available code fixes and refactoring

#### Debugging LSP Issues

If you encounter issues with the language server:

1. **Check LSP events**: `M-x eglot-events-buffer` to see LSP communication
2. **View server errors**: `M-x eglot-stderr-buffer` to see server error messages
3. **Restart LSP server**: `M-x eglot-shutdown` followed by `M-x eglot` or reopening the file
4. **Verify pylsp installation**: Ensure `pylsp` is available in your virtual environment

The modeline will display `[venv: project-name]` when a virtual environment is active, helping you verify the current configuration.
