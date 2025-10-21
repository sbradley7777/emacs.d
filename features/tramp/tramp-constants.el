;;; tramp-constants.el --- TRAMP Configuration Constants -*- lexical-binding: t -*-

;;; Commentary:
;; Constants for TRAMP (Transparent Remote Access, Multiple Protocol) configuration.
;; These settings control remote file access behavior.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TRAMP (Remote Access) Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst
 tramp-default-shell "/bin/bash"
 "Default remote shell for TRAMP connections.
Bash is widely available and provides consistent behavior across remote systems.")

(defconst
 tramp-user-paths '("~/.local/bin")
 "Additional remote paths for TRAMP executable search.
These directories are added to the remote PATH when connecting via TRAMP.")

(provide 'tramp-constants)

;;; tramp-constants.el ends here
