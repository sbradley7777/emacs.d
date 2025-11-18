;;; forge-constants.el --- Forge Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized constants for forge configuration modules.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst forge-authinfo-path "~/.authinfo" "Path to the authinfo file.")
(defconst
 forge-authinfo-username-suffix "^forge"
 "Suffix appended to usernames in ~/.authinfo for Forge authentication.
Required by ghub/forge package to identify tokens used for Forge operations.")
(defconst
 forge-markdown-url-search-limit
 500
 "Maximum character search distance for finding URLs after markdown link brackets.")
(defconst
 forge-api-timeout-seconds 30
 "Timeout in seconds for forge API calls during git-sync operations.
If an API call does not complete within this time, it is considered failed.")
(provide 'forge-constants)
;;; forge-constants.el ends here
