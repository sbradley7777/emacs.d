;;; local.el --- Local User Configuration (Not Version Controlled) -*- lexical-binding: t -*-
;;; Commentary:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This file is for local, user-specific Emacs configuration that should NOT be
;; committed to version control.  It's loaded automatically by init.el if it exists.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PURPOSE:
;; --------
;; • Machine-specific settings (paths, system-dependent configurations)
;; • Personal preferences that differ from the shared configuration
;; • Experimental settings you want to test without affecting the main config
;; • Private or sensitive configuration (API keys, personal info, etc.)
;; • Override any settings from the main configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; USAGE:
;; ------
;; This file is loaded AFTER all the main configuration modules, so you can:
;; • Override any variables or settings defined in the main config
;; • Add additional packages or features
;; • Customize keybindings
;; • Set machine-specific variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Code:
(require 'logging-init)

;; Declare external variables to suppress byte-compiler warnings
(defvar eglot-events-buffer-size) ; From eglot.el

(logging-loading "=== local.el: Loading local user configuration ===")
;; ============================================
;; 1. THEME CONFIGURATION
;; ============================================
;; The default theme is doom-1337. To change it, uncomment one of these:
;; (setq themes-config-preferred-theme 'doom-zenburn)        ; Retro warm colors
;; (setq themes-config-preferred-theme 'doom-Iosvkem)        ; Clean, modern dark theme
;; (setq themes-config-preferred-theme 'doom-gruvbox)        ; Retro groove colors
;; (setq themes-config-preferred-theme 'doom-material-dark)  ; Material design dark variant
;; (setq themes-config-preferred-theme 'doom-monokai-machine) ; Enhanced Monokai colors
;; (setq themes-config-preferred-theme 'doom-tomorrow-night) ; Clean, minimal design
;; (setq themes-config-preferred-theme 'doom-peacock)        ; Vibrant, colorful theme
;; (setq themes-config-preferred-theme 'wombat)              ; Built-in dark theme
;; (setq themes-config-preferred-theme 'tango-dark)          ; Built-in tango variant

;; ============================================
;; 2. PLATFORM-SPECIFIC CONFIGURATION
;; ============================================
;; macOS XQuartz Key Mapping Fix
;; In XQuartz make sure that the following is enabled in "Settings"-> "Input" -> "Option key sends Alt_L and Alt_R".
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fix Command/Alt key swapping when using Emacs GUI over SSH from macOS with XQuartz
(when
 (and (display-graphic-p) (eq system-type 'gnu/linux))
 ;; Make Option key work as Meta in GUI mode (instead of printing special characters)
 (setq x-alt-keysym 'meta)
 ;; Also try setting the meta keysym
 (setq x-meta-keysym 'alt))

;; ============================================
;; 3. REMOTE DEVELOPMENT (TRAMP) CONFIGURATION
;; ============================================
;; The core configuration is set to be completely silent and NEVER show the
;; TRAMP connection buffer (`*tramp/ssh...*`) by default. Use the settings
;; below to see debugging information.

;; --- TRAMP Verbosity Level ---
;; To see debugging output, you must increase the verbosity level.
;; Uncomment the line below.
;; - A value of `3` shows basic connection messages.
;; - A value of `6` provides detailed debugging, which is recommended
;;   for troubleshooting.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setting this to any value greater than 2 will cause the TRAMP
;; connection buffer to appear.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (setq tramp-verbose 6)

;; ============================================
;; 4. LSP/EGLOT CONFIGURATION
;; ============================================
;; Disable eglot event logging to improve performance and reduce memory usage
;; Setting to 0 completely disables the *EGLOT events* buffer
(setq eglot-events-buffer-size 0)

;; ============================================
;; 5. FLYMAKE DIAGNOSTIC DISPLAY
;; ============================================
;; Show diagnostics inline at the end of problematic lines (Emacs 30+ only)
;; When enabled, error/warning messages appear directly in the code like:
;;   def foo(x):
;;       return x + "string"  # ❌ Operator not supported between int and str
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This can make the code look cluttered, so it's disabled by default.
;; To enable, uncomment the line below:
;; (setq flymake-show-diagnostics-at-end-of-line t)

;; ============================================
;; 6. SPELL CHECKING (ASPELL)
;; ============================================
;; Flymake-aspell is disabled by default.
;; - Toggle on/off in current buffer:
;;   C-c f a (or M-x toggle-flymake-aspell)
;; - To enable it automatically for text files (.txt, .md, etc.):
;;   (add-hook 'text-mode-hook 'enable-flymake-aspell)
;; - To enable it automatically for programming files (.py, .el, etc. - comments/strings only):
;;   (add-hook 'prog-mode-hook 'enable-flymake-aspell)
;; - You can enable both hooks if you work with both text and code files

;; ============================================
;; 7. GIT AUTO-SYNC (OPTIONAL)
;; ============================================
;; By default, git/forge syncing is MANUAL only (use M-x git-sync-repository).
;; To enable AUTOMATIC syncing (fetch magit data and pull forge metadata
;; once per repository when first file is opened), uncomment the lines below:
;; (logging-config "Enabling automatic git/forge sync on file open")
;; (add-hook 'find-file-hook #'git-auto-sync-repository-once)

;; ============================================
;; 8. DEBUG BUFFER AUTO-SAVE (OPTIONAL)
;; ============================================
;; Automatically save debug buffers (*Warnings*, *Compile-Log*, *Flymake diagnostics*,
;; *EGLOT stderr/output*, etc.) to ~/.emacs.d/local/log/debug/ when Emacs exits.
;;
;; Each buffer maintains its own rotation history (up to 5 files):
;;   Warnings.log → Warnings.log.1 → Warnings.log.2 → ... → Warnings.log.5
;;   Compile-Log.log → Compile-Log.log.1 → Compile-Log.log.2 → etc.
;;
;; The debug directory is only created if there are buffers to save.
;;
;; Uncomment the following line to enable auto-save on exit:
;; (add-hook 'kill-emacs-hook #'logging--save-debug-buffers-on-exit)
;;
;; Manual command available anytime:
;;   M-x logging-save-debug-buffers  - Save debug buffers immediately

;; ============================================
;; 9. FLYMAKE STRICT VALIDATION (OPTIONAL)
;; ============================================
;; Enable strict validation modes for Flymake backend configuration.
;; By default, all validation is warnings-only (non-breaking).
;; These options enforce stricter checking, useful for development/testing.

;; Validate registry on load - errors if any registry entry is invalid
;; (setq flymake-strict-validation t)

;; Require all backends to be registered - errors if backend not in registry
;; (setq flymake-require-registry-entry t)

;; Error on mode compatibility mismatches - errors instead of warning
;; (setq flymake-strict-mode-checking t)

;; ============================================
;; 10. ADDITIONAL EXAMPLES (COMMENTED OUT)
;; ============================================
;; Personal keybindings
;; (global-set-key (kbd "C-c p") 'my-personal-function)
;; (global-set-key (kbd "C-c t") 'switch-theme)  ; Quick theme switching
(logging-info "=== local.el: The loading of local user configuration finished ===")
(logging-success "Local user configuration loaded successfully")
(provide 'local)
;;; local.el ends here
