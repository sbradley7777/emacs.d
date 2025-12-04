;;; command-palette-data.el --- Command Palette Data Persistence -*- lexical-binding: t -*-
;;; Commentary:
;; Data persistence functions for command palette.
;; Handles saving and loading of favorites, diagnostics, and history.

;;; Code:
(require 'command-palette-init)
(require 'command-palette-constants)
(require 'command-palette-defaults)
(require 'logging-init)
(require 'ring)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--ensure-data-directory
 ()
 "Ensure the command palette data directory exists, creating it if necessary."
 (core-ensure-directory command-palette-data-dir))

(defun
 command-palette--insert-file-header
 (file-path description)
 "Insert standard file header for FILE-PATH with DESCRIPTION."
 (insert (format ";;; %s -*- lexical-binding: t -*-\n" (file-name-nondirectory file-path)))
 (insert ";;;\n")
 (insert (format ";;; This file stores the command palette %s.\n" description))
 (insert ";;; Generated automatically - do not edit manually.\n")
 (insert ";;;\n\n"))

(defun
 command-palette--get-config
 (data-key)
 "Get persistence config for DATA-KEY (history, favorites, or diagnostics)."
 (cdr (assoc data-key command-palette--persistence-configs)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generic Save Function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--save-data (data-key)
 "Save data for DATA-KEY to persistent storage.
DATA-KEY should be one of: history, favorites, diagnostics."
 (command-palette--ensure-data-directory)
 (let* ((config (command-palette--get-config data-key))
        (variable (plist-get config :variable))
        (saved-var (plist-get config :saved-var))
        (file-path (symbol-value (plist-get config :file)))
        (data-type (plist-get config :data-type))
        (description (plist-get config :description))
        (data (symbol-value variable)))
   (condition-case err
       (with-temp-file
        file-path
        (command-palette--insert-file-header file-path description)
        (insert (format "(setq %s\n" saved-var))
        (insert "  '(")
        (let ((first t))
          (if
           (eq data-type 'ring)
           (dotimes
            (i (ring-length data))
            (let ((item (ring-ref data i)))
              (unless first (insert "\n    "))
              (setq first nil)
              (insert (format "%S" item))))
           (dolist
            (item data)
            (unless first (insert "\n    "))
            (setq first nil)
            (insert (format "%S" item)))))
        (insert "))\n\n")
        (insert (format ";;; %s ends here\n" (file-name-nondirectory file-path)))
        (logging-success
         "Saved command palette %s to %s" description (abbreviate-file-name file-path)))
     (error
      (logging-error
       "Failed to save command palette %s: %s" description (error-message-string err))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generic Load Function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--load-data (data-key &optional silent)
 "Load data for DATA-KEY from persistent storage.
If SILENT is non-nil, suppress success messages.  Returns t if successful, nil otherwise.
DATA-KEY should be one of: history, favorites, diagnostics."
 (let* ((config (command-palette--get-config data-key))
        (variable (plist-get config :variable))
        (saved-var (plist-get config :saved-var))
        (file-path (symbol-value (plist-get config :file)))
        (data-type (plist-get config :data-type))
        (description (plist-get config :description))
        (default-value (plist-get config :default)))
   (if
    (file-exists-p file-path)
    (condition-case err
        (progn
         (load file-path)
         (when
          (boundp saved-var)
          (if
           (eq data-type 'ring)
           (progn
            (set variable (make-ring command-palette-history-size))
            (dolist
             (item (reverse (symbol-value saved-var))) (ring-insert (symbol-value variable) item)))
           (set variable (symbol-value saved-var)))
          (unless
           silent
           (logging-success
            "Loaded %d %s command(s)" (length (symbol-value saved-var)) description))
          t))
      (error
       (logging-warning
        "Failed to load command palette %s: %s" description (error-message-string err))
       (when default-value (set variable default-value))
       nil))
    (progn
     (when default-value (set variable default-value))
     (unless silent (logging-info "Using default command palette %s" description))
     nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public API Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--save-history
 ()
 "Save command history to persistent storage."
 (command-palette--save-data 'history))

(defun
 command-palette--load-history (&optional silent)
 "Load command history from persistent storage.
If SILENT is non-nil, suppress success messages.  Returns t if successful, nil otherwise."
 (command-palette--load-data 'history silent))

(defun
 command-palette--save-favorites
 ()
 "Save favorites list to persistent storage."
 (command-palette--save-data 'favorites))

(defun
 command-palette--load-favorites (&optional silent)
 "Load favorites from persistent storage.
If SILENT is non-nil, suppress success messages.  Returns t if successful, nil otherwise."
 (command-palette--load-data 'favorites silent))

(defun
 command-palette--save-diagnostics
 ()
 "Save diagnostics list to persistent storage."
 (command-palette--save-data 'diagnostics))

(defun
 command-palette--load-diagnostics (&optional silent)
 "Load diagnostics from persistent storage.
If SILENT is non-nil, suppress success messages.  Returns t if successful, nil otherwise."
 (command-palette--load-data 'diagnostics silent))

(provide 'command-palette-data)
;;; command-palette-data.el ends here
