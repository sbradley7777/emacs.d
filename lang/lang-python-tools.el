;;; lang-python-tools.el --- Python Development Tools Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Python development tools: elpy, flycheck integration, and IDE-like features.
;;      This configuration is extracted from core-packages.el for better organization.

(defvar config-load-start-time (current-time))
(message "Loading lang-python-tools.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Elpy Python Development Environment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

;; Make this module available for loading with (require 'lang-python-tools)
(provide 'lang-python-tools)
(message "lang-python-tools.el loaded (%.2fs)"
         (float-time (time-subtract (current-time) config-load-start-time)))
