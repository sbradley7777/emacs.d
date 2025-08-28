;;; core-packages.el --- Package Declarations and Configurations -*- lexical-binding: t -*-
;;; Commentary:
;;      Package installation and configuration using use-package.
;;      Note: Package manager setup is handled by core-package-manager.el

(message "Loading core-packages.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Essential Package Categories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Organized package lists for better maintainability
(defvar my-essential-packages
  '(spacemacs-theme zenburn-theme yaml-mode)
  "Essential packages that must be installed.")

(defvar my-development-packages
  '(elpy flycheck pylint which-key pyvenv)
  "Development and programming packages.")

(defvar my-packages (append my-essential-packages my-development-packages)
  "Complete list of packages to install.")

;; Install packages from organized lists
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      my-packages)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package configurations using use-package
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package spacemacs-theme :defer t)                     ; Deferred loading for spacemacs theme
(use-package zenburn-theme :defer t)                       ; Deferred loading for zenburn theme
(use-package yaml-mode :mode ("\\.ya?ml\\'" . yaml-mode)) ; YAML file support
(use-package flycheck :hook (prog-mode . flycheck-mode))  ; Syntax checking for programming modes
(use-package pylint :after python)                        ; Python linting support

(use-package elpy
             :init
             (elpy-enable)
             :config
             ;; Dynamically find Python executable for better portability
             (setq python-shell-interpreter (or (executable-find "python3") (executable-find "python") "python3")
                   elpy-rpc-python-command (or (executable-find "python3") (executable-find "python") "python3"))
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
