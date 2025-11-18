;;; user-keybindings.el --- User Key Bindings Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      User-specific keyboard behavior and custom hotkeys (keyboard-modifiers or shortcuts)

;;; Code:
(require 'core-utils)
(require 'user-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set up the keyboard so the delete key on both regular keyboard and keypad delete the character under the cursor
;; and to the right under X, instead of the default backspace behavior.
(global-set-key (kbd "<delete>") 'delete-char)
(global-set-key (kbd "<kp-delete>") 'delete-char)
(setq delete-key-deletes-forward t)

;; Use Alt-c instead of Command-c on osx for copying.
(global-set-key (kbd "M-c") 'kill-ring-save) ; Copy selected region

;; Utility function keys
(global-set-key (kbd "<f1>") 'toggle-flymake-diagnostics-window) ; Show Flymake diagnostics
(global-set-key (kbd "<f2>") 'flymake-goto-prev-error) ; Go to previous flymake error
(global-set-key (kbd "<f3>") 'flymake-goto-next-error) ; Go to next flymake error
(global-set-key (kbd "<f4>") 'treemacs-smart-toggle) ; Smart toggle Treemacs file tree
(global-set-key (kbd "C-x t 1") 'treemacs-delete-other-windows) ; Treemacs delete other windows
(global-set-key (kbd "C-x t t") 'treemacs) ; Open treemacs
(global-set-key (kbd "C-x t C-t") 'treemacs-find-file) ; Find file in treemacs
(global-set-key (kbd "<f5>") 'user-imenu-list-smart-toggle) ; Smart toggle imenu-list symbol navigation
(global-set-key (kbd "<f6>") 'delete-trailing-whitespace) ; Delete trailing whitespace

;; Navigation keybindings
(global-set-key (kbd "C-c i a") 'imenu-anywhere) ; Cross-buffer symbol search
(global-set-key (kbd "C-c i l") 'user-imenu-list-smart-toggle) ; Toggle imenu-list sidebar
(global-set-key (kbd "C-c i s") 'imenu-list-show-current-symbol) ; Show current symbol in imenu-list
(global-set-key (kbd "C-c i r") 'imenu-list-refresh) ; Refresh imenu-list

;; Git diff navigation (diff-hl)
(global-set-key (kbd "C-c g n") 'diff-hl-next-hunk) ; Jump to next change
(global-set-key (kbd "C-c g p") 'diff-hl-previous-hunk) ; Jump to previous change
(global-set-key (kbd "C-c g d") 'diff-hl-diff-goto-hunk) ; Show diff for current change
(global-set-key (kbd "C-c g r") 'diff-hl-revert-hunk) ; Revert current change

(global-set-key (kbd "ESC <left>") 'scroll-down) ; Scroll buffer down
(global-set-key (kbd "ESC <right>") 'scroll-up) ; Scroll buffer up
;; Buffer navigation
(global-set-key (kbd "<f7>") 'user-next-buffer) ; Cycle to next buffer that is filter to not include all buffers
(global-set-key (kbd "<f8>") 'next-buffer) ; Cycle to next buffer
(global-set-key (kbd "<f9>") 'command-palette-toggle) ; Toggle command palette
(global-set-key (kbd "<f10>") 'toggle-forge-issues-window) ; Toggle forge issues window

;; Page down/up move the point, not the screen. Can move point to beginning or end of buffer.
;; Reference: http://snarfed.org/emacs_page_up_page_down
;; Page down/up the buffer with smart boundaries
(global-set-key (kbd "<f11>") 'user-smart-page-up) ; Page up with smart boundary handling
(global-set-key (kbd "<f12>") 'user-smart-page-down) ; Page down with smart boundary handling

(with-eval-after-load
 'consult
 (global-set-key (kbd "C-x b") 'consult-buffer) ; Better buffer switching with preview
 (global-set-key (kbd "C-s") 'consult-line) ; Better in-buffer search with preview
 (global-set-key (kbd "M-y") 'consult-yank-pop) ; Better kill ring browsing
 (global-set-key (kbd "M-g g") 'consult-goto-line) ; Better goto-line
 (global-set-key (kbd "M-g M-g") 'consult-goto-line) ; Alternative binding
 (core-message-config "Consult keybindings configured"))
(provide 'user-keybindings)
;;; user-keybindings.el ends here
