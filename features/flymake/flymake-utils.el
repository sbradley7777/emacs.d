;;; flymake-utils.el --- Flymake Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for Flymake diagnostics formatting and display

;;; Code:
(require 'core-constants)
(require 'logging-init)
(require 'core-table-utils)
(require 'core-side-window-utils)
(require 'core-utils)
(require 'eglot-registry)
(require 'flymake-registry)
(require 'flymake-diagnostic-data)
(require 'flymake-diagnostic-window)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
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
  (if (flymake-is-running) "checking" "idle")
  "unknown"))

(defun
 flymake--format-diagnostic-counts (error-count warning-count note-count)
 "Format diagnostic counts as a string.
ERROR-COUNT is the number of errors.
WARNING-COUNT is the number of warnings.
NOTE-COUNT is the number of notes.
Returns formatted string like \\='3 errors, 2 warnings, 1 note\\='."
 (format
  "Diagnostics: %d %s, %d %s, %d %s"
  error-count
  (core-pluralize error-count "error")
  warning-count
  (core-pluralize warning-count "warning")
  note-count
  (core-pluralize note-count "note")))

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
      (let ((description (registry-get-description flymake-backend-registry backend)))
        (push (format "  - %s (%s)" description backend) lines))))
    (push "Active Backends: None" lines))
   (nreverse lines)))

(defun
 flymake--get-lsp-config ()
 "Get LSP configuration for current `major-mode' from `eglot-lsp-server-registry'.
Returns cons cell (MODE . SERVER-EXECUTABLE) or nil if no LSP configured for this mode."
 (when
  (boundp 'eglot-lsp-server-registry)
  (let ((server-symbol (registry-find-by-mode eglot-lsp-server-registry major-mode)))
    (when
     server-symbol
     (let ((binary (registry-get-property eglot-lsp-server-registry server-symbol :binary)))
       (when binary (cons major-mode binary)))))))

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
        ((or (eq type :error) (eq type 'eglot-error))
         (setq error-count (1+ error-count)))
        ((or (eq type :warning) (eq type 'eglot-warning))
         (setq warning-count (1+ warning-count)))
        ((or (eq type :note) (eq type 'eglot-note) (eq type 'eglot-info))
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
 flymake-check-backend-availability ()
 "Check Flymake backend status and log appropriate messages.
Provides success messages when backends are active, warnings about missing LSP servers,
or info messages for unconfigured modes.  Remains silent when eglot is configured but
still connecting.  Uses `flymake-backend-registry' and `eglot-lsp-server-registry'."
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
              (lambda
               (backend) (registry-get-description flymake-backend-registry backend))
              active-backends ", ")))
        (logging-success "Flymake: Active backends for %s: %s" mode-name backend-names)))
     ;; Case 2: LSP configured but server not installed
     ((and lsp-config lsp-server (not (executable-find lsp-server)))
      (logging-warning
       "Flymake: No backends active for %s. LSP server \"%s\" not found in PATH."
       mode-name
       lsp-server))
     ;; Case 3: LSP configured and server exists (eglot may still be connecting, stay silent)
     (lsp-config
      nil)
     ;; Case 4: No backends and no LSP configured
     (t
      (logging-info
       "Flymake: No backends configured for %s. Consider adding LSP support or custom backend."
       mode-name))))))

(defun
 diagnostics-show-flymake-backends ()
 "Display comprehensive Flymake diagnostics including buffers and all backend types.
Shows 4 tables: buffers, LSP backends, direct backends, and loader backends.
Includes backend binary/LSP server information and installation status."
 (interactive)
 (let ((lines nil))
   ;; Table 1: Flymake Buffers
   (push "Flymake Buffers" lines)
   (dolist (line (flymake--build-all-buffers-table)) (push line lines))
   (push "" lines)
   ;; Table 2: Flymake LSP Backends
   (push "Flymake LSP Backends" lines)
   (dolist (line (flymake--build-lsp-backends-table)) (push line lines))
   (push "" lines)
   ;; Table 3: Flymake Direct Backends
   (push "Flymake Direct Backends" lines)
   (dolist (line (flymake--build-direct-backends-table)) (push line lines))
   (push "" lines)
   ;; Table 4: Flymake Loader Backends
   (push "Flymake Loader Backends" lines)
   (dolist (line (flymake--build-loader-backends-table)) (push line lines))
   ;; Validation issues (if any) - at bottom
   (when-let ((validation-lines (flymake--format-validation-issues)))
     (push "" lines)
     (dolist (line validation-lines) (push line lines)))
   ;; Display all tables
   (logging-diagnostic "Flymake Comprehensive Diagnostics" (nreverse lines))))

(defun
 flymake--diagnostics-find-window ()
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
 (core-side-window-toggle
  "\\*Flymake diagnostics"
  (lambda
   ()
   (when
    (fboundp 'user-close-exclusive-side-windows) (user-close-exclusive-side-windows))
   (require 'flymake nil t)
   (if
    (fboundp 'flymake-show-buffer-diagnostics)
    (flymake-show-buffer-diagnostics)
    (logging-warning "Flymake is not available")))
  (lambda (pattern) (flymake--diagnostics-find-window))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enhanced Diagnostics Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 flymake--get-backend-binary-info (backend-symbol)
 "Get binary/LSP server information for BACKEND-SYMBOL.
Returns plist with :type, :binary/:lsp-server, :installed keys.
Checks registry first, then `eglot-lsp-server-registry' for LSP backends.

Examples:
  LSP backend:    (:type lsp :lsp-server \"pylsp\" :installed t)
  Direct backend: (:type direct :binary \"shellcheck\" :installed nil)
  Loader backend: (:type loader-based :binary nil :installed t)
  Built-in:       (:type direct :binary \"(built-in)\" :installed t)"
 (let* ((backend-type (registry-get-property flymake-backend-registry backend-symbol :type))
        (binary-name (registry-get-property flymake-backend-registry backend-symbol :binary))
        (modes (registry-get-modes flymake-backend-registry backend-symbol)))
   (cond
    ;; LSP backend
    ((eq backend-type 'lsp)
     (let* ((mode (car modes))
            (lsp-server
             (when
              (boundp 'eglot-lsp-server-registry)
              (let ((server-symbol (registry-find-by-mode eglot-lsp-server-registry mode)))
                (when
                 server-symbol
                 (registry-get-property eglot-lsp-server-registry server-symbol :binary)))))
            (installed (and lsp-server (executable-find lsp-server))))
       (list :type 'lsp :lsp-server (or lsp-server "-") :installed (if installed t nil))))
    ;; Direct backend with binary
    ((and (eq backend-type 'direct) binary-name)
     (let ((installed (if (string= binary-name "(built-in)") t (executable-find binary-name))))
       (list :type 'direct :binary binary-name :installed (if installed t nil))))
    ;; Direct backend without binary (should not happen after registry updates)
    ((eq backend-type 'direct)
     (list :type 'direct :binary "(built-in)" :installed t))
    ;; Loader-based backend
    ((eq backend-type 'loader-based)
     (list :type 'loader-based :binary (or binary-name "-") :installed t))
    ;; Unknown/unregistered
    (t
     (list :type 'unknown :binary "-" :installed nil)))))

(defun
 flymake--validate-buffer-backends (buffer)
 "Validate backends in BUFFER against registry.
Returns list of validation issues, or nil if all valid.
Only flags backends completely missing from registry as issues.
Disabled backends in registry are not flagged as issues."
 (with-current-buffer
  buffer
  (when
   (and (boundp 'flymake-mode) flymake-mode)
   (let ((active-backends (flymake--get-active-backends))
         (issues nil))
     (dolist
      (backend active-backends)
      (let ((spec (registry-find-entry flymake-backend-registry backend)))
        (unless
         spec
         (push (format "Buffer %s: Backend %s not in registry" (buffer-name) backend) issues))))
     issues))))

(defun
 flymake--collect-all-buffer-info ()
 "Collect Flymake information for all buffers with `flymake-mode' enabled.
Returns list of plists with :buffer, :mode, :backends, :diagnostics, :status keys."
 (let ((buffer-info nil))
   (dolist
    (buf (buffer-list))
    (with-current-buffer
     buf
     (when
      (and (boundp 'flymake-mode) flymake-mode)
      (let* ((active-backends (flymake--get-active-backends))
             (backend-count (length active-backends))
             (diagnostic-counts (flymake--count-diagnostics))
             (error-count (or (plist-get diagnostic-counts :errors) 0))
             (warning-count (or (plist-get diagnostic-counts :warnings) 0))
             (note-count (or (plist-get diagnostic-counts :notes) 0))
             (status (if active-backends "enabled" "disabled")))
        (push
         (list
          :buffer (buffer-name)
          :mode (format "%s" major-mode)
          :backend-count (number-to-string backend-count)
          :backends (mapconcat (lambda (b) (format "%s" b)) active-backends ", ")
          :diagnostics (format "%d/%d/%d" error-count warning-count note-count)
          :status status)
         buffer-info)))))
   (nreverse buffer-info)))

(defun
 flymake--build-all-buffers-table ()
 "Build Flymake Buffers table.
Returns list of formatted table lines with total row."
 (let* ((buffer-info (flymake--collect-all-buffer-info))
        (headers '("Buffer" "Major Mode" "Backends" "Backend List" "Diagnostics" "Status"))
        (rows
         (mapcar
          (lambda
           (info)
           (list
            (plist-get info :buffer) (plist-get info :mode) (plist-get info :backend-count)
            (let ((backends (plist-get info :backends)))
              (if (string-empty-p backends) "-" backends))
            (plist-get info :diagnostics) (plist-get info :status)))
          buffer-info)))
   (if
    rows
    (let* ((total-backends 0)
           (total-errors 0)
           (total-warnings 0)
           (total-notes 0))
      (dolist
       (info buffer-info)
       (let ((backend-count-str (plist-get info :backend-count))
             (diag-str (plist-get info :diagnostics)))
         (setq total-backends (+ total-backends (string-to-number backend-count-str)))
         (when
          (string-match "\\([0-9]+\\)/\\([0-9]+\\)/\\([0-9]+\\)" diag-str)
          (setq total-errors (+ total-errors (string-to-number (match-string 1 diag-str))))
          (setq total-warnings (+ total-warnings (string-to-number (match-string 2 diag-str))))
          (setq total-notes (+ total-notes (string-to-number (match-string 3 diag-str)))))))
      (let ((total-spec
             (lambda
              (headers rows)
              (list
               "TOTAL"
               (number-to-string (length rows))
               (number-to-string total-backends)
               "-"
               (format "%d/%d/%d" total-errors total-warnings total-notes)
               "-"))))
        (core-table-format headers rows total-spec)))
    (list "No buffers with flymake-mode enabled"))))

(defun
 flymake--format-validation-issues ()
 "Format validation issues section for all buffers.
Returns list of formatted strings, or nil if no issues."
 (let ((all-issues nil))
   (dolist
    (buf (buffer-list))
    (let ((issues (flymake--validate-buffer-backends buf)))
      (when issues (setq all-issues (append all-issues issues)))))
   (when all-issues (cons "\nValidation Issues:" all-issues))))

(defun
 flymake--count-active-buffers-backend ()
 "Count how many buffers are using each backend.
Returns alist of (backend-symbol . count)."
 (let ((backend-counts nil))
   (dolist
    (buf (buffer-list))
    (with-current-buffer
     buf
     (when
      (and (boundp 'flymake-mode) flymake-mode)
      (let ((active-backends (flymake--get-active-backends)))
        (dolist
         (backend active-backends)
         (let ((entry (assq backend backend-counts)))
           (if entry (setcdr entry (1+ (cdr entry))) (push (cons backend 1) backend-counts))))))))
   backend-counts))

(defun
 flymake--count-buffers-per-backend-mode ()
 "Count how many buffers are using each backend for each mode.
Returns alist of ((backend-symbol . mode-symbol) . count)."
 (let ((counts nil))
   (dolist
    (buf (buffer-list))
    (with-current-buffer
     buf
     (when
      (and (boundp 'flymake-mode) flymake-mode)
      (let ((active-backends (flymake--get-active-backends))
            (mode major-mode))
        (dolist
         (backend active-backends)
         (let* ((key (cons backend mode))
                (entry (assoc key counts)))
           (if entry (setcdr entry (1+ (cdr entry))) (push (cons key 1) counts))))))))
   counts))

(defun
 flymake--lsp-running-for-mode-p (mode)
 "Check if LSP server is running for any buffer with major MODE.
Returns t if at least one buffer with MODE has eglot managing it."
 (catch
  'found
  (dolist
   (buf (buffer-list))
   (with-current-buffer
    buf
    (when
     (and (eq major-mode mode) (fboundp 'eglot-managed-p) (eglot-managed-p)) (throw 'found t))))
  nil))

(defun
 flymake--build-lsp-backends-table ()
 "Build Flymake LSP Backends table.
Returns list of formatted table lines with total row showing running count.
Creates one row per mode/LSP-server combination from `eglot-lsp-server-registry'."
 (let* ((headers
         '("Major Mode"
           "Backend"
           "Description"
           "Binary"
           "Installed"
           "Enabled"
           "Priority"
           "Running"))
        (rows nil))
   (when
    (boundp 'eglot-lsp-server-registry)
    (dolist
     (entry eglot-lsp-server-registry)
     (let* ((server-symbol (registry-entry-identifier entry))
            (description (registry-entry-description entry))
            (modes (registry-entry-modes entry))
            (lsp-server (registry-entry-get-property entry :binary))
            (disabled (registry-entry-get-property entry :disabled))
            (priority (or (registry-entry-get-property entry :priority) 100))
            (backend-symbol 'eglot-flymake-backend))
       (unless
        disabled
        (dolist
         (mode modes)
         (let* ((installed (executable-find lsp-server))
                (running (flymake--lsp-running-for-mode-p mode))
                (installed-str (if installed "yes" "no"))
                (enabled-str "yes")
                (running-str (if running "yes" "no")))
           (push
            (list
             (format "%s" mode)
             (format "%s" backend-symbol)
             description
             lsp-server
             installed-str
             enabled-str
             (number-to-string priority)
             running-str)
            rows)))))))
   (if
    rows
    (let* ((reversed-rows (nreverse rows))
           (running-count (cl-count-if (lambda (row) (string= (nth 7 row) "yes")) reversed-rows))
           (row-count (length reversed-rows))
           (total-spec
            (core-table-total-with-count-label
             "Total" row-count "-" "-" "-" "-" "-" "-" (number-to-string running-count))))
      (core-table-format headers reversed-rows total-spec))
    (list "No LSP backends registered"))))

(defun
 flymake--build-backends-table-by-type (backend-type empty-message)
 "Build Flymake backends table filtered by BACKEND-TYPE.
Returns list of formatted table lines with total row showing buffer count.
Creates one row per mode/backend combination.

BACKEND-TYPE is the backend type symbol to filter (e.g., \\='direct, \\='loader-based).
EMPTY-MESSAGE is the message to display when no backends of this type exist."
 (let* ((headers
         '("Major Mode"
           "Backend"
           "Description"
           "Binary"
           "Installed"
           "Enabled"
           "Priority"
           "Buffers"))
        (rows nil)
        (buffer-counts (flymake--count-buffers-per-backend-mode)))
   (dolist
    (entry flymake-backend-registry)
    (let* ((backend-symbol (registry-entry-identifier entry))
           (description (registry-entry-description entry))
           (modes (registry-entry-modes entry))
           (priority (or (registry-entry-get-property entry :priority) 100))
           (disabled (registry-entry-get-property entry :disabled))
           (info (flymake--get-backend-binary-info backend-symbol)))
      (when
       (eq (plist-get info :type) backend-type)
       (let* ((binary (plist-get info :binary))
              (installed (plist-get info :installed))
              (installed-str (if installed "yes" "no"))
              (enabled-str (if (not disabled) "yes" "no")))
         (dolist
          (mode modes)
          (let* ((key (cons backend-symbol mode))
                 (count-entry (assoc key buffer-counts))
                 (buffer-count (if count-entry (cdr count-entry) 0)))
            (push
             (list
              (format "%s" mode)
              (format "%s" backend-symbol)
              description
              binary
              installed-str
              enabled-str
              (number-to-string priority)
              (number-to-string buffer-count))
             rows)))))))
   (if
    rows
    (let* ((reversed-rows (nreverse rows))
           (total-buffers
            (apply '+ (mapcar (lambda (row) (string-to-number (nth 7 row))) reversed-rows)))
           (row-count (length reversed-rows))
           (total-spec
            (core-table-total-with-count-label
             "Total" row-count "-" "-" "-" "-" "-" "-" (number-to-string total-buffers))))
      (core-table-format headers reversed-rows total-spec))
    (list empty-message))))

(defun
 flymake--build-direct-backends-table ()
 "Build Flymake Direct Backends table.
Returns list of formatted table lines with total row showing buffer count.
Creates one row per mode/backend combination."
 (flymake--build-backends-table-by-type 'direct "No direct backends registered"))

(defun
 flymake--build-loader-backends-table ()
 "Build Flymake Loader Backends table.
Returns list of formatted table lines with total row showing buffer count.
Creates one row per mode/backend combination."
 (flymake--build-backends-table-by-type 'loader-based "No loader backends registered"))

(provide 'flymake-utils)
;;; flymake-utils.el ends here
