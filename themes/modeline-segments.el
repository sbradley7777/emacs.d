;;; modeline-segments.el --- Custom doom-modeline segments -*- lexical-binding: t -*-
;;; Commentary:
;;      Custom segment definitions for doom-modeline.
;;      These segments are used in modeline-config.el.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'tree-sitter-utils)
(require 'tramp-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
   (let* ((is-ts-mode (treesit-utils-is-ts-mode-p major-mode))
          (lang (treesit-utils-extract-lang-from-mode major-mode))
          (lang-cap (if is-ts-mode (capitalize lang) "inactive"))
          (icon-face (if is-ts-mode 'doom-modeline-info 'doom-modeline-buffer-minor-mode))
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
        (define-key map [mode-line mouse-1] 'treesit-utils-show-info)
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
         (define-key map [mode-line mouse-1] 'tramp-utils-show-connection-info)
         map)))
    ;; Local machine
    (let* ((local-icon (doom-modeline-icon 'mdicon "nf-md-home" "🏠" " " :face 'doom-modeline-host))
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
         (define-key map [mode-line mouse-1] 'tramp-utils-show-connection-info)
         map))))))
(provide 'modeline-segments)
;;; modeline-segments.el ends here
