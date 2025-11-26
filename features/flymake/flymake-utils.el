;;; flymake-utils.el --- Flymake Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for Flymake diagnostics formatting and display

;;; Code:
(require 'core-constants)
(require 'core-logging)
(require 'core-ui-utils)
(require 'core-utils)
(require 'features-constants)
(require 'flymake-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 flymake-diagnostics--current-width 'compact "Current width state of flymake diagnostics window.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake--get-active-backends ()
 "Get list of active Flymake backends for current buffer.
Filters out hook markers (t) from `flymake-diagnostic-functions'.
Returns nil if Flymake is not active or no backends are configured."
 (when
  (boundp 'flymake-diagnostic-functions) (delq t (copy-sequence flymake-diagnostic-functions))))

(defun
 flymake--format-running-status ()
 "Format flymake running status as a string.
Returns string indicating whether flymake is checking or idle."
 (if
  (and (boundp 'flymake--state) flymake--state)
  (if (flymake-is-running) "🔄 checking" "✅ idle")
  "unknown"))

(defun
 flymake--format-diagnostic-counts (error-count warning-count note-count)
 "Format diagnostic counts as a string.
ERROR-COUNT is the number of errors.
WARNING-COUNT is the number of warnings.
NOTE-COUNT is the number of notes.
Returns formatted string like \\='3 errors, 2 warnings, 1 note\\='."
 (format
  "Diagnostics: %d error%s, %d warning%s, %d note%s"
  error-count
  (if (= error-count 1) "" "s")
  warning-count
  (if (= warning-count 1) "" "s")
  note-count
  (if (= note-count 1) "" "s")))

(defun
 flymake--format-backend-list (active-backends)
 "Format active backends list as strings.
ACTIVE-BACKENDS is a list of active backend symbols.
Returns list of formatted strings describing each backend."
 (let ((lines nil))
   (if
    active-backends
    (progn
     (push (format "Active Backends (%d):" (length active-backends)) lines)
     (dolist
      (backend active-backends)
      (let ((backend-spec (flymake--find-backend-spec backend)))
        (if
         backend-spec
         (push (format "  - %s (%s)" (nth 1 backend-spec) backend) lines)
         (push (format "  - %s" backend) lines)))))
    (push "Active Backends: None" lines))
   (nreverse lines)))

(defun
 flymake--find-backend-spec (backend-symbol)
 "Find backend specification in `flymake-backend-registry' for BACKEND-SYMBOL.
Returns the backend spec entry (FUNCTION-SYMBOL DESCRIPTION MODES) or nil if not found."
 (assq backend-symbol flymake-backend-registry))

(defun
 flymake--get-backend-description (backend-symbol)
 "Get human-readable description for BACKEND-SYMBOL.
Looks up the backend in `flymake-backend-registry' and returns its description.
Falls back to the backend function name if not found in registry."
 (let ((spec (flymake--find-backend-spec backend-symbol)))
   (if spec (nth 1 spec) (format "%s" backend-symbol))))

(defun
 flymake--get-lsp-config ()
 "Get LSP configuration for current `major-mode' from `features-eglot-lsp-server-map'.
Returns cons cell (MODE . SERVER-EXECUTABLE) or nil if no LSP configured for this mode."
 (when (boundp 'features-eglot-lsp-server-map) (assq major-mode features-eglot-lsp-server-map)))

(defun
 flymake--count-diagnostics ()
 "Count Flymake diagnostics by severity for current buffer.
Returns plist with :errors, :warnings, and :notes counts.
Returns nil if Flymake is not active or no diagnostics exist."
 (when
  (and (boundp 'flymake-mode) flymake-mode)
  (let ((diagnostics (flymake-diagnostics))
        (error-count 0)
        (warning-count 0)
        (note-count 0))
    (dolist
     (diag diagnostics)
     (let ((type (flymake-diagnostic-type diag)))
       (cond
        ((eq type :error)
         (setq error-count (1+ error-count)))
        ((eq type :warning)
         (setq warning-count (1+ warning-count)))
        ((eq type :note)
         (setq note-count (1+ note-count))))))
    (list :errors error-count :warnings warning-count :notes note-count))))

(defun
 flymake--build-buffer-info-lines (diagnostic-counts active-backends)
 "Build buffer information lines for diagnostics display.
DIAGNOSTIC-COUNTS is a plist from `flymake--count-diagnostics'.
ACTIVE-BACKENDS is a list of active backend symbols.
Returns a list of formatted strings describing the buffer state."
 (let ((lines nil))
   ;; Basic buffer info
   (push (format "Buffer: %s" (buffer-name)) lines)
   (when buffer-file-name (push (format "File: %s" (abbreviate-file-name buffer-file-name)) lines))
   (push (format "Major Mode: %s" major-mode) lines)
   (push
    (format
     "Flymake: %s" (if (and (boundp 'flymake-mode) flymake-mode) "✅ enabled" "❌ disabled"))
    lines)

   ;; Flymake-specific info (only when flymake is enabled)
   (when
    (and (boundp 'flymake-mode) flymake-mode)
    (push (format "Running: %s" (flymake--format-running-status)) lines)
    (push
     (flymake--format-diagnostic-counts
      (plist-get diagnostic-counts :errors)
      (plist-get diagnostic-counts :warnings)
      (plist-get diagnostic-counts :notes))
     lines)
    (dolist
     (backend-line (flymake--format-backend-list active-backends)) (push backend-line lines))
    (push " " lines))

   (nreverse lines)))

(defun
 flymake--build-backend-table-data (active-backends)
 "Build backend table data for diagnostics display.
ACTIVE-BACKENDS is a list of active backend symbols.
Returns a list of lists, each containing (STATUS BACKEND DESCRIPTION MODES)."
 (let ((backend-data nil))
   (dolist
    (backend-spec flymake-backend-registry)
    (let* ((backend-func (nth 0 backend-spec))
           (description (nth 1 backend-spec))
           (modes (nth 2 backend-spec))
           (is-active (memq backend-func active-backends))
           (is-available (fboundp backend-func))
           (status
            (cond
             (is-active
              "Active")
             (is-available
              "Available")
             (t
              "Not Installed")))
           (modes-str
            (if
             (eq (car modes) 'multiple)
             "multiple"
             (mapconcat (lambda (m) (format "%s" m)) modes ", "))))
      (push (list status (format "%s" backend-func) description modes-str) backend-data)))
   (nreverse backend-data)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake-check-backend-availability ()
 "Check Flymake backend status and log appropriate messages.
Provides success messages when backends are active, warnings about missing LSP servers,
or info messages for unconfigured modes.  Remains silent when eglot is configured but
still connecting.  Uses `flymake-backend-registry' and `features-eglot-lsp-server-map'."
 (when
  (and (boundp 'flymake-mode) flymake-mode)
  (let* ((active-backends (flymake--get-active-backends))
         (mode-name (symbol-name major-mode))
         (lsp-config (flymake--get-lsp-config))
         (lsp-server (cdr lsp-config)))
    (cond
     ;; Case 1: Has active backends - show success message
     (active-backends
      (let ((backend-names
             (mapconcat
              (lambda (backend) (flymake--get-backend-description backend)) active-backends ", ")))
        (core-message-success "Flymake: Active backends for %s: %s" mode-name backend-names)))
     ;; Case 2: LSP configured but server not installed
     ((and lsp-config lsp-server (not (executable-find lsp-server)))
      (core-message-warning
       "Flymake: No backends active for %s. LSP server \"%s\" not found in PATH."
       mode-name
       lsp-server))
     ;; Case 3: LSP configured and server exists (eglot may still be connecting, stay silent)
     (lsp-config
      nil)
     ;; Case 4: No backends and no LSP configured
     (t
      (core-message-info
       "Flymake: No backends configured for %s. Consider adding LSP support or custom backend."
       mode-name))))))

(defun
 diagnostics-show-flymake-backend-info ()
 "Display Flymake backend configuration for current buffer.
Shows a table of all known backends with their status, description, and
supported major modes.  Marks backends active in the current buffer."
 (interactive)
 (let* ((active-backends (flymake--get-active-backends))
        (diagnostic-counts (flymake--count-diagnostics))
        (info-lines (flymake--build-buffer-info-lines diagnostic-counts active-backends))
        (backend-data (flymake--build-backend-table-data active-backends))
        (table-lines
         (core-ui-utils-format-table
          '("Status" "Backend" "Description" "Major Modes") backend-data))
        (lines nil))
   ;; Combine buffer info and table
   (dolist (info-line info-lines) (push info-line lines))
   (dolist (table-line table-lines) (push table-line lines))
   (core-message-diagnostic "Flymake Backend Configuration" (nreverse lines))))

(defun
 flymake-diagnostics--find-window ()
 "Find the Flymake diagnostics window if it exists.
Returns the window displaying *Flymake diagnostics* buffer, or nil if not found."
 (let ((diag-window nil))
   (walk-windows
    (lambda
     (win)
     (when
      (string-match-p
       "\\*Flymake diagnostics" (buffer-name (window-buffer win)))
      (setq diag-window win)))
    nil t)
   diag-window))

(defun
 toggle-flymake-diagnostics-window ()
 "Toggle the Flymake diagnostics window with size cycling.
When buffer is closed, opens at 30%.  When buffer is open, toggles between 30% and 50%.
Automatically focuses the diagnostics window when opened or resized.
Displays syntax errors, warnings, and notes from all active Flymake backends."
 (interactive)
 (let ((existing-window (flymake-diagnostics--find-window)))
   (if
    existing-window
    (progn
     (if
      (eq flymake-diagnostics--current-width 'compact)
      (progn
       (core-ui-utils-resize-window-to-ratio
        existing-window features-side-window-expanded-width)
       (setq flymake-diagnostics--current-width 'expanded))
      (core-ui-utils-resize-window-to-ratio existing-window features-side-window-compact-width)
      (setq flymake-diagnostics--current-width 'compact))
     (select-window existing-window))
    (progn
     (when (fboundp 'user-close-exclusive-side-windows) (user-close-exclusive-side-windows))
     (require 'flymake nil t)
     (if
      (fboundp 'flymake-show-buffer-diagnostics)
      (progn
       (flymake-show-buffer-diagnostics) (setq flymake-diagnostics--current-width 'compact)
       (let ((diag-window (flymake-diagnostics--find-window)))
         (when diag-window (select-window diag-window))))
      (core-message-warning "Flymake is not available"))))))

(defun
 flymake-max-backend-name-length
 ()
 "Calculate the maximum length of backend names in `flymake-diagnostics-backend-abbreviations'."
 (if
  flymake-diagnostics-backend-abbreviations
  (apply
   'max
   (mapcar (lambda (mapping) (length (cdr mapping))) flymake-diagnostics-backend-abbreviations))
  10))
(defun
 flymake-friendly-backend-name (backend-name)
 "Convert cryptic backend names to user-friendly versions.
Looks up BACKEND-NAME in `flymake-diagnostics-backend-abbreviations' and returns
the first matching friendly name, or the original name if no match found.

Handles both string and list formats (e.g., (flymake flymake) or \"flymake\")."
 (let ((backend-str
        (cond
         ((stringp backend-name)
          backend-name)
         ((listp backend-name)
          (format "%s" (car backend-name)))
         ((symbolp backend-name)
          (symbol-name backend-name))
         (t
          (format "%s" backend-name))))
       (friendly-name nil))
   ;; Search for first matching pattern in mappings
   (catch
    'found
    (dolist
     (mapping flymake-diagnostics-backend-abbreviations)
     (when
      (string-match (car mapping) backend-str)
      (setq friendly-name (cdr mapping))
      (throw 'found friendly-name))))
   ;; Return friendly name or fall back to original
   (or friendly-name backend-str)))

(defun
 flymake-setup-custom-format (error-code-extractor)
 "Set up custom diagnostics buffer format with Code column.
Creates a custom `tabulated-list-format' that adds a 'Code' column for error codes
and replaces cryptic backend names with user-friendly versions.
  ERROR-CODE-EXTRACTOR is a function that takes a message and returns an error code string.

  Column layout:
  - Line: Line number (5 chars, right-aligned, sortable)
  - Col: Column number (3 chars, right-aligned)
  - Type: Diagnostic type (8 chars, sortable by severity)
  - Code: Error code like F401, I001 (6 chars, extracted from message)
  - Backend: User-friendly backend name (dynamic width based on longest name)
  - Message: Full diagnostic text (unlimited width, sortable)"
 (setq
  tabulated-list-format
  (vector
   '("Line"
     5
     (lambda (l1 l2) (< (plist-get (car l1) :line) (plist-get (car l2) :line)))
     :right-align t)
   '("Col" 3 nil :right-align t)
   '("Type" 8 (lambda (l1 l2) (< (plist-get (car l1) :severity) (plist-get (car l2) :severity))))
   '("Code" 6 t)
   (list "Backend" (flymake-max-backend-name-length) t)
   '("Message" 0 t)))
 ;; Override the entries function to customize data extraction
 ;; This function processes each diagnostic entry and extracts/formats the data
 ;; for our custom column layout
 (setq
  tabulated-list-entries
  (lambda
   ()
   ;; Get the original diagnostic entries from flymake
   (let ((original-entries (flymake--diagnostics-buffer-entries)))
     ;; Process each entry to extract and format data for our columns
     (mapcar
      (lambda
       (entry)
       (let* ((diag-data (car entry)) ; Diagnostic metadata
              (values (cadr entry)) ; Column values array
              (message (aref values 4)) ; Original message text
              ;; Extract error code from message using provided function
              (error-code
               (if (functionp error-code-extractor) (funcall error-code-extractor message) ""))
              ;; Convert backend name to friendly version
              (backend-name (flymake-friendly-backend-name (aref values 3))))
         ;; Return formatted entry with our custom column data
         (list
          diag-data
          (vector
           (aref values 0) ; Line number
           (aref values 1) ; Column number
           (aref values 2) ; Diagnostic type (error/warning)
           error-code ; Extracted error code
           backend-name ; User-friendly backend name
           message)))) ; Full diagnostic message
      original-entries))))
 (tabulated-list-init-header))
(provide 'flymake-utils)
;;; flymake-utils.el ends here
