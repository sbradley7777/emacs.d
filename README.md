# emacs.d

Personal Emacs configuration files and customizations.

## Configuration Structure

- `init.el` - Main Emacs initialization file that loads all configuration modules
- `early-init.el` - Early initialization file for performance optimizations (Emacs 27+ feature, loaded before `init.el` and package.el)
- `config/` - Core configuration modules
  - `core-package-manager.el` - Package management and setup
  - `core-packages.el`        - Package declarations and configurations
  - `core-ui.el`              - Basic UI configuration
  - `core-editing.el`         - Editing preferences and behavior
  - `core-files.el`           - File handling and backup settings
  - `core-keybindings.el`     - Global key bindings
- `lang/`   - Language-specific configurations
  - `lang-python-core.el`  - Core Python development settings
  - `lang-python-tools.el` - Python development tools and packages
  - `lang-python-venv.el`  - Python virtual environment management
  - `lang-lisp.el`         - Lisp/Elisp development settings
  - `lang-yaml.el`         - YAML file handling
- `themes/` - Theme and appearance configuration
  - `theme-config.el` - Theme setup and customization
- `custom/` - Custom functions and utilities
  - `functions.el` - Custom helper functions
  - `aliases.el`   - Custom command aliases
- `scripts/` - Installation and utility scripts
  - `install.sh` - Automated installation script
  - `README.md` - Detailed installation guide

## Features

### Performance Optimizations

The configuration includes several performance enhancements:

- **Early initialization** (`early-init.el`): Loaded before package.el and GUI initialization for faster startup
- **Garbage collection tuning**: Optimized GC settings during startup
- **Package management**: Controlled package loading and initialization
- **File handler optimization**: Temporary disabling of file name handlers during startup

### Language Support

- **Python Development**: Comprehensive Python support with tools, virtual environment management, and core development features
- **Lisp/Elisp Development**: Enhanced support for Lisp programming
- **YAML Configuration**: Specialized handling for YAML files

### Code Style and Standards

This configuration follows consistent formatting standards documented in `STYLEGUIDE.md`:

- Uses `elisp-autofmt` for automated code formatting
- Follows GNU Emacs Lisp conventions
- Consistent file organization and naming
- Standardized file headers and documentation

## Usage

After installation, simply restart Emacs or reload your configuration with `M-x eval-buffer` while viewing the `init.el` file.

Any changes you make to files in this repository will be immediately available in Emacs since they are symlinked.

## Installation

To use this Emacs configuration:

```bash
# Clone this repository
$ git clone <your-repository-url> ~/github/emacs.d

# Navigate to the repository directory
$ cd ~/github/emacs.d

# Run the installer script
$ chmod +x scripts/install.sh
$ ./scripts/install.sh
```

The installer creates symlinks from `~/.emacs.d/` to this repository, allowing you to keep your configuration in version control while making changes immediately available in Emacs.

For detailed installation options, troubleshooting, and manual setup instructions, see [`scripts/README.md`](scripts/README.md).
