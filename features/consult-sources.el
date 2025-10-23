;;; consult-sources.el --- Custom Consult Buffer Sources -*- lexical-binding: t -*-

;;; Commentary:
;;      Custom buffer sources for consult-buffer with filtering capabilities.
;;      Provides filtered buffer views that exclude utility and internal buffers.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Buffer Filtering Patterns
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define buffer name patterns to hide from consult-buffer sources.
;; These patterns are used by custom sources to filter out utility and internal buffers.
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
(require 'core-utils)
(core-utils-with-load-timing
 "consult-sources.el"
 ;; Shared annotation function for buffer sources showing: status, size, permissions, mode-name, abbreviated file path
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
             (status (concat modified read-only "-"))
             (file (when buffer-file-name (abbreviate-file-name buffer-file-name)))
             (permissions
              (if
               (and file (file-exists-p file))
               (file-attribute-modes (file-attributes file))
               "----------"))
             (size (file-size-human-readable (buffer-size)))
             (mode-display (format "%s (%s)" mode-name (symbol-name major-mode))))
        (concat
         "  "
         (propertize status 'face 'marginalia-modified)
         "  "
         (propertize (format "%6s" size) 'face 'marginalia-size)
         "  "
         (propertize permissions 'face 'marginalia-date)
         "  "
         (propertize (format "%-35s" mode-display) 'face 'marginalia-mode)
         (when file (concat "  " (propertize file 'face 'marginalia-file-name)))))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Custom Filtered Buffer Source
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Define custom filtered buffer source that excludes patterns from minibuffer-config-ignored-buffer-patterns.
 ;; This source displays buffers like consult--source-buffer but filters out utility/internal buffers
 ;; and the current buffer.
 (defvar
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
 "Filtered buffer source for `consult-buffer' that excludes patterns in minibuffer-config-ignored-buffer-patterns and the current buffer.")
(core-message-config "Custom filtered buffer source loaded")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project Buffer Source Customization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customize the built-in project buffer source to filter out utility/internal buffers
(with-eval-after-load
 'consult
 ;; Assign unique narrowing key to project buffer source. By default it shares 'b' with regular buffers, causing conflicts
 (plist-put consult--source-project-buffer :narrow ?p)
 (plist-put consult--source-project-buffer :hidden nil)
 ;; Remove category to allow custom annotations
 (plist-put consult--source-project-buffer :category nil)
 ;; Add shared custom annotation function
 (plist-put consult--source-project-buffer :annotate #'consult-sources--buffer-annotation)

 ;; Filter project buffers to exclude patterns from minibuffer-config-ignored-buffer-patterns
 ;; and ensure only buffers in the current project are shown
 (plist-put
  consult--source-project-buffer
  :items
  (lambda
   ()
   (when-let ((project (project-current)))
     (let* ((project-root (expand-file-name (project-root project)))
            (all-buffers (consult--buffer-query :sort 'visibility :as #'buffer-name))
            ;; Filter to only buffers whose files are in the current project
            (project-buffers
             (seq-filter
              (lambda
               (buf)
               (when-let ((file (buffer-file-name (get-buffer buf))))
                 (string-prefix-p project-root (expand-file-name file))))
              all-buffers)))
       ;; Then remove buffers matching ignored patterns
       (seq-remove
        (lambda
         (buf)
         (seq-some
          (lambda (pattern) (string-match-p pattern buf))
          minibuffer-config-ignored-buffer-patterns))
        project-buffers)))))

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
(provide 'consult-sources)
;;; consult-sources.el ends here
