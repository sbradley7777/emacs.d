;;; keybindings.el --- Global Key Bindings Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Keyboard behavior and custom hotkeys (keyboard-modifiers or shortcuts)

(require 'user-functions)

(core-utils-with-load-timing
 "keybindings.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Keyboard behavior and Custom HotKeys (aka: keyboard-modifiers or shortcuts):
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; List of hotkeys: http://www.math.uh.edu/~bgb/emacs_keys.html | Use CTRL-h k to describe keys (describe-key)

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
 (global-set-key (kbd "<f6>") 'delete-trailing-whitespace) ; Delete trailing whitespace

 ;; Navigation keybindings
 (global-set-key (kbd "C-c i a") 'imenu-anywhere) ; Cross-buffer symbol search

 ;; Keyboard commands for controlling the buffer.
 ;;
 ;; Scroll buffer down/up
 (global-set-key (kbd "ESC <left>") 'scroll-down) ; Scroll buffer down
 (global-set-key (kbd "ESC <right>") 'scroll-up) ; Scroll buffer up
 ;; Buffer navigation
 (global-set-key (kbd "<f7>") 'user-next-buffer) ; Cycle to next buffer that is filter to not include all buffers
 (global-set-key (kbd "<f8>") 'next-buffer) ; Cycle to next buffer
 (global-set-key (kbd "<f9>") 'command-palette-toggle) ; Toggle command palette

 ;; Page down/up move the point, not the screen. Can move point to beginning or end of buffer.
 ;; Reference: http://snarfed.org/emacs_page_up_page_down
 ;; Page down/up the buffer with smart boundaries
 (global-set-key (kbd "<f11>") 'user-smart-page-up) ; Page up with smart boundary handling
 (global-set-key (kbd "<f12>") 'user-smart-page-down) ; Page down with smart boundary handling

 ;; Make this module available for loading with (require 'keybindings)
 (provide 'keybindings))
