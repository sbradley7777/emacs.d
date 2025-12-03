# Emacs Configuration Keymap

This document provides a comprehensive reference for all keybindings and executable commands available in this Emacs configuration, covering both general Emacs operations and language-specific development features.

## Table of Contents

- [How to Use This Guide](#how-to-use-this-guide)
- [Keybindings](#keybindings)
  - [Function Keys](#function-keys)
  - [Special Keys](#special-keys)
  - [Code Completion (Corfu)](#code-completion-corfu)
  - [Essential Emacs Operations](#essential-emacs-operations)
  - [Which-Key System](#which-key-system)
  - [Custom Navigation](#custom-navigation)
  - [Imenu-List Navigation](#imenu-list-navigation)
  - [Treemacs Project Navigation](#treemacs-project-navigation)
  - [Dired Directory Browsing](#dired-directory-browsing)
  - [Command Palette](#command-palette)
  - [Language-Specific Keybindings](#language-specific-keybindings)
  - [Code Formatting](#code-formatting)
  - [Diagnostic and Error Checking](#diagnostic-and-error-checking)
- [Functions](#functions)
  - [Virtual Environment Management](#virtual-environment-management)
  - [Package Management](#package-management)
  - [Git Integration](#git-integration)
  - [Theme Management](#theme-management)
- [Related Documentation](#related-documentation)

## How to Use This Guide

### Key Notation
- **`C-`** means hold `Ctrl` key (e.g., `C-a` = `Ctrl`+`a`)
- **`M-`** means hold `Alt`/`Meta` key (e.g., `M-.` = `Alt`+`.`)
- **`S-`** means hold `Shift` key (e.g., `S-TAB` = `Shift`+`Tab`)
- **Multiple keys:** Press in sequence (e.g., `C-c` `TAB` = `Ctrl`+`c`, then `Tab`)

### Context Information
- **Context-dependent:** Some keys behave differently based on what's active
- **`-`** in "Context" column represents always available (no specific context required)

### Commands Without Keybindings
For functions without keybindings, use `M-x function-name` (hold `Alt`+`x`, then type the function name).

### Understanding Output Symbols
This configuration uses visual symbols in messages and output (like ✅, 🔄, ❌). For a complete reference of these symbols and their meanings, see [`STYLEGUIDE.md`](STYLEGUIDE.md#message-symbol-reference).

## Keybindings

This section contains all commands that have keyboard shortcuts assigned. These keybindings allow you to quickly access functionality without having to type command names. Each keybinding shows the key combination to press and describes what action it performs.

**How to use keybindings**:
- Press the key combinations as shown (e.g., `C-x C-f` means hold Ctrl, press x, release, then hold Ctrl and press f)
- Most keybindings work immediately when you press them
- Some are context-dependent and only work in specific modes or situations

**Example to try**: Press `F1` to toggle the Flymake diagnostics window, `F4` to toggle the Treemacs file tree, or `F5` to toggle the imenu-list sidebar.

## Function Keys

These are configuration-specific shortcuts designed for quick access to common operations:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `F1` | `toggle-flymake-diagnostics-window` | Toggle Flymake diagnostics window | - |
| `F2` | `flymake-goto-prev-error` | Go to previous flymake error | Flymake active |
| `F3` | `flymake-goto-next-error` | Go to next flymake error | Flymake active |
| `F4` | `toggle-treemacs-window` | Smart toggle Treemacs file tree sidebar | - |
| `F5` | `toggle-imenu-list-window` | Toggle imenu-list sidebar | - |
| `F6` | `delete-trailing-whitespace` | Clean up line endings | - |
| `F7` | `user-previous-buffer` | Switch to previous buffer (file buffers and *Messages* only) | - |
| `F8` | `next-buffer` | Switch to next buffer | - |
| `F9` | `command-palette-toggle` | Toggle command palette side window | - |
| `F10` | `end-of-buffer` | Jump to file end | - |
| `F11` | Smart scroll down | Scroll with boundary handling | - |
| `F12` | Smart scroll up | Scroll with boundary handling | - |

## Special Keys

Additional keyboard mappings for improved functionality:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `Delete` | `delete-char` | Delete character under cursor | - |
| `Keypad Delete` | `delete-char` | Delete character under cursor | - |

## Code Completion (Corfu)

Intelligent auto-completion powered by [Corfu](https://github.com/minad/corfu) with full terminal support:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C-c` `TAB` | `completion-at-point` | Manually trigger completion | Always |
| `M-TAB` | `completion-at-point` | Alternative completion trigger | Always |
| `C-M-i` | `completion-at-point` | Traditional completion trigger | Always |
| `TAB` | `python-indent-line-function` | Auto-indent line | Normal editing |
| `S-TAB` | `corfu-previous` | Navigate to previous candidate | Popup active |
| `S-TAB` | `python-dedent-line-function` | Decrease indentation | Normal editing |
| `RET` | `corfu-insert` | Accept selected completion | Popup active |
| `M-d` | `corfu-popupinfo-toggle` | Toggle documentation popup | Popup active (GUI only) |
| `M-n` | `corfu-popupinfo-scroll-up` | Scroll documentation down | Popup active (GUI only) |
| `M-p` | `corfu-popupinfo-scroll-down` | Scroll documentation up | Popup active (GUI only) |

**Documentation Display:**
- **GUI mode**: Documentation appears in child frame popups (via `corfu-popupinfo`)
- **Terminal mode**: Documentation appears in echo area/minibuffer (via `corfu-echo`)
- **Delay**: Documentation appears after 0.1 seconds

## Essential Emacs Operations

Core Emacs commands for file management and text editing:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C-x` `C-f` | `find-file` | Open file browser to select file | - |
| `C-x` `C-s` | `save-buffer` | Save current file to disk | - |
| `C-x` `b` | `switch-to-buffer` | Switch between open buffers | - |
| `C-s` | `isearch-forward` | Interactive search forward | - |
| `C-r` | `isearch-backward` | Interactive search backward | - |
| `M-%` | `query-replace` | Find and replace with confirmation | - |
| `C-w` | `kill-region` | Cut selected text | - |
| `M-w` | `kill-ring-save` | Copy selected text | - |
| `C-y` | `yank` | Paste text from kill ring | - |
| `C-/` | `undo` | Undo last action | - |

## Which-Key System

[Which-key](https://github.com/justbur/emacs-which-key) is an interactive keybinding discovery system that displays available key combinations in a popup window. This configuration has which-key enabled with a 0.3-second delay for faster response.

### How Which-Key Works

When you press a prefix key (like `C-x` or `C-c`), which-key automatically shows you all available completions after a short delay. This makes discovering and learning keybindings much easier.

### Basic Usage Examples

| Prefix Key | What Happens | Common Completions |
|:-----------|:-------------|:-------------------|
| `C-x` | Shows file and buffer operations | `C-f` (find-file), `C-s` (save), `b` (switch-buffer) |
| `C-c` | Shows mode-specific commands | `C-c` (compile/send-buffer), `C-r` (rename/send-region) |
| `M-g` | Shows goto and navigation commands | `n` (next-error), `p` (prev-error), `g` (goto-line) |
| `C-h` | Shows help system commands | `.` (local-help), `f` (describe-function), `k` (describe-key) |

### Interactive Discovery Process

1. **Start with a prefix:** Press any prefix key like `C-x`
2. **Wait briefly:** Which-key popup appears after 0.3 seconds
3. **Browse options:** See all available key combinations with descriptions
4. **Complete or cancel:** Press a key to execute, or `ESC`/`C-g` to cancel

### Common Which-Key Patterns

| Pattern | Description | Example |
|:--------|:------------|:--------|
| **File Operations** | `C-x` + file letter | `C-x C-f` (find), `C-x C-s` (save) |
| **Mode Commands** | `C-c` + function key | `C-c C-c` (compile), `C-c C-r` (rename) |
| **Navigation** | `M-g` + direction | `M-g n` (next), `M-g p` (previous) |
| **Help System** | `C-h` + help type | `C-h f` (function), `C-h k` (key) |

### Which-Key Configuration Details

This setup uses these which-key settings:
- **Delay:** 0.3 seconds (faster than default)
- **Description length:** 40 characters maximum
- **Separator:** " → " between key and description
- **Column padding:** 1 space for better readability

### Tips for Using Which-Key

- **Don't memorize everything:** Let which-key guide you to commands
- **Learn patterns:** Most modes follow similar `C-c` prefix conventions
- **Use help system:** `C-h` prefix shows extensive help options
- **Cancel safely:** `C-g` or `ESC` cancels any incomplete key sequence

## Custom Navigation

Additional navigation commands for efficient code browsing:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `ESC` `←` | `scroll-down` | Scroll buffer content down | - |
| `ESC` `→` | `scroll-up` | Scroll buffer content up | - |

## Imenu-List Navigation

Symbol navigation and outline sidebar powered by [imenu-list](https://github.com/bmag/imenu-list):

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `F5` | `toggle-imenu-list-window` | Toggle imenu-list sidebar | - |
| `C-c` `i` `l` | `toggle-imenu-list-window` | Toggle imenu-list sidebar (alternative) | - |
| `C-c` `i` `s` | `imenu-list-show-current-symbol` | Show current symbol in sidebar | - |
| `C-c` `i` `r` | `imenu-list-refresh` | Refresh symbol list | - |

### Imenu-List Sidebar Navigation

When the imenu-list sidebar is active, these keys work within the sidebar:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `RET` | `imenu-list-goto-entry` | Jump to selected symbol | Imenu sidebar |
| `TAB` | `hs-toggle-hiding` | Expand/collapse symbol groups | Imenu sidebar |
| `n` | `imenu-list-next-line` | Move to next symbol | Imenu sidebar |
| `p` | `imenu-list-prev-line` | Move to previous symbol | Imenu sidebar |
| `q` | `imenu-list-quit-window` | Close sidebar | Imenu sidebar |
| `r` | `imenu-list-refresh` | Refresh symbol list | Imenu sidebar |
| `f` | `imenu-list-find-symbol` | Find symbol in buffer | Imenu sidebar |
| `s` | `imenu-list-show-current-symbol` | Highlight current symbol | Imenu sidebar |

### Treemacs Project Navigation

Project file tree navigation powered by [Treemacs](https://github.com/Alexander-Miller/treemacs):

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `F4` | `toggle-treemacs-window` | Smart toggle Treemacs (open/close/focus) | - |
| `C-x` `t` `t` | `treemacs` | Open Treemacs sidebar | - |
| `C-x` `t` `C-t` | `treemacs-find-file` | Find current file in Treemacs | - |
| `C-x` `t` `1` | `treemacs-delete-other-windows` | Keep only Treemacs and current window | - |

#### Treemacs Sidebar Navigation

When the Treemacs sidebar is active, these keys work within the sidebar:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `RET` | Open file/expand directory | Open selected file or expand/collapse directory | Treemacs sidebar |
| `TAB` | Expand/collapse directory | Toggle directory expansion without opening | Treemacs sidebar |
| `o` | Open file in other window | Open file while keeping focus in Treemacs | Treemacs sidebar |
| `n` | Next line | Move to next item | Treemacs sidebar |
| `p` | Previous line | Move to previous item | Treemacs sidebar |
| `q` | Quit Treemacs | Close Treemacs sidebar | Treemacs sidebar |
| `w` | Set width | Change sidebar width | Treemacs sidebar |
| `r` | Refresh | Refresh current directory | Treemacs sidebar |
| `cf` | Create file | Create new file in current directory | Treemacs sidebar |
| `cd` | Create directory | Create new directory | Treemacs sidebar |
| `R` | Rename | Rename file or directory | Treemacs sidebar |
| `d` | Delete | Delete file or directory | Treemacs sidebar |
| `s` | Sort | Change sorting method | Treemacs sidebar |
| `h` | Show/hide hidden files | Toggle hidden file visibility | Treemacs sidebar |

### Dired Directory Browsing

Enhanced directory navigation with inline tree expansion powered by [dired-subtree](https://github.com/Fuco1/dired-hacks):

**Opening Dired:**
- `C-x C-f` then navigate to directory (standard Emacs file browser)
- `C-x d` - open dired for a specific directory

**Dired Subtree Extensions:**

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `i` | `dired-subtree-toggle` | Toggle inline directory expansion/collapse | Dired buffer |
| `TAB` | `dired-subtree-cycle` | Cycle subtree depth (collapsed → 1 level → 2 levels → ...) | Dired buffer |

**Standard Dired Navigation:**

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `RET` | Open file/directory | Open file or enter directory | Dired buffer |
| `^` | Go to parent directory | Navigate up one directory level | Dired buffer |
| `n` | Next line | Move to next file/directory | Dired buffer |
| `p` | Previous line | Move to previous file/directory | Dired buffer |
| `g` | Refresh | Reload directory listing | Dired buffer |
| `q` | Quit dired | Close dired buffer | Dired buffer |

**File Operations:**

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C` | Copy file | Copy file(s) to destination | Dired buffer |
| `R` | Rename/move file | Rename or move file(s) | Dired buffer |
| `D` | Delete file | Delete marked file(s) | Dired buffer |
| `+` | Create directory | Create new directory | Dired buffer |
| `m` | Mark file | Mark file for operations | Dired buffer |
| `u` | Unmark file | Remove mark from file | Dired buffer |
| `U` | Unmark all | Remove all marks | Dired buffer |

**Display Features:**
- **Icons**: File-type icons appear automatically (requires Nerd Font in terminal)
- **Inline trees**: Expand directories without opening new buffers
- **Human-readable sizes**: File sizes shown with KB/MB/GB units
- **Auto-refresh**: Directory updates automatically when files change

### Command Palette

Interactive command launcher with history tracking and customizable favorites powered by [command-palette.el](user/command-palette.el):

**Opening the Command Palette:**
- `F9` - Toggle command palette side window

**Command Palette Keybindings:**

When the command palette is active, these keys work within the palette window:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `F9` | `command-palette-toggle` | Toggle command palette window | - |
| `q` | Close palette | Close command palette window | Command palette |
| `a` | Promote to favorite | Promote recent command to favorites by index | Command palette |
| `r` | Remove favorite | Remove favorite command by index | Command palette |
| Mouse click | Execute command | Execute any command button | Command palette |

**Command Palette Features:**
- **Automatic M-x tracking** - all M-x commands captured in recent history
- **Clickable buttons** - mouse or keyboard navigation
- **Numbered commands** - easy visual scanning (1-9, 10-20, etc.)
- **Auto-close** - closes automatically after executing command
- **Persistent storage** - favorites and history saved between sessions
- **Mutual exclusion** - opening palette closes F1 (Flymake) and F5 (Imenu-list) windows

**Interactive Commands:**

These commands are available via button clicks in the palette:

| Action | Description |
|:-------|:------------|
| **Execute Favorite** | Click any numbered favorite command to run it |
| **Execute Recent** | Click any numbered recent command to run it |
| **Promote Recent to Favorite** | Click button or press 'a', then enter index number |
| **Remove Favorite** | Click button or press 'r', then enter index number |
| **Clear History** | Click button to reset recent commands list |
| **Close Palette** | Click button or press 'q' to close window |

**Default Favorite Commands:**
1. Show Installed Packages
2. Search Packages
3. Show Package Upgrades
4. List Themes
5. Pyvenv Activate
6. Pyvenv Deactivate
7. Pyvenv Workon
8. Run Python
9. Shell

**Tips:**
- Use the palette to discover commands you use frequently
- Promote useful commands from recent history to favorites
- The palette automatically sizes to fit content
- Recent history excludes commands already in favorites

## Language-Specific Keybindings

### Python Development

Python-specific editing and REPL interaction using built-in Python-mode:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C-c` `C-p` | `run-python` | Start Python REPL in dedicated buffer | Python files |
| `C-c` `C-c` | `python-shell-send-buffer` | Execute entire file in REPL | Python files |
| `C-c` `C-r` | `python-shell-send-region` | Execute selected region in REPL | Python files |
| `C-M-a` | `python-nav-backward-defun` | Jump to previous function/class | Python files |
| `C-M-e` | `python-nav-forward-defun` | Jump to next function/class | Python files |
| `C-M-u` | `python-nav-backward-up-list` | Move up one indentation level | Python files |

### Makefile Development

Makefile-specific keybindings for build system editing and compilation:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `TAB` | `makefile-tab` | Insert proper tab character (required for Makefile syntax) | Makefile mode |
| `C-c` `C-c` | `compile` (make) | Run make (compile) | Makefile mode |
| `C-c` `C-t` | `makefile-pickup-targets` | Refresh target list | Makefile mode |
| `C-c` `C-f` | `makefile-pickup-filenames-as-targets` | Add files as targets | Makefile mode |

### Markdown Support

Markdown-specific keybindings for documentation editing:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C-c` `C-c` | `markdown-command` | Preview markdown file | Markdown files |
| `C-c` `C-p` | `markdown-preview` | Live preview in browser | Markdown files |
| `C-c` `C-l` | `markdown-insert-link` | Insert markdown link | Markdown files |
| `C-c` `C-i` | `markdown-insert-image` | Insert markdown image | Markdown files |
| `C-c` `C-c` `b` | `markdown-insert-bold` | Insert bold formatting | Markdown files |
| `C-c` `C-c` `i` | `markdown-insert-italic` | Insert italic formatting | Markdown files |
| `C-c` `C-c` `c` | `markdown-insert-code` | Insert code formatting | Markdown files |

### TOML Configuration

TOML-specific keybindings for configuration file editing:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C-m` | `newline-and-indent` | Insert newline with proper TOML indentation | TOML files |

### YAML Development

YAML-specific keybindings for configuration file editing:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C-m` | `newline-and-indent` | Insert newline with proper YAML indentation | YAML files |

## Code Formatting

Automated code formatting commands using [elisp-autofmt](https://github.com/emacsmirror/elisp-autofmt):

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C-c` `C-f` | `elisp-autofmt-buffer` | Format Emacs Lisp buffer | Emacs Lisp files |

### Diagnostic and Error Checking

Built-in Emacs diagnostic tools (Flymake is built into Emacs):

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `F1` | `toggle-flymake-diagnostics-window` | Toggle diagnostics window | Flymake active |
| `F2` | `flymake-goto-prev-error` | Go to previous diagnostic | Flymake active |
| `F3` | `flymake-goto-next-error` | Go to next diagnostic | Flymake active |
| `M-g` `n` | `flymake-goto-next-error` | Jump to next diagnostic (alternative) | Flymake active |
| `M-g` `p` | `flymake-goto-prev-error` | Jump to previous diagnostic (alternative) | Flymake active |
| `C-h` `.` | `display-local-help` | Show diagnostic details at point | Flymake active |

## Functions

This section contains commands that don't have keyboard shortcuts but can be executed by typing their names. These functions provide additional functionality that you can access when needed.

**How to use functions:**
- Press `M-x` (hold Alt and press x) to open the command prompt
- Type the function name exactly as shown in the tables below
- Press Enter to execute the function
- Most functions will provide feedback about what they did

**Example to try:** Press `M-x pyvenv-activate` to manually activate a Python virtual environment.

### Virtual Environment Management

Python virtual environment commands for project isolation using [pyvenv](https://github.com/jorgenschaefer/pyvenv):

| Function | Description |
|:---------|:------------|
| `pyvenv-activate` | Manually activate a virtual environment |
| `pyvenv-deactivate` | Deactivate current virtual environment |
| `pyvenv-workon` | Switch to a different virtual environment |

### Package Management

Interactive package management commands for browsing, updating, and maintaining installed packages:

| Function | Description |
|:---------|:------------|
| `package-ui-show-installed` | View all installed packages with update indicators and status labels |
| `package-ui-search` | Search for packages by name or keyword across repositories |
| `package-ui-show-upgrades` | Check for available package updates (manual override of weekly check) |
| `package-maintenance-cleanup` | Remove unused package dependencies and reset metadata cache |

**Features:**
- **Package browser** - displays all packages with "Installed (by User)" or "Dependency" labels
- **Update checking** - shows current version → new version for available updates
- **One-click updates** - `[Update All]` button when updates are available
- **Cleanup utilities** - removes orphaned dependencies and resets cache

**Dashboard Integration:**
All package management functions are accessible from the startup dashboard via icon buttons:
- **Update** button - runs `package-ui-show-upgrades`
- **Installed Packages** button - runs `package-ui-show-installed`
- **Search Packages** button - runs `package-ui-search`
- **Package Cleanup** button - runs `package-maintenance-cleanup`

### Git Integration

Git and Forge synchronization commands using [Magit](https://magit.vc/) and [Forge](https://github.com/magit/forge):

| Function | Description |
|:---------|:------------|
| `git-sync-repository` | Manually synchronize Git refs and Forge data for current repository |
| `magit-status` | Open Magit status buffer for current repository |
| `forge-pull` | Fetch issues and pull requests from forge (GitHub/GitLab) |

**Using `git-sync-repository`:**
- **Default behavior**: Synchronization is manual-only (no auto-sync on file open)
- Run `M-x git-sync-repository` to sync Git refs and Forge data on demand
- Fetches Git refs (branches, tags, commits) via `magit-fetch-all`
- Pulls Forge metadata (issues, PRs, comments) via Forge API
- Only syncs once per repository per session (subsequent calls skip redundant fetches)
- Non-blocking operation - continue working while sync happens in background

**Optional Auto-Sync:**
- To enable automatic syncing when opening files, add to `~/.emacs.d/local.el`:
  ```elisp
  ;; Optional: Auto-sync Git and Forge data when opening files (default: disabled)
  (require 'git-sync)
  (add-hook 'find-file-hook #'git-auto-sync-repository-once)
  ```
- See [`GIT.md`](GIT.md#git-and-forge-synchronization) for complete documentation

**Magit and Forge:**
- `magit-status` - Main Git interface for staging, committing, branching, etc.
- `forge-pull` - Fetch issues/PRs directly (also called by `git-sync-repository`)
- For complete setup and usage guide, see [`GIT.md`](GIT.md)

### Theme Management

Interactive theme selection and customization using [Doom Themes](https://github.com/doomemacs/themes):

| Function | Description |
|:---------|:------------|
| `theme-utils-switch-theme` | Quick theme selection with tab completion |
| `toggle-list-themes-window` | Interactive theme browser with live testing |

**Using `theme-utils-switch-theme`:**
- Press `M-x theme-utils-switch-theme` to open theme selector with tab completion
- Type to filter from 68+ doom themes plus other terminal-friendly themes
- Press `TAB` to see all available options
- Changes apply immediately when you select a theme

**Using `toggle-list-themes-window` (Recommended for theme browsing):**
- Press `M-x toggle-list-themes-window` to open dedicated theme browser
- **Navigation**: Use arrow keys to move between themes
- **Selection**: Press `RET` (Enter) on any theme to apply it instantly
- **Testing**: Buffer stays open so you can test multiple themes easily
- **Current theme**: Marked with `->` indicator
- **Exit**: Press `q` or `C-g` to close the browser when done

**Available Themes:**
- **68+ Doom Themes**: All doom-themes dynamically discovered and sorted alphabetically
- **Popular choices**: `doom-1337` (default), `doom-zenburn`, `doom-Iosvkem`, `doom-gruvbox`, `doom-material-dark`, `doom-monokai-machine`
- **Terminal-optimized**: `doom-1337` (default), `doom-zenburn`, `doom-gruvbox`, `doom-material-dark`, `doom-tomorrow-night`
- **Other options**: `wombat`, `tango-dark`, `leuven`

**Theme Persistence:**
- Your selected theme preference is automatically saved
- Set permanent preferences in `local.el` (see [`configs/local.el`](configs/local.el))

## Related Documentation

**For Understanding Features:**
- [`FEATURES.md`](FEATURES.md) - Detailed feature documentation and capabilities
- [`FAQ.md`](FAQ.md) - Common questions about using features

**For Setup Help:**
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Solutions when keybindings don't work
