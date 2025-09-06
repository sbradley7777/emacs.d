# Emacs Configuration Keymap

This document provides a comprehensive reference for all keybindings and executable commands available in this Emacs configuration, covering both general Emacs operations and language-specific development features.

## Table of Contents

- [How to Use This Guide](#how-to-use-this-guide)
- [Function Keys](#function-keys)
- [Code Intelligence (LSP via Eglot)](#code-intelligence-lsp-via-eglot)
- [Code Completion (Corfu)](#code-completion-corfu)
- [Essential Emacs Operations](#essential-emacs-operations)
- [Custom Navigation](#custom-navigation)
- [Language-Specific Keybindings](#language-specific-keybindings)
  - [Python Development](#python-development)
  - [Makefile Development](#makefile-development)
  - [Markdown Support](#markdown-support)
  - [TOML Configuration](#toml-configuration)
  - [YAML Development](#yaml-development)
- [Code Formatting](#code-formatting)
- [Commands Without Keybindings (M-x Commands)](#commands-without-keybindings-m-x-commands)
  - [Virtual Environment Management](#virtual-environment-management)
- [Diagnostic and Error Checking](#diagnostic-and-error-checking)
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

## Function Keys

These are configuration-specific shortcuts designed for quick access to common operations:

| Key Binding | Function | Description |
|:------------|:---------|:------------|
| `F1` | `flymake-show-buffer-diagnostics` | Display syntax errors and warnings |
| `F4` | `kill-this-buffer` | Close current buffer |
| `F5` | `clipboard-kill-ring-save` | Copy to system clipboard |
| `F6` | `delete-trailing-whitespace` | Clean up line endings |
| `F7` | `previous-buffer` | Switch to previous buffer |
| `F8` | `next-buffer` | Switch to next buffer |
| `F9` | `beginning-of-buffer` | Jump to file start |
| `F10` | `end-of-buffer` | Jump to file end |
| `F11` | Smart scroll down | Scroll with boundary handling |
| `F12` | Smart scroll up | Scroll with boundary handling |

## Code Intelligence (LSP via Eglot)

Advanced code navigation and analysis powered by [Eglot](https://github.com/joaotavora/eglot):

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `M-.` | `xref-find-definitions` | Jump to function/class/variable definition | LSP active |
| `M-,` | `xref-go-back` | Return from definition jump | LSP active |
| `M-?` | `xref-find-references` | Find all references to symbol | LSP active |
| `C-h` `.` | `display-local-help` | Show documentation in echo area | LSP active |
| `C-c` `C-r` | `eglot-rename` | Rename symbol project-wide | LSP active |
| `C-c` `C-a` | `eglot-code-actions` | Show quick fixes and refactoring | LSP active |

## Code Completion (Corfu)

Intelligent auto-completion powered by [Corfu](https://github.com/minad/corfu):

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C-c` `TAB` | `completion-at-point` | Manually trigger completion | Always |
| `M-TAB` | `completion-at-point` | Alternative completion trigger | Always |
| `TAB` | `python-indent-line-function` | Auto-indent line | Normal editing |
| `S-TAB` | `corfu-previous` | Navigate to previous candidate | Popup active |
| `S-TAB` | `python-dedent-line-function` | Decrease indentation | Normal editing |
| `RET` | `corfu-insert` | Accept selected completion | Popup active |

## Essential Emacs Operations

Core Emacs commands for file management and text editing:

| Key Binding | Function | Description |
|:------------|:---------|:------------|
| `C-x` `C-f` | `find-file` | Open file browser to select file |
| `C-x` `C-s` | `save-buffer` | Save current file to disk |
| `C-x` `b` | `switch-to-buffer` | Switch between open buffers |
| `C-s` | `isearch-forward` | Interactive search forward |
| `C-r` | `isearch-backward` | Interactive search backward |
| `M-%` | `query-replace` | Find and replace with confirmation |
| `C-w` | `kill-region` | Cut selected text |
| `M-w` | `kill-ring-save` | Copy selected text |
| `C-y` | `yank` | Paste text from kill ring |
| `C-/` | `undo` | Undo last action |

## Custom Navigation

Additional navigation commands for efficient code browsing:

| Key Binding | Function | Description |
|:------------|:---------|:------------|
| `C-a` | `smart-beginning-of-line` | Jump to first non-whitespace or line start |
| `ESC` `←` | `scroll-down` | Scroll buffer content down |
| `ESC` `→` | `scroll-up` | Scroll buffer content up |

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

Makefile-specific keybindings for build system editing:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `TAB` | `makefile-tab` | Insert proper tab character (required for Makefile syntax) | Makefile mode |

### Markdown Support

Markdown-specific keybindings for documentation editing:

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `C-c` `C-c` | `markdown-command` | Preview markdown file | Markdown files |
| `C-c` `C-p` | `markdown-preview` | Live preview in browser | Markdown files |

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

## Commands Without Keybindings (M-x Commands)

These functions don't have direct keybindings but can be executed using `M-x function-name`:

### Virtual Environment Management

Python virtual environment commands for project isolation using [pyvenv](https://github.com/jorgenschaefer/pyvenv):

| Function | Description |
|:---------|:------------|
| `pyvenv-activate` | Manually activate a virtual environment |
| `pyvenv-deactivate` | Deactivate current virtual environment |
| `pyvenv-workon` | Switch to a different virtual environment |

## Diagnostic and Error Checking

Built-in Emacs diagnostic tools (Flymake is built into Emacs):

| Key Binding | Function | Description | Context |
|:------------|:---------|:------------|:--------|
| `F1` | `flymake-show-buffer-diagnostics` | Show diagnostics in side window | Flymake active |
| `M-g` `n` | `flymake-goto-next-error` | Jump to next diagnostic | Flymake active |
| `M-g` `p` | `flymake-goto-prev-error` | Jump to previous diagnostic | Flymake active |
| `C-h` `.` | `display-local-help` | Show diagnostic details at point | Flymake active |

## Related Documentation

- [`CONTRIBUTING.md`](CONTRIBUTING.md) - Guidelines for contributing to the configuration
- [`FAQ.md`](FAQ.md) - Frequently asked questions about configuration and usage
- [`FEATURES.md`](FEATURES.md) - Detailed feature documentation, version-aware capabilities, and language support
- [`README.md`](README.md) - Main project documentation and setup instructions
- [`STYLEGUIDE.md`](STYLEGUIDE.md) - Code formatting and style standards
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Solutions for common issues and debugging guides
