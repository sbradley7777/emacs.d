# emacs.d

Personal Emacs configuration files and customizations.

## Installation

To use this Emacs configuration, run the installer script which will create symlinks from your `~/.emacs.d/` directory to this repository:

```bash
# Clone this repository if you haven't already.
$ git clone https://github.com/yourusername/emacs.d.git ~/github/emacs.d

# Navigate to the repository directory.
$ cd ~/github/emacs.d

# Make the installer executable and run it.
$ chmod +x install.sh
$ ./install.sh
```


### Installation Options

The installer supports several command-line options:

```bash
$ ./install.sh [OPTIONS]

Options:
    -h, --help      Show help message
    --no-backup     Skip backing up conflicting files
    --no-test       Skip configuration testing
    --force         Force installation even if validation fails
```

#### Example Commands

**Standard installation** (recommended for first-time setup):
```bash
$ ./install.sh
```
- Creates backups of existing configuration
- Validates repository structure
- Tests configuration loading
- Provides detailed diagnostics

**Quick installation** (skip backups and testing):
```bash
$ ./install.sh --no-backup --no-test
```
- Fastest installation option
- Use when you don't need backups (e.g., fresh system)
- Skips configuration testing

**Development/testing setup** (skip testing only):
```bash
$ ./install.sh --no-test
```
- Still creates backups for safety
- Skips configuration testing (useful if you know config has issues)
- Good for iterative development

**Force installation** (override validation failures):
```bash
$ ./install.sh --force
```
- Continues even if repository validation fails
- Use with caution - may result in broken configuration
- Helpful when you know certain files are missing but want to proceed

**Fresh system installation** (no backups needed):
```bash
$ ./install.sh --no-backup
```
- Skip backup step when ~/.emacs.d is empty or doesn't exist
- Slightly faster installation
- Still validates and tests configuration

**Show help information**:
```bash
$ ./install.sh --help
```
- Displays usage information and all available options
- No installation is performed

**Combine multiple options**:
```bash
$ ./install.sh --no-backup --force
```
- Skip backups AND force installation even with validation errors
- Most aggressive installation mode

### What the installer does

The installer script performs the following steps:

1. **Check Emacs installation**: Verifies Emacs is available and checks version compatibility (26.1+ recommended)
2. **Validate repository structure**: Ensures all required files and directories exist in the repository
3. **Backup existing configuration**: Creates timestamped backups in `/tmp/` for any conflicting files (init.el, config/, lang/, themes/, custom/)
4. **Create symlinks**:
   - `~/.emacs.d/init.el` → `~/github/emacs.d/init.el`
   - `~/.emacs.d/config/` → `~/github/emacs.d/config/`
   - `~/.emacs.d/lang/` → `~/github/emacs.d/lang/`
   - `~/.emacs.d/themes/` → `~/github/emacs.d/themes/`
   - `~/.emacs.d/custom/` → `~/github/emacs.d/custom/`
5. **Verify installation**: Confirms all symlinks are properly created and valid
6. **Test configuration**: Attempts to load the configuration in batch mode and provides diagnostics

This approach allows you to:
- Keep your configuration in version control
- Make changes directly in the repository that are immediately reflected in Emacs
- Safely backup and restore previous configurations
- Easily update or rollback changes
- Share your configuration across multiple machines

### Manual Installation

If you prefer to set up the symlinks manually:

```bash
# Remove existing directories/files (be careful!).
$ rm -rf ~/.emacs.d/init.el ~/.emacs.d/config ~/.emacs.d/lang ~/.emacs.d/themes ~/.emacs.d/custom

# Create symlinks.
$ ln -s ~/github/emacs.d/init.el ~/.emacs.d/init.el
$ ln -s ~/github/emacs.d/config ~/.emacs.d/config
$ ln -s ~/github/emacs.d/lang ~/.emacs.d/lang
$ ln -s ~/github/emacs.d/themes ~/.emacs.d/themes
$ ln -s ~/github/emacs.d/custom ~/.emacs.d/custom
```

## Configuration Structure

- `init.el` - Main Emacs initialization file that loads all configuration modules
- `config/` - Core configuration modules
  - `core-packages.el`    - Package management and setup
  - `core-ui.el`          - Basic UI configuration
  - `core-editing.el`     - Editing preferences and behavior
  - `core-files.el`       - File handling and backup settings
  - `core-keybindings.el` - Global key bindings
- `lang/`   - Language-specific configurations
  - `lang-python.el` - Python development settings
  - `lang-yaml.el`   - YAML file handling
- `themes/` - Theme and appearance configuration
  - `theme-config.el` - Theme setup and customization
- `custom/` - Custom functions and utilities
  - `functions.el` - Custom helper functions

## Usage

After installation, simply restart Emacs or reload your configuration with `M-x eval-buffer` while viewing the `init.el` file.

Any changes you make to files in this repository will be immediately available in Emacs since they are symlinked.

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
