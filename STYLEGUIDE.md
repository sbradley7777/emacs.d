# Emacs Configuration Style Guide

This document outlines the formatting and code style conventions used in this Emacs configuration.

## Table of Contents

- [General Principles](#general-principles)
- [File Structure and Organization](#file-structure-and-organization)
  - [Directory Layout](#directory-layout)
  - [File Naming Convention](#file-naming-convention)
- [Emacs Lisp Formatting Standards](#emacs-lisp-formatting-standards)
  - [File Headers](#file-headers)
  - [Indentation and Spacing](#indentation-and-spacing)
  - [Line Length](#line-length)
  - [Section Separators](#section-separators)
  - [Comments](#comments)
  - [Variables and Functions](#variables-and-functions)
  - [Error Handling](#error-handling)
- [Language-Specific Standards](#language-specific-standards)
  - [Python Configuration](#python-configuration)
  - [YAML Configuration](#yaml-configuration)
- [Automated Formatting](#automated-formatting)
  - [elisp-autofmt Configuration](#elisp-autofmt-configuration)
  - [Tab to Space Conversion](#tab-to-space-conversion)
- [Module Structure](#module-structure)
  - [Module Template](#module-template)
  - [Required Elements](#required-elements)
- [Message Symbol Reference](#message-symbol-reference)
  - [Symbol Categories and Usage](#symbol-categories-and-usage)
  - [Message Formatting Standards](#message-formatting-standards)
  - [Symbol Usage Guidelines](#symbol-usage-guidelines)
  - [Benefits of the Symbol System](#benefits-of-the-symbol-system)
- [Quality Assurance](#quality-assurance)
  - [`pre-commit` Hooks](#pre-commit-hooks)
  - [Performance Considerations](#performance-considerations)
- [Best Practices](#best-practices)
  - [Configuration Loading](#configuration-loading)
  - [Package Management](#package-management)
  - [Performance](#performance)

## General Principles

This configuration follows established Emacs Lisp community standards and best practices:

- **Consistency**: All files follow the same formatting conventions
- **Readability**: Code is formatted for clarity and maintainability
- **Standards Compliance**: Adheres to [GNU Emacs Lisp conventions](https://www.gnu.org/software/emacs/manual/html_node/elisp/Tips.html)
- **Automated Formatting**: Uses `elisp-autofmt` for consistent formatting

## File Structure and Organization

### Directory Layout
```
emacs.d/
├── init.el                      # Main configuration entry point
├── early-init.el                # Early initialization and performance optimizations
├── [`core/`](core/)                        # Essential Emacs functionality (loaded first)
│   ├── package-system/          # Modular package management system
│   ├── core-packages.el         # Essential package installations and configurations
│   ├── core-ui.el               # User interface and visual settings
│   ├── core-editing.el          # Text editing behavior and preferences
│   ├── core-files.el            # File handling, backup, and auto-save settings
│   └── keybindings.el           # Global keybindings and shortcuts
├── [`features/`](features/)                    # Optional enhancements (can be disabled independently)
│   ├── completion-config.el     # Core auto-completion framework
│   ├── flymake-config.el        # Flymake diagnostic display configuration
│   ├── rainbow-delimiters-config.el    # Enhanced delimiter visibility
│   └── indent-guides.el         # Visual indentation guides
├── [`lang/`](lang/)                        # Language-specific configurations
│   ├── lisp-config.el                  # Lisp and Emacs Lisp development settings
│   ├── yaml-config.el                  # YAML file editing configuration
│   └── python/                  # Python development environment
│       ├── python-core.el       # Basic Python mode settings and indentation
│       ├── pyvenv-config.el              # Virtual environment management
├── [`themes/`](themes/)                      # Theme configurations
│   └── themes-config.el         # Core theme and appearance configuration
├── [`user/`](user/)                        # Personal customizations
│   ├── user-functions.el        # User-defined utility functions
│   └── user-aliases.el          # Command aliases and shortcuts
├── [`scripts/`](scripts/)                     # Installation and utility scripts
│   ├── install.sh               # Automated configuration installation
│   └── README.md                # Script documentation
├── STYLEGUIDE.md                # This document - formatting and style conventions
└── README.md                    # Project documentation and setup instructions
```

### File Naming Convention
- Use [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) for file names: `python-config.el`, `markdown-config.el`
- Directory structure provides categorization (no prefixes needed)
- Use descriptive names that indicate purpose
- Add `-config` suffix for configuration files that might conflict with built-in packages

## Emacs Lisp Formatting Standards

### File Headers
All `.el` files must include a standardized header:

```elisp
;;; filename.el --- Brief Description -*- lexical-binding: t -*-
;;; Commentary:
;;      Detailed description of file purpose and contents.
```

### Indentation and Spacing

#### Basic Rules
- **Indentation**: 2 spaces per level (automatic via `elisp-autofmt`)
- **No Tabs**: Use spaces only (`indent-tabs-mode nil`)
- **Tab Width**: 4 spaces when displaying tabs (`tab-width 4`)

#### Function Definitions
```elisp
(defun function-name (arg1 arg2)
  "Docstring describing the function."
  (let ((local-var value))
    (function-body)))
```

#### Use-Package Declarations
```elisp
(use-package package-name
  :config
  (setq option-1 value-1
        option-2 value-2)
  :hook (mode . function))
```

#### Multi-line setq Statements
```elisp
(setq
 variable-1 value-1
 variable-2 value-2
 variable-3 value-3)
```

### Line Length
- **Maximum Line Length**: 127 characters
- **Fill Column**: Set to 127 characters
- **Visual Indicator**: Fill column indicator enabled globally

### Section Separators
Use consistent section separators for organization:

```elisp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Section Title
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
```

### Comments

#### Comment Types
- **Section Headers**: Use the full-width separator shown above
- **Inline Comments**: Use `;` for end-of-line comments
- **Block Comments**: Use `;;` for explanatory text
- **Major Sections**: Use `;;;` for major section dividers

#### Comment Style
```elisp
;;; Major section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Subsection or explanation
(setq variable value) ; Inline comment
```

### Variables and Functions

#### Naming Conventions
- Use [`kebab-case`](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) for all identifiers
- Prefix custom variables with project/config identifier
- Use descriptive names that indicate purpose

#### Configuration Variables
```elisp
(defvar config-essential-packages '(doom-themes yaml-mode)
  "Essential packages that must be installed.")
```

#### Custom Functions
```elisp
(defun safe-load-config (config-name &optional description)
  "Safely load a configuration module with comprehensive error handling.
CONFIG-NAME is the module to load. DESCRIPTION is an optional human-readable description."
  (condition-case err
      (require config-name)
    (error
     (message "Failed to load %s: %s" config-name (error-message-string err)))))
```

### Error Handling
Use `condition-case` for robust error handling:

```elisp
(condition-case err
    (risky-operation)
  (error
   (message "Operation failed: %s" (error-message-string err))))
```

## Language-Specific Standards

### Python Configuration
- **Indentation**: 4 spaces (`python-indent 4`)
- **No Tabs**: Spaces only (`indent-tabs-mode nil`)
- **Auto-detection**: Enable indent guessing (`python-indent-guess-indent-offset t`)

### YAML Configuration
- **Indentation**: 2 spaces ([YAML standard](https://yaml.org/))
- **Auto-indent**: Enabled on newline

## Automated Formatting

### elisp-autofmt Configuration
The configuration uses [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt) for automatic formatting:

```elisp
(use-package elisp-autofmt
  :hook (emacs-lisp-mode . elisp-autofmt-mode)
  :bind (:map emacs-lisp-mode-map ("C-c C-f" . elisp-autofmt-buffer))
  :config
  (setq elisp-autofmt-style 'native
        elisp-autofmt-parallel-jobs 1))
```

#### Key Features
- **Automatic formatting on save** for [Emacs Lisp](https://www.gnu.org/software/emacs/manual/html_node/elisp/) files
- **Manual formatting** via `C-c C-f` keybinding
- **Native Emacs style** using built-in indentation rules
- **Single-threaded** processing for consistency

### Tab to Space Conversion
Automatic conversion of tabs to spaces in [Emacs Lisp](https://www.gnu.org/software/emacs/manual/html_node/elisp/) files:

```elisp
(add-hook 'emacs-lisp-mode-hook
  (lambda ()
    (add-hook 'before-save-hook 'untabify-buffer nil t)))
```

## Module Structure

### Module Template
Each configuration module should follow this template:

```elisp
;;; module-name.el --- Module Description -*- lexical-binding: t -*-
;;; Commentary:
;;      Detailed description of module purpose.

(defvar config-load-start-time (current-time))
(message "Loading module-name.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Section Title
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Configuration code here

;; Make this module available for loading
(provide 'module-name)
(message "module-name.el loaded (%.2fs)"
         (float-time (time-subtract (current-time) config-load-start-time)))
```

### Required Elements
1. **File header** with lexical binding
2. **Load timing** measurement
3. **Section separators** for organization
4. **Module provision** via `(provide 'module-name)`
5. **Load completion** message with timing

## Message Utilities Reference

**REQUIRED:** All user-facing messages must use the centralized message utilities from `core/logging.el` instead of direct `(message)` calls.

### Message Utility Functions
The configuration provides standardized message functions for consistent, professional output:

```elisp
;; Always require logging at the top of your file
(require 'core-logging)

;; Unicode message functions (preferred for operational status)
(core-message-loading "Loading %s..." module-name)    ; 🔄  Loading...
(core-message-success "Loaded %s successfully" name)  ; ✅  Success
(core-message-error "Failed: %s" error-msg)           ; ❌  Failed
(core-message-warning "Warning: %s" warning-msg)      ; ⚠️  Warning
(core-message-package "Installing %s" pkg-name)       ; 📦  Package
(core-message-config "Configured %s" feature)         ; ⚙️  Config
(core-message-debug "Debug info: %s" info)            ; 🛠️  Debug
(core-message-info "Information: %s" info)            ; ℹ️  Info
(core-message-theme "Theme: %s" theme-name)           ; 🎨  Theme

;; Plain message function (for system diagnostics, section headers)
(core-message-plain "=== Section Header ===")        ; No Unicode prefix
```

### Message Categories and Usage Guidelines

#### Unicode Messages (Operational Status)
Use for user feedback, progress indicators, and operational status:
- **Loading operations**: `core-message-loading`
- **Success/completion**: `core-message-success`
- **Errors/failures**: `core-message-error`
- **Warnings**: `core-message-warning`
- **Package operations**: `core-message-package`
- **Configuration complete**: `core-message-config`
- **Debug/diagnostics**: `core-message-debug`
- **Information**: `core-message-info`
- **Theme operations**: `core-message-theme`

#### Plain Messages (System Information)
Use for system diagnostics and configuration summaries:
- System startup information
- Configuration section headers
- Debug output without visual emphasis
- Performance statistics

### Legacy Code Migration
When updating existing code, replace direct message calls:

```elisp
;; OLD - Don't do this
(message "🔄  Loading %s..." name)
(message "✅  Success: %s" result)
(message "❌  Failed: %s" error)

;; NEW - Use utilities
(core-message-loading "Loading %s..." name)
(core-message-success "Success: %s" result)
(core-message-error "Failed: %s" error)
```

### Symbol Categories and Technical Reference

#### Process & Status Symbols
| Symbol | Function | Purpose |
|--------|----------|---------|
| 🔄 | `core-message-loading` | Loading/In Progress |
| ✅ | `core-message-success` | Success/Completion |
| ❌ | `core-message-error` | Errors/Failures |
| ⚠️ | `core-message-warning` | Warnings |
| ℹ️ | `core-message-info` | Information/Details |

#### Operation-Specific Symbols
| Symbol | Function | Purpose |
|--------|----------|---------|
| 📦 | `core-message-package` | Package Operations |
| ⚙️ | `core-message-config` | Configuration Complete |
| 🛠️ | `core-message-debug` | Debug/Diagnostics |
| 🎨 | `core-message-theme` | Theme Operations |

### Context-Specific Usage Patterns

**Module Loading Pattern:**
```elisp
(core-message-loading "Loading module-name.el...")
;; ... configuration code ...
(core-message-success "module-name.el loaded successfully")
```

**Package Installation Pattern:**
```elisp
(core-message-package "Installing %d packages..." count)
(core-message-success "Already installed: %s" package)
(core-message-success "Installed: %s" package)
(core-message-error "Failed to install %s: %s" package error)
```

**Configuration Pattern:**
```elisp
(core-message-config "%s configured successfully" feature-name)
(core-message-debug "Global Mode: %s" status)
(core-message-info "Consider checking: %s" suggestion)
```

### Implementation Benefits

- **Consistency**: Standardized message format across all modules
- **Maintainability**: Centralized message formatting logic
- **Visual Hierarchy**: Unicode symbols create scannable message categories
- **Professional Output**: Consistent spacing and formatting
- **Easy Updates**: Change message format in one place
- **Error Prevention**: No more manual Unicode symbol management

## Quality Assurance

### `pre-commit` Hooks
The configuration includes [`pre-commit`](https://github.com/pre-commit/pre-commit) hooks for quality assurance (see [.pre-commit-config.yaml](.pre-commit-config.yaml)):

#### Code Quality Hooks
- **Trailing whitespace** removal
- **End-of-file** newline enforcement
- **Large file** prevention
- **Shell script** linting (shellcheck, bashate)
- **Spell checking** (codespell)

#### Emacs Lisp Formatting Hook
- **elisp-autofmt** - Automatic formatting for `.el` files using [elisp-autofmt](https://github.com/emacsmirror/elisp-autofmt)
  - Enforces consistent indentation and spacing
  - Applies native [Emacs Lisp formatting standards](https://www.gnu.org/software/emacs/manual/html_node/elisp/Tips.html)
  - Automatically formats files on commit
  - Provides clear feedback when changes are made
  - Can be configured with custom binary path if needed

The elisp-autofmt hook ensures all [Emacs Lisp](https://www.gnu.org/software/emacs/manual/html_node/elisp/) files follow the formatting standards defined in this style guide automatically.

### Performance Considerations
- **Startup optimization** via early-init.el
- **Deferred loading** for non-essential packages
- **Error handling** to prevent configuration failures
- **Loading diagnostics** for performance monitoring

## Best Practices

### Configuration Loading
1. Load core packages first (package manager, UI)
2. Load language configurations after core setup
3. Load custom functions and aliases last
4. Use `safe-load-config` for robust error handling

### Package Management
- Use [`use-package`](https://www.gnu.org/software/emacs/manual/html_mono/use-package.html) for all package declarations
- Pin security-critical packages to trusted repositories
- Enable package signature verification when available
- Organize packages by category (essential, development)

### Performance
- Optimize garbage collection for long-running sessions
- Use deferred loading (`:defer t`) for optional packages
- Measure and monitor configuration load times
- Avoid blocking operations during startup

## Related Documentation

**For Development:**
- [`CONTRIBUTING.md`](CONTRIBUTING.md) - Guidelines using this style guide
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Development and testing procedures

---

*This style guide is automatically enforced by [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt) and [`pre-commit`](https://github.com/pre-commit/pre-commit) hooks.*
