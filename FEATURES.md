# Emacs Configuration Features

This document provides comprehensive details about all features available in this Emacs configuration, targeting Emacs 30.2+ exclusively with modern language-specific enhancements.

## Table of Contents

- [Modern Emacs 30.2+ Features](#modern-emacs-302-features)
- [Performance Optimizations](#performance-optimizations)
- [Package Management](#package-management)
- [System Management](#system-management)
  - [Message Logging System](#message-logging-system)
  - [Font Management](#font-management)
- [Auto-Completion System](#auto-completion-system)
- [Language Support](#language-support)
  - [Python Development Environment](#python-development-environment)
  - [Lisp/Elisp Development](#lispellisp-development)
  - [Makefile Development](#makefile-development)
  - [Markdown Support](#markdown-support)
  - [TOML Configuration](#toml-configuration)
  - [YAML Configuration](#yaml-configuration)
- [Code Style and Standards](#code-style-and-standards)
- [User Interface Enhancements](#user-interface-enhancements)
  - [Theme System](#theme-system)
  - [Project Navigation](#project-navigation)
  - [Directory Browsing (Dired)](#directory-browsing-dired)
  - [Startup Dashboard](#startup-dashboard)
  - [Navigation and Discovery](#navigation-and-discovery)
  - [Visual Improvements](#visual-improvements)
  - [Enhanced Diagnostics](#enhanced-diagnostics)
- [Related Documentation](#related-documentation)

## Modern Emacs 30.2+ Features

This configuration is designed exclusively for Emacs 30.2+ and utilizes specific modern features that are not available in earlier versions:

### Core Modern Dependencies

**Native Compilation Enhancements**:
- **Improved bytecode generation**: Faster package loading and runtime execution
- **Automatic optimization**: Transparent performance improvements for all loaded packages
- **Memory efficiency**: Reduced memory footprint through optimized compiled code
- **Startup acceleration**: Native compilation cache reduces initialization time

**Built-in Use-Package Integration**:
- **Modern lazy-loading**: Advanced deferred loading mechanisms not available in earlier versions
- **Enhanced error handling**: Improved package failure recovery and diagnostics
- **Configuration validation**: Built-in syntax checking for package declarations

### Performance Features

**Advanced Garbage Collection** ([`core/core-constants.el`](core/core-constants.el)):
- **Dynamic thresholds**: 8MB for normal operation, 200MB during long development sessions
- **Modern GC algorithms**: Leveraging Emacs 30.2+ garbage collection improvements
- **Session-aware tuning**: Automatic adjustment based on usage patterns
- **Memory pressure handling**: Intelligent collection scheduling during intensive operations

**LSP and Development Optimizations**:
- **Real-time diagnostics**: Improved Flymake integration with immediate error display
- **Process optimization**: Better subprocess management for development tools

### User Interface Enhancements

**Modern Display Features** ([`core/ui.el`](core/ui.el)):
- **Enhanced line numbers**: `global-display-line-numbers-mode` with visual line support and performance improvements
- **Advanced theming**: Native support for modern color schemes and visual elements
- **Window management**: Enhanced split-window behavior and display management

**Interactive Features**:
- **Advanced completion**: Native completion-at-point improvements for better responsiveness
- **Modern help system**: Enhanced documentation display and interactive help
- **Improved which-key**: Better keybinding discovery with modern display capabilities

### Why These Features Matter

**For Daily Development**:
- **Faster workflow**: Reduced latency in code completion, diagnostics, and navigation
- **Better reliability**: Improved error handling prevents configuration crashes
- **Enhanced productivity**: Modern UI features reduce cognitive load

**Legacy Compatibility Note**: These features are not available through compatibility layers or workarounds in earlier Emacs versions. The configuration leverages native implementations that require the modern Emacs architecture introduced in 30.2+.

## Performance Optimizations

### Startup Performance
- **Early initialization** ([`early-init.el`](early-init.el)): Loaded before package.el and GUI initialization
- **Garbage collection tuning**: Temporarily disabled during startup for faster loading
- **Package management**: Controlled package loading and initialization order
- **File handler optimization**: Temporary disabling of file name handlers during startup

### Runtime Performance
- **Intelligent GC management**: Automatic threshold adjustment based on session length
- **Deferred loading**: Optional packages loaded only when needed
- **Native compilation support**: Automatic utilization when available

### Package Management Performance
- **Intelligent package caching**: Package catalog metadata cached in `~/.emacs.d/local/package-metadata.el`
- **Repository refresh optimization**: Only downloads catalogs when needed, avoiding unnecessary network calls
- **Fast startup**: Skips package refresh during startup when recent cache exists
- **Safe cache reset**: Delete `~/.emacs.d/local/package-metadata.el` to force fresh repository downloads

## Package Management

Interactive package management commands for browsing, updating, and maintaining installed packages:

**Features** ([`core/core-packages.el`](core/core-packages.el)):
- **Package Browser**: View all installed packages with status and version information
- **Update Checking**: Automatic weekly update checks with manual override option
- **Package Search**: Search for packages by name or keyword across repositories
- **Cleanup Utilities**: Remove unused package dependencies and reset metadata cache

**Interactive Commands:**

**`M-x show-installed-packages`** ([`core/core-packages.el:148-244`](core/core-packages.el)):
- **Comprehensive package listing** showing all installed packages with status labels
- **Update availability indicator** (`*` marker) for packages with available updates
- **Clear status labels**: "Installed (by User)" vs "Dependency" for easy identification
- **One-click updates**: `[Update All]` button when updates are available
- **Detailed columns**: Package name, installed version, update status, and description
- **Sorted display**: Alphabetically sorted for easy navigation

**`M-x search-packages`** ([`core/core-packages.el:246-252`](core/core-packages.el)):
- **Keyword-based search** across all available package repositories
- **Interactive results**: Browse and install packages directly from search results
- **Repository coverage**: Searches MELPA, GNU ELPA, and all configured repositories

**`M-x show-package-upgrades`** ([`core/core-packages.el:278-309`](core/core-packages.el)):
- **Manual update check** on demand (bypasses weekly automatic check)
- **Detailed upgrade information**: Shows current version → new version for each package
- **Repository diagnostics**: Confirms successful contact with all package repositories
- **Network-aware**: Includes timeout protection and error handling
- **Usage instructions**: Provides next steps for installing updates via `package-list-packages`

**`M-x core-packages-cleanup`** ([`core/core-packages.el:316-361`](core/core-packages.el)):
- **Automatic dependency removal**: Uses built-in `package-autoremove` to clean orphaned packages
- **Metadata cache reset**: Clears package metadata for fresh repository state
- **Safe operation**: Auto-accepts removal prompts for streamlined cleanup
- **Status reporting**: Shows count of removed packages and cleanup results
- **Error handling**: Graceful failure recovery with detailed error messages

**Automatic Update Checking:**
- **Weekly schedule**: Automatically checks for updates once per week during interactive sessions
- **Persistent tracking**: Stores last check timestamp in `~/.emacs.d/local/package-metadata.el`
- **Non-disruptive**: Notifies about available updates without installing them
- **Network-aware**: Only runs when network connectivity is available
- **Timeout protection**: 30-second timeout prevents hanging on slow connections
- **User control**: Manual installation required for all updates (prevents surprise breakage)

**Benefits:**
- **Stay informed**: Know when package updates are available without manual checking
- **Maintain stability**: Review and approve updates before installation
- **Easy maintenance**: One-command cleanup for unused dependencies
- **Clear visibility**: Understand package status and update availability at a glance

## System Management

### Message Logging System

Automatic message logging with rotation for session history and debugging:

**Features** ([`core/logging.el`](core/logging.el)):
- **Automatic log saving** on Emacs exit to preserve session messages
- **Log rotation** with configurable file retention (default: 5 files)
- **Timestamped entries** with session end markers for debugging
- **Organized storage** in `<emacs-local-dir>/log/` directory with automatic creation
- **Error handling** with graceful fallbacks for filesystem issues

**Log Management:**
- **Primary log**: `<emacs-local-dir>/log/messages.log` - current session messages
- **Rotated logs**: `messages.log.1`, `messages.log.2`, etc. - previous sessions
- **Automatic cleanup** removes oldest logs when exceeding retention limit
- **Session markers** help identify different Emacs sessions in logs

**Benefits:**
- **Debugging support** - preserve error messages and warnings across sessions
- **Development tracking** - maintain history of configuration changes and issues
- **Performance analysis** - review startup timing and load messages
- **Troubleshooting** - access complete message history for problem diagnosis

### Font Management

Automatic system-wide font installation for icon packages:

**Features** ([`core/core-fonts.el`](core/core-fonts.el)):
- **Automatic font installation** for [nerd-icons](https://github.com/rainstormstudio/nerd-icons.el) package
- **System-wide availability** installs fonts to `~/.local/share/fonts/` (Linux) or `~/Library/Fonts/` (macOS)
- **Cross-application support** fonts available to terminals, browsers, and other applications
- **Fast verification** uses file-based checks instead of slow font system queries
- **Automatic detection** only installs fonts when packages are present and fonts missing

**Supported Font Packages:**
- **nerd-icons fonts (NFM.ttf)** - Nerd Font symbols for enhanced terminal and GUI display
- **Platform detection** automatically uses correct font directory for your system

**Font Installation Process:**
1. **Package verification** - checks if icon packages are installed
2. **Font detection** - fast file-based check for existing fonts
3. **Automatic installation** - downloads and installs missing fonts
4. **System integration** - fonts immediately available to all applications
5. **Terminal compatibility** - configure your terminal to use installed fonts manually

**Benefits:**
- **Zero configuration** - fonts installed automatically when needed
- **Cross-application icons** - use the same icons in terminal, IDE, and browser
- **Development workflow** - enhanced file explorers and project managers with consistent icons
- **Visual consistency** - unified icon experience across your development environment

## Auto-Completion System

### Universal Completion Framework
Powered by [Corfu](https://github.com/minad/corfu) for comprehensive auto-completion across all file types:

**Features:**
- **Automatic completion** appears after typing 1 character (200ms delay)
- **Smart `TAB` behavior** - completes when possible, indents otherwise
- **Terminal mode support** - full Corfu functionality in both GUI and terminal environments
- **Intelligent documentation display**:
  - **GUI mode**: Documentation popups via `corfu-popupinfo` with child frames
  - **Terminal mode**: Documentation in echo area via `corfu-echo`
  - **Responsive feedback**: 0.1s documentation delay
  - **Documentation controls** (GUI): `M-d` (toggle), `M-n`/`M-p` (scroll)
- **Completion type icons** via `kind-icon` for visual identification
- **Multiple trigger options**:
  - `TAB` - Smart completion/indentation
  - `C-c TAB` - Manual completion trigger (reliable in all environments)
  - `M-TAB` - Traditional Alt+TAB completion
  - `C-M-i` - Traditional Ctrl+Alt+i completion

**Completion Sources:**
- LSP servers for intelligent code completion
- Built-in Emacs completion functions
- Mode-specific completion backends
- Context-aware suggestions based on file type

## Language Support

### Python Development Environment

Comprehensive Python development setup with intelligent environment management:

#### Core Features
- **Automatic virtual environment detection and activation** using [pyvenv](https://github.com/jorgenschaefer/pyvenv) ([`lang/python/pyvenv-config.el`](lang/python/pyvenv-config.el))
- **Remote development support** with [TRAMP](https://www.gnu.org/software/emacs/manual/html_node/tramp/) integration for SSH-based Python projects ([`lang/python/pyvenv-remote.el`](lang/python/pyvenv-remote.el))
- **Enhanced modeline display** showing active virtual environment and `python` version with optional color customization
- **Project-aware environment switching** with automatic detection for both local and remote files

#### Virtual Environment Management
**Automatic Detection** ([`lang/python/pyvenv-config.el`](lang/python/pyvenv-config.el)):
- Detects `venv/` directories in project roots
- Project root determined by `.git/`, `pyproject.toml`, or `requirements.txt`
- Automatic activation when opening Python files
- Python version detection and display

**Remote Development** ([`lang/python/pyvenv-remote.el`](lang/python/pyvenv-remote.el)):
- **TRAMP-aware virtual environment detection** for SSH-based remote development
- **Seamless remote project support** using [TRAMP connection-local variables](https://www.gnu.org/software/emacs/manual/html_node/tramp/Connection-local-variables.html)
- **Fallback detection** to local equivalent when remote virtual environment not found
- **Unified modeline display** showing remote virtual environment status
- **Pre-configured remote paths** automatically searches common Python installation locations ([`lang/python/python-constants.el`](lang/python/python-constants.el))
- **Optimized environment variables** for Python development over TRAMP connections

**Manual Control:**
- `M-x pyvenv-activate` - Manually activate a virtual environment
- `M-x pyvenv-deactivate` - Deactivate current virtual environment
- `M-x pyvenv-workon` - Switch to a different virtual environment

#### Virtual Environment Display

**Default pyvenv Modeline Indicator**:
- Uses pyvenv's built-in `[ venvname ]` modeline indicator
- Automatically appears when a virtual environment is activated
- Clean, simple display without custom formatting

#### Development Tools
- **Advanced Python Linting** via [flymake-ruff](https://github.com/erickgnavar/flymake-ruff) integration ([`lang/python/flymake-ruff-config.el`](lang/python/flymake-ruff-config.el))
  - **Real-time error detection** using [Ruff](https://github.com/astral-sh/ruff) - the fastest Python linter
  - **Custom diagnostics buffer** with enhanced column layout for better error analysis
  - **Error code extraction** - separate "Code" column showing rule identifiers (F401, I001, E402, etc.)
  - **User-friendly backend names** - "Ruff" instead of cryptic internal identifiers
  - **Comprehensive rule coverage** - style, imports, complexity, and syntax checking
  - **Optimized performance** - single backend configuration eliminates duplicate diagnostics
- Basic code navigation and editing features

**Enhanced Diagnostics Display:**
- **Custom Column Layout**: Line, Col, Type, Code, Backend, Message
- **Sortable columns** for efficient error prioritization
- **Error code identification** for quick rule lookup and configuration
- **Clean, professional interface** replacing cryptic backend identifiers

### Lisp/Elisp Development

Enhanced support for Lisp programming with comprehensive development tools:

**Features** ([`lang/lisp-config.el`](lang/lisp-config.el)):
- **Intelligent completion** for functions, variables, and macros
- **Enhanced evaluation** with inline result display for Emacs Lisp development
- **Auto-formatting** via [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt) integration

### Makefile Development

Professional [Makefile](https://www.gnu.org/software/make/manual/make.html) editing support with intelligent features:

**Features** ([`lang/makefile-config.el`](lang/makefile-config.el)):
- **Smart indentation** respecting Makefile tab requirements
- **Target completion** and navigation
- **Variable highlighting** and substitution awareness
- **Make command integration** for rapid build testing

### Markdown Support

Enhanced [Markdown](https://daringfireball.net/projects/markdown/) editing for documentation and content creation using [markdown-mode](https://github.com/jrblevin/markdown-mode):

**Features** ([`lang/markdown-config.el`](lang/markdown-config.el)):
- **Syntax highlighting** with [GitHub Flavored Markdown](https://github.github.com/gfm/) support
- **Live preview** capabilities (when markdown processors are available)
- **Table editing** assistance
- **Header navigation** and structure management

### TOML Configuration

Comprehensive [TOML](https://toml.io/) support for modern configuration management using [toml-mode](https://github.com/dryman/toml-mode.el):

**Features** ([`lang/toml-config.el`](lang/toml-config.el)):
- **Syntax highlighting** for TOML configuration files
- **Project integration** with `pyproject.toml` support
- **Structure validation** with error highlighting
- **Auto-completion** for common TOML keys and values

### YAML Configuration

Specialized handling for [YAML](https://yaml.org/) files with structure-aware features using [yaml-mode](https://github.com/yoshiki/yaml-mode):

**Features** ([`lang/yaml-config.el`](lang/yaml-config.el)):
- **Structure-aware completion** for YAML hierarchies
- **Indentation management** (2 spaces, [YAML standard](https://yaml.org/))
- **Syntax highlighting** with nested structure visualization
- **Auto-indent on newline** for consistent formatting

## Code Style and Standards

### Automated Formatting
This configuration enforces consistent code style through automated tools:

**[elisp-autofmt](https://github.com/emacsmirror/elisp-autofmt) Integration:**
- **Automatic formatting on save** for Emacs Lisp files
- **Manual formatting** via `C-c C-f` keybinding
- **Native Emacs style** using built-in indentation rules
- **Pre-commit integration** for quality assurance

**Standards Compliance:**
- **[GNU Emacs Lisp conventions](https://www.gnu.org/software/emacs/manual/html_node/elisp/Tips.html)** for all configuration files
- **Consistent file organization** and naming conventions
- **Standardized file headers** and documentation format
- **Automated quality checks** via [`pre-commit`](https://github.com/pre-commit/pre-commit) hooks

For detailed style guidelines, see [`STYLEGUIDE.md`](STYLEGUIDE.md).

## User Interface Enhancements

### Theme System

Advanced theme management powered by [Doom Themes](https://github.com/doomemacs/themes) with dynamic discovery and interactive browsing:

**Features** ([`themes/themes-config.el`](themes/themes-config.el)):
- **Default Theme**: `doom-zenburn` - classic zenburn theme with excellent terminal compatibility
- **Dynamic Discovery**: Automatically finds all 68+ available doom themes at runtime
- **Interactive Browser**: Dedicated theme testing interface with live preview
- **Terminal Compatibility**: Automatic adjustments for terminal vs GUI environments
- **Persistent Selection**: Automatically saves and remembers your theme preference
- **Local Customization**: Override themes in `local.el` for personal preferences

**Theme Selection Methods**:
- **`M-x switch-theme`**: Quick selection with tab completion from all available themes
- **`M-x list-themes`**: Interactive browser for testing multiple themes (recommended)

**Interactive Theme Browser Features**:
- **Live Testing**: Apply themes instantly without closing the browser
- **Visual Navigation**: Arrow keys to browse, Enter to apply, q to quit
- **Current Theme Indicator**: Shows active theme with `->` marker
- **Persistent Browser**: Stay open for easy theme comparison and testing
- **Full Collection**: Access to all 68+ doom themes plus additional options

**Available Themes** (Dynamically Discovered):
- **68+ Doom Themes**: Complete collection including `doom-zenburn`, `doom-1337`, `doom-acario-dark`, `doom-ayu-dark`, etc.
- **Popular Choices**: `doom-zenburn` (default), `doom-1337`, `doom-Iosvkem`, `doom-gruvbox`, `doom-material-dark`, `doom-monokai-machine`
- **Terminal-Optimized**: `doom-zenburn` (default), `doom-1337`, `doom-gruvbox`, `doom-material-dark`, `doom-tomorrow-night`
- **Built-in Fallbacks**: `wombat`, `tango-dark`, `leuven` for system compatibility

**Customization** ([`configs/local.el`](configs/local.el)):
```elisp
;; Set your preferred theme in local.el to override the default doom-zenburn
(setq user-preferred-theme 'doom-1337)  ; Example override from configs/local.el

;; Theme-specific customizations
(setq user-theme-customizations
      '((doom-zenburn . ((doom-themes-enable-bold . t)))))
```

**Why Doom Themes?**
- **Professional Quality**: Carefully crafted color schemes designed for long coding sessions
- **Comprehensive Coverage**: Support for all major programming languages and modes
- **Active Maintenance**: Regular updates and community support
- **Performance**: Optimized for both GUI and terminal environments

### Project Navigation

Comprehensive project management and file tree navigation:

**[Treemacs](https://github.com/Alexander-Miller/treemacs) Integration** ([`features/treemacs-config.el`](features/treemacs-config.el)):
- **File tree sidebar** with project structure visualization and git integration
- **Smart theming** - uses `Default` theme by default, customizable via `local.el`
- **Project management** with automatic root detection and directory navigation
- **Git integration** shows file status and changes directly in the tree
- **Intelligent display** with collapsible directories and sorting options

**Key Features:**
- **F4 toggle** - smart treemacs toggle that opens, closes, or switches focus
- **Project following** - automatically tracks current file location in tree
- **File watching** - real-time updates when files change on disk
- **Workspace persistence** - remembers project layout between sessions
- **Dired integration** - enhanced directory browsing with icons (GUI mode only)

**Navigation Keybindings:**
- **F4** - Toggle treemacs sidebar (smart focus management)
- **C-x t t** - Open treemacs
- **C-x t C-t** - Find current file in treemacs
- **C-x t 1** - Delete other windows, keep treemacs

**Display Optimization:**
- **Terminal compatibility** - uses text-based Default theme for maximum compatibility
- **GUI enhancement** - leverages nerd-icons for rich visual experience
- **Performance tuning** - optimized refresh rates and minimal resource usage
- **Responsive design** - adapts to window size changes and split configurations

### Directory Browsing (Dired)

Enhanced file and directory management with inline tree expansion and icon support:

**[Dired](https://www.gnu.org/software/emacs/manual/html_node/emacs/Dired.html) Enhancements** ([`features/dired-config.el`](features/dired-config.el)):
- **Inline tree expansion** via [dired-subtree](https://github.com/Fuco1/dired-hacks) package
- **File-type icons** via [nerd-icons-dired](https://github.com/rainstormstudio/nerd-icons-dired) package
- **Smart defaults** for recursive operations and auto-refresh
- **Human-readable sizes** in directory listings

**Dired Subtree Features:**
- **Inline directory expansion** - expand directories without opening new buffers
- **Tree-like navigation** - visual hierarchy showing nested directory structure
- **Quick toggle** - press `i` on any directory to expand/collapse inline
- **Depth cycling** - use `TAB` to cycle through expansion depths
- **Clean interface** - no buffer clutter, everything in one dired buffer

**Icon Support:**
- **Automatic icons** - file-type specific icons appear automatically in dired buffers
- **Terminal and GUI** - works in both modes when terminal uses a Nerd Font
- **Font requirement** - terminal emulator needs Nerd Font configuration for icon display
- **Visual file types** - instantly identify files by type (code, config, images, etc.)

**Enhanced Dired Settings:**
- **Smart target suggestions** - suggests visible dired buffers for copy/move operations
- **Recursive operations** - always copies directories recursively without asking
- **Auto-refresh** - dired buffers update automatically when files change
- **Buffer management** - kills old dired buffer when opening new one (cleaner workflow)

**Keybindings:**
- **`i`** - Toggle inline subtree expansion/collapse for directory under cursor
- **`TAB`** - Cycle subtree expansion depth (collapsed → 1 level → 2 levels → ...)
- **Standard dired keys** - all normal dired operations still available

**Terminal Font Setup for Icons:**

For icon display in terminal mode, configure your terminal to use a Nerd Font:

```bash
# macOS (iTerm2/Terminal.app)
brew install font-fira-code-nerd-font
# Then: iTerm2 → Preferences → Profiles → Text → Font → "FiraCode Nerd Font Mono"

# Linux (download from https://www.nerdfonts.com/)
# Extract to ~/.local/share/fonts/ and run:
fc-cache -fv
```

**Without a Nerd Font in your terminal, icons will appear as empty boxes.**

### Startup Dashboard

Professional startup screen with quick access to recent files, package management, and system actions:

**[Dashboard](https://github.com/emacs-dashboard/emacs-dashboard) Features** ([`features/dashboard-config.el`](features/dashboard-config.el)):
- **Welcome screen** - displays on Emacs startup with branding and navigation
- **Recent files** - quick access to last 5 recently opened files
- **Bookmarks** - access to saved file bookmarks (last 5)
- **Icon navigation** - clickable buttons with Nerd Font icons for common actions
- **System information** - startup time and initialization details

**Dashboard Navigation Buttons:**
- **Home** - browse dashboard homepage (documentation)
- **Restart** - restart Emacs session
- **Update** - check for package updates (`show-package-upgrades`)
- **Installed Packages** - view all installed packages (`show-installed-packages`)
- **Search Packages** - search for new packages (`search-packages`)
- **Package Cleanup** - remove unused packages and reset cache (`core-packages-cleanup`)
- **Settings** - open `init.el` configuration file
- **Quit** - exit Emacs with save prompts

**Display Features:**
- **Centered content** - professional centered layout
- **Icon support** - uses Nerd Icons for visual navigation
- **Smart startup** - appears on launch, doesn't interfere with file opening
- **Keyboard accessible** - navigate buttons with `TAB` and `RET`

**Benefits:**
- **Quick navigation** - one-click access to common operations
- **Package management** - integrated package maintenance without memorizing commands
- **Recent files** - fast access to working files
- **Professional appearance** - polished startup experience

### Navigation and Discovery

- **[Breadcrumb Navigation](https://github.com/joaotavora/breadcrumb)** ([`features/breadcrumbs-config.el`](features/breadcrumbs-config.el)): Hierarchical navigation showing file path and code structure in the header line
  - **Always visible** - enabled globally via `breadcrumb-mode`
  - **Dual navigation** - shows both file system path and code structure (via imenu)
  - **Terminal-optimized colors** - custom color scheme for enhanced readability
  - **Visual hierarchy** - distinct colors for project base, path components, and current location
  - **Code structure display** - shows current function/class context with bright highlighting

- **[Which-Key](https://github.com/justbur/emacs-which-key)** ([`core/core-packages.el`](core/core-packages.el)): Interactive keybinding discovery system that displays available key combinations in popup windows
  - **0.3-second delay** for faster response than default settings
  - **40 character descriptions** with improved readability
  - **Smart column padding** and arrow separators (" → ")
  - **Automatic mode detection** showing context-appropriate keybindings

- **[Imenu-List](https://github.com/bmag/imenu-list)** ([`features/imenu-list-config.el`](features/imenu-list-config.el)): Symbol navigation sidebar for code structure visualization
  - **Toggle sidebar** with `F5` or `C-c i l` for quick access
  - **Real-time symbol updates** showing functions, classes, and variables
  - **Interactive navigation** with dedicated sidebar keybindings
  - **Project structure overview** for large codebases
  - **Auto-refresh** when switching between files and buffers

### Visual Improvements
- **[Rainbow Delimiters](https://github.com/Fanael/rainbow-delimiters)** ([`features/rainbow-delimiters-config.el`](features/rainbow-delimiters-config.el)): Enhanced delimiter visibility with color coding
- **[Indent Guides](https://github.com/DarthFennec/highlight-indent-guides)** ([`features/indent-guides.el`](features/indent-guides.el)): Visual indentation guides for better code structure
- **Theme Support** ([`themes/themes-config.el`](themes/themes-config.el)): [Doom Themes](https://github.com/doomemacs/themes) with doom-zenburn default and terminal compatibility

### Enhanced Diagnostics

- **[Flymake Integration](https://www.gnu.org/software/emacs/manual/html_mono/flymake.html)** ([`features/flymake-config.el`](features/flymake-config.el), [`features/flymake-utils.el`](features/flymake-utils.el)): Real-time syntax checking and linting
  - **Enhanced diagnostics buffer** with user-friendly backend names
  - **Intelligent backend mapping** - Ruff, Eglot, and other checkers displayed clearly
  - **Diagnostics window toggle** via `F1` for quick access
  - **Navigation shortcuts** - `F2`/`F3` for previous/next error

- **[Eglot LSP Client](https://github.com/joaotavora/eglot)** ([`features/eglot-config.el`](features/eglot-config.el)): Language Server Protocol integration for intelligent code features
  - **Automatic LSP detection** - enables LSP when server executables are found
  - **Local and remote support** - seamless TRAMP integration for SSH-based development
  - **Supported languages**:
    - **Python**: `pylsp` ([python-lsp-server](https://github.com/python-lsp/python-lsp-server))
      - Base installation: `pip install python-lsp-server`
      - Recommended plugin: `pip install python-lsp-ruff` (integrates ruff linting into LSP)
    - **C/C++**: `clangd`
  - **Smart connection handling** - 60-second timeout for remote connections
  - **Informative logging** - shows LSP command availability checks for debugging
  - **Automatic mode hooks** - LSP activates automatically for configured languages

- **System Diagnostics** ([`core/diagnostics.el`](core/diagnostics.el)): OS detection, startup logging, and configuration diagnostics

- **Performance Monitoring**: Load time tracking for configuration modules with detailed startup information

## Related Documentation

**For Using These Features:**
- [`KEYMAP.md`](KEYMAP.md) - Complete keybinding reference for all features
- [`FAQ.md`](FAQ.md) - Common questions about feature usage

**For Setup and Issues:**
- [`README.md`](README.md) - Installation and requirements
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Feature-specific troubleshooting
