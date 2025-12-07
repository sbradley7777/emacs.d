;;; eglot-config.el --- Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for Eglot (Emacs Polyglot) LSP client.
;;      Enables language server protocol support with automatic local/remote detection.
;;
;; Defer-Check Integration (GitHub Issue #55):
;;   The eglot-managed-mode-hook triggers flymake-start for LSP-only modes
;;   (like C) that have no standalone linter. This works with flymake-config.el
;;   which disables auto-start for all modes with LSP. The conditional hook only
;;   triggers when ONLY eglot-flymake-backend is present, avoiding duplicate calls
;;   for dual-backend modes (which eglot handles automatically).

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'logging-init)
(require 'tramp-utils)
(require 'eglot-constants)
(require 'eglot-registry)
(require 'features-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq eglot-connect-timeout eglot-connection-timeout)
(setq eglot-autoshutdown eglot-autoshutdown)
(setq eglot-send-changes-idle-time eglot-send-changes-idle-time)
(setq eglot-report-progress eglot-report-progress)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 eglot--trigger-flymake-after-connect ()
 "Trigger flymake check after eglot connects for LSP-only backends.
When defer-check is enabled, `flymake-start-on-flymake-mode' is set to nil.
This prevents auto-start for all modes with LSP. However, eglot only calls
flymake-start if there were pre-existing non-eglot backends. This function
ensures flymake-start is called for LSP-only modes (like C) where there are
no standalone linters."
 (when
  (and
   (bound-and-true-p eglot--managed-mode) (bound-and-true-p flymake-mode)
   (not
    (cl-some
     (lambda
      (backend) (and (symbolp backend) (not (eq backend 'eglot-flymake-backend))))
     flymake-diagnostic-functions)))
  (flymake-start)))

(defun
 eglot--setup-lsp-for-mode (mode lsp-executable)
 "Set up eglot hook for MODE if LSP-EXECUTABLE is available.
MODE is the major mode symbol to configure.
LSP-EXECUTABLE is the name of the LSP server executable to check for.
Checks local or remote host appropriately based on `default-directory'."
 (add-hook
  (intern (format "%s-hook" mode))
  (lambda
   ()
   (let* ((is-remote (tramp-is-remote-file))
          (hostname (if is-remote (file-remote-p default-directory 'host) (system-name)))
          (location (if is-remote "remote" "local")))
     (logging-info
      "Checking if the LSP command exists \"%s\" for major mode \"%s\" on host (%s): %s"
      lsp-executable
      mode
      location
      hostname)
     (let ((should-enable (core-check-command-in-path lsp-executable)))
       ;; Start eglot directly - no timer needed.
       ;; Eglot handles async connection internally, so it won't block even during git-sync.
       (when should-enable (eglot-ensure)))))))

(dolist
 (entry eglot-lsp-server-registry)
 (let* ((lsp-server-symbol (nth 0 entry))
        (modes (nth 2 entry))
        (props (nthcdr 3 entry))
        (lsp-executable (plist-get props :binary))
        (disabled (plist-get props :disabled)))
   (unless disabled (dolist (mode modes) (eglot--setup-lsp-for-mode mode lsp-executable)))))

;; Trigger flymake-start for LSP-only backends (no standalone linter)
;; Only calls start if ONLY eglot-flymake-backend is present
(add-hook 'eglot-managed-mode-hook 'eglot--trigger-flymake-after-connect)
(provide 'eglot-config)
;;; eglot-config.el ends here
