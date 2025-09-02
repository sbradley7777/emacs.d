# emacs.d

Personal Emacs configuration files and customizations.

## Table of Contents

- [Configuration Structure](#configuration-structure)
- [Features](#features)
  - [Performance Optimizations](#performance-optimizations)
  - [Language Support](#language-support)
  - [Code Style and Standards](#code-style-and-standards)
- [Usage](#usage)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Option 1: Development Installation (Symlinks)](#option-1-development-installation-symlinks)
  - [Option 2: Standard Installation (Copy)](#option-2-standard-installation-copy)
- [Python Development Setup](#python-development-setup)
  - [Prerequisites](#prerequisites)
  - [Virtual Environment Configuration](#virtual-environment-configuration)
    - [Automatic Detection](#automatic-detection)
    - [Project Setup Example](#project-setup-example)
    - [Manual Virtual Environment Control](#manual-virtual-environment-control)
  - [Features and Debugging](#features-and-debugging)
    - [Available Features](#available-features)
    - [Debugging LSP Issues](#debugging-lsp-issues)

## Configuration Structure

- `init.el` - Main Emacs initialization file that loads all configuration modules
- `early-init.el` - Early initialization file for performance optimizations (Emacs 27+ feature, loaded before `init.el` and package.el)
- `config/` - Core configuration modules (loaded in dependency order)
  - [`core-package-manager.el`](config/core-package-manager.el) - Package management and setup
  - [`core-packages.el`](config/core-packages.el)        - Package declarations and configurations
  - [`core-ui.el`](config/core-ui.el)              - Basic UI configuration
  - [`core-editing.el`](config/core-editing.el)         - Editing preferences and behavior
  - [`core-files.el`](config/core-files.el)           - File handling and backup settings
  - [`core-flymake.el`](config/core-flymake.el)        - Flymake diagnostic display configuration
  - [`core-eglot.el`](config/core-eglot.el)          - General LSP client configuration
  - [`core-completion.el`](config/core-completion.el)       - Core auto-completion framework
  - [`core-keybindings.el`](config/core-keybindings.el)     - Global key bindings
- `lang/`   - Language-specific configurations
  - [`lang-python-core.el`](lang/lang-python-core.el)  - Core Python development settings
  - [`lang-python-venv.el`](lang/lang-python-venv.el)  - Python virtual environment management with auto-detection
  - [`lang-python-eglot.el`](lang/lang-python-eglot.el) - Python-specific LSP server configuration
  - [`lang-python-tools.el`](lang/lang-python-tools.el) - Python development tools and packages
  - [`lang-lisp.el`](lang/lang-lisp.el)         - Lisp/Elisp development settings
  - [`lang-yaml.el`](lang/lang-yaml.el)         - YAML file handling
- `themes/` - Theme and appearance configuration
  - [`core-themes.el`](themes/core-themes.el) - Core theme and appearance configuration
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

### Auto-Completion

- **Universal Auto-Completion**: Powered by Corfu framework for all file types and modes
  - **Automatic completion** appears after typing 1 character (200ms delay)
  - **Smart TAB behavior** - completes when possible, indents otherwise
  - **Multiple trigger options** - `TAB`, `C-c TAB`, `M-TAB`, `C-M-i`
  - **Context-aware suggestions** from LSP servers, built-in completion, and mode-specific sources

### Language Support

- **Python Development**: Full-featured Python development environment with:
  - **Eglot LSP integration** using `python-lsp-server` (pylsp) for intelligent code completion, diagnostics, and navigation
  - **Automatic virtual environment detection and activation** with project-aware switching
  - **Flymake integration** for real-time syntax checking and linting
  - **Enhanced modeline display** showing active virtual environment and project name
- **Lisp/Elisp Development**: Enhanced support for Lisp programming with auto-completion for functions, variables, and macros
- **YAML Configuration**: Specialized handling for YAML files with structure-aware completion

### Code Style and Standards

This configuration follows consistent formatting standards documented in [`STYLEGUIDE.md`](STYLEGUIDE.md):

- Uses [`elisp-autofmt`](https://github.com/purcell/elisp-autofmt) for automated code formatting
- Follows GNU Emacs Lisp conventions
- Consistent file organization and naming
- Standardized file headers and documentation

## Usage

After installation, simply restart Emacs or reload your configuration with `M-x eval-buffer` while viewing the [`init.el`](init.el) file.

**Note**: If you used the development installation (symlinks), any changes you make to files in this repository will be immediately available in Emacs for testing and development purposes.

## Requirements

- **Emacs 30.2** or later
- Access to install Python packages (for Python development features)

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

## Python Development Setup

This configuration provides comprehensive Python development support through Eglot LSP integration and automatic virtual environment management.

### Prerequisites

To use the full Python development features, you'll need to install the following packages system-wide or for your user:

```bash
# Install pylsp and plugins system-wide (user installation)
pip3.9 install --user python-lsp-server pylsp-mypy python-lsp-ruff mypy ruff

# Or install system-wide (if you have admin privileges)
sudo pip3.9 install python-lsp-server pylsp-mypy python-lsp-ruff mypy ruff
```

**Important**: Ensure your `~/.bash_profile` includes `$HOME/.local/bin` in your PATH:

```bash
# Add to ~/.bash_profile
export PATH="$HOME/.local/bin:$PATH"
```

This ensures the `pylsp` binary installed by `python-lsp-server` is accessible from Emacs.

### Python LSP Configuration

The configuration uses the default pylsp setup without configuration overrides. This provides the cleanest, most maintainable setup. However, since you have installed both `mypy` and `ruff` packages along with their pylsp plugins (`pylsp-mypy` and `python-lsp-ruff`), these tools will override the built-in linters when available.

**Key providers enabled:**
- **Ruff**: Fast linting and formatting (overrides built-in pycodestyle, pyflakes, etc.)
- **MyPy**: Static type checking (enhanced type analysis)

The pylsp plugins automatically detect when `mypy` and `ruff` are installed and prioritize them over built-in linters.

#### Optional: Tool-specific Configuration

You can configure the individual tools using their standard configuration files:

**MyPy Configuration** (`~/.mypy.ini`):
```ini
[mypy]
python_version = 3.11
show_error_codes = true
pretty = true

# -- Strictness Checks --
disallow_untyped_defs = true
disallow_any_unimported = true
disallow_incomplete_defs = true
check_untyped_defs = false
no_implicit_optional = true
warn_return_any = true
warn_unused_ignores = true
disallow_untyped_decorators = true

# -- Per-module overrides --
[mypy-tests.*]
disable_error_code = arg-type
```

**Ruff Configuration** (`~/.config/ruff/pyproject.toml`):
```toml
[tool.ruff]
line-length = 127
indent-width = 4
target-version = "py311"

[tool.ruff.lint]
# Enable the default set of rules (E, F) and extend it with others.
select = ["E", "F"]
extend-select = ["D"]
# The error D107 conflicts with "pydoclint" error DOC301. Ignore the "ruff" error.
ignore = ["E501", "D107"]
# Allow fix for all enabled rules (when `--fix`) is provided.
fixable = ["ALL"]
unfixable = []

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.format]
quote-style = "single"
indent-style = "space"
skip-magic-trailing-comma = true
line-ending = "auto"
# Enable auto-formatting of code examples in docstrings. Markdown,
# reStructuredText code/literal blocks and doctests are all supported.
# This is currently disabled by default, but it is planned for this
# to be opt-out in the future.
docstring-code-format = false
# Set the line length limit used when formatting code snippets in
# docstrings. This only has an effect when the `docstring-code-format` setting
# is enabled.
docstring-code-line-length = "dynamic"
```

For project-specific configurations, you can create configuration files in your project root that will override these system-wide/user settings.

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

# Install your project dependencies
pip install -r requirements.txt  # or your project dependencies

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


### Features and Debugging

#### Available Features

- **Auto-completion** - Universal completion across all file types with multiple trigger options:
  - `TAB` - Smart completion (complete when possible, indent otherwise)
  - `C-c TAB` - Manual completion trigger (reliable in all environments)
  - `M-TAB` - Traditional Alt+TAB completion
  - `C-M-i` - Traditional Ctrl+Alt+i completion
- **Intelligent completion** - Context-aware suggestions based on LSP servers, mode-specific sources, and type hints
- **Real-time diagnostics** - Syntax errors, type checking, and linting displayed in-buffer
- **Go to definition** - `M-.` to jump to function/class definitions
- **Find references** - `M-?` to find all references to a symbol
- **Symbol renaming** - `C-c r` to rename symbols across the project
- **Code actions** - `C-c a` for available code fixes and refactoring

#### Debugging Issues

**Auto-completion troubleshooting**:
1. **Check Corfu status**: `M-x corfu-debug-info` to see completion system status
2. **Test manual completion**: Use `M-x completion-at-point` to verify completions are available
3. **Verify key bindings**: Try different completion triggers (`C-c TAB`, `M-TAB`, `C-M-i`)

**LSP server issues**:
1. **Check LSP events**: `M-x eglot-events-buffer` to see LSP communication
2. **View server errors**: `M-x eglot-stderr-buffer` to see server error messages
3. **Restart LSP server**: `M-x eglot-shutdown` followed by `M-x eglot` or reopening the file
4. **Verify pylsp installation**: Ensure `pylsp` is available in your virtual environment

The modeline will display `[venv: project-name]` when a virtual environment is active, helping you verify the current configuration.
