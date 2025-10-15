;;; modeline-segments.el --- Custom doom-modeline segments -*- lexical-binding: t -*-
;;; Commentary:
;;      Custom segment definitions for doom-modeline.
;;      These segments are used in modeline-config.el.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "modeline-segments.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Helper Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  modeline-treesitter-show-info
  ()
  "Display tree-sitter status information in minibuffer."
  (interactive)
  (if
   (treesit-available-p)
   (let* ((mode-symbol (symbol-name major-mode))
          (mode-display-name (format-mode-line mode-name))
          (is-ts-mode (string-match-p "-ts-mode$" mode-symbol))
          (lang (when is-ts-mode (replace-regexp-in-string "-ts-mode$" "" mode-symbol)))
          (lang-cap (when lang (capitalize lang)))
          (grammar-available (when lang (treesit-language-available-p (intern lang))))
          (grammar-file
           (when lang (format "libtree-sitter-%s%s" lang (car dynamic-library-suffixes)))))
     (if
      is-ts-mode
      (message
       "Tree-sitter> Mode Name: %s | Mode Symbol: %s | Grammar: %s"
       mode-display-name
       mode-symbol
       (if grammar-available grammar-file "NOT INSTALLED"))
      (message
       "Tree-sitter> Mode Name: %s | Mode Symbol: %s | Status: inactive"
       mode-display-name
       mode-symbol)))
   (message "Tree-sitter: not available in this Emacs build")))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Generic Segments
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (with-eval-after-load
  'doom-modeline

  ;; Define separator segment
  (doom-modeline-def-segment
   separator "Visual separator." (propertize " ◆ " 'face 'doom-modeline-buffer-path))

  ;; Define tree-sitter indicator segment
  (doom-modeline-def-segment
   treesitter-indicator "Display tree-sitter mode indicator when active. Click to show status."
   (when
    (and (bound-and-true-p major-mode) (string-match-p "-ts-mode$" (symbol-name major-mode)))
    (let* ((mode-name (symbol-name major-mode))
           (lang (replace-regexp-in-string "-ts-mode$" "" mode-name))
           (lang-cap (capitalize lang))
           (icon
            (if
             (fboundp 'nerd-icons-mdicon)
             (nerd-icons-mdicon "nf-md-tree" :face 'doom-modeline-info)
             "TS")))
      (propertize
       (format " %s " icon)
       'face
       'doom-modeline-info
       'mouse-face
       'mode-line-highlight
       'help-echo
       (format "Tree-sitter: %s (click for info)" lang-cap)
       'local-map
       (let ((map (make-sparse-keymap)))
         (define-key map [mode-line mouse-1] 'modeline-treesitter-show-info)
         map)))))

  ;; Define remote/local host indicator segment
  (doom-modeline-def-segment
   remote-file-indicator "Display remote or local host indicator with click handler."
   (if-let* ((host (file-remote-p default-directory 'host)))
     ;; Remote connection
     (let* ((method (file-remote-p default-directory 'method))
            (user (file-remote-p default-directory 'user))
            (display-text (format " (%s %s@%s)" "🌐" (or user "?") host)))
       (propertize
        display-text
        'face
        'doom-modeline-host
        'help-echo
        "Click for remote connection details"
        'mouse-face
        'mode-line-highlight
        'local-map
        (let ((map (make-sparse-keymap)))
          (define-key
           map [mode-line mouse-1]
           (lambda
            () (interactive)
            (message
             "Remote Connection | Method: %s | User: %s | Host: %s | Path: %s"
             method
             (or user "default")
             host
             (file-remote-p default-directory 'localname))))
          map)))
     ;; Local machine
     (let* ((local-icon
             (doom-modeline-icon 'mdicon "nf-md-home" "🏠" " " :face 'doom-modeline-host))
            (display-text (format " (%s local)" local-icon)))
       (propertize
        display-text
        'face
        'doom-modeline-host
        'help-echo
        "Click for local directory info"
        'mouse-face
        'mode-line-highlight
        'local-map
        (let ((map (make-sparse-keymap)))
          (define-key
           map
           [mode-line mouse-1]
           (lambda () (interactive) (message "Local Directory: %s" default-directory)))
          map)))))))

(provide 'modeline-segments)

;;; modeline-segments.el ends here
