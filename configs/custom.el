;;; custom.el --- Emacs Customize Interface Settings -*- lexical-binding: t -*-
;;; Commentary:
;;      This file contains customizations made through Emacs' built-in customize interface.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      USAGE:
;;      - Accessed via M-x customize or the Options menu
;;      - Changes made through the customize interface are automatically saved here
;;      - This file is loaded conditionally during startup if it exists
;;      - Kept in .gitignore to preserve personal customizations locally
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      WHAT'S STORED HERE:
;;      - custom-set-variables: User preferences set through customize interface
;;      - custom-set-faces: Font and color customizations from customize
;;      - All settings use the standard Emacs customize system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      NOTE: This is a test file demonstrating the loading mechanism.
;;      Real customize changes will overwrite this content automatically.

;;; Code:
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; Display a message to confirm loading
(require 'core-logging)
(core-message-success "custom.el loaded - menu customizations are working!")
(provide 'custom)
;;; custom.el ends here
