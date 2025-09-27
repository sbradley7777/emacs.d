;;; init.el --- Emacs Configuration Entry Point -*- lexical-binding: t -*-
;;; Commentary:
;;      Main entry point for Emacs configuration.
;;      Loads configuration modules in the correct order.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ensure early-init.el is loaded (for batch mode compatibility)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; In interactive mode, early-init.el loads automatically before init.el
;; In batch mode, it doesn't load automatically, so we load it here if needed
(unless (boundp 'emacs-local-dir) (load (expand-file-name "early-init.el" user-emacs-directory)))

;; Note: logging utilities are now loaded in early-init.el, so we can use them immediately
(core-message-loading "Loading init.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package system configuration (Snap-compatible approach)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance optimizations for faster startup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Restore normal performance values after startup is complete
(add-hook
 'emacs-startup-hook
 (lambda
  ()
  ;; Restore normal garbage collection settings
  (setq
   gc-cons-threshold core-gc-normal-threshold ; Normal operation threshold
   gc-cons-percentage core-gc-percentage-normal) ; Normal GC percentage

  ;; Restore file name handlers (disabled in early-init.el for faster startup)
  (setq file-name-handler-alist default-file-name-handler-alist)

  ;; Restore normal input processing
  (setq which-func-update-delay core-idle-update-delay-normal) ; Faster idle updates for responsiveness

  (core-message-success "Emacs startup complete. Performance settings restored.")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup configuration directories (needed early for constants loading)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar core-dir (expand-file-name "core" user-emacs-directory))
(defvar features-dir (expand-file-name "features" user-emacs-directory))
(defvar lang-dir (expand-file-name "lang" user-emacs-directory))
(defvar python-dir (expand-file-name "lang/python" user-emacs-directory))
(defvar themes-dir (expand-file-name "themes" user-emacs-directory))
(defvar user-dir (expand-file-name "user" user-emacs-directory))

;; Add directories to load path (order matters - features before python-dir)
(mapc
 (lambda (dir) (add-to-list 'load-path dir))
 (list core-dir features-dir themes-dir user-dir lang-dir python-dir))

;; Load core constants early so they're available for validation
(require 'core-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration Validation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Validate that early-init.el properly set up required variables
(unless
 (boundp 'default-file-name-handler-alist)
 (core-message-warning
  "default-file-name-handler-alist not set by early-init.el - performance may be suboptimal")
 (setq default-file-name-handler-alist file-name-handler-alist))

;; Validate that early-init performance optimizations were applied
(unless
 (> gc-cons-threshold core-gc-check-threshold)
 (core-message-warning "GC threshold not optimized by early-init.el - startup may be slower"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Native Compilation Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Defer native compilation configuration until the system is fully initialized.
;; This prevents startup errors caused by trying to modify variables that
;; have not yet been defined. This hook-based approach is the most robust way
;; to configure native compilation.
(defun
 my/configure-native-comp-for-snap
 ()
 "Exclude the read-only Snap directory from native compilation."
 (add-to-list 'native-comp-deferred-compilation-deny-list "/snap/emacs/.*"))

(add-hook 'native-comp-init-hook #'my/configure-native-comp-for-snap)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Error handling and robustness
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar init-start-time (current-time) "Time when Emacs initialization started.")

(defvar config-load-results '() "List of configuration loading results for diagnostics.")

(defun
 safe-load-config (config-name &optional description)
 "Safely load a configuration module with comprehensive error handling.
CONFIG-NAME is the module to load. DESCRIPTION is an optional human-readable description."
 (let ((load-time (current-time))
       (desc (or description (symbol-name config-name))))
   (condition-case err
       (progn
        (require config-name)
        (let ((elapsed (float-time (time-subtract (current-time) load-time))))
          (add-to-list 'config-load-results (list config-name 'success elapsed desc))
          (core-message-success "Loaded %s (%.3f seconds)" desc elapsed)
          t))
     (error
      (let ((elapsed (float-time (time-subtract (current-time) load-time))))
        (add-to-list
         'config-load-results (list config-name 'failed elapsed desc (error-message-string err)))
        (core-message-error "Failed to load %s: %s" desc (error-message-string err))
        (core-message-info
         "Consider checking: file exists, syntax is valid, dependencies available")
        nil)))))


(defun
 show-config-diagnostics () "Display configuration loading diagnostics."
 (let ((total-time (float-time (time-subtract (current-time) init-start-time)))
       (successful 0)
       (failed 0))
   (core-message-plain "\n=== Configuration Loading Summary ====")
   (dolist
    (result (reverse config-load-results))
    (let ((name (nth 0 result))
          (status (nth 1 result))
          (time (nth 2 result))
          (desc (nth 3 result)))
      (if
       (eq status 'success)
       (progn
        (core-utils-increment-counter successful) (core-message-success "%s (%.3fs)" desc time))
       (core-utils-increment-counter failed)
       (core-message-error "%s (%.3fs) - %s" desc time (nth 4 result)))))
   (core-message-debug
    "Total: %d successful, %d failed (%.3fs total)" successful failed total-time)
   (core-message-plain "====================================\n")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load configuration modules in order with error handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CRITICAL LOADING ORDER: Dependencies must be satisfied before dependent modules load.
;; Changing this order may cause configuration failures or missing functionality.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 1: Foundation Layer - System Infrastructure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load diagnostics FIRST - provides early error logging and system info for troubleshooting
(safe-load-config 'diagnostics "System and configuration diagnostics")

;; Show system information immediately after diagnostics loads (before packages)
(diagnostics-show-system-info)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 2: Package and Resource Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load package system BEFORE any packages are used - establishes repositories and use-package
(safe-load-config 'core-packages "Package declarations")

;; Load font management BEFORE UI - ensures fonts are available for interface setup
(safe-load-config 'core-fonts "Font management")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 3: User Interface Layer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load UI foundation BEFORE themes - establishes basic interface elements
(safe-load-config 'ui "Basic UI setup")
(safe-load-config 'gui-mode "GUI mode configuration")

;; Load theme configuration BEFORE theme utilities - establishes theme system
(safe-load-config 'themes-config "Theme configuration")

;; Load theme utilities AFTER theme configuration - provides interactive theme switching
(safe-load-config 'theme-utils "Theme utilities")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 4: Core Editing and File Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load editing preferences BEFORE file handling - establishes basic editing behavior
(safe-load-config 'editing "Editing preferences")

;; Load file handling BEFORE TRAMP - establishes local file management
(safe-load-config 'core-files "File handling")

;; Load TRAMP utilities BEFORE TRAMP config - provides helper functions for remote access
(safe-load-config 'tramp-utils "TRAMP utility functions")

;; Load TRAMP config AFTER utilities - establishes remote file access using helper functions
(safe-load-config 'tramp-config "TRAMP remote file access")

;; Load keybindings LAST in core phase - allows binding to all previously loaded functionality
(safe-load-config 'keybindings "Global keybindings")

;; Load log writer system AFTER file handling - establishes message logging with rotation
(safe-load-config 'log-writer "Message logging and log rotation")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 5: Enhanced Features (Optional Components)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load completion framework FIRST in features - provides foundation for other enhanced features
(safe-load-config 'completion-config "Auto-completion framework")

;; Load diagnostics BEFORE language modes - provides error reporting for code files
(safe-load-config 'flymake-config "Flymake configuration")

;; Load visual enhancements - order independent within this group
(safe-load-config 'rainbow-delimiters-config "Rainbow delimiters for better code readability")
(safe-load-config 'indent-guides "Visual indentation guides")

;; Load navigation tools AFTER completion - may integrate with completion system
(safe-load-config 'imenu-list-config "Symbol sidebar navigation")
(safe-load-config 'treemacs-config "Project tree navigation")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 6: Language-Specific Configurations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load general language modes - order independent, no cross-dependencies
(safe-load-config 'lisp-config "Emacs Lisp development")
(safe-load-config 'yaml-config "YAML file support")
(safe-load-config 'toml-config "TOML file support")
(safe-load-config 'markdown-config "Markdown file support")
(safe-load-config 'makefile-config "Makefile support")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 7: Python Development Stack (Complex Dependencies)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Python core FIRST - establishes basic Python editing capabilities
(safe-load-config 'python-core "Python core editing")

;; Load Python constants AFTER core - provides configuration values for other Python modules
(safe-load-config 'python-constants "Python configuration constants")

;; Load pyvenv utilities BEFORE pyvenv config - provides helper functions for virtual environments
(safe-load-config 'pyvenv-utils "Python virtual environment utilities")

;; Load pyvenv config AFTER utilities - establishes virtual environment management using helpers
(safe-load-config 'pyvenv-config "Python virtual environments")

;; Load pyvenv remote AFTER local pyvenv - extends virtual environment support to TRAMP sessions
(safe-load-config 'pyvenv-remote "Python virtual environments TRAMP support")

;; Load Ruff integration LAST - requires Python core, flymake, and pyvenv to be established
(safe-load-config 'flymake-ruff-config "Flymake Ruff integration")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 8: User Customizations (Final Layer)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load user functions BEFORE aliases - aliases may reference custom functions
(safe-load-config 'functions "Custom helper functions")

;; Load aliases LAST - may reference any previously loaded functionality
(safe-load-config 'aliases "Function aliases and shortcuts")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom settings via emacs menu system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use standard Emacs convention for custom settings
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Load custom settings if the file exists
(when (file-exists-p custom-file) (load custom-file 'noerror))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Local user configuration (not version controlled)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load optional local configuration file for user-specific settings
(let ((local-config (expand-file-name "local.el" user-emacs-directory)))
  (when
   (file-exists-p local-config)
   (core-message-loading "Loading local.el...")
   (load local-config 'noerror)
   (core-message-success "local.el loaded successfully")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Development configuration (not version controlled)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load optional development configuration file for testing new configurations
(let ((dev-config (expand-file-name "dev.el" user-emacs-directory)))
  (when
   (file-exists-p dev-config)
   (core-message-debug "Loading dev.el...")
   (load dev-config 'noerror)
   (core-message-success "dev.el loaded successfully")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization complete - show diagnostics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display detailed loading diagnostics
(show-config-diagnostics)

;; Show version-aware configuration status
(core-message-success "Emacs 30.2+ configuration loaded successfully")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Memory Management Strategy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Manual GC approach chosen for light usage patterns (typically < 10 buffers):
;; - Automatic timers add unnecessary overhead for minimal memory pressure
;; - Emacs' built-in GC triggers are sufficient for light buffer usage
;; - Manual optimization available via M-x optimize-gc-for-long-session if needed
;; - This approach avoids over-optimization complexity for predictable, light workflows

(defun
 init-optimize-gc-for-long-session ()
 "Optimize garbage collection for long-running sessions.
Can be called manually when needed for intensive work sessions."
 (interactive)
 (setq
  gc-cons-threshold core-gc-long-session-threshold ; Long session threshold
  gc-cons-percentage core-gc-percentage-normal) ; Normal GC percentage
 )

(core-message-success "init.el loaded successfully.")
