;;; package-refresh.el --- Package Refresh Operations -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized package refresh logic with network awareness and timeout protection.
;;      Provides safe refresh operations that only contact responsive repositories.

;;; Code:
(require 'core-logging)
(require 'pkg-system-network-utils)
(require 'pkg-system-repositories)
(require 'pkg-system-cache)
(require 'package)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customization Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defcustom
 pkg-system-refresh-timeout
 30
 "Timeout in seconds for overall package refresh operation."
 :type 'integer
 :group 'package)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro
 pkg-system-refresh-with-available (&rest body)
 "Execute BODY with `package-archives' temporarily set to only available repositories.
Tests repository connectivity and filters out unresponsive ones."
 `(let ((original-archives package-archives)
        (available-repos (pkg-system-get-available)))
    (unwind-protect
     (progn (setq package-archives available-repos) ,@body)
     (setq package-archives original-archives))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 pkg-system-refresh-with-timeout ()
 "Refresh package contents with comprehensive diagnostic feedback.
Only contacts responsive repositories to prevent hanging on offline repos."
 (core-message-package "Refreshing package archive contents...")
 (let ((start-time (current-time))
       (timeout-seconds pkg-system-refresh-timeout))
   (pkg-system-refresh-with-available
    (let ((archive-count (length package-archives)))
      (if
       (= archive-count 0)
       (core-message-error "No repositories available - cannot refresh package contents")
       (progn
        (core-message-info
         "Contacting %d package archive(s) to refresh metadata: %s"
         archive-count
         (mapconcat (lambda (archive) (car archive)) package-archives ", "))
        (core-message-info "This updates available package lists and dependency information")
        (condition-case err
            (with-timeout
             (timeout-seconds
              (core-message-error
               "Package refresh timed out after %.1fs (limit: %ds)"
               (pkg-system--network-elapsed-since start-time)
               timeout-seconds)
              (core-message-info "Using any cached package data available"))
             (package-refresh-contents)
             (core-message-success
              "Package refresh completed in %.2fs (%d packages available)"
              (pkg-system--network-elapsed-since start-time)
              (length package-archive-contents))
             ;; Event-based cache invalidation on success
             (pkg-system-repositories-clear-cache))
          (error
           (core-message-error
            "Package refresh failed after %.2fs: %s"
            (pkg-system--network-elapsed-since start-time)
            (error-message-string err))
           (core-message-info "Will attempt to use cached package data if available")))))))))

(provide 'pkg-system-refresh)
;;; pkg-system-refresh.el ends here
