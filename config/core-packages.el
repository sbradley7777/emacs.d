;;; core-packages.el --- Package Management Configuration
;;; Commentary:
;;      Package management and MELPA repository setup

(message "Loading core-packages.el...")
(message "Loading package management and MELPA repository.")
(require 'cl-lib)
(require 'package)
;; Enable both MELPA repositories for maximum package availability
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; Set package archive priorities (higher number = higher priority)
;; Prefer stable packages when available, fallback to development versions
(setq package-archive-priorities
      '(("melpa-stable" . 20)
        ("gnu" . 15)
        ("melpa" . 10)))

;; Package initialization - check if already initialized to prevent duplicate calls
;; This should eliminate the "Unnecessary call to 'package-initialize'" warning
(require 'package)
(unless package--initialized
  (package-initialize))
;; Secure keyring management - pin keyring updates to GNU ELPA for security
(add-to-list 'package-pinned-packages '("gnu-elpa-keyring-update" . "gnu"))

;; Ensure GNU ELPA keyring is available before installing other packages
;; This approach maintains security by keeping signature verification enabled
(unless (package-installed-p 'gnu-elpa-keyring-update)
  ;; Refresh package contents to get latest keyring package info
  (package-refresh-contents)
  ;; Install the keyring update package from GNU ELPA (signatures are trusted)
  (package-install 'gnu-elpa-keyring-update)
  ;; The keyring update will automatically update GPG keys for package verification
  (message "GNU ELPA keyring updated for secure package verification"))
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
  '(use-package
    spacemacs-theme
    zenburn-theme
    yaml-mode
    elpy
    flycheck
    pylint
    which-key
    )
  )

;; Install packages from myPackages list (including use-package)
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure use-package
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(eval-when-compile
  (require 'use-package))

;; Always ensure packages are installed
(setq use-package-always-ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package configurations using use-package
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package spacemacs-theme
	     :defer t)

(use-package zenburn-theme
	     :defer t)

(use-package yaml-mode
	     :mode ("\\.ya?ml\\'" . yaml-mode))

(use-package flycheck
	     :hook (prog-mode . flycheck-mode))

(use-package pylint
	     :after python)

(use-package elpy
	     :init
	     (elpy-enable)
	     :config
	     ;; Dynamically find Python executable for better portability
	     (setq python-shell-interpreter (or (executable-find "python3")
	                                        (executable-find "python")
	                                        "python3"))
	     (setq elpy-rpc-python-command (or (executable-find "python3")
	                                       (executable-find "python")
	                                       "python3"))
	     ;; Use flycheck instead of flymake
	     (when (require 'flycheck nil t)
	       (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
	       (add-hook 'elpy-mode-hook 'flycheck-mode)
	       (flycheck-add-next-checker 'python-flake8 'python-pylint)))

(use-package which-key
	     :config
	     (which-key-mode 1)
	     (setq which-key-idle-delay 0.5))

;; Make this module available for loading with (require 'core-packages)
(provide 'core-packages)
(message "core-packages.el loaded successfully.")
