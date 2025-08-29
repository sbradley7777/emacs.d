;;; core-packages.el --- Package Declarations and Configurations -*- lexical-binding: t -*-
;;; Commentary:
;;      Package installation and configuration using use-package.
;;      Note: Package manager setup is handled by core-package-manager.el

(defvar config-load-start-time (current-time))
(message "Loading core-packages.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Essential Package Categories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Organized package lists for better maintainability
(defvar config-essential-packages '(spacemacs-theme zenburn-theme yaml-mode)
  "Essential packages that must be installed.")

(defvar config-development-packages '(elpy flycheck pylint which-key pyvenv elisp-autofmt)
  "Development and programming packages.")

(defvar config-packages (append config-essential-packages config-development-packages)
  "Complete list of packages to install.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Robust Package Installation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun install-packages-safely (package-list)
  "Install packages from PACKAGE-LIST with comprehensive error handling."
  (let ((failed-packages '())
        (installed-count 0)
        (skipped-count 0))

    (message "Installing %d packages..." (length package-list))

    (dolist (package package-list)
      (cond
       ;; Already installed
       ((package-installed-p package)
        (setq skipped-count (1+ skipped-count))
        (message "✓ Already installed: %s" package))

       ;; Install with error handling
       (t
        (condition-case err
            (progn
              (package-install package)
              (setq installed-count (1+ installed-count))
              (message "✓ Installed: %s" package))
          (error
           (push package failed-packages)
           (message "✗ Failed to install %s: %s" package (error-message-string err)))))))

    ;; Installation summary
    (message "\n=== Package Installation Summary ===")
    (message "Installed: %d packages" installed-count)
    (message "Already present: %d packages" skipped-count)
    (when failed-packages
      (message "Failed: %d packages" (length failed-packages))
      (dolist (pkg failed-packages)
        (message "  - %s" pkg))
      (message "Consider running (package-refresh-contents) and retrying failed packages"))

    ;; Return list of failed packages for further handling
    failed-packages))

;; Install packages using robust installation function
(install-packages-safely config-packages)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package configurations using use-package
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package spacemacs-theme :defer t) ; Deferred loading for spacemacs theme
(use-package zenburn-theme :defer t) ; Deferred loading for zenburn theme
(use-package yaml-mode :mode ("\\.ya?ml\\'" . yaml-mode)) ; YAML file support
(use-package flycheck :hook (prog-mode . flycheck-mode)) ; Syntax checking for programming modes
(use-package pylint :after python) ; Python linting support

;; Note: Elpy configuration moved to lang-python-tools.el for better organization

(use-package
 which-key
 :config (which-key-mode 1)
 (setq
  which-key-idle-delay 0.3 ; Faster response (was 0.5)
  which-key-max-description-length 40 ; Longer descriptions
  which-key-add-column-padding 1 ; Better spacing
  which-key-separator " → "))

(use-package
 elisp-autofmt
 :config
 ;; Configure elisp-autofmt for consistent formatting
 (setq elisp-autofmt-style 'native) ; Use native Emacs indentation style
 (setq elisp-autofmt-parallel-jobs 1)) ; Single-threaded for consistency


;; Make this module available for loading with (require 'core-packages)
(provide 'core-packages)
(message "core-packages.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
