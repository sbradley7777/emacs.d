;;; eglot-config.el --- Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for Eglot (Emacs Polyglot) LSP client.
;;      Enables language server protocol support with automatic local/remote detection.
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'tramp-utils)
(require 'eglot-constants)
(require 'features-constants)
(core-utils-with-load-timing
 "eglot-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Eglot Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Connection timeout for remote LSP servers
 (setq eglot-connect-timeout features-eglot-connection-timeout)

 ;; Performance optimizations
 (setq eglot-autoshutdown features-eglot-autoshutdown)
 (setq eglot-send-changes-idle-time features-eglot-send-changes-idle-time)

 ;; Progress reporting - send to Messages buffer instead of mode line
 (setq eglot-report-progress features-eglot-report-progress)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Eglot Hook Setup
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  eglot-setup-lsp-for-mode (mode lsp-executable)
  "Set up eglot hook for MODE if LSP-EXECUTABLE is available.
Checks local or remote host appropriately using tramp-is-remote-file."
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
      (let ((should-enable
             (if
              is-remote
              (core-utils-check-command-in-path-remote-host lsp-executable)
              (core-utils-check-command-in-path lsp-executable))))
        ;; Start eglot directly - no timer needed.
        ;; Eglot handles async connection internally, so it won't block even during git-sync.
        (when should-enable (eglot-ensure)))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Automatically Configure All Modes
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (dolist
  (mode-config features-eglot-lsp-server-map)
  (let ((mode (car mode-config))
        (lsp-executable (cdr mode-config)))
    (eglot-setup-lsp-for-mode mode lsp-executable)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )
(provide 'eglot-config)
;;; eglot-config.el ends here
