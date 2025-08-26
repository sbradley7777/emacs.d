;;; core-packages.el --- Package Management Configuration
;;; Commentary:
;;      Package management and MELPA repository setup

(message "Loading core-packages.el...")
(message "Loading package management and MELPA repository.")
(require 'cl-lib)
(require 'package)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
;;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; The init will load all the packages into the load path.
(package-initialize)
(add-to-list 'package-pinned-packages '("gnu-elpa-keyring-update" . "gnu"))
;; Install or update the key required for "melpa".
;;   - https://stackoverflow.com/questions/5701388/where-can-i-find-the-public-key-for-gnu-emacs
(unless (package-installed-p 'gnu-elpa-keyring-update)
  ;; Save default value of `package-check-signature' variable
  (defvar package-check-signature-default package-check-signature)
  ;; Disable signature checking
  (setq package-check-signature nil)
  ;; Download package archives (without signature checking)
  (package-refresh-contents)
  ;; Install package `gnu-elpa-keyring-update' (without signature checking)
  (package-install 'gnu-elpa-keyring-update t)
  ;; Restore `package-check-signature' value to default.
  (setq package-check-signature package-check-signature-default))
;; If there are no archived package contents, refresh them
(when (not package-archive-contents)
  (package-refresh-contents))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Install and load packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; myPackages contains a list of package names
;;   - https://github.com/nashamri/spacemacs-theme
;;   - https://github.com/jorgenschaefer/elpy?tab=readme-ov-file
(defvar myPackages
  '(spacemacs-theme
    zenburn-theme
    yaml-mode
    elpy
    flycheck
    pylint
    )
  )

;; Scans the list in myPackages and if the package listed is not already installed, then install it.
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

(provide 'core-packages)
(message "core-packages.el loaded successfully.")
