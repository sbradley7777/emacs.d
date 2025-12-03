;;; dired-config.el --- Dired Configuration with Nerd Icons -*- lexical-binding: t -*-
;;; Commentary:
;;      Enhanced dired configuration with icon support and inline directory expansion.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      TERMINAL FONT REQUIREMENT:
;;      To see icons in terminal mode (SSH or local terminal), your terminal emulator
;;      must use a Nerd Font.  Install a Nerd Font on the machine running the terminal:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      macOS (for iTerm2/Terminal.app):
;;        brew install font-fira-code-nerd-font
;;        Then configure iTerm2 → Preferences → Profiles → Text → Font → "FiraCode Nerd Font Mono"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      Linux (for local terminal):
;;        Download from https://www.nerdfonts.com/
;;        Extract to ~/.local/share/fonts/ and run: fc-cache -fv
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      Without a Nerd Font, you'll see empty boxes instead of icons.

;;; Code:
(require 'core-constants)
(require 'logging-init)

;; Declare external variables to suppress byte-compiler warnings
(defvar dired-dwim-target) ; From dired.el
(defvar dired-recursive-copies) ; From dired.el
(defvar dired-recursive-deletes) ; From dired.el
(defvar dired-kill-when-opening-new-dired-buffer) ; From dired.el
(defvar dired-auto-revert-buffer) ; From dired.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq dired-dwim-target t)
(setq dired-recursive-copies 'always)
(setq dired-recursive-deletes 'top)
(setq dired-listing-switches "-alh")
(setq dired-kill-when-opening-new-dired-buffer t)
(setq dired-auto-revert-buffer t)

(use-package
 nerd-icons-dired
 :hook (dired-mode . nerd-icons-dired-mode)
 :config (logging-config "Nerd icons dired mode configured"))

(use-package
 dired-subtree
 :after dired
 :bind (:map dired-mode-map ("i" . dired-subtree-toggle) ("TAB" . dired-subtree-cycle))
 :config (logging-config "Dired subtree configured - use 'i' to toggle subtrees"))
(provide 'dired-config)
;;; dired-config.el ends here
