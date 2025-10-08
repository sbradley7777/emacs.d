;;; theme-doom-1337.el --- Doom 1337 Theme Customizations -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Doom 1337 theme-specific customizations
;; WHY:  Isolates theme-specific settings for maintainability
;; PROVIDES: doom-1337 face customizations, modeline tweaks
;;
;; All doom-1337 specific customizations including:
;; - Comment and doc face colors
;; - Modeline face customizations
;; - Breadcrumb customizations
;; - Other theme-specific tweaks

;;; Dependencies:
;; - doom-themes package

(require 'doom-themes)

(core-utils-with-load-timing
 "theme-doom-1337.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Comment Color Customization
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defvar
  doom-1337-comment-color
  "#989898"
  "Custom comment color for doom-1337 theme - light gray for better readability.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Face Customizations
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  doom-1337-apply-face-customizations () "Apply all face customizations for doom-1337 theme."
  (custom-set-faces
   ;; Comment and documentation faces
   `(font-lock-comment-face ((t (:foreground ,doom-1337-comment-color :slant italic))))
   `(font-lock-doc-face ((t (:foreground ,doom-1337-comment-color :slant italic))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Modeline Face Customizations
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  doom-1337-modeline-faces-apply ()
  "Apply doom-1337 theme-specific colors to doom-modeline faces.
Doom-1337 color palette:
  - Cyan: #00ff9f (primary accent, bright cyan-green)
  - Purple: #ff00ff (secondary accent, magenta)
  - Blue: #00b8ff (tertiary accent, bright blue)
  - Orange: #ff9800 (warnings)
  - Red: #ff0055 (errors, critical)
  - Yellow: #ffe66d (modified, attention)
  - Green: #7bc275 (success, additions)
  - Dark bg: #191919 (background)
  - Light fg: #c5c8c6 (foreground text)"

  (custom-set-faces
   ;; Buffer identification and state
   '(doom-modeline-buffer-file ((t (:foreground "#00ff9f" :weight bold)))) ; Bright cyan for current file
   '(doom-modeline-buffer-modified ((t (:foreground "#ffe66d" :weight bold)))) ; Yellow for modified state
   '(doom-modeline-buffer-path ((t (:foreground "#7bc275")))) ; Green for file path
   '(doom-modeline-buffer-minor-mode ((t (:foreground "#8c8c8c")))) ; Dim gray for minor modes

   ;; Project and directory
   '(doom-modeline-project-dir ((t (:foreground "#00b8ff" :weight bold)))) ; Bright blue for project
   '(doom-modeline-project-root-dir ((t (:foreground "#00b8ff")))) ; Blue for root directory

   ;; Evil/modal editing states
   '(doom-modeline-evil-normal-state ((t (:foreground "#00ff9f" :weight bold)))) ; Cyan for normal
   '(doom-modeline-evil-insert-state ((t (:foreground "#ff00ff" :weight bold)))) ; Purple for insert
   '(doom-modeline-evil-visual-state ((t (:foreground "#ff9800" :weight bold)))) ; Orange for visual
   '(doom-modeline-evil-replace-state ((t (:foreground "#ff6b9d" :weight bold)))) ; Light red for replace
   '(doom-modeline-evil-operator-state ((t (:foreground "#00b8ff" :weight bold)))) ; Blue for operator
   '(doom-modeline-evil-motion-state ((t (:foreground "#ffe66d" :weight bold)))) ; Yellow for motion
   '(doom-modeline-evil-emacs-state ((t (:foreground "#7bc275" :weight bold)))) ; Green for emacs state

   ;; Git/VCS status
   '(doom-modeline-vcs-branch ((t (:foreground "#ff00ff")))) ; Purple for branch name
   '(doom-modeline-vcs-info ((t (:foreground "#8c8c8c")))) ; Gray for VCS info

   ;; LSP/Language server
   '(doom-modeline-lsp-success ((t (:foreground "#7bc275")))) ; Green for LSP connected
   '(doom-modeline-lsp-warning ((t (:foreground "#ff9800")))) ; Orange for warnings
   '(doom-modeline-lsp-error ((t (:foreground "#ff6b9d")))) ; Light red for errors
   '(doom-modeline-lsp-running ((t (:foreground "#00b8ff")))) ; Blue for LSP running

   ;; Diagnostic/Checker status
   '(doom-modeline-info ((t (:foreground "#00b8ff")))) ; Blue for info
   '(doom-modeline-warning ((t (:foreground "#ff9800")))) ; Orange for warnings
   '(doom-modeline-urgent ((t (:foreground "#ff6b9d" :weight bold)))) ; Light red for errors/urgent
   '(doom-modeline-debug ((t (:foreground "#ffe66d")))) ; Yellow for debug

   ;; Compilation and process
   '(doom-modeline-compilation ((t (:foreground "#00b8ff")))) ; Blue for compilation status

   ;; Input method
   '(doom-modeline-input-method ((t (:foreground "#ff00ff")))) ; Purple for input method

   ;; Modeline emphasis and highlights
   '(doom-modeline-emphasis ((t (:foreground "#00ff9f" :weight bold)))) ; Cyan for emphasized items
   '(doom-modeline-highlight ((t (:foreground "#ff00ff")))) ; Purple for highlights

   ;; Inactive modeline (non-selected windows)
   '(doom-modeline-inactive-buffer-file ((t (:foreground "#5f5f5f")))) ; Dim for inactive
   '(doom-modeline-inactive-buffer-modified ((t (:foreground "#8c8c8c")))) ; Dim yellow for inactive modified

   ;; Bar and separator
   '(doom-modeline-bar ((t (:background "#00ff9f")))) ; Cyan bar
   '(doom-modeline-bar-inactive ((t (:background "#3a3a3a")))) ; Dark bar for inactive

   ;; Time display
   '(doom-modeline-time ((t (:foreground "#ff6b9d")))) ; Light red for time

   ;; Panel (like treemacs integration)
   '(doom-modeline-panel ((t (:background "#242424" :foreground "#00ff9f"))))) ; Dark bg, cyan fg

  (core-message-theme "Applied doom-1337 modeline faces"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Main Setup Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  doom-1337-setup
  ()
  "Apply all doom-1337 theme customizations."
  (doom-1337-apply-face-customizations)
  (doom-1337-modeline-faces-apply)
  (core-message-theme "Applied doom-1337 customizations")))

;; Make this module available for loading with (require 'theme-doom-1337)
(provide 'theme-doom-1337)

;;; theme-doom-1337.el ends here
