# Frequently Asked Questions

This document answers common questions about the Emacs configuration, its features, and usage.

## Table of Contents

- [General Configuration](#general-configuration)
- [Installation and Setup](#installation-and-setup)
- [Features and Functionality](#features-and-functionality)
- [Font and Icon Management](#font-and-icon-management)
- [Project Navigation with Treemacs](#project-navigation-with-treemacs)
- [Message Logging and Session History](#message-logging-and-session-history)
- [Python Development](#python-development)
- [Performance and Optimization](#performance-and-optimization)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Related Documentation](#related-documentation)

## General Configuration

*Questions about the overall design philosophy and approach of this configuration.*

### Q: What makes this configuration different from others?

**A:** This configuration focuses on several key principles:
- **Modern optimization**: Full utilization of Emacs 30.2+ features
- **Minimal dependencies**: Uses built-in Emacs features when possible
- **Performance optimization**: Startup times optimized for daily use
- **Professional development**: Comprehensive Python development environment with LSP integration
- **Automated quality**: Pre-commit hooks and formatting ensure consistent code quality

### Q: What Emacs versions are supported?

**A:** This configuration requires Emacs 30.2+ exclusively due to specific technical dependencies:

**Core Requirements:**
- **Native compilation improvements**: Enhanced bytecode generation for package performance
- **Built-in use-package enhancements**: Modern lazy-loading and configuration capabilities
- **Memory management**: Advanced garbage collection tuning not available in earlier versions

**Why older versions won't work:**
- Missing native compilation optimizations cause startup performance issues
- UI feature limitations prevent proper line number and diagnostic display
- Package loading mechanisms lack modern reliability features

### Q: How is the configuration optimized for Emacs 30.2+?

**A:** The configuration directly utilizes modern Emacs features ([`core/core-constants.el`](core/core-constants.el)) with:

**Performance Optimizations:**
- **Garbage collection tuning**: 8MB normal, 200MB for long sessions (modern GC algorithms)
- **Native compilation**: Automatic bytecode optimization for all packages
- **Startup optimization**: Modern file handler management and initialization
- **Memory efficiency**: Advanced heap management for development workloads

**Modern UI Features:**
- **Enhanced line numbers**: `global-display-line-numbers-mode` with visual line support
- **Improved diagnostics**: Advanced Flymake integration with real-time updates
- **Visual enhancements**: Modern theme and display capabilities

**Development Features:**
- **Package management**: Reliable use-package with modern dependency resolution
- **Python integration**: Optimized virtual environment detection
- **Code quality**: Enhanced formatting and linting tool integration

### Q: Is this configuration suitable for beginners?

**A:** Yes! The configuration is designed to work out-of-the-box with sensible defaults. However, it's also comprehensive enough for professional development. New users can start with basic features and gradually explore advanced capabilities.

## Installation and Setup

*Questions about getting the configuration installed and running on your system.*

### Q: Should I use the development installation (symlinks) or standard installation (copy)?

**A:** Choose based on your needs:
- **Development installation (symlinks)**: Use if you want to modify the configuration itself, test changes, or contribute improvements
- **Standard installation (copy)**: Use for regular daily use without configuration development

For detailed installation instructions, see [`scripts/install.sh`](scripts/install.sh), [`scripts/README.md`](scripts/README.md), or the main [`README.md`](README.md) installation section.

### Q: Can I install this alongside my existing Emacs configuration?

**A:** Not directly. This is a complete configuration replacement. To test:
1. Backup your existing `~/.emacs.d/` directory
2. Install this configuration
3. If you want to revert, restore your backup

### Q: How do I verify my installation is working correctly?

**A:** Use the included configuration test script:

```bash
# Quick configuration test
~/github/emacs.d/scripts/test-config.sh
```

**What the test shows:**
- ✅ Which Emacs version is being used (important for alias detection)
- ✅ Module loading status and timing information
- ✅ Modern Emacs 30.2+ feature utilization
- ✅ Detailed diagnostics for any failures

**Expected results:**
- **All modules successful**: Configuration is working perfectly
- **Feature availability**: All modern features should be available in Emacs 30.2+
- **Network/package warnings**: Normal in batch mode (packages work when needed)

**Manual testing alternatives:**
```bash
# Interactive debug mode (shows detailed errors)
emacs --debug-init

# Simple batch test
# Note: Disable trampolines to prevent ~/.emacs.d/eln-cache/ creation in wrong location
#       This configuration uses ~/.emacs.d/local/eln-cache/ instead
emacs --batch --eval "(setq native-comp-enable-subr-trampolines nil)" --eval "(load-file \"~/.emacs.d/init.el\")" --eval "(message \"Configuration loaded\")"
```

For comprehensive testing documentation and troubleshooting, see [`scripts/TESTING.md`](scripts/TESTING.md).

### Q: What if I want to use only parts of this configuration?

**A:** The modular structure allows selective use:
- Copy individual modules from [`core/`](core/), [`features/`](features/), or [`lang/`](lang/) directories
- Modify [`init.el`](init.el) to load only desired modules
- See [`CONTRIBUTING.md`](CONTRIBUTING.md) for guidance on customization

### Q: Do I need to install external dependencies?

**A:** For basic functionality, no external dependencies are required. For enhanced features:
- **Code formatting**: Requires [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt)
- **Pre-commit hooks**: Requires `pre-commit` Python package

See [`README.md`](README.md#requirements) for complete requirements.

## Features and Functionality

*Questions about using the various features and capabilities provided by this configuration.*

### Q: How does the auto-completion system work?

**A:** The configuration uses [Corfu](https://github.com/minad/corfu) for universal completion:
- **Automatic triggers**: Completion appears after 1 character (200ms delay)
- **Multiple activation methods**: `TAB`, `C-c TAB`, `M-TAB`, `C-M-i`
- **Smart behavior**: `TAB` completes when possible, indents otherwise
- **Context-aware**: Uses built-in completion and mode-specific sources

See [`FEATURES.md`](FEATURES.md#auto-completion-system) for detailed information and [`KEYMAP.md`](KEYMAP.md#code-completion-corfu) for complete keybinding reference.

### Q: What programming languages are supported?

**A:** Current language support includes:
- **Python**: Full development environment with virtual environments, remote development via TRAMP, and debugging
- **Emacs Lisp**: Enhanced development with formatting and evaluation
- **YAML**: Structure-aware editing and completion

The modular design makes it easy to add support for additional languages.

### Q: How does the theme system work?

**A:** The configuration uses [Doom Themes](https://github.com/doomemacs/themes) ([`themes/themes-config.el`](themes/themes-config.el)) with:
- **Default theme**: `doom-1337` in the main configuration
- **40+ professional themes**: Comprehensive collection from the Doom Emacs ecosystem
- **Terminal optimization**: Automatic adjustments to reduce warnings in terminal mode
- **Interactive switching**: Use `M-x switch-theme` to preview and change themes
- **Local customization**: Override theme preferences in `local.el`

**Popular theme options:**
- **Terminal-friendly**: `doom-1337` (default), `doom-zenburn`, `doom-gruvbox`, `doom-material-dark`
- **GUI-optimized**: `doom-Iosvkem`, `doom-monokai-machine`, `doom-peacock`
- **Built-in fallbacks**: `wombat`, `tango-dark`

**Example override:** The [`configs/local.el`](configs/local.el) includes examples for overriding to alternative themes like `doom-zenburn`.

### Q: How do I set up Git integration (Magit and Forge)?

**A:** The configuration provides comprehensive Git integration through Magit (Git interface) and Forge (GitHub/GitLab integration). Setup requires three main steps:

**Quick Setup:**
1. **Configure forge hosts** in `~/.gitconfig`:
   ```ini
   [emacs-forge "github.com"]
       apihost = api.github.com
       webhost = github.com
       type = github
       user = YOUR_USERNAME
   ```

2. **Create personal access token**:
   - GitHub: https://github.com/settings/tokens (scopes: `repo`, `user`, `read:org`)
   - GitLab: https://gitlab.com/-/profile/personal_access_tokens (scopes: `api`, `read_api`, `read_user`)

3. **Add credentials** to `~/.authinfo`:
   ```bash
   echo "machine api.github.com login YOUR_USERNAME^forge password YOUR_TOKEN" >> ~/.authinfo
   chmod 600 ~/.authinfo
   ```

**Important Notes:**
- The `^forge` suffix on the username is required
- Restart Emacs or run `M-x forge-gitconfig-populate-forge-alist-from-gitconfig`
- Test with `M-x magit-status` then `M-x forge-pull`

**Automatic Features:**
- Repository-local usernames are automatically configured when you open files
- Forge hosts from `~/.gitconfig` are automatically loaded on startup
- Use `M-x forge-authinfo-generate-entries` for interactive credential setup

For complete setup instructions, troubleshooting, and usage guide, see [`GIT.md`](GIT.md).

### Q: How does Git/Forge synchronization work?

**A:** The configuration provides both manual and automatic synchronization options for Git refs and Forge data.

**Default Behavior (Manual Sync):**
- **No automatic sync** - By default, Git and Forge data are NOT automatically synchronized when files are opened
- **Manual sync command** - Use `M-x git-sync-repository` to synchronize Git refs and Forge data on demand
- **User control** - Sync only when you choose, avoiding unexpected network activity during file opening
- **Network efficient** - Tracks synced repositories to avoid redundant fetches in the same session

**Why Manual by Default:**
- **Reduces startup delays** - No network activity when opening files
- **Avoids surprise pauses** - No unexpected "fetching..." delays during work
- **User control** - Sync only when you need updated Git/Forge data
- **Battery friendly** - Less background network activity

**Optional Auto-Sync (Opt-In):**
If you prefer automatic syncing when opening files in a repository:

1. **Enable in local.el** - Uncomment two lines in `~/.emacs.d/local.el`:
   ```elisp
   ;; Optional: Auto-sync Git and Forge data when opening files (default: disabled)
   (require 'git-sync)
   (add-hook 'find-file-hook #'git-auto-sync-repository-once)
   ```

2. **Restart Emacs** - The auto-sync hook will now be active
3. **Once per session** - Each repository syncs once per session when first file is opened
4. **Background operation** - Non-blocking, allows you to continue working immediately

**Sync Features:**
- **Magit integration** - Fetches Git refs (branches, tags, commits) via `magit-fetch-all`
- **Forge integration** - Pulls Forge metadata (issues, PRs, comments) via Forge API
- **Progress indicators** - Shows sync status in modeline
- **Smart completion** - Success/failure notifications after sync completes

See [`FEATURES.md`](FEATURES.md#git-and-forge-synchronization) for detailed information.

### Q: Can I disable specific features?

**A:** Yes! The modular structure allows easy feature control:
- Comment out unwanted modules in [`init.el`](init.el)
- Individual features can be disabled in their respective configuration files
- Use [`use-package`](https://www.gnu.org/software/emacs/manual/html_mono/use-package.html) `:disabled t` to temporarily disable specific packages

## Font and Icon Management

*Questions about automatic font installation and icon display.*

### Q: How does automatic font installation work?

**A:** The configuration includes automatic font management ([`core/core-fonts.el`](core/core-fonts.el)) that:
- **Detects installed packages**: Automatically installs fonts when icon packages are present
- **System-wide installation**: Installs fonts to `~/.local/share/fonts/` (Linux) or `~/Library/Fonts/` (macOS)
- **Fast verification**: Uses file-based checks instead of slow font system queries
- **Cross-application availability**: Fonts work in Emacs, terminals, browsers, and other applications

**Supported Font Packages:**
- **nerd-icons (NFM.ttf)**: Nerd Font symbols for enhanced display

### Q: Why do I see boxes or missing icons?

**A:** Icon display issues typically have these causes:

**In GUI mode:**
1. **Missing fonts**: Fonts may not be installed correctly
2. **Font cache**: System font cache may need refreshing
3. **Package issues**: Icon packages may not be fully loaded

**In terminal mode:**
1. **Expected behavior**: Terminal mode uses text-based `Default` theme by design
2. **Terminal font**: Your terminal needs a Nerd Font configured to display icons
3. **Terminal limitations**: Some terminals don't support advanced font features

**Solutions:**
- **Force font installation**: `M-x nerd-icons-install-fonts`
- **Refresh font cache**: `fc-cache -fv` (Linux)
- **Terminal setup**: Install and configure a Nerd Font in your terminal settings
- **Restart applications**: Restart Emacs and terminal after font installation

### Q: Can I use these fonts in my terminal?

**A:** Yes! The fonts are installed system-wide and available to all applications:

**Terminal Setup:**
1. **Install fonts**: The configuration automatically installs Nerd Fonts
2. **Configure terminal**: Set your terminal to use a Nerd Font (e.g., "Hack Nerd Font", "FiraCode Nerd Font")
3. **Restart terminal**: Required for font changes to take effect
4. **Test display**: Icons should display properly in terminal applications

**Popular Nerd Font Options:**
- **Hack Nerd Font**: Good readability and icon support
- **FiraCode Nerd Font**: Programming ligatures plus icons
- **JetBrains Mono Nerd Font**: Professional appearance

### Q: How do I check if fonts are installed correctly?

**A:** Several verification methods:

**File-based check:**
```bash
# Linux
ls ~/.local/share/fonts/ | grep NFM

# macOS
ls ~/Library/Fonts/ | grep NFM
```

**Emacs verification:**
```elisp
M-x fonts-check-nerd-icons
```

**Expected files:**
- `NFM.ttf` - Nerd Font symbols

## Project Navigation with Treemacs

*Questions about the file tree sidebar and project management.*

### Q: How do I use the Treemacs file tree?

**A:** Treemacs provides a comprehensive file tree sidebar ([`features/treemacs/treemacs-config.el`](features/treemacs/treemacs-config.el)):

**Basic Usage:**
- **Toggle sidebar**: Press `F4` to open/close/focus Treemacs
- **Navigate files**: Use arrow keys or `n`/`p` to move between items
- **Open files**: Press `RET` (Enter) to open files or expand directories
- **Project context**: Automatically shows project structure with git integration

**Key Features:**
- **Smart theming**: Uses `Default` theme by default, customizable via `local.el`
- **Git integration**: Shows file status (modified, staged, untracked) with visual indicators
- **Project following**: Automatically tracks current file location in tree
- **File watching**: Real-time updates when files change on disk

### Q: Why do I see different icons in GUI vs terminal mode?

**A:** This is intentional design for optimal compatibility:

**GUI Mode:**
- Uses `nerd-icons` theme with rich graphical icons
- Requires `nerd-icons` fonts to be installed
- Provides the best visual experience with color-coded file types

**Terminal Mode:**
- Uses `Default` theme with text-based symbols (ASCII characters)
- Works in any terminal without font dependencies
- Ensures compatibility across different terminal environments

**Benefits:**
- **Consistent functionality**: Same navigation and features in both modes
- **Universal compatibility**: Terminal mode works everywhere
- **Optimal experience**: GUI mode provides enhanced visuals when available

### Q: What keybindings are available in Treemacs?

**A:** Comprehensive keybinding support ([`KEYMAP.md`](KEYMAP.md#treemacs-project-navigation)):

**Global bindings:**
- **F4**: Smart toggle (open/close/focus Treemacs)
- **C-x t t**: Open Treemacs
- **C-x t C-t**: Find current file in Treemacs
- **C-x t 1**: Keep only Treemacs and current window

**Within Treemacs sidebar:**
- **RET**: Open file or expand/collapse directory
- **TAB**: Expand/collapse without opening
- **o**: Open in other window
- **cf**: Create file
- **cd**: Create directory
- **R**: Rename file/directory
- **d**: Delete file/directory
- **r**: Refresh
- **q**: Quit Treemacs

### Q: How do I customize Treemacs behavior?

**A:** Treemacs offers extensive customization options:

**Common settings (in [`features/treemacs/treemacs-config.el`](features/treemacs/treemacs-config.el)):**
- **Width**: `treemacs-width` (default: 30)
- **Indentation**: `treemacs-indentation` (default: 2)
- **Hidden files**: `treemacs-show-hidden-files` (default: t)
- **Sorting**: `treemacs-sorting` (default: alphabetic-case-insensitive-asc)

**Git integration:**
- **Enable/disable**: `treemacs-git-integration` (default: t)
- **File watching**: `treemacs-filewatch-mode` (default: enabled)

**Override in local.el:**
```elisp
;; Example customizations
(setq treemacs-width 40)                    ; Wider sidebar
(setq treemacs-show-hidden-files nil)       ; Hide dotfiles
(setq treemacs-collapse-dirs 5)             ; Collapse more levels
```

## Message Logging and Session History

*Questions about automatic message logging and debugging support.*

### Q: How does message logging work?

**A:** The configuration includes automatic message logging ([`core/logging.el`](core/logging.el)) that:
- **Saves on exit**: Automatically saves Messages buffer content when Emacs exits
- **Log rotation**: Maintains up to 5 log files with automatic rotation
- **Timestamped entries**: Adds session end timestamps for debugging
- **Organized storage**: Stores logs in `<emacs-local-dir>/log/` directory

**Log File Structure:**
- **Current session**: `<emacs-local-dir>/log/messages.log`
- **Previous sessions**: `messages.log.1`, `messages.log.2`, etc.
- **Automatic cleanup**: Removes oldest logs when exceeding retention limit

### Q: What information is captured in logs?

**A:** The logs capture complete Messages buffer content including:
- **Startup messages**: Module loading times and status
- **Error messages**: Package failures and configuration issues
- **Warning messages**: Performance and compatibility warnings
- **Debug output**: Development and troubleshooting information
- **Session markers**: Clear separation between different Emacs sessions

**Benefits for development:**
- **Debugging support**: Preserve error messages across sessions
- **Performance analysis**: Review startup timing and load patterns
- **Development tracking**: Maintain history of configuration changes
- **Troubleshooting**: Access complete message history for problem diagnosis

### Q: How can I access log files?

**A:** Several methods to access logs:

**Direct file access:**
```bash
# View current session log
less <emacs-local-dir>/log/messages.log

# View previous session
less <emacs-local-dir>/log/messages.log.1

# List all logs
ls -la <emacs-local-dir>/log/
```

**From within Emacs:**
```elisp
# View current Messages buffer
M-x view-echo-area-messages

# Open log directory
C-x C-f <emacs-local-dir>/log/

# Force save current messages
M-x core-save-messages-log
```

### Q: Can I customize logging behavior?

**A:** Yes, several customization options ([`core/logging.el`](core/logging.el)):

**Configuration variables:**
- **`core-log-max-files`**: Number of rotated logs to keep (default: 5)
- **`core-log-directory`**: Directory for log storage (default: `<emacs-local-dir>/log`)
- **`core-messages-log-file`**: Base filename (default: `messages.log`)

**Override in local.el:**
```elisp
;; Example customizations
(setq core-log-max-files 10)                 ; Keep more log files
(setq core-log-directory "~/emacs-logs")     ; Different directory
```

**Manual control:**
```elisp
;; Force log save
(core-save-messages-log)

;; Rotate logs manually
(core-rotate-log-files "messages.log")
```

## Python Development

*Questions specific to Python programming and development environment setup.*

### Q: How does virtual environment detection work?

**A:** Virtual environment detection works for both local and remote files:

**Local Detection** ([`lang/python/pyvenv-config.el`](lang/python/pyvenv-config.el)):
1. **Project root detection**: Searches upward for `.git/`, `pyproject.toml`, or `requirements.txt`
2. **Virtual environment location**: Looks for `venv/` directory in project root
3. **Automatic activation**: Activates environment when opening Python files
4. **Python version detection**: Displays Python version in modeline

**Remote Detection** ([`lang/python/pyvenv-remote.el`](lang/python/pyvenv-remote.el)):
1. **TRAMP-aware detection**: Searches remote filesystem for virtual environments
2. **Fallback to local**: Uses local project structure when remote venv not found
3. **Connection-local variables**: Uses official TRAMP mechanisms for remote configuration
4. **Unified experience**: Same modeline display and activation behavior for remote files

### Q: Can I use different virtual environment names or locations?

**A:** Currently, the configuration expects virtual environments to be named `venv` in the project root. For custom setups:
- Use manual activation: `M-x pyvenv-activate`
- Modify the detection logic in [`lang/python/pyvenv-config.el`](lang/python/pyvenv-config.el)
- Consider using `M-x pyvenv-workon` for system-wide virtual environments

### Q: Are there limitations with Python virtual environment management?

**A:** Yes, this configuration uses a **single-project approach** with these limitations:
- **One active project per session**: Only one Python project can be active at a time
- **Auto-detect once**: The first Python file with a venv sets the global project
- **Modeline behavior**: Files outside the detected project show "inactive" status

**Rationale**: This simplified approach reduces complexity by 80% compared to multi-project solutions while supporting the most common development workflow.

**Workarounds**:
- Use `M-x pyvenv-activate` to manually switch projects
- Restart Emacs to change the primary project context
- Run separate Emacs instances for different projects

### Q: Does remote development work with TRAMP?

**A:** Yes, the configuration includes comprehensive TRAMP support for SSH-based remote Python development:

**Features:**
- **Seamless virtual environment detection** for remote Python projects
- **TRAMP connection-local variables** for proper remote Python configuration
- **Unified modeline display** showing remote virtual environment status
- **Fallback detection** using local project structure when remote venv not found

**Setup:**
1. **Remote paths**: Python virtual environments automatically detected in standard locations
2. **SSH configuration**: Uses standard SSH settings, no special TRAMP configuration required
3. **Local customization**: Override remote Python paths in [`configs/local.el`](configs/local.el) if needed

**Default Configuration** ([`features/tramp/tramp-config.el`](features/tramp/tramp-config.el)):
```elisp
;; Connection settings
(setq tramp-default-method "ssh")              ; Use SSH for remote connections
(setq tramp-default-remote-shell "/bin/bash")  ; Use bash as remote shell
(setq tramp-verbose 0)                         ; Silent operation by default

;; Performance optimizations
(setq tramp-use-ssh-controlmaster-options nil) ; Disable SSH control master
(setq tramp-completion-reread-directory-timeout nil) ; Faster completion
```

**Python Remote Paths** ([`lang/python/python-constants.el`](lang/python/python-constants.el)):
```elisp
;; Standard Python installation locations searched automatically
python-tramp-remote-bin-paths:
  ~/venv/bin ~/.venv/bin ~/env/bin ~/.local/bin
  ~/.pyenv/shims /opt/conda/bin /usr/local/python/bin

;; Environment variables set for remote Python processes
python-tramp-environment-vars:
  PYTHONIOENCODING=utf-8 PYTHONUNBUFFERED=1
  PYTHONDONTWRITEBYTECODE=1 VIRTUAL_ENV_DISABLE_PROMPT=1
  PIP_DISABLE_PIP_VERSION_CHECK=1
```

**Usage:**
```elisp
C-x C-f /ssh:user@hostname:/path/to/project/file.py
```

The configuration automatically detects and activates the appropriate virtual environment for remote Python files.

## Performance and Optimization

### Q: Why does Emacs start quickly with this configuration?

**A:** Several optimizations contribute to fast startup:
- **Early initialization** ([`early-init.el`](early-init.el)): Optimizations before package loading
- **Garbage collection tuning**: Deferred GC during startup
- **Deferred loading**: Non-essential packages loaded on-demand
- **Modern optimization**: Settings optimized for Emacs 30.2+

### Q: How does the configuration handle long-running Emacs sessions?

**A:** The configuration includes long-session optimizations:
- **Dynamic GC adjustment**: Automatically increases GC thresholds for long sessions
- **Memory management**: Modern heap optimization
- **Performance monitoring**: Load time tracking for configuration modules

### Q: Can I monitor performance and resource usage?

**A:** Yes, several tools are available:
- **Startup timing**: Check the `*Messages*` buffer for module load times
- **Memory usage**: Use `M-x memory-usage` to see buffer memory consumption
- **GC statistics**: Monitor garbage collection in the `*Messages*` buffer
- **Profiling**: Use Emacs built-in profiler for detailed analysis

## Customization

*Questions about modifying and extending the configuration for your specific needs.*

### Q: How do I add my own customizations?

**A:** The configuration provides several customization points:
- **User directory**: Add personal functions to [`user/user-utils.el`](user/user-utils.el)
- **Aliases**: Add command aliases to [`user/user-aliases.el`](user/user-aliases.el)
- **Package additions**: Add packages to [`core/core-packages.el`](core/core-packages.el)
- **Key bindings**: Extend [`user/user-keybindings.el`](user/user-keybindings.el)

### Q: Can I override default settings?

**A:** Yes, you can override settings in several ways:
- **Modify configuration files**: Edit existing modules to change defaults
- **Add local configuration**: Create additional files in the [`user/`](user/) directory
- **Use hooks**: Add customizations via mode hooks
- **Override variables**: Set variables after package loading

### Q: How do I add support for a new programming language?

**A:** To add language support:
1. **Create language module**: Add a new file in the [`lang/`](lang/) directory
2. **Configure packages**: Add language-specific packages and configuration
3. **Load module**: Add the new module to [`init.el`](init.el)
4. **Follow conventions**: Use the style from existing language modules

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for detailed guidelines.

### Q: How do I add local configuration that won't be committed to git?

**A:** Use the optional configuration files for local, machine-specific settings:
- **`~/.emacs.d/local.el`**: Hand-written local configuration that loads after all main config
- **`~/.emacs.d/custom.el`**: Settings from Emacs' customize system (automatically created)

Both files are automatically loaded if they exist and can override any main configuration settings. See [`configs/`](configs/) for detailed templates and documentation.

### Q: Can I use a different completion framework?

**A:** While the configuration is optimized for [Corfu](https://github.com/minad/corfu), you can switch to alternatives:
- **Disable Corfu**: Comment out the corfu configuration in [`features/completion-config.el`](features/completion-config.el)
- **Add alternative**: Configure your preferred completion framework
- **Test thoroughly**: Ensure LSP integration works with your chosen framework

## Troubleshooting

### Q: What should I do if something doesn't work?

**A:** Follow this troubleshooting sequence:
1. **Check the Messages buffer**: Look for error messages and warnings
2. **Verify requirements**: Ensure all dependencies are installed
3. **Test in isolation**: Try the problematic feature in isolation
4. **Consult documentation**: Check [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) for specific issues
5. **Start with minimal config**: Test with `emacs -Q` to isolate issues

### Q: How do I reset the package system if it's having issues?

**A:** The configuration uses a package metadata cache that can be safely reset:

**Quick Reset** (most common solution):
```bash
rm ~/.emacs.d/local/package-metadata.el
```
This file stores package catalog timestamps and counts. Deleting it forces fresh repository downloads on next startup.

**Full Package Reset** (for persistent issues):
```bash
rm ~/.emacs.d/local/package-metadata.el
rm -rf ~/.emacs.d/local/elpa/
```
This removes both the cache and all installed packages, forcing a complete reinstall.

**What the cache contains:**
- **Repository refresh timestamps**: When catalogs were last downloaded from MELPA, GNU ELPA, etc.
- **Package count**: Number of available packages in the cached catalog
- **Performance optimization**: Avoids unnecessary network calls during startup

Both reset methods are completely safe - all files will be automatically recreated when Emacs restarts.

### Q: How do I report bugs or request features?

**A:** When reporting issues:
1. **Reproduce the issue**: Ensure you can consistently reproduce the problem
2. **Gather information**: Include OS and error messages (Emacs 30.2+ required)
3. **Check existing issues**: Search for similar reported problems
4. **Provide context**: Include relevant configuration details
5. **Follow guidelines**: See [`CONTRIBUTING.md`](CONTRIBUTING.md) for contribution guidelines

### Q: Can I get help with specific problems?

**A:** Several resources are available:
- **Documentation**: Check all documentation files for guidance
- **Error messages**: Use `M-x toggle-debug-on-error` for detailed error information
- **Community help**: Consider asking in Emacs community forums or channels
- **Self-diagnosis**: Use built-in Emacs diagnostic tools

## Getting More Help

If your question isn't answered here:
1. **Search the documentation**: Use your browser's search function across all documentation files
2. **Check configuration comments**: Many modules include inline documentation
3. **Explore the code**: The modular structure makes it easy to understand specific features
4. **Test incrementally**: Load modules individually to understand their behavior

## Related Documentation

**For Setup Issues:**
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Detailed solutions for common problems
- [`README.md`](README.md) - Installation and setup instructions

**For Development:**
- [`FEATURES.md`](FEATURES.md) - Complete feature documentation
- [`KEYMAP.md`](KEYMAP.md) - Keybinding reference and commands
