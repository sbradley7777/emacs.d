;;; forge-issue-links.el --- Append raw URLs to Forge issue display for terminal clickability -*- lexical-binding: t -*-
;;; Commentary:
;; WHAT: Automatically append raw URLs to Forge issue/PR displays
;; WHY:  Terminal emulators can click raw URLs but not markdown-rendered links over SSH
;; PROVIDES: Hook that extracts markdown links and appends them as clickable raw URLs
;;
;; This addresses GitHub issue #35 by working around the terminal limitation documented
;; in issue #30. While markdown links [text](url) aren't clickable in terminal Emacs,
;; raw URLs are Command+clickable in iTerm2 and similar terminal emulators.
;;
;; Implementation:
;; - Advises `forge-insert-post-content` to append extracted URLs after post body
;; - Extracts all markdown link URLs using regex pattern
;; - Deduplicates and formats as a clean list at the bottom of each post
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "forge-issue-links.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; URL Extraction Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge-issue-links--extract-markdown-links (text)
  "Extract all markdown links from TEXT.
Returns a deduplicated list of (TEXT . URL) cons cells found in markdown [text](url) format."
  (let ((links '())
        (pos 0))
    (while
     (string-match "\\[\\(.*?\\)\\](\\(https?://[^)]+\\))" text pos)
     (let ((link-text (match-string 1 text))
           (url (match-string 2 text)))
       (push (cons link-text url) links))
     (setq pos (match-end 0)))
    ;; Deduplicate by both text and URL (only skip if both are identical)
    (let ((seen (make-hash-table :test 'equal))
          (result '()))
      (dolist
       (link (nreverse links))
       (let* ((text (car link))
              (url (cdr link))
              (key (cons text url)))
         (unless (gethash key seen) (puthash key t seen) (push link result))))
      (nreverse result))))

 (defun
  forge-issue-links--format-links-section (links)
  "Format LINKS as a markdown section with raw URLs for terminal clickability.
LINKS is a list of (TEXT . URL) cons cells.
Returns formatted and fontified string with section header and bullet list of URLs with titles.
The section is rendered through markdown fontification for proper styling.
Returns nil if LINKS is empty."
  (when
   links
   (let ((markdown-text
          (concat
           "\n\n---\n\n## Links\n\n"
           (mapconcat
            (lambda
             (link)
             (let ((text (car link))
                   (url (cdr link)))
               ;; Only show text if it's meaningful (not empty, not just the URL itself)
               (if
                (or (string-empty-p text) (string= text url) (string-prefix-p "http" text))
                (format "- %s" url)
                (format "- %s (%s)" url text))))
            links "\n")
           "\n")))
     ;; Fontify the markdown text to get proper header and separator rendering
     (forge--fontify-markdown markdown-text))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Forge Integration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  forge-issue-links--insert-post-content-with-links (orig-fun post)
  "Advice for `forge-insert-post-content' to append raw URLs.
ORIG-FUN is the original function, POST is the forge post object.
Extracts markdown links from post body and appends them as clickable raw URLs."
  ;; Call the original function to insert the post content
  (funcall orig-fun post)
  ;; Extract and append links if any are found
  (when-let* ((body (oref post body))
              (links (forge-issue-links--extract-markdown-links body))
              (links-section (forge-issue-links--format-links-section links)))
    (save-excursion
     ;; Move back to before the trailing newlines added by original function
     (backward-char 2) (insert links-section))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Activation
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (with-eval-after-load
  'forge-topic
  (advice-add
   'forge-insert-post-content
   :around #'forge-issue-links--insert-post-content-with-links)
  (core-message-config "Forge link extraction enabled")))
(provide 'forge-issue-links)
;;; forge-issue-links.el ends here
