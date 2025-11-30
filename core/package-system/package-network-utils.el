;;; package-network-utils.el --- Network Testing Utilities -*- lexical-binding: t -*-
;;; Commentary:
;;      Pure network connectivity testing without repository knowledge.
;;      Foundation layer with no package-system dependencies.
;;      Provides generic URL testing that can be used by repository management.

;;; Code:
(require 'url)
(require 'url-http)

;; External url-http variables
(defvar url-http-attempt-keepalives)
(defvar url-http-open-connections)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; URL Library Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure url library for fail-fast behavior
(setq url-http-attempt-keepalives nil) ; Disable keepalives to prevent hanging connections

;; Initialize url-http-open-connections if needed
(unless
 (hash-table-p url-http-open-connections)
 (setq url-http-open-connections (make-hash-table :test 'equal)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defcustom
 network-utils-test-timeout 3
 "Timeout in seconds for testing URL connectivity.
Uses asynchronous retrieval to properly timeout even during TCP connection phase."
 :type 'integer
 :group 'package)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 network-utils--elapsed-since (start-time)
 "Calculate seconds elapsed since START-TIME.
START-TIME should be from `current-time'."
 (float-time (time-subtract (current-time) start-time)))

(defun
 network-utils-test-url (url &optional timeout)
 "Test if URL is responsive within TIMEOUT seconds.
Returns t if URL responds successfully, nil otherwise.
Uses asynchronous retrieval to properly handle TCP connection timeouts.

This is a pure network testing function with no caching or repository knowledge.
For repository-aware testing with caching, use package-repositories functions."
 (let* ((start-time (current-time))
        (timeout-seconds (or timeout network-utils-test-timeout))
        (deadline (time-add (current-time) timeout-seconds))
        (status nil)
        (done nil)
        (buf nil))
   (condition-case err
       (with-timeout
        (timeout-seconds (when (buffer-live-p buf) (ignore-errors (kill-buffer buf))) nil)
        ;; Use asynchronous url-retrieve to avoid TCP connection hang bug (Emacs bug #71295)
        (setq
         buf
         (url-retrieve
          url (lambda (status-arg) (setq done t) (setq status (not (plist-get status-arg :error))))
          nil ; cbargs
          t)) ; silent
        ;; Wait for async process to complete or timeout
        (when
         buf
         (let ((proc (get-buffer-process buf)))
           ;; Use short intervals (0.1s) to check process output until done or deadline
           (while
            (and (not done) (process-live-p proc) (time-less-p (current-time) deadline))
            (accept-process-output proc 0.1))
           ;; Clean up buffer if still alive
           (when (buffer-live-p buf) (ignore-errors (kill-buffer buf))))))
     (error
      (when (buffer-live-p buf) (ignore-errors (kill-buffer buf)))
      (setq status nil)))
   status))

(provide 'package-network-utils)
;;; package-network-utils.el ends here
