;;; modeline-segments.el --- Custom doom-modeline segments -*- lexical-binding: t -*-
;;; Commentary:
;;      Custom segment definitions for doom-modeline.
;;      These segments are used in modeline-config.el.

(require 'core-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "modeline-segments.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Generic Segments
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (with-eval-after-load
  'doom-modeline

  ;; Define separator segment
  (doom-modeline-def-segment
   separator "Visual separator." (propertize " ◆ " 'face 'doom-modeline-buffer-path))

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
