;;; early-init.el --- Early Initialization Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Early initialization file loaded before package.el and GUI initialization.
;;      This file is processed before init.el and is perfect for:
;;      - Performance optimizations
;;      - Preventing UI element flashing
;;      - Package system configuration

(message "Loading early-init.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance Optimizations - Startup Phase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Maximize garbage collection threshold during startup for faster loading
;; This will be restored to normal values in init.el after startup
(setq gc-cons-threshold most-positive-fixnum       ; Maximum possible value
      gc-cons-percentage 0.6)                      ; Allow 60% of heap for GC

;; Prevent premature redisplay during startup
(setq redisplay-dont-pause t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System Early Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disable package.el auto-initialization to prevent loading warnings
;; This must be done very early, before any package loading attempts
(setq package-enable-at-startup nil
      package-quickstart nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GUI Element Suppression - Prevents UI Flashing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disable GUI elements in default-frame-alist to prevent them from appearing
;; even briefly during startup (eliminates the "flash" effect)
;; Consolidated GUI element suppression (single operation for better performance)
(setq default-frame-alist
      (append default-frame-alist
              '((tool-bar-lines . 0)
                (menu-bar-lines . 0)
                (vertical-scroll-bars . nil)
                (horizontal-scroll-bars . nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File Handling Optimizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Optimize file-name-handler-alist during startup (restore in init.el)
(defvar default-file-name-handler-alist file-name-handler-alist
  "Backup of default file-name-handler-alist for restoration after init.")

;; Temporarily disable file name handlers for faster startup
(setq file-name-handler-alist nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Additional Startup Optimizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prevent unnecessary work during startup
(setq frame-inhibit-implied-resize t)          ; Don't resize frame implicitly
(setq inhibit-startup-screen t)                ; Skip startup screen
(setq inhibit-startup-echo-area-message t)     ; Skip echo area message
(setq initial-scratch-message nil)             ; Clean scratch buffer

;; Disable bidirectional text support for performance (can be re-enabled if needed)
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completion and Input Optimizations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reduce input processing overhead during startup
(setq idle-update-delay 1.0)                   ; Longer delay for idle updates during startup

;; Reduce startup noise and font cache overhead
(setq inhibit-compacting-font-caches t          ; Don't compact font caches during startup
      inhibit-startup-buffer-menu t)            ; Don't show buffer menu at startup

(message "early-init.el loaded successfully - performance optimizations active.")
