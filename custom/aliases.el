;;; aliases.el --- Function Aliases and Shortcuts
;;; Commentary:
;;      Function aliases to improve usability and provide shortcuts
;;      for commonly used Emacs functions.

(message "Loading aliases.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interactive function aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use shorter y/n prompts instead of yes/no
(defalias 'yes-or-no-p 'y-or-n-p)

;; Make this module available for loading with (require 'aliases)
(provide 'aliases)
(message "aliases.el loaded successfully.")
