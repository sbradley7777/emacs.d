;;; core-process-utils.el --- Process Execution Utilities -*- lexical-binding: t -*-
;;; Commentary:
;;      Standardized wrappers for running external commands with
;;      consistent error handling and logging.
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "core-process-utils.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Synchronous Command Execution
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  core-process-run-sync (command quiet &rest args)
  "Run COMMAND with ARGS synchronously and return output as string.
Returns the command output as a trimmed string on success, or nil on failure.

COMMAND is the executable name (e.g., \"git\", \"uname\").
QUIET is a boolean - if non-nil, don't log errors for non-zero exit codes.
ARGS are the command-line arguments as separate strings.

Logs errors via core-message-error for consistent error reporting unless
QUIET is non-nil. Exceptions are always logged regardless of QUIET.

Example:
  (core-process-run-sync \"git\" nil \"config\" \"--global\" \"--get\" \"user.name\")
  (core-process-run-sync \"git\" t \"config\" \"--global\" \"--get\" \"user.name\")
  (core-process-run-sync \"uname\" nil \"-sr\")"
  (condition-case err
      (with-temp-buffer
       (let ((exit-code (apply #'call-process command nil t nil args)))
         (if
          (zerop exit-code) (string-trim (buffer-string))
          (unless
           quiet
           (core-message-error
            "Command '%s %s' failed with exit code %d"
            command
            (mapconcat #'identity args " ")
            exit-code))
          nil)))
    (error
     (core-message-error "Process execution error for '%s': %s" command (error-message-string err))
     nil)))

 (core-message-config "Process execution utilities loaded"))
(provide 'core-process-utils)
;;; core-process-utils.el ends here
