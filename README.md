# emacs.d

Personal Emacs configuration files and customizations.

## Table of Contents

- [Overview](#overview)
- [Configuration Structure](#configuration-structure)
- [Requirements](#requirements)
  - [Shell Configuration for Terminal Colors](#shell-configuration-for-terminal-colors)
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
- **Dual completion systems**:
  - [Corfu](https://github.com/minad/corfu) for in-buffer code completion with full terminal support
  - [Vertico](https://github.com/minad/vertico) + [Consult](https://github.com/minad/consult) for enhanced minibuffer completion with fuzzy matching
- **LSP integration** via [Eglot](https://github.com/joaotavora/eglot) for Python, C, and C++ with automatic local/remote detection
- **Visual enhancements**:
  - [Doom-modeline](https://github.com/seagle0128/doom-modeline) showing Git status, LSP indicators, and Python environment
  - [Dimmer](https://github.com/gonewest818/dimmer.el) for visual focus by dimming inactive buffers
  - [diff-hl](https://github.com/dgutov/diff-hl) showing git changes in the fringe/margin
- **Breadcrumb navigation** showing file path and code structure in the header line
- **Python development** with automatic virtual environment management
- **Remote development** with seamless [TRAMP](https://www.gnu.org/software/emacs/manual/html_node/tramp/) integration for SSH-based Python projects
- **Project navigation** with [Treemacs](https://github.com/Alexander-Miller/treemacs) file tree sidebar and project management
- **Custom dashboard** with quick access to recent files, package management, and system actions
- **Command palette** with M-x history tracking, customizable favorites, and one-click command execution
- **Git integration** with [Magit](https://magit.vc/) and [Forge](https://github.com/magit/forge) for GitHub/GitLab workflows
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
    - [`package-manager.el`](core/package-system/package-manager.el) - Package system orchestration and module loading
    - [`package-bootstrap.el`](core/package-system/package-bootstrap.el) - Use-package installation and configuration
    - [`package-cache.el`](core/package-system/package-cache.el) - Package state caching system (stores cache in `~/.emacs.d/local/package-metadata.el`)
    - [`package-network.el`](core/package-system/package-network.el) - Network-aware package operations
    - [`package-repositories.el`](core/package-system/package-repositories.el) - Repository configuration and security
    - [`package-maintenance.el`](core/package-system/package-maintenance.el) - Package upgrade and cleanup utilities
  - [`core-constants.el`](core/core-constants.el) - Modern Emacs 30.2+ constants and configuration values
  - [`core-packages.el`](core/core-packages.el) - Package declarations and configurations
  - [`core-fonts.el`](core/core-fonts.el) - Automatic font management for icon packages
  - [`core-utils.el`](core/core-utils.el) - Utility functions and load timing system
  - [`core-config-loader.el`](core/core-config-loader.el) - Configuration module loading with custom use-package keywords
  - [`core-ui.el`](core/core-ui.el) - Basic UI configuration
  - [`core-gui-mode.el`](core/core-gui-mode.el) - GUI mode settings and window management
  - [`core-editing.el`](core/core-editing.el) - Editing preferences and behavior
  - [`core-files.el`](core/core-files.el) - File handling and backup settings
  - [`core-logging.el`](core/core-logging.el) - Message logging and log rotation system
  - [`core-log-writer.el`](core/core-log-writer.el) - Log file writing and rotation functionality
  - [`core-user-interaction-utils.el`](core/core-user-interaction-utils.el) - Standardized user input collection utilities
  - [`core-process-utils.el`](core/core-process-utils.el) - Centralized process execution utility
  - [`core-diagnostics.el`](core/core-diagnostics.el) - System information and configuration diagnostics
- **[`features/`](features/)** - Optional enhancements (can be disabled independently)
  - [`breadcrumbs-config.el`](features/breadcrumbs-config.el) - Breadcrumb navigation for file path and code structure
  - [`completion-config.el`](features/completion-config.el) - [Corfu](https://github.com/minad/corfu) in-buffer auto-completion framework with terminal support
  - [`minibuffer-config.el`](features/minibuffer-config.el) - Modern minibuffer completion with Vertico, Orderless, Marginalia, and Consult
  - [`consult-sources.el`](features/consult-sources.el) - Custom Consult buffer sources with filtering
  - [`dashboard-config.el`](features/dashboard-config.el) - Startup dashboard with quick access to files and actions
  - [`dimmer-config.el`](features/dimmer-config.el) - Visual focus enhancement by dimming inactive buffers
  - [`diff-hl-config.el`](features/diff-hl-config.el) - Git diff highlighting in fringe/margin
  - [`dired-config.el`](features/dired-config.el) - Enhanced directory browsing with inline tree expansion and icons
  - **[`eglot/`](features/eglot/)** - LSP client integration
    - [`eglot-config.el`](features/eglot/eglot-config.el) - [Eglot](https://github.com/joaotavora/eglot) LSP client with automatic local/remote detection
    - [`eglot-constants.el`](features/eglot/eglot-constants.el) - Eglot configuration constants
  - **[`flymake/`](features/flymake/)** - Syntax checking and diagnostics
    - [`flymake-config.el`](features/flymake/flymake-config.el) - Flymake diagnostic display configuration
    - [`flymake-utils.el`](features/flymake/flymake-utils.el) - Flymake utility functions and backend formatting
  - **Git Integration** - Magit and Forge for GitHub/GitLab workflows
    - **[`git/`](features/git/)** - Git and Magit configuration
      - [`git-config.el`](features/git/git-config.el) - Magit configuration for Git operations
      - [`git-constants.el`](features/git/git-constants.el) - Git configuration constants
      - [`git-utils.el`](features/git/git-utils.el) - Git utility functions and issue browser
      - [`git-sync.el`](features/git/git-sync.el) - Automatic Git and Forge synchronization on file open
      - [`git-forge-config.el`](features/git/git-forge-config.el) - Automatic forge host configuration from ~/.gitconfig
      - [`magit-utils.el`](features/git/magit-utils.el) - Magit-specific utility functions
    - **[`forge/`](features/forge/)** - Forge integration for GitHub/GitLab
      - [`forge-config.el`](features/forge/forge-config.el) - Forge configuration for GitHub/GitLab integration
      - [`forge-constants.el`](features/forge/forge-constants.el) - Forge configuration constants
      - [`forge-authinfo.el`](features/forge/forge-authinfo.el) - Interactive credential management for ~/.authinfo
      - [`forge-markdown.el`](features/forge/forge-markdown.el) - Markdown rendering for issues and pull requests
      - [`forge-issue-links.el`](features/forge/forge-issue-links.el) - Issue link extraction and display
      - [`forge-issues.el`](features/forge/forge-issues.el) - Dedicated issue management commands
      - [`forge-utils.el`](features/forge/forge-utils.el) - Forge utility functions
  - [`highlight-indent-guides-config.el`](features/highlight-indent-guides-config.el) - Visual indentation guides
  - [`imenu-list-config.el`](features/imenu-list-config.el) - Symbol navigation sidebar for code structure
  - [`rainbow-delimiters-config.el`](features/rainbow-delimiters-config.el) - Enhanced delimiter visibility
  - **[`tramp/`](features/tramp/)** - Remote file access configuration
    - [`tramp-config.el`](features/tramp/tramp-config.el) - TRAMP remote file access with Python support
    - [`tramp-constants.el`](features/tramp/tramp-constants.el) - TRAMP configuration constants
    - [`tramp-utils.el`](features/tramp/tramp-utils.el) - TRAMP utility functions for remote development
  - **[`tree-sitter/`](features/tree-sitter/)** - Tree-sitter integration
    - [`tree-sitter-config.el`](features/tree-sitter/tree-sitter-config.el) - Automatic tree-sitter mode switching
    - [`tree-sitter-constants.el`](features/tree-sitter/tree-sitter-constants.el) - Tree-sitter configuration constants
    - [`tree-sitter-utils.el`](features/tree-sitter/tree-sitter-utils.el) - Tree-sitter utility functions
  - **[`treemacs/`](features/treemacs/)** - File tree navigation
    - [`treemacs-config.el`](features/treemacs/treemacs-config.el) - File tree navigation and project management
    - [`treemacs-utils.el`](features/treemacs/treemacs-utils.el) - Treemacs utility functions
  - [`features-constants.el`](features/features-constants.el) - Feature-specific constants
- **[`lang/`](lang/)** - Language-specific configurations
  - [`lang-utils.el`](lang/lang-utils.el) - Language configuration utilities
  - **[`bash/`](lang/bash/)** - Bash/shell script development
    - [`bash-config.el`](lang/bash/bash-config.el) - Bash mode configuration
  - **[`c/`](lang/c/)** - C/C++ development
    - [`c-config.el`](lang/c/c-config.el) - C and C++ development settings
  - **[`json/`](lang/json/)** - JSON configuration
    - [`json-config.el`](lang/json/json-config.el) - JSON mode configuration
  - **[`lisp/`](lang/lisp/)** - Lisp/Elisp development
    - [`lisp-config.el`](lang/lisp/lisp-config.el) - Lisp/Elisp development settings
  - **[`makefile/`](lang/makefile/)** - Makefile development
    - [`makefile-config.el`](lang/makefile/makefile-config.el) - Makefile development settings
  - **[`markdown/`](lang/markdown/)** - Markdown support
    - [`markdown-config.el`](lang/markdown/markdown-config.el) - Markdown mode support and configuration
  - **[`python/`](lang/python/)** - Python development environment
    - [`python-config.el`](lang/python/python-config.el) - Core Python development settings
    - [`python-constants.el`](lang/python/python-constants.el) - Python configuration constants (LSP paths, etc.)
    - [`pyvenv-config.el`](lang/python/pyvenv-config.el) - Virtual environment management with auto-detection
    - [`pyvenv-modeline.el`](lang/python/pyvenv-modeline.el) - Python environment modeline display
    - [`pyvenv-remote.el`](lang/python/pyvenv-remote.el) - TRAMP-aware virtual environment support
    - [`pyvenv-utils.el`](lang/python/pyvenv-utils.el) - Python virtual environment utilities
    - [`flymake-ruff-config.el`](lang/python/flymake-ruff-config.el) - Advanced Python linting with Ruff integration
  - **[`toml/`](lang/toml/)** - TOML configuration
    - [`toml-config.el`](lang/toml/toml-config.el) - TOML mode support for configuration files
  - **[`yaml/`](lang/yaml/)** - YAML configuration
    - [`yaml-config.el`](lang/yaml/yaml-config.el) - YAML file handling
- **[`themes/`](themes/)** - Theme and appearance configuration
  - [`themes-config.el`](themes/themes-config.el) - [Doom Themes](https://github.com/doomemacs/themes) configuration with terminal compatibility
  - [`themes-constants.el`](themes/themes-constants.el) - Theme configuration constants
  - [`themes-utils.el`](themes/themes-utils.el) - Theme utilities and helper functions
  - [`theme-doom-1337.el`](themes/theme-doom-1337.el) - Doom 1337 theme-specific customizations
  - [`theme-doom-1337-constants.el`](themes/theme-doom-1337-constants.el) - Doom 1337 theme color constants
  - [`modeline-config.el`](themes/modeline-config.el) - [Doom-modeline](https://github.com/seagle0128/doom-modeline) configuration
  - [`modeline-faces.el`](themes/modeline-faces.el) - Theme-specific modeline face customizations
  - [`modeline-segments.el`](themes/modeline-segments.el) - Custom modeline segments and utilities
- **[`user/`](user/)** - Personal customizations
  - [`command-palette.el`](user/command-palette.el) - Interactive command launcher with history tracking
  - [`user-aliases.el`](user/user-aliases.el) - Custom command aliases
  - [`user-keybindings.el`](user/user-keybindings.el) - Global key bindings
  - [`user-utils.el`](user/user-utils.el) - Custom helper functions
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
- **`~/.emacs.d/local/`** - Runtime data (package cache, recentf, auto-save files, logs, etc.)

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

### Shell Configuration for Terminal Colors

**For consistent theme colors in terminal mode (both local and remote SSH sessions):**

This configuration uses 24-bit true color (RGB) values for theme customization. To ensure colors display consistently across all environments, you need to enable true color support in your terminal:

```bash
# Add to ~/.bashrc or ~/.zshrc
export COLORTERM=truecolor
```

**Why this is needed:**
- Without `COLORTERM=truecolor`, Emacs approximates RGB colors to the nearest 256-color palette entry
- This can cause colors to appear different between local and remote SSH sessions
- The doom-1337 theme uses specific RGB values (`#rrggbb`) that require true color support

**After adding this setting:**
1. Reload your shell configuration: `source ~/.bashrc` (or `source ~/.zshrc`)
2. Verify it's set: `echo $COLORTERM` should output `truecolor`
3. For SSH sessions, ensure this is set on the **remote host's** shell configuration

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
- [`GIT.md`](GIT.md) - Git integration setup and usage guide (Magit and Forge)
- [`KEYMAP.md`](KEYMAP.md) - Comprehensive keybinding reference
- [`CONTRIBUTING.md`](CONTRIBUTING.md) - Development and contribution guidelines
- [`STYLEGUIDE.md`](STYLEGUIDE.md) - Code formatting standards
