;;; theme-doom-1337.el --- Doom 1337 Theme Customizations -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Doom 1337 theme-specific customizations
;; WHY:  Isolates theme-specific settings for maintainability
;; PROVIDES: doom-1337 face customizations, modeline tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; All doom-1337 specific customizations including:
;; - Comment and doc face colors
;; - Modeline face customizations
;; - Breadcrumb customizations
;; - Other theme-specific tweaks

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'doom-themes)
(require 'themes-doom-1337-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 themes--doom-1337-apply-face-customizations
 ()
 "Apply all face customizations for doom-1337 theme."
 (custom-set-faces
  ;; Comment and documentation faces
  `(font-lock-comment-face ((t (:foreground ,themes-doom-1337-comment-color :slant italic))))
  `(font-lock-doc-face ((t (:foreground ,themes-doom-1337-comment-color :slant italic))))
  ;; Search and replace faces - match consult-line/orderless highlighting
  `(isearch ((t (:foreground ,themes-doom-1337-search-highlight-color :weight bold :underline t))))
  `(lazy-highlight ((t (:foreground ,themes-doom-1337-search-highlight-color :weight bold))))
  `(isearch-fail ((t (:foreground ,themes-doom-1337-color-red :weight bold))))))

(defun
 themes-doom-1337-modeline-faces-apply
 ()
 "Apply doom-1337 theme-specific colors to doom-modeline faces using shared color constants."

 ;; VCS State Color Mapping
 ;; Maps version control states to specific modeline faces for visual feedback
 (setq
  doom-modeline-vcs-state-faces-alist
  '((edited . doom-modeline-debug) ; Yellow for uncommitted changes
    (added . doom-modeline-info) ; Blue for added/staged files
    (removed . doom-modeline-urgent) ; Red for deleted files
    (conflict . doom-modeline-urgent) ; Red for merge conflicts
    (needs-merge . doom-modeline-warning) ; Orange for needs merge
    (needs-update . doom-modeline-warning) ; Orange for behind remote
    (unregistered . doom-modeline-vcs-default))) ; Purple for untracked files

 (custom-set-faces
  ;; Base modeline backgrounds
  `(mode-line
    ((t (:background ,themes-doom-1337-modeline-bg :foreground ,themes-doom-1337-modeline-fg))))
  `(mode-line-inactive
    ((t (:background ,themes-doom-1337-modeline-inactive-bg :foreground "#808080"))))

  ;; Buffer identification and state
  `(doom-modeline-buffer-file ((t (:foreground ,themes-doom-1337-color-cyan :weight bold))))
  `(doom-modeline-buffer-modified ((t (:foreground ,themes-doom-1337-color-yellow :weight bold))))
  `(doom-modeline-buffer-path ((t (:foreground ,themes-doom-1337-color-green))))
  `(doom-modeline-buffer-minor-mode ((t (:foreground ,themes-doom-1337-color-dim-gray))))

  ;; Project and directory
  `(doom-modeline-project-dir ((t (:foreground ,themes-doom-1337-color-blue :weight bold))))
  `(doom-modeline-project-root-dir ((t (:foreground ,themes-doom-1337-color-blue))))

  ;; Evil/modal editing states
  `(doom-modeline-evil-normal-state ((t (:foreground ,themes-doom-1337-color-cyan :weight bold))))
  `(doom-modeline-evil-insert-state
    ((t (:foreground ,themes-doom-1337-color-purple :weight bold))))
  `(doom-modeline-evil-visual-state
    ((t (:foreground ,themes-doom-1337-color-orange :weight bold))))
  `(doom-modeline-evil-replace-state ((t (:foreground ,themes-doom-1337-color-red :weight bold))))
  `(doom-modeline-evil-operator-state
    ((t (:foreground ,themes-doom-1337-color-blue :weight bold))))
  `(doom-modeline-evil-motion-state
    ((t (:foreground ,themes-doom-1337-color-yellow :weight bold))))
  `(doom-modeline-evil-emacs-state ((t (:foreground ,themes-doom-1337-color-green :weight bold))))

  ;; Git/VCS status faces
  `(doom-modeline-vcs-branch ((t (:foreground ,themes-doom-1337-color-purple)))) ; Branch name
  `(doom-modeline-vcs-default ((t (:foreground ,themes-doom-1337-color-purple)))) ; Clean repository

  ;; LSP/Language server
  `(doom-modeline-lsp-success ((t (:foreground ,themes-doom-1337-color-green))))
  `(doom-modeline-lsp-warning ((t (:foreground ,themes-doom-1337-color-orange))))
  `(doom-modeline-lsp-error ((t (:foreground ,themes-doom-1337-color-red))))
  `(doom-modeline-lsp-running ((t (:foreground ,themes-doom-1337-color-blue))))

  ;; Diagnostic/Checker status
  `(doom-modeline-info ((t (:foreground ,themes-doom-1337-color-blue))))
  `(doom-modeline-warning ((t (:foreground ,themes-doom-1337-color-orange))))
  `(doom-modeline-urgent ((t (:foreground ,themes-doom-1337-color-red :weight bold))))
  `(doom-modeline-debug ((t (:foreground ,themes-doom-1337-color-yellow))))

  ;; Compilation and process
  `(doom-modeline-compilation ((t (:foreground ,themes-doom-1337-color-blue))))

  ;; Input method
  `(doom-modeline-input-method ((t (:foreground ,themes-doom-1337-color-purple))))

  ;; Modeline emphasis and highlights
  `(doom-modeline-emphasis ((t (:foreground ,themes-doom-1337-color-cyan :weight bold))))
  `(doom-modeline-highlight ((t (:foreground ,themes-doom-1337-color-purple))))

  ;; Inactive modeline (non-selected windows)
  '(doom-modeline-inactive-buffer-file ((t (:foreground "#707070"))))
  '(doom-modeline-inactive-buffer-modified ((t (:foreground "#999999"))))

  ;; Bar and separator
  `(doom-modeline-bar ((t (:background ,themes-doom-1337-color-cyan))))
  `(doom-modeline-bar-inactive ((t (:background ,themes-doom-1337-modeline-inactive-bg))))

  ;; Time display
  `(doom-modeline-time ((t (:foreground ,themes-doom-1337-color-teal))))

  ;; Remote host indicator (TRAMP/SSH)
  `(doom-modeline-host ((t (:foreground ,themes-doom-1337-color-purple :weight bold))))

  ;; Panel (like treemacs integration)
  `(doom-modeline-panel
    ((t (:background ,themes-doom-1337-modeline-bg :foreground ,themes-doom-1337-color-cyan)))))

 (logging-theme "Applied doom-1337 modeline faces with gray background"))

(defun
 themes-doom-1337-breadcrumb-faces-apply
 ()
 "Apply doom-1337 theme-specific colors to breadcrumb faces using shared color constants."
 (when
  (featurep 'breadcrumb)
  (set-face-attribute 'breadcrumb-face nil :foreground themes-doom-1337-color-cyan)
  (set-face-attribute
   'breadcrumb-project-base-face
   nil
   :foreground themes-doom-1337-color-blue
   :weight 'bold)
  (set-face-attribute 'breadcrumb-project-crumbs-face nil :foreground themes-doom-1337-color-green)
  (set-face-attribute
   'breadcrumb-project-leaf-face
   nil
   :foreground themes-doom-1337-color-cyan
   :weight 'bold)
  (set-face-attribute 'breadcrumb-imenu-crumbs-face nil :foreground themes-doom-1337-color-green)
  (set-face-attribute
   'breadcrumb-imenu-leaf-face
   nil
   :foreground themes-doom-1337-color-cyan
   :weight 'bold)
  (logging-theme "Applied doom-1337 breadcrumb faces")))

(defun
 themes-doom-1337-markdown-faces-apply
 ()
 "Apply doom-1337 theme-specific colors to markdown link faces using shared color constants."
 (custom-set-faces
  ;; Markdown link text (applies to [text](url) style links)
  `(markdown-link-face ((t (:foreground ,themes-doom-1337-color-blue :underline t))))
  ;; Plain URLs (applies to standalone URLs like https://example.com)
  `(markdown-plain-url-face ((t (:foreground ,themes-doom-1337-color-blue :underline t))))
  ;; URL portion in markdown links (the URL part in [text](url))
  `(markdown-url-face ((t (:foreground ,themes-doom-1337-color-teal)))))
 (logging-theme "Applied doom-1337 markdown link faces"))

(defun
 themes-doom-1337-setup
 ()
 "Apply all doom-1337 theme customizations."
 (themes--doom-1337-apply-face-customizations)
 (themes-doom-1337-modeline-faces-apply)
 (themes-doom-1337-breadcrumb-faces-apply)
 (themes-doom-1337-markdown-faces-apply)
 (logging-theme "Applied doom-1337 customizations"))

;; Make this module available for loading with (require 'theme-doom-1337)
(provide 'theme-doom-1337)
;;; theme-doom-1337.el ends here
