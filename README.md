# emacs.d

Personal Emacs configuration files and customizations.

## Installation

To use this Emacs configuration, run the installer script which will create symlinks from your `~/.emacs.d/` directory to this repository:

```bash
# Clone this repository if you haven't already
git clone https://github.com/yourusername/emacs.d.git ~/github/emacs.d

# Navigate to the repository directory
cd ~/github/emacs.d

# Make the installer executable and run it
chmod +x install.sh
./install.sh
```

### What the installer does

The installer script will:

1. **Backup existing configuration**: Any existing `~/.emacs.d/init.el` file or `~/.emacs.d/site-lisp/` directory will be backed up with a timestamp
2. **Create symlinks**: 
   - `~/.emacs.d/init.el` → `~/github/emacs.d/init.el`
   - `~/.emacs.d/site-lisp/` → `~/github/emacs.d/site-lisp/`

This approach allows you to:
- Keep your configuration in version control
- Make changes directly in the repository that are immediately reflected in Emacs
- Easily update or rollback changes
- Share your configuration across multiple machines

### Manual Installation

If you prefer to set up the symlinks manually:

```bash
# Backup existing files (optional)
mv ~/.emacs.d/init.el ~/.emacs.d/init.el.backup
mv ~/.emacs.d/site-lisp ~/.emacs.d/site-lisp.backup

# Create symlinks
ln -s ~/github/emacs.d/init.el ~/.emacs.d/init.el
ln -s ~/github/emacs.d/site-lisp ~/.emacs.d/site-lisp
```

## Configuration Structure

- `init.el` - Main Emacs initialization file
- `site-lisp/` - Custom Emacs Lisp files
  - `functions.el` - Custom functions
  - `hotkeys.el` - Key bindings
  - `modes.el` - Mode configurations
  - `prefs.el` - General preferences
  - `filearchive.el` - File archive utilities

## Usage

After installation, simply restart Emacs or reload your configuration with `M-x eval-buffer` while viewing the `init.el` file.

Any changes you make to files in this repository will be immediately available in Emacs since they are symlinked.
