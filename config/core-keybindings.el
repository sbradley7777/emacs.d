;;; core-keybindings.el --- Global Key Bindings Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Keyboard behavior and custom hotkeys (keyboard-modifiers or shortcuts)

(defvar config-load-start-time (current-time))
(message "Loading core-keybindings.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keyboard behavior and Custom HotKeys (aka: keyboard-modifiers or shortcuts):
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; List of hotkeys: http://www.math.uh.edu/~bgb/emacs_keys.html | Use CTRL-h k to describe keys (describe-key)

;; Set up the keyboard so the delete key on both regular keyboard and keypad delete the character under the cursor
;; and to the right under X, instead of the default backspace behavior.
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)
(setq delete-key-deletes-forward t)


;; Utility function keys
(global-set-key [f1] 'flymake-show-buffer-diagnostics) ; Show Flymake diagnostics
(global-set-key [f4] 'kill-this-buffer) ; Kill the buffer
(global-set-key [f5] 'clipboard-kill-ring-save) ; Copy what is highlighted
(global-set-key [f6] 'delete-trailing-whitespace) ; Delete trailing whitespace


;; Keyboard commands for controlling the buffer.
;;
;; Scroll buffer down/up
(global-set-key (kbd "ESC <left>") 'scroll-down) ; Scroll buffer down
(global-set-key (kbd "ESC <right>") 'scroll-up) ; Scroll buffer up
;; Buffer navigation
(global-set-key [f7] 'previous-buffer) ; Cycle to previous buffer
(global-set-key [f8] 'next-buffer) ; Cycle to next buffer
(global-set-key [f9] 'beginning-of-buffer) ; Goto top of buffer
(global-set-key [f10] 'end-of-buffer) ; Goto end of buffer

;; Page down/up move the point, not the screen. Can move point to beginning or end of buffer.
;; Reference: http://snarfed.org/emacs_page_up_page_down
;; Page down/up the buffer with smart boundaries
(global-set-key
 [f11]
 (lambda ()
   (interactive)
   (condition-case nil
       (scroll-down)
     (beginning-of-buffer
      (goto-char (point-min))))))

(global-set-key
 [f12]
 (lambda ()
   (interactive)
   (condition-case nil
       (scroll-up)
     (end-of-buffer
      (goto-char (point-max))))))

;; Make this module available for loading with (require 'core-keybindings)
(provide 'core-keybindings)
(message "core-keybindings.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
