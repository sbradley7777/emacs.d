;;; forge-config.el --- Forge Configuration and Customizations -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Forge configuration and customizations for improved markdown rendering
;; WHY:  Provides better visual display of issues/PRs with hidden markup and styled links
;; PROVIDES: Improved markdown rendering in forge topic buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customizations include:
;; - Override forge--fontify-markdown to hide markdown markup
;; - Ensure links are properly styled (colors set in theme)

;;; Code:
(require 'core-logging)
(require 'forge-markdown)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 forge-config--fontify-with-hidden-markup (orig-fun text &optional indent)
 "Wrap forge--fontify-markdown to enable markdown-hide-markup.
ORIG-FUN is the original function being advised.
TEXT is the markdown text to fontify.
INDENT is the optional indentation level."
 (let ((markdown-hide-markup t))
   (funcall orig-fun text indent)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(with-eval-after-load
 'forge-topic
 (advice-add 'forge--fontify-markdown :around #'forge-config--fontify-with-hidden-markup)
 (advice-add 'forge--fontify-markdown :override #'forge-markdown--fontify-with-hiding)
 (core-message-config "Forge markdown rendering configured with markup hiding"))
(provide 'forge-config)
;;; forge-config.el ends here
