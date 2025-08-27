;;; theme-config.el --- Theme Configuration
;;; Commentary:
;;      Theme selection and customization

(message "Loading theme-config.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure the theme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Theme
;;   - https://github.com/bbatsov/zenburn-emacs
;; Set variables for theme.
;;  - https://github.com/bbatsov/zenburn-emacs?tab=readme-ov-file#customization
(setq zenburn-override-colors-alist
      '(("zenburn-bg"  . "#000000")
        ))
;; Load the theme.
(load-theme 'zenburn t)

(provide 'theme-config)
(message "theme-config.el loaded successfully.")
