;;; early-init.el --- Early Initialization Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Early initialization file loaded before package.el and GUI initialization.
;;      This file is processed before init.el and is perfect for:
;;      - Performance optimizations
;;      - Preventing UI element flashing
;;      - Package system configuration
;; Set up minimal load path for loading constants and utilities early

;;; Code:
(add-to-list 'load-path (expand-file-name "core" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "core/logging" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "core/pkg-system" user-emacs-directory))
;; Load constants first (includes emacs-local-dir and startup constants)
(require 'core-constants)
;; Load message utilities for consistent logging
(require 'core-logging)
(core-message-loading "Loading early-init.el...")

;; Declare external variables to suppress byte-compiler warnings
(defvar package-enable-at-startup) ; From package.el
(defvar package-quickstart) ; From package.el
(defvar native-comp-async-env-modifier-form) ; From comp.el
(defvar which-func-update-delay) ; From which-func.el
(defvar byte-compile-output-dir) ; From bytecomp.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 default-file-name-handler-alist
 file-name-handler-alist
 "Backup of default `file-name-handler-alist' for restoration after init.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 early-init--running-in-snap-p
 ()
 "Return non-nil if Emacs is running from a Snap package."
 (string-match-p "/snap/" invocation-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance Optimizations - Startup Phase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Maximize garbage collection threshold during startup for faster loading
;; This will be restored to normal values in init.el after startup
(setq
 gc-cons-threshold most-positive-fixnum ; Maximum possible value
 gc-cons-percentage core-gc-percentage-startup) ; Allow % of heap for GC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System Early Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure package directory to use emacs-local-dir
(setq package-user-dir core-packages-dir)
;; Disable package.el auto-initialization to prevent loading warnings
;; This must be done very early, before any package loading attempts
(setq package-enable-at-startup nil package-quickstart nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Version-Specific Byte-Code Compilation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Store byte-compiled files (.elc) in a version-specific directory to
;; prevent stale file issues when switching Emacs versions.
(setq
 byte-compile-output-dir
 (expand-file-name (format core-byte-compile-dir-pattern emacs-version) user-emacs-directory))
;; Set docstring maximum column to match project line-length standard.
;; This prevents byte-compiler warnings about "docstring wider than 80 characters" during
;; batch compilation. Without this, batch mode uses the default value of 80, ignoring
;; the `fill-column' setting in core-editing.el which only applies to interactive sessions.
(setq byte-compile-docstring-max-column core-fill-column)
;; Configure async compilation (native-comp) to use the same docstring width setting.
;; This form is evaluated in each async compilation subprocess before compilation begins.
;; Without this, async compilation spawns new Emacs processes that don't load early-init.el
;; and thus use the default 80-character limit, generating false warnings.
(setq
 native-comp-async-env-modifier-form `(setq byte-compile-docstring-max-column ,core-fill-column))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File Handling Optimizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Temporarily disable file name handlers for faster startup
(setq file-name-handler-alist nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Additional Startup Optimizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prevent unnecessary work during startup
(setq frame-inhibit-implied-resize t) ; Don't resize frame implicitly
(setq inhibit-startup-screen t) ; Skip startup screen
(setq inhibit-startup-echo-area-message t) ; Skip echo area message
(setq initial-scratch-message nil) ; Clean scratch buffer
;; Disable bidirectional text support for performance (can be re-enabled if needed)
(setq-default bidi-display-reordering 'left-to-right bidi-paragraph-direction 'left-to-right)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completion and Input Optimizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reduce input processing overhead during startup
(setq which-func-update-delay core-idle-update-delay-startup) ; Longer delay for idle updates during startup
;; Reduce startup noise and font cache overhead
(setq
 inhibit-compacting-font-caches t ; Don't compact font caches during startup
 inhibit-startup-buffer-menu t) ; Don't show buffer menu at startup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System Initialization (early)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrap the package system and install use-package
(require 'pkg-system-manager)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Native Compilation Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Snap packages have library compatibility issues with native compilation due to:
;; 1. Host system libraries vs Snap's bundled libraries (Ubuntu-based)
;; 2. Linker errors with .relr.dyn sections (newer ELF feature incompatibility)
;; 3. Library path conflicts between /var/lib/snapd/snap/.../lib and system libs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Detection: Snap installations run from /var/lib/snapd/snap/emacs/*/usr/bin/
;; Solution: Disable native compilation for Snap, enable for other platforms (macOS, Linux, etc.)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; KNOWN ISSUE: Even with comprehensive disabling (deferred, JIT, and trampolines all set to nil),
;; Snap's Emacs may still attempt some background compilation. This appears to be hardcoded
;; behavior in the Snap package itself, not user configuration. The compilation attempts can
;; be safely ignored as they don't affect functionality, but may generate background noise
;; in compilation buffers. This is an acceptable limitation for Snap environments.
(if
 (early-init--running-in-snap-p)
 (progn
  ;; Disable native compilation for Snap due to library compatibility issues
  (setq native-comp-jit-compilation nil)
  (setq native-comp-enable-subr-trampolines nil)
  (setq native-comp-eln-load-path (list core-eln-cache-dir))
  (core-message-warning "Native compilation disabled (running in Snap environment)"))
 (progn
  ;; Enable native compilation for non-Snap installations (macOS, Linux, etc.)
  (setq native-comp-jit-compilation t)
  (setq native-comp-eln-load-path (list core-eln-cache-dir))
  (core-message-success "Native compilation enabled (standard installation)")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ensure all essential directories exist on startup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load core utilities for directory creation
(add-to-list 'load-path (expand-file-name "core" user-emacs-directory))
(require 'core-utils)
(let ((dirs-to-create
       (list
        core-eln-cache-dir
        core-files-autosave-dir
        core-files-backup-dir
        core-files-auto-save-list-dir
        core-packages-dir)))
  (dolist (dir dirs-to-create) (core-utils-ensure-directory dir)))
(core-message-success "early-init.el loaded successfully - performance optimizations active.")
(provide 'early-init)
;;; early-init.el ends here
