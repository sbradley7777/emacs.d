;;; forge-config.el --- Forge Configuration and Customizations -*- lexical-binding: t -*-

;;; Commentary:
;; WHAT: Forge configuration and customizations for improved markdown rendering
;; WHY:  Provides better visual display of issues/PRs with hidden markup and styled links
;; PROVIDES: Improved markdown rendering in forge topic buffers
;;
;; Customizations include:
;; - Override forge--fontify-markdown to hide markdown markup
;; - Ensure links are properly styled (colors set in theme)
(require 'core-utils)
(require 'core-logging)
(require 'forge-markdown)
(core-utils-with-load-timing
 "forge-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Forge Markdown Rendering Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Override forge--fontify-markdown with improved version that hides markup
 ;; This makes issue/PR content cleaner by hiding [](url) syntax and showing only link text
 (with-eval-after-load
  'forge-topic
  (advice-add 'forge--fontify-markdown :override #'forge--fontify-markdown-with-hiding)
  (core-message-config "Forge markdown rendering configured with markup hiding")))
(provide 'forge-config)
;;; forge-config.el ends here
