;;; forge-markdown.el --- Forge Markdown Rendering Functions -*- lexical-binding: t -*-

;;; Commentary:
;; WHAT: Markdown rendering functions for Forge issues and pull requests
;; WHY:  Provides improved markdown display with hidden markup and styled links
;; PROVIDES: forge--fontify-markdown-with-hiding and helper functions
;;
;; Functions for rendering markdown content in Forge topic buffers with:
;; - Markdown markup hiding ([](url) syntax hidden)
;; - URL hiding/compression
;; - Face property normalization to prevent rendering errors
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "forge-markdown.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Face Normalization
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge--normalize-face-value (face-val)
  "Normalize quoted face symbols to avoid 'Invalid face reference: quote' error.
FACE-VAL can be a single face symbol, a quoted face symbol, or a list of faces."
  (cond
   ;; Handle quoted face: 'face-name -> face-name
   ((and (listp face-val) (eq (car face-val) 'quote))
    (cadr face-val))
   ;; Handle list of faces (some might be quoted)
   ((and (listp face-val) (not (eq (car face-val) 'quote)))
    (mapcar (lambda (f) (if (and (listp f) (eq (car f) 'quote)) (cadr f) f)) face-val))
   ;; Regular face symbol
   (t
    face-val)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Buffer Setup and Fontification
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge--setup-markdown-buffer
  (text)
  "Set up a temporary buffer with TEXT for markdown fontification.
Enables gfm-mode, markdown hiding features, and applies fontification."
  (delay-mode-hooks (gfm-mode))
  (insert text)
  ;; Enable markup and URL hiding for cleaner display
  (setq-local markdown-hide-markup t)
  (setq-local markdown-hide-urls t)
  (setq-local markdown-fontify-code-blocks-natively t)
  ;; Apply fontification
  (font-lock-ensure)
  ;; Reload extensions to apply hiding behavior
  (markdown-reload-extensions))

 (defun
  forge--apply-post-processing (indent)
  "Apply post-fontification processing with optional INDENT.
Fills region if forge-post-fill-region is set, and applies indentation if INDENT is specified."
  (when
   forge-post-fill-region
   (when indent (setq fill-column (- fill-column indent)))
   (fill-region (point-min) (point-max)))
  (when indent (indent-rigidly (point-min) (point-max) indent)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Face Property Conversion
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge--convert-face-properties (string)
  "Convert face properties to font-lock-face in STRING.
Normalizes quoted face symbols in both face and mouse-face properties to avoid rendering errors."
  (let ((beg 0)
        (end (length string)))
    (while
     (< beg end)
     (let ((pos (next-single-property-change beg 'face string end))
           (face-val (get-text-property beg 'face string))
           (mouse-face-val (get-text-property beg 'mouse-face string)))
       ;; Normalize and copy face property to font-lock-face
       (when
        face-val
        (put-text-property beg pos 'font-lock-face (forge--normalize-face-value face-val) string))
       ;; Normalize mouse-face property (if present)
       (when
        mouse-face-val
        (put-text-property
         beg pos 'mouse-face (forge--normalize-face-value mouse-face-val) string))
       (remove-list-of-text-properties beg pos '(face) string)
       (setq beg pos)))
    string))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Main Markdown Fontification Function
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge--fontify-markdown-with-hiding (text &optional indent)
  "Fontify markdown TEXT with markup hiding enabled.
This is an improved version of forge--fontify-markdown that hides markdown
markup characters and URLs for cleaner display in forge topic buffers.
Optional INDENT specifies indentation level."
  (with-temp-buffer
   (forge--setup-markdown-buffer text)
   (forge--apply-post-processing indent)
   (forge--convert-face-properties (buffer-string))))

 (core-message-config "Forge markdown rendering functions loaded"))
(provide 'forge-markdown)
;;; forge-markdown.el ends here
