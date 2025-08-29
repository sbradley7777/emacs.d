# Emacs Configuration Style Guide

This document outlines the formatting and code style conventions used in this Emacs configuration.

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
├── init.el                 # Main configuration entry point
├── early-init.el          # Early initialization settings
├── config/                # Core configuration modules
├── lang/                  # Language-specific configurations
├── themes/                # Theme configurations
└── custom/                # Custom functions and aliases
```

### File Naming Convention
- Use kebab-case for file names: `core-package-manager.el`
- Prefix files by category: `core-`, `lang-`, `theme-`
- Use descriptive names that indicate purpose

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
(defvar config-essential-packages '(spacemacs-theme zenburn-theme)
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

## Quality Assurance

### Pre-commit Hooks
The configuration includes pre-commit hooks for quality assurance (see [.pre-commit-config.yaml](.pre-commit-config.yaml)):

- **Trailing whitespace** removal
- **End-of-file** newline enforcement
- **Large file** prevention
- **Shell script** linting (shellcheck, bashate)
- **Spell checking** (codespell)

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
