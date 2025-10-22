;;; core-utils.el --- Configuration Utilities -*- lexical-binding: t -*-

;;; Commentary:
;; Utility functions and macros for configuration loading and management.

(require 'core-logging)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Timing Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro
 core-utils-with-load-timing (module-name &rest body)
 "Execute BODY and report loading time for MODULE-NAME.
MODULE-NAME should be a string identifying the module being loaded."
 (declare (indent 1))
 `(let ((start-time (current-time)))
    (core-message-loading "Loading %s..." ,module-name)
    ,@body
    (message
     "%s loaded (%.2fs)" ,module-name (float-time (time-subtract (current-time) start-time)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Command Path Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun
 core-utils-format-command-found-message (command path host location)
 "Format success message when COMMAND is found.
COMMAND is the command name, PATH is the full path, HOST is the hostname,
LOCATION is either 'local' or 'remote'."
 (core-message-success
  "The LSP command \"%s\" was found in PATH at %s on host (%s): %s" command path location host))

(defun
 core-utils-format-command-not-found-message (command host location)
 "Format warning message when COMMAND is not found.
COMMAND is the command name, HOST is the hostname,
LOCATION is either 'local' or 'remote'."
 (core-message-warning
  "The LSP command \"%s\" was not found in PATH on host (%s): %s" command location host))

(defun
 core-utils-check-command-in-path (command)
 "Check if COMMAND exists in PATH and log message if not found.
Returns t if command is found, nil otherwise."
 (let ((command-path (executable-find command))
       (host (system-name)))
   (if
    command-path
    (progn (core-utils-format-command-found-message command command-path host "local") t)
    (core-utils-format-command-not-found-message command host "local")
    nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Counter Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro
 core-utils-increment-counter
 (counter-var)
 "Increment COUNTER-VAR and return new value."
 `(setq ,counter-var (1+ ,counter-var)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Directory Management Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun
 core-utils-ensure-directory (dir-path)
 "Ensure DIR-PATH exists, creating it if necessary.
Returns t if directory exists/was created, nil if creation failed."
 (let ((expanded-path (expand-file-name dir-path)))
   (if
    (file-exists-p expanded-path)
    t ; Directory already exists
    (condition-case err
        (progn
         (make-directory expanded-path t)
         (core-message-package "Created directory: %s" expanded-path)
         t)
      (error
       (core-message-error
        "Failed to create directory %s: %s" expanded-path (error-message-string err))
       nil)))))

(defun
 core-utils-scan-directory-for-pattern (dir pattern transform-fn)
 "Scan DIR for files matching PATTERN and apply TRANSFORM-FN to each match.
DIR should be a directory path (string).
PATTERN should be a regular expression (string) to match against filenames.
TRANSFORM-FN is a function that takes the filename and match groups, returning a result.

Returns a list of results from applying TRANSFORM-FN to each matching file.

Example:
  (core-utils-scan-directory-for-pattern
   \"/path/to/grammars\"
   \"libtree-sitter-\\\\([^.]+\\\\)\\\\.\\\\(so\\\\|dylib\\\\)$\"
   (lambda (file lang ext)
     (list :name lang :file file)))"
 (when
  (and dir (file-directory-p dir))
  (let ((results '()))
    (dolist
     (file (directory-files dir nil pattern))
     (when
      (string-match pattern file)
      (let* ((num-groups (1- (/ (length (match-data)) 2)))
             (match-groups (cl-loop for i from 1 to num-groups collect (match-string i file)))
             (result (apply transform-fn file match-groups)))
        (when result (push result results)))))
    (nreverse results))))

;;; Provide this module

(provide 'core-utils)

;;; core-utils.el ends here
