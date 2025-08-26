# emacs.d

Personal Emacs configuration files and customizations.

## Installation

To use this Emacs configuration, run the installer script which will create symlinks from your `~/.emacs.d/` directory to this repository:

```bash
# Clone this repository if you haven't already
$ git clone https://github.com/yourusername/emacs.d.git ~/github/emacs.d

# Navigate to the repository directory
$ cd ~/github/emacs.d

# Make the installer executable and run it
$ chmod +x install.sh
$ ./install.sh
```

### What the installer does

The installer script will:

1. **Remove existing configuration**: Any existing directories or files that conflict with the new structure will be removed
2. **Create symlinks**:
   - `~/.emacs.d/init.el` → `~/github/emacs.d/init.el`
   - `~/.emacs.d/config/` → `~/github/emacs.d/config/`
   - `~/.emacs.d/lang/` → `~/github/emacs.d/lang/`
   - `~/.emacs.d/themes/` → `~/github/emacs.d/themes/`
   - `~/.emacs.d/custom/` → `~/github/emacs.d/custom/`

This approach allows you to:
- Keep your configuration in version control
- Make changes directly in the repository that are immediately reflected in Emacs
- Easily update or rollback changes
- Share your configuration across multiple machines

### Manual Installation

If you prefer to set up the symlinks manually:

```bash
# Remove existing directories/files (be careful!)
$ rm -rf ~/.emacs.d/init.el ~/.emacs.d/config ~/.emacs.d/lang ~/.emacs.d/themes ~/.emacs.d/custom

# Create symlinks
$ ln -s ~/github/emacs.d/init.el ~/.emacs.d/init.el
$ ln -s ~/github/emacs.d/config ~/.emacs.d/config
$ ln -s ~/github/emacs.d/lang ~/.emacs.d/lang
$ ln -s ~/github/emacs.d/themes ~/.emacs.d/themes
$ ln -s ~/github/emacs.d/custom ~/.emacs.d/custom
```

## Configuration Structure

- `init.el` - Main Emacs initialization file that loads all configuration modules
- `config/` - Core configuration modules
  - `core-packages.el` - Package management and setup
  - `core-ui.el` - Basic UI configuration
  - `core-editing.el` - Editing preferences and behavior
  - `core-files.el` - File handling and backup settings
  - `core-keybindings.el` - Global key bindings
- `lang/` - Language-specific configurations
  - `lang-python.el` - Python development settings
  - `lang-yaml.el` - YAML file handling
- `themes/` - Theme and appearance configuration
  - `theme-config.el` - Theme setup and customization
- `custom/` - Custom functions and utilities
  - `functions.el` - Custom helper functions

## Usage

After installation, simply restart Emacs or reload your configuration with `M-x eval-buffer` while viewing the `init.el` file.

Any changes you make to files in this repository will be immediately available in Emacs since they are symlinked.
