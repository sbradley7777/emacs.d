;;; eglot-config.el --- Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for Eglot (Emacs Polyglot) LSP client.
;;      Enables language server protocol support with automatic local/remote detection.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'tramp-utils)
(require 'eglot-constants)
(require 'features-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq eglot-connect-timeout features-eglot-connection-timeout)
(setq eglot-autoshutdown features-eglot-autoshutdown)
(setq eglot-send-changes-idle-time features-eglot-send-changes-idle-time)
(setq eglot-report-progress features-eglot-report-progress)

;; Configure bash-language-server
;; NOTE: bash-language-server v5.6.0 appears broken (produces no LSP output)
;; Commented out until fixed - using flymake-shellcheck instead
;; Remove bash modes from eglot-server-programs to prevent Eglot from trying to start
(with-eval-after-load
 'eglot
 (setq eglot-server-programs (assq-delete-all 'sh-mode eglot-server-programs))
 (setq eglot-server-programs (assq-delete-all 'bash-ts-mode eglot-server-programs)))
;; (with-eval-after-load
;;  'eglot
;;  ;; Explicitly add bash-language-server to eglot-server-programs
;;  (add-to-list
;;   'eglot-server-programs '((sh-mode bash-ts-mode sh-ts-mode) . ("bash-language-server" "start")))
;;  ;; Configure shellcheck path
;;  (add-to-list 'eglot-workspace-configuration '(:bashIde (:shellcheckPath "shellcheck"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 eglot-setup-lsp-for-mode (mode lsp-executable)
 "Set up eglot hook for MODE if LSP-executable is available.
Checks local or remote host appropriately based on `default-directory'."
 (add-hook
  (intern (format "%s-hook" mode))
  (lambda
   ()
   (let* ((is-remote (tramp-is-remote-file))
          (hostname (if is-remote (file-remote-p default-directory 'host) (system-name)))
          (location (if is-remote "remote" "local")))
     (core-message-info
      "Checking if the LSP command exists \"%s\" for major mode \"%s\" on host (%s): %s"
      lsp-executable
      mode
      location
      hostname)
     (let ((should-enable (core-utils-check-command-in-path lsp-executable)))
       ;; Start eglot directly - no timer needed.
       ;; Eglot handles async connection internally, so it won't block even during git-sync.
       (when should-enable (eglot-ensure)))))))

(dolist
 (mode-config features-eglot-lsp-server-map)
 (let ((mode (car mode-config))
       (lsp-executable (cdr mode-config)))
   (eglot-setup-lsp-for-mode mode lsp-executable)))
(provide 'eglot-config)
;;; eglot-config.el ends here
