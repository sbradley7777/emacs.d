;;; core-utils.el --- Configuration Utilities -*- lexical-binding: t -*-
;;; Commentary:
;; Utility functions and macros for configuration loading and management.

;;; Code:
(require 'core-logging)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Command Path Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-utils-format-command-found-message (command path host location)
 "Format success message when COMMAND is found.
COMMAND is the command name, PATH is the full path, HOST is the hostname,
LOCATION is either \\='local\\=' or \\='remote\\='."
 (core-message-success
  "The command \"%s\" was found in PATH at %s on host (%s): %s"
  command
  (abbreviate-file-name path)
  location
  host))

(defun
 core-utils-format-command-not-found-message (command host location)
 "Format warning message when COMMAND is not found.
COMMAND is the command name, HOST is the hostname,
LOCATION is either \\='local\\=' or \\='remote\\='."
 (core-message-warning
  "The command \"%s\" was not found in PATH on host (%s): %s" command location host))

(defun
 core-utils-check-command-in-path (command)
 "Check if COMMAND exists in PATH and log message if not found.
Returns t if command is found, nil otherwise.

Properly detects local vs remote (TRAMP) paths based on default-directory."
 (let* ((is-remote (file-remote-p default-directory))
        (host
         (if
          is-remote (or (file-remote-p default-directory 'host) "unknown-remote") (system-name)))
        (location (if is-remote "remote" "local"))
        (command-path (executable-find command)))
   (if
    command-path
    (progn (core-utils-format-command-found-message command command-path host location) t)
    (progn (core-utils-format-command-not-found-message command host location) nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Path Constant Definition Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro
 core-utils-defconst-path (name subpath base-dir docstring)
 "Define a path constant NAME by combining SUBPATH with BASE-DIR.
NAME is the symbol name for the constant.
SUBPATH is the subdirectory or file path relative to BASE-DIR.
BASE-DIR is the base directory (e.g., emacs-local-dir, user-emacs-directory).
DOCSTRING is the documentation string for the constant.

Example:
  (core-utils-defconst-path
   my-config-dir \"config/\" emacs-local-dir
   \"Directory for configuration files.\")"
 (declare (indent 1)) `(defconst ,name (expand-file-name ,subpath ,base-dir) ,docstring))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Counter Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro
 core-utils-increment-counter
 (counter-var)
 "Increment COUNTER-VAR and return new value."
 `(setq ,counter-var (1+ ,counter-var)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Window Management Utilities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-utils-find-window-by-buffer-name (buffer-name-pattern &optional exact-match)
 "Find window displaying buffer matching BUFFER-NAME-PATTERN.
If EXACT-MATCH is non-nil, match buffer name exactly using string=.
Otherwise, use string-prefix-p for prefix matching (default).
Returns the window if found, nil otherwise.

Example:
  (core-utils-find-window-by-buffer-name \"*Flymake diagnostics\")
  (core-utils-find-window-by-buffer-name \"*Ilist*\" t)"
 (require 'cl-lib)
 (cl-find-if
  (lambda
   (window)
   (let ((buffer-name (buffer-name (window-buffer window))))
     (if
      exact-match
      (string= buffer-name-pattern buffer-name)
      (string-prefix-p buffer-name-pattern buffer-name))))
  (window-list)))

(defun
 core-utils-close-window-by-buffer-name (buffer-name-pattern &optional exact-match)
 "Close window displaying buffer matching BUFFER-NAME-PATTERN.
If EXACT-MATCH is non-nil, match buffer name exactly using string=.
Otherwise, use string-prefix-p for prefix matching (default).
Returns t if window was found and closed, nil otherwise.

Example:
  (core-utils-close-window-by-buffer-name \"*Flymake diagnostics\")
  (core-utils-close-window-by-buffer-name \"*Ilist*\" t)"
 (let ((window (core-utils-find-window-by-buffer-name buffer-name-pattern exact-match)))
   (when window (quit-window nil window) t)))

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
         (core-message-package "Created directory: %s" (abbreviate-file-name expanded-path))
         t)
      (error
       (core-message-error
        "Failed to create directory %s: %s"
        (abbreviate-file-name expanded-path)
        (error-message-string err))
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
