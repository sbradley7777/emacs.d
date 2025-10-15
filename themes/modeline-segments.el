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
          (parent-mode (get major-mode 'derived-mode-parent))
          (parent-mode-name (if parent-mode (symbol-name parent-mode) "none"))
          (is-ts-mode (string-match-p "-ts-mode$" mode-symbol))
          (lang (when is-ts-mode (replace-regexp-in-string "-ts-mode$" "" mode-symbol)))
          (grammar-available (when lang (treesit-language-available-p (intern lang))))
          (grammar-file
           (if
            (and lang grammar-available)
            (format "libtree-sitter-%s%s" lang (car dynamic-library-suffixes))
            "none")))
     (message
      "Tree-Sitter> Mode Name: %s | Mode Symbol: %s | Parent Mode: %s | Tree-sitter: %s | Grammar Installed: %s"
      mode-display-name
      mode-symbol
      parent-mode-name
      (if is-ts-mode "yes" "no")
      grammar-file))
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
   treesitter-indicator
   "Display tree-sitter mode indicator. Active modes show in color, inactive in gray. Click to show status."
   (when
    (and (treesit-available-p) (bound-and-true-p major-mode))
    (let* ((mode-name (symbol-name major-mode))
           (is-ts-mode (string-match-p "-ts-mode$" mode-name))
           (lang (when is-ts-mode (replace-regexp-in-string "-ts-mode$" "" mode-name)))
           (lang-cap (if is-ts-mode (capitalize lang) "inactive"))
           (icon-face (if is-ts-mode 'doom-modeline-info 'doom-modeline-inactive))
           (icon
            (if
             (fboundp 'nerd-icons-mdicon)
             (nerd-icons-mdicon "nf-md-tree" :face icon-face)
             (if is-ts-mode "TS" "ts"))))
      (propertize
       (format " %s " icon)
       'face
       icon-face
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
