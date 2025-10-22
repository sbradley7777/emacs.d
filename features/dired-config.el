;;; dired-config.el --- Dired Configuration with Nerd Icons -*- lexical-binding: t -*-
;;; Commentary:
;;      Enhanced dired configuration with icon support and inline directory expansion.
;;
;;      TERMINAL FONT REQUIREMENT:
;;      To see icons in terminal mode (SSH or local terminal), your terminal emulator
;;      must use a Nerd Font. Install a Nerd Font on the machine running the terminal:
;;
;;      macOS (for iTerm2/Terminal.app):
;;        brew install font-fira-code-nerd-font
;;        Then configure iTerm2 → Preferences → Profiles → Text → Font → "FiraCode Nerd Font Mono"
;;
;;      Linux (for local terminal):
;;        Download from https://www.nerdfonts.com/
;;        Extract to ~/.local/share/fonts/ and run: fc-cache -fv
;;
;;      Without a Nerd Font, you'll see empty boxes instead of icons.
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "dired-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Built-in Dired Settings
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Better dired defaults
 (setq dired-dwim-target t) ; Suggest other visible dired buffer as copy/move target
 (setq dired-recursive-copies 'always) ; Always copy directories recursively
 (setq dired-recursive-deletes 'top) ; Ask once for recursive deletes
 (setq dired-listing-switches "-alh") ; Human-readable sizes in listings
 (setq dired-kill-when-opening-new-dired-buffer t) ; Kill old dired buffer when opening new one

 ;; Auto-refresh dired buffers when files change
 (setq dired-auto-revert-buffer t)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Nerd Icons Dired
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Configure nerd-icons-dired for icon support in dired buffers
 ;; Provides file-type icons using Nerd Fonts (works in both GUI and terminal with proper font)
 (use-package
  nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode)
  :config (core-message-config "Nerd icons dired mode configured"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Dired Subtree
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Configure dired-subtree for inline directory expansion
 ;; Press 'i' on a directory to expand/collapse it inline (like a tree view)
 (use-package
  dired-subtree
  :after dired
  :bind
  (:map
   dired-mode-map ("i" . dired-subtree-toggle)
   ("TAB" . dired-subtree-cycle)) ; TAB to cycle expand/collapse depth
  :config (core-message-config "Dired subtree configured - use 'i' to toggle subtrees")))
(provide 'dired-config)
