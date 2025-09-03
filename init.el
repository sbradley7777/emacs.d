;;; init.el --- Emacs Configuration Entry Point -*- lexical-binding: t -*-
;;; Commentary:
;;      Main entry point for Emacs configuration.
;;      Loads configuration modules in the correct order.

(message "🔄  Loading init.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package system configuration (Snap-compatible approach)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Note: Package auto-initialization is now disabled in early-init.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance optimizations for faster startup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Note: Initial performance settings are handled in early-init.el
;; Restore normal performance values after startup is complete
(add-hook
 'emacs-startup-hook
 (lambda
  ()
  ;; Restore normal garbage collection settings
  (setq
   gc-cons-threshold (* 2 1000 1000) ; 2MB for normal operation
   gc-cons-percentage 0.1) ; 10% of heap for GC

  ;; Restore file name handlers (disabled in early-init.el for faster startup)
  (setq file-name-handler-alist default-file-name-handler-alist)

  ;; Restore normal input processing
  (setq idle-update-delay 0.5) ; Faster idle updates for responsiveness

  (message "✅  Emacs startup complete. Performance settings restored.")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration Validation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Validate that early-init.el properly set up required variables
(unless
 (boundp 'default-file-name-handler-alist)
 (warn "⚠️  default-file-name-handler-alist not set by early-init.el - performance may be suboptimal")
 (setq default-file-name-handler-alist file-name-handler-alist))

;; Validate that early-init performance optimizations were applied
(unless
 (> gc-cons-threshold 800000)
 (warn "⚠️  GC threshold not optimized by early-init.el - startup may be slower"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup configuration directories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar core-dir (expand-file-name "core" user-emacs-directory))
(defvar features-dir (expand-file-name "features" user-emacs-directory))
(defvar lang-dir (expand-file-name "lang" user-emacs-directory))
(defvar python-dir (expand-file-name "lang/python" user-emacs-directory))
(defvar themes-dir (expand-file-name "themes" user-emacs-directory))
(defvar user-dir (expand-file-name "user" user-emacs-directory))

;; Add directories to load path (order matters - features before python-dir)
(mapc (lambda (dir) (add-to-list 'load-path dir)) (list core-dir features-dir themes-dir user-dir lang-dir python-dir))

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
(safe-load-config 'package-manager "Package system setup") ; Package system setup first
(safe-load-config 'packages "Package declarations") ; Package declarations and configurations
(safe-load-config 'ui "Basic UI setup") ; Basic UI setup
(safe-load-config 'themes "Theme configuration") ; Visual appearance
(safe-load-config 'editing "Editing preferences") ; Editing preferences
(safe-load-config 'files "File handling") ; File handling
(safe-load-config 'keybindings "Global keybindings") ; Global keybindings

;; Optional features (load eglot first before language-specific configs)
(safe-load-config 'completion "Auto-completion framework") ; Core completion system
(safe-load-config 'lsp "General LSP configuration") ; General eglot settings
(safe-load-config 'flymake-config "Flymake configuration") ; Flymake diagnostic display
(safe-load-config 'rainbow-delimiters "Rainbow delimiters for better code readability") ; Enhanced delimiter visibility
(safe-load-config 'indent-guides "Visual indentation guides") ; Column-based indentation visualization

;; Language-specific configurations
(safe-load-config 'lisp "Emacs Lisp development")
(safe-load-config 'yaml "YAML file support")

;; Python configurations (load after general eglot)
(safe-load-config 'core "Python core editing")
(safe-load-config 'venv "Python virtual environments")
(safe-load-config 'eglot-config "Python LSP (eglot) configuration") ; This loads lang/python/eglot-config.el
(safe-load-config 'tools "Python development tools")

;; User functions and aliases
(safe-load-config 'functions "Custom helper functions")
(safe-load-config 'aliases "Function aliases and shortcuts")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI tweaks via emacs menu:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set location of any changes to emacs while running. These changes are not loaded when emacs restarts.
(setq custom-file "~/.emacs.d/custom_prefs.el")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization complete - show diagnostics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display detailed loading diagnostics
(show-config-diagnostics)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Memory Management Optimization for Long-Running Sessions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Garbage collection optimization for long-running sessions
(defun
 optimize-gc-for-long-session () "Optimize garbage collection for long-running sessions."
 (setq
  gc-cons-threshold (* 100 1000 1000) ; 100MB threshold for normal operation
  gc-cons-percentage 0.1)) ; 10% of heap for GC

;; Run GC optimization every 15 minutes when idle to maintain performance
(run-with-idle-timer 900 t #'optimize-gc-for-long-session)

(message "✅  init.el loaded successfully.")
