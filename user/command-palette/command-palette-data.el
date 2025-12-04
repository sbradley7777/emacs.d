;;; command-palette-data.el --- Command Palette Data Persistence -*- lexical-binding: t -*-
;;; Commentary:
;; Data persistence functions for command palette.
;; Handles saving and loading of favorites, diagnostics, and history.

;;; Code:
(require 'command-palette-init)
(require 'command-palette-defaults)
(require 'logging-init)
(require 'ring)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette--ensure-data-directory
 ()
 "Ensure the command palette data directory exists, creating it if necessary."
 (core-ensure-directory command-palette-data-dir))

(defun
 command-palette--save-history
 ()
 "Save command history to persistent storage."
 (command-palette--ensure-data-directory)
 (condition-case err
     (with-temp-file
      command-palette-history-file
      (insert
       ";;; command-palette-history.el --- Command Palette History -*- lexical-binding: t -*-\n")
      (insert ";;;\n")
      (insert ";;; This file stores the command palette execution history.\n")
      (insert ";;; Generated automatically - do not edit manually.\n")
      (insert ";;;\n\n")
      (insert "(setq command-palette-saved-history\n")
      (insert "  '(")
      (let ((first t))
        (dotimes
         (i (ring-length user--command-palette-history))
         (let ((item (ring-ref user--command-palette-history i)))
           (unless first (insert "\n    "))
           (setq first nil)
           (insert (format "%S" item)))))
      (insert "))\n\n")
      (insert ";;; command-palette-history.el ends here\n")
      (logging-success
       "Saved command palette history to %s" (abbreviate-file-name command-palette-history-file)))
   (error
    (logging-error "Failed to save command palette history: %s" (error-message-string err)))))

(defun
 command-palette--load-history (&optional silent)
 "Load command history from persistent storage.
If SILENT is non-nil, suppress success messages.  Returns t if successful, nil otherwise."
 (when
  (file-exists-p command-palette-history-file)
  (condition-case err
      (progn
       (load command-palette-history-file)
       (when
        (boundp 'command-palette-saved-history)
        (setq user--command-palette-history (make-ring command-palette-history-size))
        (dolist
         (item (reverse command-palette-saved-history))
         (ring-insert user--command-palette-history item))
        (unless
         silent
         (logging-success
          "Loaded %d command(s) from history" (length command-palette-saved-history)))
        t))
    (error
     (logging-warning "Failed to load command palette history: %s" (error-message-string err))
     nil))))

(defun
 command-palette--save-favorites
 ()
 "Save favorites list to persistent storage."
 (command-palette--ensure-data-directory)
 (condition-case err
     (with-temp-file
      command-palette-favorites-file
      (insert
       ";;; command-palette-favorites.el --- Command Palette Favorites -*- lexical-binding: t -*-\n")
      (insert ";;;\n")
      (insert ";;; This file stores the command palette favorites list.\n")
      (insert ";;; Generated automatically - do not edit manually.\n")
      (insert ";;;\n\n")
      (insert "(setq command-palette-saved-favorites\n")
      (insert "  '(")
      (let ((first t))
        (dolist
         (item user-command-palette-favorites)
         (unless first (insert "\n    "))
         (setq first nil)
         (insert (format "%S" item))))
      (insert "))\n\n")
      (insert ";;; command-palette-favorites.el ends here\n")
      (logging-success
       "Saved command palette favorites to %s"
       (abbreviate-file-name command-palette-favorites-file)))
   (error
    (logging-error "Failed to save command palette favorites: %s" (error-message-string err)))))

(defun
 command-palette--load-favorites (&optional silent)
 "Load favorites from persistent storage.
If SILENT is non-nil, suppress success messages.  Returns t if successful, nil otherwise."
 (if
  (file-exists-p command-palette-favorites-file)
  (condition-case err
      (progn
       (load command-palette-favorites-file)
       (when
        (boundp 'command-palette-saved-favorites)
        (setq user-command-palette-favorites command-palette-saved-favorites)
        (unless
         silent
         (logging-success "Loaded %d favorite command(s)" (length user-command-palette-favorites)))
        t))
    (error
     (logging-warning "Failed to load command palette favorites: %s" (error-message-string err))
     (setq user-command-palette-favorites command-palette-default-favorites)
     nil))
  (progn
   (setq user-command-palette-favorites command-palette-default-favorites)
   (unless silent (logging-info "Using default command palette favorites"))
   nil)))

(defun
 command-palette--save-diagnostics
 ()
 "Save diagnostics list to persistent storage."
 (command-palette--ensure-data-directory)
 (condition-case err
     (with-temp-file
      command-palette-diagnostics-file
      (insert
       ";;; command-palette-diagnostics.el --- Command Palette Diagnostics -*- lexical-binding: t -*-\n")
      (insert ";;;\n")
      (insert ";;; This file stores the command palette diagnostics list.\n")
      (insert ";;; Generated automatically - do not edit manually.\n")
      (insert ";;;\n\n")
      (insert "(setq command-palette-saved-diagnostics\n")
      (insert "  '(")
      (let ((first t))
        (dolist
         (item user-command-palette-diagnostics)
         (unless first (insert "\n    "))
         (setq first nil)
         (insert (format "%S" item))))
      (insert "))\n\n")
      (insert ";;; command-palette-diagnostics.el ends here\n")
      (logging-success
       "Saved command palette diagnostics to %s"
       (abbreviate-file-name command-palette-diagnostics-file)))
   (error
    (logging-error "Failed to save command palette diagnostics: %s" (error-message-string err)))))

(defun
 command-palette--load-diagnostics (&optional silent)
 "Load diagnostics from persistent storage.
If SILENT is non-nil, suppress success messages.  Returns t if successful, nil otherwise."
 (if
  (file-exists-p command-palette-diagnostics-file)
  (condition-case err
      (progn
       (load command-palette-diagnostics-file)
       (when
        (boundp 'command-palette-saved-diagnostics)
        (setq user-command-palette-diagnostics command-palette-saved-diagnostics)
        (unless
         silent
         (logging-success
          "Loaded %d diagnostic command(s)" (length user-command-palette-diagnostics)))
        t))
    (error
     (logging-warning "Failed to load command palette diagnostics: %s" (error-message-string err))
     (setq user-command-palette-diagnostics command-palette-default-diagnostics)
     nil))
  (progn
   (setq user-command-palette-diagnostics command-palette-default-diagnostics)
   (unless silent (logging-info "Using default command palette diagnostics"))
   nil)))

(provide 'command-palette-data)
;;; command-palette-data.el ends here
