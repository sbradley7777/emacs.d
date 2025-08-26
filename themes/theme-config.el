;;; theme-config.el --- Theme Configuration
;;; Commentary:
;; Theme selection and customization
;;; Code:

(message "Loading theme-config.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure the theme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; List of themes
;;   - https://melpa.org/#/?q=theme&sort=downloads&asc=false
;; Set variables for theme.
;;   - https://github.com/nashamri/spacemacs-theme?tab=readme-ov-file#override-themes-colors
;;(custom-set-variables
;; '(spacemacs-theme-comment-bg nil)
;; '(spacemacs-theme-custom-colors (quote ((bg1 . "#000000")))))
;;(custom-set-faces)
;; Load the theme.
;;   - https://github.com/nashamri/spacemacs-theme
;; (load-theme 'spacemacs-dark t)

;; Set variables for theme.
;;  - https://github.com/bbatsov/zenburn-emacs?tab=readme-ov-file#customization
(setq zenburn-override-colors-alist
      '(("zenburn-bg"  . "#000000")
        ))
;; Load the theme.
;;   - https://github.com/bbatsov/zenburn-emacs
(load-theme 'zenburn t)

(message "theme-config.el loaded successfully.")
(provide 'theme-config)
;;; theme-config.el ends here
