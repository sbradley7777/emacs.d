;;; core-utils.el --- Configuration Utilities -*- lexical-binding: t -*-
;;; Commentary:
;; Utility functions and macros for configuration loading and management.

;;; Code:
(require 'logging-messages) ; Only need message functions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro
 core-define-path (name subpath base-dir docstring)
 "Define a path constant NAME by combining SUBPATH with BASE-DIR.
NAME is the symbol name for the constant.
SUBPATH is the subdirectory or file path relative to BASE-DIR.
BASE-DIR is the base directory (e.g., core-emacs-local-dir, `user-emacs-directory').
DOCSTRING is the documentation string for the constant.

Example:
  (core-define-path
   my-config-dir \"config/\" core-emacs-local-dir
   \"Directory for configuration files.\")"
 (declare (indent 1)) `(defconst ,name (expand-file-name ,subpath ,base-dir) ,docstring))

(defmacro
 core-increment-counter
 (counter-var)
 "Increment COUNTER-VAR and return new value."
 `(setq ,counter-var (1+ ,counter-var)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core-is-remote-file (&optional file)
 "Check if FILE (or `default-directory') is accessed via TRAMP.
FILE defaults to `default-directory' if not specified.
Returns non-nil if the file/directory is remote, nil otherwise."
 (file-remote-p (or file default-directory)))

(defun
 core-validate-non-empty-string (value &optional description)
 "Validate that VALUE is a non-empty string.
Returns t if valid, logs warning and returns nil otherwise.
DESCRIPTION is optional name for error messages (defaults to \\='Value\\=')."
 (cond
  ((not (stringp value))
   (logging-warning "%s must be a string, got: %s" (or description "Value") (type-of value))
   nil)
  ((string-empty-p value)
   (logging-warning "%s cannot be empty" (or description "Value"))
   nil)
  (t
   t)))

(defun
 core-validate-hostname (hostname)
 "Validate that HOSTNAME is a valid hostname format.
Returns t if valid format, nil otherwise.  Does not validate DNS resolution.
Checks RFC-compliant hostname syntax: alphanumeric start/end, hyphens and dots allowed in middle, no consecutive
dots."
 (and
  (stringp hostname)
  (not (string-empty-p hostname))
  (string-match-p "^[a-zA-Z0-9][-a-zA-Z0-9.]*[a-zA-Z0-9]$" hostname)
  (not (string-match-p "\\.\\." hostname))))

(defun
 core-check-command-in-path (command)
 "Check if COMMAND exists in PATH and log message if not found.
Returns t if command is found, nil otherwise.

Properly detects local vs remote (TRAMP) paths based on `default-directory'.
When `default-directory' is remote, searches for COMMAND on the remote host."
 (let* ((is-remote (core-is-remote-file))
        (host
         (if
          is-remote (or (file-remote-p default-directory 'host) "unknown-remote") (system-name)))
        (location (if is-remote "remote" "local"))
        (command-path (executable-find command is-remote)))
   (if
    command-path
    (progn
     (logging-success
      "The command \"%s\" was found in PATH at %s on host (%s): %s"
      command
      (abbreviate-file-name command-path)
      location
      host)
     t)
    (progn
     (logging-warning
      "The command \"%s\" was not found in PATH on host (%s): %s" command location host)
     nil))))

(defun
 core-ensure-directory (dir-path)
 "Ensure DIR-PATH exists, creating it if necessary.
Returns t if directory exists/was created, nil if creation failed."
 (let ((expanded-path (expand-file-name dir-path)))
   (if
    (file-exists-p expanded-path)
    t ; Directory already exists
    (condition-case err
        (progn
         (make-directory expanded-path t)
         (logging-package "Created directory: %s" (abbreviate-file-name expanded-path))
         t)
      (error
       (logging-error
        "Failed to create directory %s: %s"
        (abbreviate-file-name expanded-path)
        (error-message-string err))
       nil)))))

(defun
 core-extract-directory-name (path)
 "Extract final directory name from PATH.
Returns the directory name as a string, or nil if PATH is nil.

Example:
  (core-extract-directory-name \"/home/user/projects/myapp/\")
  => \"myapp\""
 (when path (file-name-nondirectory (directory-file-name path))))

(defun
 core-find-dominating-directory-by-markers (markers &optional directory)
 "Find dominating directory containing any file/directory from MARKERS list.
MARKERS is a list of filenames or directory names to search for.
DIRECTORY is the starting directory (defaults to `default-directory').

Returns the directory path containing the first matching marker, or nil if none found.
Searches upward through parent directories until a marker is found.

Example:
  (core-find-dominating-directory-by-markers
   \\='(\".git\" \"pyproject.toml\" \"Cargo.toml\"))
  => \"/home/user/projects/myapp/\""
 (let ((current-dir (or directory default-directory)))
   (cl-some (lambda (marker) (locate-dominating-file current-dir marker)) markers)))

(defun
 core-scan-directory-for-pattern (dir pattern transform-fn)
 "Scan DIR for files matching PATTERN and apply TRANSFORM-FN to each match.
DIR should be a directory path (string).
PATTERN should be a regular expression (string) to match against filenames.
TRANSFORM-FN is a function that takes the filename and match groups, returning a result.

Returns a list of results from applying TRANSFORM-FN to each matching file.

Example:
  (core-scan-directory-for-pattern
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

(defun
 core-set-file-permissions (file mode &optional description)
 "Set FILE to MODE (octal, e.g., #o600).
MODE should be an octal number representing file permissions.
DESCRIPTION is optional name for error messages (defaults to FILE).
Returns t on success, nil on failure."
 (let ((desc (or description (abbreviate-file-name file))))
   (condition-case err
       (progn (set-file-modes file mode) (logging-debug "Set permissions on %s to %o" desc mode) t)
     (error
      (logging-error "Failed to set permissions on %s: %s" desc (error-message-string err))
      nil))))

;;; Provide this module
(provide 'core-utils)
;;; core-utils.el ends here
