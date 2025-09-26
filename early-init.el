;;; early-init.el --- Early Initialization Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Early initialization file loaded before package.el and GUI initialization.
;;      This file is processed before init.el and is perfect for:
;;      - Performance optimizations
;;      - Preventing UI element flashing
;;      - Package system configuration

;; Early init constants (can't require core-constants since load path not set up yet)
(defconst early-gc-percentage-startup 0.6 "GC percentage during startup (60% of heap).")
(defconst early-idle-update-delay-startup 1.0 "Idle update delay during startup.")
(defconst
 emacs-local-dir
 (expand-file-name "local/" user-emacs-directory)
 "Path to ~/.emacs.d/local/ directory.")

(message "🔄  Loading early-init.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance Optimizations - Startup Phase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Maximize garbage collection threshold during startup for faster loading
;; This will be restored to normal values in init.el after startup
(setq
 gc-cons-threshold most-positive-fixnum ; Maximum possible value
 gc-cons-percentage early-gc-percentage-startup) ; Allow % of heap for GC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System Early Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure package directory to use emacs-local-dir
(setq package-user-dir (expand-file-name "elpa" emacs-local-dir))

;; Disable package.el auto-initialization to prevent loading warnings
;; This must be done very early, before any package loading attempts
(setq package-enable-at-startup nil package-quickstart nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Version-Specific Byte-Code Compilation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Store byte-compiled files (.elc) in a version-specific directory to
;; prevent stale file issues when switching Emacs versions.
(setq
 byte-compile-output-dir (expand-file-name (format "elc/%s" emacs-version) user-emacs-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GUI Element Suppression - Prevents UI Flashing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disable GUI elements in default-frame-alist to prevent them from appearing
;; even briefly during startup (eliminates the "flash" effect)
;; Consolidated GUI element suppression (single operation for better performance)
(setq
 default-frame-alist
 (append
  default-frame-alist
  '((tool-bar-lines . 0)
    (menu-bar-lines . 0)
    (vertical-scroll-bars . nil)
    (horizontal-scroll-bars . nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File Handling Optimizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Optimize file-name-handler-alist during startup (restore in init.el)
(defvar
 default-file-name-handler-alist
 file-name-handler-alist
 "Backup of default file-name-handler-alist for restoration after init.")

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
(setq which-func-update-delay early-idle-update-delay-startup) ; Longer delay for idle updates during startup

;; Reduce startup noise and font cache overhead
(setq
 inhibit-compacting-font-caches t ; Don't compact font caches during startup
 inhibit-startup-buffer-menu t) ; Don't show buffer menu at startup

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System Initialization (early)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add core directory to load-path to find package-system files
(add-to-list 'load-path (expand-file-name "core" user-emacs-directory))

;; Bootstrap the package system and install use-package
(require 'package-system/manager)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Native Compilation Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Snap packages have library compatibility issues with native compilation due to:
;; 1. Host system libraries vs Snap's bundled libraries (Ubuntu-based)
;; 2. Linker errors with .relr.dyn sections (newer ELF feature incompatibility)
;; 3. Library path conflicts between /var/lib/snapd/snap/.../lib and system libs
;;
;; Detection: Snap installations run from /var/lib/snapd/snap/emacs/*/usr/bin/
;; Solution: Disable native compilation for Snap, enable for other platforms (macOS, Linux, etc.)
;;
;; KNOWN ISSUE: Even with comprehensive disabling (deferred, JIT, and trampolines all set to nil),
;; Snap's Emacs may still attempt some background compilation. This appears to be hardcoded
;; behavior in the Snap package itself, not user configuration. The compilation attempts can
;; be safely ignored as they don't affect functionality, but may generate background noise
;; in compilation buffers. This is an acceptable limitation for Snap environments.

(defun
 running-in-snap-p
 ()
 "Return non-nil if Emacs is running from a Snap package."
 (string-match-p "/snap/" invocation-directory))

(if
 (running-in-snap-p)
 (progn
  ;; Disable native compilation for Snap due to library compatibility issues
  (setq native-comp-deferred-compilation nil)
  (setq native-comp-jit-compilation nil)
  (setq native-comp-enable-subr-trampolines nil)
  (setq native-comp-eln-load-path (list (expand-file-name "eln-cache" emacs-local-dir)))
  (message "⚠️  Native compilation disabled (running in Snap environment)"))
 (progn
  ;; Enable native compilation for non-Snap installations (macOS, Linux, etc.)
  (setq native-comp-deferred-compilation t)
  (setq native-comp-eln-load-path (list (expand-file-name "eln-cache" emacs-local-dir)))
  (message "✅  Native compilation enabled (standard installation)")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ensure all essential directories exist on startup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(let ((dirs-to-create
       (list
        (expand-file-name "eln-cache" emacs-local-dir)
        (expand-file-name "tramp-autosave" emacs-local-dir)
        (expand-file-name "autosaves" emacs-local-dir)
        (expand-file-name "backups" emacs-local-dir)
        (expand-file-name "auto-save-list" emacs-local-dir)
        (expand-file-name "elpa" emacs-local-dir))))
  (dolist (dir dirs-to-create) (unless (file-directory-p dir) (make-directory dir t))))

(message "✅  early-init.el loaded successfully - performance optimizations active.")

(provide 'early-init)
