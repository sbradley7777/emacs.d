;;; init.el --- Emacs Configuration Entry Point -*- lexical-binding: t -*-
;;; Commentary:
;;      Main entry point for Emacs configuration.
;;      Loads configuration modules in the correct order.

(message "🔄  Loading init.el...")

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
  (setq idle-update-delay core-idle-update-delay-normal) ; Faster idle updates for responsiveness

  (message "✅  Emacs startup complete. Performance settings restored.")))

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
 (warn
  "⚠️  default-file-name-handler-alist not set by early-init.el - performance may be suboptimal")
 (setq default-file-name-handler-alist file-name-handler-alist))

;; Validate that early-init performance optimizations were applied
(unless
 (> gc-cons-threshold core-gc-check-threshold)
 (warn "⚠️  GC threshold not optimized by early-init.el - startup may be slower"))


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
          (message "✅  Loaded %s (%.3f seconds)" desc elapsed)
          t))
     (error
      (let ((elapsed (float-time (time-subtract (current-time) load-time))))
        (add-to-list
         'config-load-results (list config-name 'failed elapsed desc (error-message-string err)))
        (message "❌  Failed to load %s: %s" desc (error-message-string err))
        (message "ℹ️  Consider checking: file exists, syntax is valid, dependencies available")
        nil)))))


(defun
 show-config-diagnostics () "Display configuration loading diagnostics."
 (let ((total-time (float-time (time-subtract (current-time) init-start-time)))
       (successful 0)
       (failed 0))
   (message "\n=== Configuration Loading Summary ===")
   (dolist
    (result (reverse config-load-results))
    (let ((name (nth 0 result))
          (status (nth 1 result))
          (time (nth 2 result))
          (desc (nth 3 result)))
      (if
       (eq status 'success)
       (progn (setq successful (1+ successful)) (message "    ✅  %s (%.3fs)" desc time))
       (setq failed (1+ failed))
       (message "  ❌  %s (%.3fs) - %s" desc time (nth 4 result)))))
   (message "    🛠️  Total: %d successful, %d failed (%.3fs total)" successful failed total-time)
   (message "====================================\n")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load configuration modules in order with error handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core configuration (order matters)
(safe-load-config 'diagnostics "System and configuration diagnostics") ; System diagnostics (load first for early Messages buffer logging)

;; Show system information immediately after diagnostics loads (before packages)
(show-system-info)

(safe-load-config 'package-system/manager "Package system setup") ; Package system setup
(safe-load-config 'core-packages "Package declarations") ; Package declarations and configurations
(safe-load-config 'ui "Basic UI setup") ; Basic UI setup
(safe-load-config 'themes-config "Theme configuration") ; Visual appearance
(safe-load-config 'theme-utils "Theme utilities") ; Interactive theme tools
(safe-load-config 'editing "Editing preferences") ; Editing preferences
(safe-load-config 'core-files "File handling") ; File handling
(safe-load-config 'tramp-config "TRAMP remote file access") ; Remote file access
(safe-load-config 'keybindings "Global keybindings") ; Global keybindings

;; Optional features (load eglot first before language-specific configs)
(safe-load-config 'completion-config "Auto-completion framework") ; Core completion system
(safe-load-config 'lsp-config "General LSP configuration") ; General eglot settings
(safe-load-config 'flymake-config "Flymake configuration") ; Flymake diagnostic display
(safe-load-config 'rainbow-delimiters-config "Rainbow delimiters for better code readability") ; Enhanced delimiter visibility
(safe-load-config 'indent-guides "Visual indentation guides") ; Column-based indentation visualization
(safe-load-config 'imenu-list-config "Symbol sidebar navigation") ; Imenu-list for file structure sidebar

;; Language-specific configurations
(safe-load-config 'lisp-config "Emacs Lisp development")
(safe-load-config 'yaml-config "YAML file support")
(safe-load-config 'toml-config "TOML file support")
(safe-load-config 'markdown-config "Markdown file support")
(safe-load-config 'makefile-config "Makefile support")

;; Python configurations (load after general eglot)
(safe-load-config 'python-core "Python core editing")
(safe-load-config 'python-constants "Python configuration constants")
(safe-load-config 'pyvenv-utils "Python virtual environment utilities")
(safe-load-config 'pyvenv-config "Python virtual environments")
;; (safe-load-config 'pyvenv-remote "Python virtual environments TRAMP support") ; Disabled - using auto-detect approach in pyvenv-config
(safe-load-config 'eglot-config "Python LSP (eglot) configuration") ; This loads lang/python/eglot-config.el
(safe-load-config 'python-tools "Python development tools")

;; User functions and aliases
(safe-load-config 'functions "Custom helper functions")
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
   (message "🔄  Loading local.el...")
   (load local-config 'noerror)
   (message "✅  local.el loaded successfully")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization complete - show diagnostics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display detailed loading diagnostics
(show-config-diagnostics)

;; Show version-aware configuration status
(message "✅ Emacs 30.2+ configuration loaded successfully")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Memory Management Strategy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Manual GC approach chosen for light usage patterns (typically < 10 buffers):
;; - Automatic timers add unnecessary overhead for minimal memory pressure
;; - Emacs' built-in GC triggers are sufficient for light buffer usage
;; - Manual optimization available via M-x optimize-gc-for-long-session if needed
;; - This approach avoids over-optimization complexity for predictable, light workflows

(defun
 optimize-gc-for-long-session ()
 "Optimize garbage collection for long-running sessions.
Can be called manually when needed for intensive work sessions."
 (interactive)
 (setq
  gc-cons-threshold core-gc-long-session-threshold ; Long session threshold
  gc-cons-percentage core-gc-percentage-normal) ; Normal GC percentage
 (message
  "✅ GC optimized for long session (threshold: %s)"
  (format-bytes-to-string core-gc-long-session-threshold)))

(message "✅  init.el loaded successfully.")
