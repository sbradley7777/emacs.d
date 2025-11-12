;;; core-user-interaction-utils.el --- User Input Collection Utilities -*- lexical-binding: t -*-
;;; Commentary:
;;      Standardized wrappers for collecting user input with consistent
;;      error handling, validation, and logging.

;;; Code:
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "core-user-interaction-utils.el"

 (defun
  core-user-read-string (prompt &optional initial-input history default-value)
  "Read a string from the user with PROMPT.
Wrapper around read-string with consistent behavior and error handling.
INITIAL-INPUT, HISTORY, and DEFAULT-VALUE are passed through to read-string."
  (condition-case err
      (read-string prompt initial-input history default-value)
    (error
     (core-message-error "Failed to read user input: %s" (error-message-string err))
     nil)))

 (defun
  core-user-read-number (prompt &optional min max)
  "Read a number from the user with PROMPT.
Validates that input is a valid number.
Optional MIN and MAX constrain the acceptable range.
Returns the number or nil if invalid/cancelled."
  (let* ((input (core-user-read-string prompt))
         (number (when input (string-to-number input))))
    (cond
     ((not input)
      nil)
     ((and input (= number 0) (not (string-match-p "^0+$" input)))
      (core-message-warning "Invalid number: %s" input)
      nil)
     ((and min (< number min))
      (core-message-warning "Number must be at least %d" min)
      nil)
     ((and max (> number max))
      (core-message-warning "Number must be at most %d" max)
      nil)
     (t
      number))))

 (defun
  core-user-read-password (prompt)
  "Read a password from the user with PROMPT.
Wrapper around read-passwd with consistent behavior."
  (condition-case err
      (read-passwd prompt)
    (error
     (core-message-error "Failed to read password: %s" (error-message-string err))
     nil)))

 (core-message-config "User interaction utilities loaded"))
(provide 'core-user-interaction-utils)
;;; core-user-interaction-utils.el ends here
