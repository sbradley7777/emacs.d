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
  - [Pre-commit Hooks](#pre-commit-hooks)
  - [Performance Considerations](#performance-considerations)
- [Best Practices](#best-practices)
  - [Configuration Loading](#configuration-loading)
  - [Package Management](#package-management)
  - [Performance](#performance)

## General Principles

This configuration follows established Emacs Lisp community standards and best practices:

- **Consistency**: All files follow the same formatting conventions
- **Readability**: Code is formatted for clarity and maintainability
- **Standards Compliance**: Adheres to GNU Emacs Lisp conventions
- **Automated Formatting**: Uses `elisp-autofmt` for consistent formatting

## File Structure and Organization

### Directory Layout
```
emacs.d/
├── init.el                      # Main configuration entry point
├── early-init.el                # Early initialization and performance optimizations
├── core/                        # Essential Emacs functionality (loaded first)
│   ├── package-manager.el       # Package repositories and use-package setup
│   ├── packages.el              # Essential package installations and configurations
│   ├── ui.el                    # User interface and visual settings
│   ├── editing.el               # Text editing behavior and preferences
│   ├── files.el                 # File handling, backup, and auto-save settings
│   └── keybindings.el           # Global keybindings and shortcuts
├── features/                    # Optional enhancements (can be disabled independently)
│   ├── completion.el            # Core auto-completion framework
│   ├── lsp.el                   # General LSP client configuration
│   ├── flymake-config.el        # Flymake diagnostic display configuration
│   ├── rainbow-delimiters.el    # Enhanced delimiter visibility
│   └── indent-guides.el         # Visual indentation guides
├── lang/                        # Language-specific configurations
│   ├── lisp.el                  # Lisp and Emacs Lisp development settings
│   ├── yaml.el                  # YAML file editing configuration
│   └── python/                  # Python development environment
│       ├── core.el              # Basic Python mode settings and indentation
│       ├── venv.el              # Virtual environment management
│       ├── eglot-config.el      # Python-specific LSP server configuration
│       └── tools.el             # Python development tools and utilities
├── themes/                      # Theme configurations
│   └── themes.el                # Core theme and appearance configuration
├── user/                        # Personal customizations
│   ├── functions.el             # User-defined utility functions
│   └── aliases.el               # Command aliases and shortcuts
├── scripts/                     # Installation and utility scripts
│   ├── install.sh               # Automated configuration installation
│   └── README.md                # Script documentation
├── STYLEGUIDE.md                # This document - formatting and style conventions
└── README.md                    # Project documentation and setup instructions
```

### File Naming Convention
- Use kebab-case for file names: `package-manager.el`, `eglot-config.el`
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
- Use `kebab-case` for all identifiers
- Prefix custom variables with project/config identifier
- Use descriptive names that indicate purpose

#### Configuration Variables
```elisp
(defvar config-essential-packages '(zenburn-theme yaml-mode)
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
- **Indentation**: 2 spaces (YAML standard)
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
- **Automatic formatting on save** for Emacs Lisp files
- **Manual formatting** via `C-c C-f` keybinding
- **Native Emacs style** using built-in indentation rules
- **Single-threaded** processing for consistency

### Tab to Space Conversion
Automatic conversion of tabs to spaces in Emacs Lisp files:

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

## Message Symbol Reference

The configuration uses a comprehensive set of Unicode symbols to create a visual messaging system for status updates, diagnostics, and information display. This symbolic language makes the Messages buffer highly scannable and provides immediate visual feedback about configuration loading and system operations.

### Symbol Categories and Usage

#### Process & Status Symbols

| Symbol | Purpose |
|--------|---------|
| 🔄 | Loading/In Progress |
| ✅ | Success/Completion |
| ❌ | Errors/Failures |
| ⚠️ | Warnings |

#### Operation-Specific Symbols

| Symbol | Purpose |
|--------|---------|
| 📦 | Package Operations |
| 💾 | File/Backup Operations |
| 🔍 | Search/Discovery |
| 🔐 | Security Operations |
| 🧹 | Cleanup Operations |

#### Information & Configuration Symbols

| Symbol | Purpose |
|--------|---------|
| ℹ️ | Information/Details |
| ⚙️ | Configuration Complete |
| 🛠️ | Debug/Diagnostics |

### Message Formatting Standards

#### Symbol Spacing
All message symbols follow a consistent spacing pattern:
- **Two spaces** after the symbol: `"🔄  Loading init.el..."`
- **Preserve indentation** before symbols: `"    ✅  %s (%.3fs)"`
- **No trailing spaces** at end of messages

#### Message Structure Examples

```elisp
;; Loading messages
(message "🔄  Loading %s..." module-name)

;; Success messages
(message "✅  %s loaded successfully" module-name)
(message "✅  Installed: %s" package-name)

;; Error messages
(message "❌  Failed to install %s: %s" package error)

;; Configuration messages
(message "⚙️  %s configured successfully" feature-name)

;; Debug/diagnostic messages
(message "🛠️  Current Major Mode: %s" major-mode)

;; Information messages
(message "ℹ️  Consider checking: %s" suggestion)
```

#### Context-Specific Usage

**Module Loading Pattern:**
```elisp
(message "🔄  Loading module-name.el...")
;; ... configuration code ...
(message "✅  module-name.el loaded successfully")
```

**Package Installation Pattern:**
```elisp
(message "📦  Installing %d packages..." count)
(message "✅  Already installed: %s" package)
(message "✅  Installed: %s" package)
(message "❌  Failed to install %s: %s" package error)
```

**Diagnostic Information Pattern:**
```elisp
(message "🛠️  Global Mode: %s" status)
(message "🛠️  Configuration: %s" value)
(message "🛠️  Current State: %s" state)
```

### Symbol Usage Guidelines

1. **Consistency**: Always use the same symbol for the same type of operation
2. **Semantic Meaning**: Choose symbols that logically represent the operation
3. **Visual Hierarchy**: Use symbols to create scannable message categories
4. **Spacing**: Maintain exactly two spaces after symbols
5. **Context**: Preserve any indentation before symbols for alignment

### Benefits of the Symbol System

- **Quick Scanning**: Users can rapidly identify message types in the Messages buffer
- **Visual Hierarchy**: Different symbol categories create clear information structure
- **Status Recognition**: Immediate visual feedback on operation success/failure
- **Professional Appearance**: Consistent symbolic language creates polished output
- **Cross-Platform Compatibility**: Unicode symbols display consistently across systems

## Quality Assurance

### Pre-commit Hooks
The configuration includes pre-commit hooks for quality assurance (see [.pre-commit-config.yaml](.pre-commit-config.yaml)):

#### Code Quality Hooks
- **Trailing whitespace** removal
- **End-of-file** newline enforcement
- **Large file** prevention
- **Shell script** linting (shellcheck, bashate)
- **Spell checking** (codespell)

#### Emacs Lisp Formatting Hook
- **elisp-autofmt** - Automatic formatting for `.el` files using [elisp-autofmt](https://github.com/emacsmirror/elisp-autofmt)
  - Enforces consistent indentation and spacing
  - Applies native Emacs Lisp formatting standards
  - Automatically formats files on commit
  - Provides clear feedback when changes are made
  - Can be configured with custom binary path if needed

The elisp-autofmt hook ensures all Emacs Lisp files follow the formatting standards defined in this style guide automatically.

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
- Use `use-package` for all package declarations
- Pin security-critical packages to trusted repositories
- Enable package signature verification when available
- Organize packages by category (essential, development)

### Performance
- Optimize garbage collection for long-running sessions
- Use deferred loading (`:defer t`) for optional packages
- Measure and monitor configuration load times
- Avoid blocking operations during startup

---

*This style guide is automatically enforced by elisp-autofmt and pre-commit hooks.*
