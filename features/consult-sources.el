;;; consult-sources.el --- Custom Consult Buffer Sources -*- lexical-binding: t -*-
;;; Commentary:
;;      Custom buffer sources for consult-buffer with filtering capabilities.
;;      Provides filtered buffer views that exclude utility and internal buffers.

;;; Code:
;; Declare external variables to suppress byte-compiler warnings
(defvar consult--source-buffer) ; From consult.el
(defvar consult--source-project-buffer) ; From consult.el
(defvar consult--source-recent-file) ; From consult.el
(defvar recentf-list) ; From recentf.el

;; Declare external functions to suppress byte-compiler warnings
(declare-function consult--buffer-state "consult" ())
(declare-function consult--buffer-query "consult" (&rest args))
(declare-function consult--buffer-file-hash "consult" ())

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 consult--source-filtered-buffer nil
 "Filtered buffer source for `consult-buffer' that excludes patterns in
minibuffer-config-ignored-buffer-patterns and the current buffer.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 minibuffer-config-ignored-buffer-patterns
 '(
   ;; Utility buffers
   "\\*Command Palette\\*" "\\*Flymake diagnostics.*\\*" "\\*Messages\\*" "\\*Completions\\*"
   ;; Common UI buffers
   "\\*scratch\\*" "\\*dashboard\\*" "\\*Buffer List\\*"
   ;; Language server protocol buffers
   "\\*eglot.*\\*" "\\*EGLOT.*\\*"
   ;; Internal buffers (starting with space)
   "\\` "
   ;; Magit buffers (uncomment if using Magit)
   ;; "^magit"
   ;; Help/info buffers (uncomment if desired)
   ;; "\\*Help\\*"
   ;; "\\*info\\*"
   )
 "List of regexp patterns for buffer names to hide from consult-buffer.
Each pattern is matched against buffer names. Matching buffers are excluded
from consult-buffer completion.

Patterns included:
- Command Palette: Side window for command history
- Flymake diagnostics: Diagnostic output window
- Messages: Emacs message log
- Completions: Completion candidates popup
- scratch: Default scratch buffer
- dashboard: Startup screen
- Buffer List: Buffer list window
- eglot: Language server protocol buffers
- Buffers starting with space: Internal Emacs buffers

To add more patterns, simply add regexp strings to this list.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq
 consult--source-filtered-buffer
 (list
  :name "Buffer (Filtered)"
  :narrow ?d
  :category nil
  :face 'consult-buffer
  :history 'buffer-name-history
  :state #'consult--buffer-state
  :default t
  :annotate #'consult-sources--buffer-annotation
  :items
  (lambda
   ()
   (let ((all-buffers (consult--buffer-query :as #'buffer-name))
         (current-buffer-name (buffer-name)))
     (seq-remove
      (lambda
       (buf)
       (or
        ;; Exclude current buffer
        (string= buf current-buffer-name)
        ;; Exclude buffers matching ignored patterns
        (seq-some
         (lambda (pattern) (string-match-p pattern buf))
         minibuffer-config-ignored-buffer-patterns)))
      all-buffers)))))

(with-eval-after-load
 'consult
 ;; Apply custom annotation to default buffer source for consistent alignment
 (plist-put consult--source-buffer :category nil)
 (plist-put consult--source-buffer :annotate #'consult-sources--buffer-annotation)

 ;; Assign unique narrowing key to project buffer source. By default it shares 'b' with regular buffers, causing conflicts
 (plist-put consult--source-project-buffer :narrow ?p)
 (plist-put consult--source-project-buffer :hidden nil)
 ;; Remove category to allow custom annotations
 (plist-put consult--source-project-buffer :category nil)
 ;; Add shared custom annotation function
 (plist-put consult--source-project-buffer :annotate #'consult-sources--buffer-annotation)

 ;; Filter git repository buffers to exclude patterns from minibuffer-config-ignored-buffer-patterns
 ;; and ensure only buffers in the current git repository are shown
 (plist-put
  consult--source-project-buffer
  :items
  (lambda
   ()
   (when-let ((git-root (vc-git-root default-directory)))
     (let* ((repo-root (expand-file-name git-root))
            (all-buffers (consult--buffer-query :sort 'visibility :as #'buffer-name))
            ;; Filter to only buffers whose files are in the current git repository
            (git-buffers
             (seq-filter
              (lambda
               (buf)
               (when-let ((file (buffer-file-name (get-buffer buf))))
                 (string-prefix-p repo-root (expand-file-name file))))
              all-buffers)))
       ;; Then remove buffers matching ignored patterns
       (seq-remove
        (lambda
         (buf)
         (seq-some
          (lambda (pattern) (string-match-p pattern buf))
          minibuffer-config-ignored-buffer-patterns))
        git-buffers)))))

 (core-message-config "Project buffer source customized with filtering")

 ;; Limit recent files shown to 10 and show full paths (not abbreviated)
 (plist-put
  consult--source-recent-file
  :items
  (lambda
   ()
   (let ((ht (consult--buffer-file-hash))
         ;; Use full paths instead of abbreviated paths
         (items recentf-list))
     (seq-take (seq-remove (lambda (x) (gethash x ht)) items) 10))))

 (core-message-config "Recent file source limited to 10 files"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 consult-sources--buffer-annotation
 (buf)
 "Annotate buffer BUF with status, size, permissions, mode-name (major-mode), and abbreviated file path."
 (let ((buffer-obj (get-buffer buf)))
   (when
    buffer-obj
    (with-current-buffer
     buffer-obj
     (let* ((modified (if (buffer-modified-p) "*" "-"))
            (read-only (if buffer-read-only "%" "-"))
            (buf-status (concat modified read-only "-"))
            (buf-file (when buffer-file-name (abbreviate-file-name buffer-file-name)))
            (buf-permissions
             (if
              (and buf-file (file-exists-p buf-file))
              (file-attribute-modes (file-attributes buf-file))
              "----------"))
            (buf-size (file-size-human-readable (buffer-size)))
            (buf-mode-display
             (format "%s (%s)" (format-mode-line mode-name) (symbol-name major-mode))))
       ;; Format annotation string manually to avoid marginalia--fields macro issues
       (concat
        (propertize (format "%-3s " buf-status) 'face 'marginalia-modified)
        (propertize (format "%-6s " buf-size) 'face 'marginalia-size)
        (propertize (format "%-12s " buf-permissions) 'face 'marginalia-date)
        (propertize
         (format
          "%-35s " (truncate-string-to-width buf-mode-display 35 nil nil t))
         'face 'marginalia-mode)
        (when buf-file (propertize buf-file 'face 'marginalia-file-name))))))))
(provide 'consult-sources)
;;; consult-sources.el ends here
