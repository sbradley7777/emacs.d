;;; command-palette-defaults.el --- Default Command Lists -*- lexical-binding: t -*-
;;; Commentary:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Default command lists for Command Palette.
;;
;; This file contains the canonical default lists for:
;; - Favorite commands (general-purpose commands)
;; - Diagnostic commands (system diagnostics and debugging)
;;
;; These defaults are used when no user customization file exists.
;; Users can modify these lists to customize their initial command palette setup.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Default Favorites List
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette-default-favorites
 '(("User Git Commit Format" . user-git-commit-format)
   ("User Copy Whole Buffer" . user-copy-whole-buffer)
   ("Menu Bar Open" . menu-bar-open)
   ("Show Installed Packages" . pkg-system-ui-show-installed)
   ("Search Packages" . pkg-system-ui-search)
   ("Show Package Upgrades" . pkg-system-ui-show-upgrades)
   ("Refresh Package Archive Lists" . pkg-system-operations-refresh-archives)
   ("Toggle List Themes" . toggle-list-themes-window)
   ("Toggle Aspell Backend" . aspell-toggle-backend)
   ("Pyvenv Activate" . pyvenv-activate)
   ("Pyvenv Deactivate" . pyvenv-deactivate)
   ("Pyvenv Workon" . pyvenv-workon)
   ("Run Python" . run-python)
   ("Shell" . shell)
   ("Treesit Install Language Grammar" . treesit-install-language-grammar)
   ("Elisp Autofmt Buffer" . elisp-autofmt-buffer)
   ("Vertico Next" . vertico-next)
   ("Project List Buffers" . project-list-buffers)
   ("Magit Status" . magit-status)
   ("Git Sync Repository" . git-sync-repository)
   ("Toggle Git Issues Window" . toggle-forge-issues-window)
   ("Generate Forge Authinfo Entries" . forge-authinfo-generate-entries))
 "Default list of favorite commands.
Format: ((\"Display Name\" . command-symbol) ...)

These commands represent general-purpose utilities and frequently-used operations.
This list is used when no user customization file exists at:
  ~/.emacs.d/local/command_palette/favorites.el

To customize, either:
  1. Modify this constant and restart Emacs
  2. Use the command palette UI to add/remove favorites (persists automatically)")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Default Diagnostics List
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette-default-diagnostics
 '(("Diagnostics Show System" . diagnostics-show-system)
   ("Diagnostics Show Flymake Backends" . diagnostics-show-flymake-backends)
   ("Diagnostics Show Forge Hosts" . diagnostics-show-forge-hosts)
   ("Diagnostics Show Package System" . diagnostics-show-pkg-system)
   ("Save Diagnostic Buffers" . logging-save-debug-buffers))
 "Default list of diagnostic commands.
Format: ((\"Display Name\" . command-symbol) ...)

These commands provide system diagnostics, debugging, and troubleshooting utilities.
This list is used when no user customization file exists at:
  ~/.emacs.d/local/command_palette/diagnostics.el

To customize, either:
  1. Modify this constant and restart Emacs
  2. Use the command palette UI to promote/manage diagnostics (persists automatically)")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Excluded Commands List
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette-excluded-commands
 '(toggle-command-palette
   command-palette--add-favorite
   command-palette--add-favorite-from-diagnostics
   command-palette--remove-favorite
   command-palette--clear-history
   keyboard-quit
   keyboard-escape-quit
   abort-recursive-edit
   exit-minibuffer
   minibuffer-complete
   minibuffer-complete-and-exit
   completion-at-point
   minibuffer-completion-help
   self-insert-command
   delete-backward-char
   y-or-n-p-insert-other
   undefined)
 "Commands to exclude from M-x history tracking.

These commands are filtered out of the command palette history because they are:
  - Internal command palette commands (would create recursion)
  - Low-level minibuffer/completion commands (too noisy)
  - Basic editing commands (not useful to track)

Commands in this list will never appear in the Recent Commands section.")

(provide 'command-palette-defaults)
;;; command-palette-defaults.el ends here
