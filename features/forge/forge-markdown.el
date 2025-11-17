;;; forge-markdown.el --- Forge Markdown Rendering Functions -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Markdown rendering functions for Forge issues and pull requests
;; WHY:  Provides improved markdown display with hidden markup and styled links
;; PROVIDES: forge-markdown--fontify-with-hiding and helper functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions for rendering markdown content in Forge topic buffers with:
;; - Markdown markup hiding ([](url) syntax hidden)
;; - URL hiding/compression
;; - Face property normalization to prevent rendering errors

;;; Code:
(require 'core-logging)
(require 'forge-constants)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Face Normalization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 forge-markdown--normalize-face-value (face-val)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Buffer Setup and Fontification
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 forge-markdown--setup-buffer
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
 forge-markdown--apply-post-processing (indent)
 "Apply post-fontification processing with optional INDENT.
Fills region if forge-post-fill-region is set, and applies indentation if INDENT is specified."
 (when
  forge-post-fill-region
  (when indent (setq fill-column (- fill-column indent)))
  (fill-region (point-min) (point-max)))
 (when indent (indent-rigidly (point-min) (point-max) indent)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; URL Detection and Link Creation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 forge-markdown--make-urls-clickable (string)
 "Add click handlers to URLs in STRING.
Makes both plain URLs and markdown link URLs clickable with mouse-1.
For markdown links [text](url), finds the link text and extracts the URL from the invisible portion."
 (with-temp-buffer
  (insert string) (goto-char (point-min))
  ;; First pass: Find all visible or invisible URLs and make them clickable
  (while
   (re-search-forward "https?://[^ \t\n\r\"<>)]*" nil t)
   (let* ((url-start (match-beginning 0))
          (url-end (match-end 0))
          (url (match-string 0))
          (map (make-sparse-keymap)))
     ;; Create a keymap that opens the URL when clicked or when RET is pressed
     (define-key map [mouse-1] `(lambda () (interactive) (browse-url ,url)))
     (define-key map (kbd "RET") `(lambda () (interactive) (browse-url ,url)))
     ;; Add interactive properties to make the link clickable
     (put-text-property url-start url-end 'keymap map)
     (put-text-property url-start url-end 'follow-link t)
     (put-text-property url-start url-end 'mouse-face 'highlight)
     (put-text-property url-start url-end 'help-echo url)))
  ;; Second pass: Find markdown link text that precedes invisible URLs
  ;; In markdown links [text](url), the url part is invisible but still in buffer
  ;; We need to find link text and associate it with the following URL
  (goto-char (point-min))
  (while
   (re-search-forward "\\[\\([^]]+\\)\\]" nil t)
   (let ((link-text-start (match-beginning 1))
         (link-text-end (match-end 1))
         (after-bracket (match-end 0)))
     ;; Check if there's a URL right after the ] (might be invisible)
     (save-excursion
      (goto-char after-bracket)
      ;; Look for (url) pattern, the parens might be invisible
      (when
       (and
        (eq (char-after) ?\()
        (re-search-forward
         "(\\(https?://[^)]+\\))" (+ after-bracket forge-markdown-url-search-limit) t))
       (let* ((url (match-string 1))
              (map (make-sparse-keymap)))
         ;; Make the link text clickable
         (define-key map [mouse-1] `(lambda () (interactive) (browse-url ,url)))
         (define-key map (kbd "RET") `(lambda () (interactive) (browse-url ,url)))
         (put-text-property link-text-start link-text-end 'keymap map)
         (put-text-property link-text-start link-text-end 'follow-link t)
         (put-text-property link-text-start link-text-end 'mouse-face 'highlight)
         (put-text-property link-text-start link-text-end 'help-echo url))))))
  (buffer-string)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Face Property Conversion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 forge-markdown--convert-face-properties (string)
 "Convert face properties to font-lock-face in STRING.
Normalizes quoted face symbols in both face and mouse-face properties to avoid rendering errors.
Preserves interactive properties (keymap, help-echo, follow-link) for clickable links."
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
       (put-text-property
        beg pos 'font-lock-face (forge-markdown--normalize-face-value face-val) string))
      ;; Normalize mouse-face property (if present)
      (when
       mouse-face-val
       (put-text-property
        beg pos 'mouse-face (forge-markdown--normalize-face-value mouse-face-val) string))
      ;; Only remove the 'face property, preserve keymap/help-echo/follow-link for clickable links
      (remove-list-of-text-properties beg pos '(face) string)
      (setq beg pos)))
   string))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Markdown Fontification Function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 forge-markdown--fontify-with-hiding (text &optional indent)
 "Fontify markdown TEXT with markup hiding enabled.
This is an improved version of forge--fontify-markdown that hides markdown
markup characters and URLs for cleaner display in forge topic buffers.
Makes links clickable with mouse-1 and RET.
Optional INDENT specifies indentation level."
 (with-temp-buffer
  (forge-markdown--setup-buffer text) (forge-markdown--apply-post-processing indent)
  (let ((fontified-string (forge-markdown--convert-face-properties (buffer-string))))
    ;; Make URLs clickable after converting face properties
    (forge-markdown--make-urls-clickable fontified-string))))

(core-message-config "Forge markdown rendering functions loaded")
(provide 'forge-markdown)
;;; forge-markdown.el ends here
