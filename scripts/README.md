# Scripts Directory

This directory contains scripts and utilities for managing the Emacs configuration.

## Table of Contents

- [Available Scripts](#available-scripts)
- [Configuration Testing](#configuration-testing)
- [elisp-autofmt Pre-commit Hook](#elisp-autofmt-pre-commit-hook)
  - [Requirements](#requirements)
  - [Usage](#usage)
  - [Hook Options](#hook-options)
  - [Configuration](#configuration)
  - [Behavior](#behavior)
  - [Example Output](#example-output)
- [Installation Guide](#installation-guide)
  - [Quick Start](#quick-start)
  - [Installation Script Options](#installation-script-options)
  - [Installation Examples](#installation-examples)
  - [What the Installer Does](#what-the-installer-does)
  - [Benefits of the Symlink Approach](#benefits-of-the-symlink-approach)
  - [Manual Installation](#manual-installation)
  - [Troubleshooting](#troubleshooting)

## Available Scripts

### Installation Script (`install.sh`)
Automated installation and setup script for the Emacs configuration.

### Configuration Testing (`test-config.sh`)
Comprehensive configuration testing script that validates your Emacs setup in batch mode. See [`TESTING.md`](TESTING.md) for detailed documentation.

### Formatting Hook (`elisp-autofmt-hook`)
Pre-commit hook wrapper for automatic Emacs Lisp code formatting.

---

## Configuration Testing

For comprehensive testing documentation including detailed usage examples, troubleshooting, limitations, and CI/CD integration, see [`TESTING.md`](TESTING.md).

### Quick Start

```bash
# Run configuration test
~/github/emacs.d/scripts/test-config.sh
```

The test script validates module loading, provides timing diagnostics, and detects version compatibility issues.

---

## elisp-autofmt Pre-commit Hook

The `elisp-autofmt-hook` script automatically formats Emacs Lisp files using [elisp-autofmt](https://github.com/emacsmirror/elisp-autofmt) during git commits.

### Requirements

1. **elisp-autofmt**: The formatting tool must be installed
   ```bash
   # Clone the elisp-autofmt repository
   git clone https://github.com/emacsmirror/elisp-autofmt.git ~/github/elisp-autofmt
   ```

2. **Python 3**: Required to run elisp-autofmt.py
   ```bash
   # Verify Python 3 is available
   python3 --version
   ```

3. **pre-commit**: For automatic hook execution
   ```bash
   # Install pre-commit
   pip install pre-commit  # https://github.com/pre-commit/pre-commit

   # Install hooks in your repository
   pre-commit install
   ```

### Usage

#### Automatic Usage (Recommended)
The hook runs automatically during git commits when pre-commit is installed:
```bash
git add file.el
git commit -m "Update configuration"
# Hook runs automatically and formats files if needed
```

#### Manual Usage
You can also run the hook manually:
```bash
# Format specific files
./scripts/elisp-autofmt-hook user/functions.el themes/themes.el

# Verbose mode for detailed output
./scripts/elisp-autofmt-hook --verbose *.el

# Custom elisp-autofmt path
./scripts/elisp-autofmt-hook --bin /custom/path/elisp-autofmt.py *.el
```

### Hook Options

| Option | Description |
|--------|-------------|
| `--bin PATH` | Custom path to elisp-autofmt.py script |
| `-v, --verbose` | Show detailed processing information |
| `-h, --help` | Display help message |

### Configuration

#### Default Path
The hook expects elisp-autofmt at: `~/github/elisp-autofmt/elisp-autofmt.py`

#### Custom Path
To use a different location, configure in `.pre-commit-config.yaml`:
```yaml
- repo: local
  hooks:
    - id: elisp-autofmt
      name: elisp-autofmt
      description: "Automatically format Emacs Lisp files using elisp-autofmt"
      entry: scripts/elisp-autofmt-hook
      language: script
      files: '\.el$'
      pass_filenames: true
      args: ["--bin", "/path/to/your/elisp-autofmt.py"]
```

### Behavior

- **Silent Success**: No output when files are already properly formatted
- **Change Detection**: Reports which files were modified with formatting changes
- **Git Integration**: Provides `git add` commands for staging formatted files
- **Exit Codes**: Returns 1 if changes were made (halting commit), 0 if no changes needed

### Example Output

**When changes are made:**
```
elisp-autofmt made formatting changes to the following files:
  - user/functions.el
  - themes/themes.el

Files have been automatically formatted. Please review and stage the changes:
  git add 'user/functions.el' 'themes/themes.el'
```

**Verbose mode:**
```
user/functions.el: The file has been modified to fix formatting issues
themes/themes.el: No formatting changes detected

elisp-autofmt made formatting changes to the following files:
  - user/functions.el

Files have been automatically formatted. Please review and stage the changes:
  git add 'user/functions.el'
```

---

## Installation Guide

## Quick Start

```bash
# Navigate to the repository directory
$ cd ~/github/emacs.d

# Make the installer executable and run it
$ chmod +x install/install.sh
$ ./scripts/install.sh
```

## Installation Script Options

The installer supports several command-line options:

```bash
$ ./scripts/install.sh [OPTIONS]

Options:
    -h, --help      Show help message
    --no-backup     Skip backing up conflicting files
    --no-test       Skip configuration testing
    --force         Force installation even if validation fails
```

## Installation Examples

### Standard Installation
**Recommended for first-time setup:**
```bash
$ ./scripts/install.sh
```
- Creates backups of existing configuration
- Validates repository structure
- Tests configuration loading
- Provides detailed diagnostics

### Quick Installation
**Skip backups and testing:**
```bash
$ ./scripts/install.sh --no-backup --no-test
```
- Fastest installation option
- Use when you don't need backups (e.g., fresh system)
- Skips configuration testing

### Development Setup
**Skip testing only:**
```bash
$ ./scripts/install.sh --no-test
```
- Still creates backups for safety
- Skips configuration testing (useful if you know config has issues)
- Good for iterative development

### Force Installation
**Override validation failures:**
```bash
$ ./scripts/install.sh --force
```
- Continues even if repository validation fails
- Use with caution - may result in broken configuration
- Helpful when you know certain files are missing but want to proceed

### Fresh System Installation
**No backups needed:**
```bash
$ ./scripts/install.sh --no-backup
```
- Skip backup step when ~/.emacs.d is empty or doesn't exist
- Slightly faster installation
- Still validates and tests configuration

### Show Help Information
```bash
$ ./scripts/install.sh --help
```
- Displays usage information and all available options
- No installation is performed

### Combine Multiple Options
```bash
$ ./scripts/install.sh --no-backup --force
```
- Skip backups AND force installation even with validation errors
- Most aggressive installation mode

## What the Installer Does

The installer script performs the following steps:

1. **Check Emacs installation**: Verifies Emacs is available and checks version compatibility (26.1+ recommended)
2. **Validate repository structure**: Ensures all required files and directories exist in the repository
3. **Backup existing configuration**: Creates timestamped backups in `/tmp/` for any conflicting files ([`init.el`](../init.el), [`early-init.el`](../early-init.el), [`core/`](../core/), [`lang/`](../lang/), [`themes/`](../themes/), custom/)
4. **Create symlinks**:
   - `~/.emacs.d/init.el` → `~/github/emacs.d/init.el`
   - `~/.emacs.d/early-init.el` → `~/github/emacs.d/early-init.el`
   - `~/.emacs.d/config/` → `~/github/emacs.d/config/`
   - `~/.emacs.d/`[`lang/`](../lang/) → `~/github/emacs.d/`[`lang/`](../lang/)
   - `~/.emacs.d/`[`themes/`](../themes/) → `~/github/emacs.d/`[`themes/`](../themes/)
   - `~/.emacs.d/custom/` → `~/github/emacs.d/custom/`
5. **Verify installation**: Confirms all symlinks are properly created and valid
6. **Test configuration**: Attempts to load the configuration in batch mode and provides diagnostics

## Benefits of the Symlink Approach

This approach allows you to:
- Keep your configuration in version control
- Make changes directly in the repository that are immediately reflected in Emacs
- Safely backup and restore previous configurations
- Easily update or rollback changes
- Share your configuration across multiple machines

## Manual Installation

If you prefer to set up the symlinks manually:

```bash
# Remove existing directories/files (be careful!)
$ rm -rf ~/.emacs.d/init.el ~/.emacs.d/early-init.el ~/.emacs.d/config ~/.emacs.d/lang ~/.emacs.d/themes ~/.emacs.d/custom

# Create symlinks
$ ln -s ~/github/emacs.d/init.el ~/.emacs.d/init.el
$ ln -s ~/github/emacs.d/early-init.el ~/.emacs.d/early-init.el
$ ln -s ~/github/emacs.d/config ~/.emacs.d/config
$ ln -s ~/github/emacs.d/lang ~/.emacs.d/lang
$ ln -s ~/github/emacs.d/themes ~/.emacs.d/themes
$ ln -s ~/github/emacs.d/custom ~/.emacs.d/custom
```

## Troubleshooting

### Configuration Test Warnings

If you see warnings like "Configuration may have issues" during installation, this is often normal behavior:

**Package-related warnings** (most common):
- The configuration automatically installs packages from MELPA on first run
- Network timeouts or package installation messages may cause warnings
- These are typically harmless and don't prevent Emacs from working
- The installer will detect and explain these automatically

**Debugging configuration issues**:
```bash
# Test configuration manually to see detailed output
$ emacs --batch --load ~/.emacs.d/init.el --eval '(message "Configuration test")'

# Start Emacs with debug information
$ emacs --debug-init

# Check for syntax errors
$ emacs --batch --eval "(check-parens)" ~/.emacs.d/init.el
```

### Backup Recovery

If you need to restore your previous configuration:
```bash
# Backups are stored in /tmp/ with timestamps
$ ls /tmp/emacs.d.backup.*

# Restore from backup (replace TIMESTAMP with actual timestamp)
$ cp -r /tmp/emacs.d.backup.TIMESTAMP/* ~/.emacs.d/
```

### Common Issues

**Permission errors:**
```bash
# Make sure the script is executable
$ chmod +x install/install.sh
```

**Emacs not found:**
- Ensure Emacs is installed and in your PATH
- Check with: `which emacs` or `emacs --version`

**Symlink conflicts:**
- The installer will backup existing files automatically
- Use `--force` flag to override validation failures if needed

**Repository validation fails:**
- Ensure you're running the script from the repository root
- Check that all required files exist: [`init.el`](../init.el), [`early-init.el`](../early-init.el), [`core/`](../core/), etc.
- Use `--force` flag to bypass validation if you know what you're doing

## Related Documentation

- [`TESTING.md`](TESTING.md) - Comprehensive testing documentation
