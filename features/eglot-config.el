;;; eglot-config.el --- Eglot LSP Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for Eglot (Emacs Polyglot) LSP client.
;;      Enables language server protocol support with automatic local/remote detection.

(require 'core-constants)
(require 'core-utils)
(require 'tramp-utils)

(core-utils-with-load-timing
 "eglot-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Eglot Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;; Increase connection timeout for remote LSP servers
 (setq eglot-connect-timeout 60)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; LSP Server Mapping
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defconst
  eglot-lsp-server-map
  '((python-mode . "pylsp") (c-mode . "clangd") (c++-mode . "clangd"))
  "Map of major modes to their LSP server executables.")

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
        (when should-enable (eglot-ensure)))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Automatically Configure All Modes
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (dolist
  (mode-config eglot-lsp-server-map)
  (let ((mode (car mode-config))
        (lsp-executable (cdr mode-config)))
    (eglot-setup-lsp-for-mode mode lsp-executable)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )

(provide 'eglot-config)

;;; eglot-config.el ends here
