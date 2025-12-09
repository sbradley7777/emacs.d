;;; breadcrumbs-config.el --- Breadcrumb Navigation Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configuration for breadcrumb navigation mode.
;;      Provides hierarchical navigation showing file path and code structure.

;;; Code:
(require 'core-constants)

;; Declare external functions to suppress byte-compiler warnings
(declare-function breadcrumb-mode "breadcrumb" (&optional arg))
(declare-function bc-local-mode "breadcrumb" (&optional arg))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 breadcrumbs--should-enable-p ()
 "Return non-nil if breadcrumb should be enabled in current buffer.
Excludes minibuffer and special buffers (starting with space or asterisk)."
 (and
  (not (minibufferp))
  (not (string-prefix-p " " (buffer-name)))
  (not (string-prefix-p "*" (buffer-name)))))

(defun
 breadcrumbs--turn-on-advice (orig-fun &rest args)
 "Advice for breadcrumb turn-on function to skip special buffers.
Only call ORIG-FUN with ARGS if buffer should have breadcrumb enabled."
 (when (breadcrumbs--should-enable-p) (apply orig-fun args)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package
 breadcrumb
 :ensure t
 :config
 ;; Prevent breadcrumb from activating in special buffers
 (advice-add
  'bc--turn-on-local-mode-on-behalf-of-global-mode
  :around #'breadcrumbs--turn-on-advice)
 (breadcrumb-mode 1)
 ;; Note: Known issue with vscode-json-languageserver and severely malformed JSON
 ;; When processing JSON files with severe errors (unclosed objects/arrays/strings,
 ;; malformed unicode escapes, deeply nested broken structures), the LSP server sends
 ;; malformed document symbols causing jsonrpc "Invalid JSON" warnings followed by
 ;; breadcrumb args-out-of-range errors. Simple JSON errors (trailing commas, missing
 ;; commas) work fine. Rare in practice since most JSON files aren't this broken.
 ;; See: https://github.com/joaotavora/breadcrumb/issues/36
 ;; Note: Theme-specific breadcrumb colors are applied by each theme's setup function
 ;; (e.g., themes-doom-1337-breadcrumb-faces-apply in theme-doom-1337.el)
 ;; This ensures breadcrumb colors always match the active theme's modeline colors
 )
(provide 'breadcrumbs-config)
;;; breadcrumbs-config.el ends here
