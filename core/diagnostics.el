;;; diagnostics.el --- System and Configuration Diagnostics -*- lexical-binding: t -*-
;;; Commentary:
;;      System information detection and configuration diagnostics
;;      Provides detailed system context and startup logging for debugging

(require 'core-constants)
(require 'utils)

(with-load-timing
 "diagnostics.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Operating System Detection
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  get-os-version-info () "Get operating system version information."
  (cond
   ;; Linux - try multiple sources for version info
   ((eq system-type 'gnu/linux)
    (or
     ;; Try /etc/os-release first (modern standard)
     (when
      (file-readable-p "/etc/os-release")
      (with-temp-buffer
       (insert-file-contents "/etc/os-release")
       (when (re-search-forward "^PRETTY_NAME=\"?\\([^\"]*\\)\"?" nil t) (match-string 1))))
     ;; Try /etc/lsb-release
     (when
      (file-readable-p "/etc/lsb-release")
      (with-temp-buffer
       (insert-file-contents "/etc/lsb-release")
       (when
        (re-search-forward "^DISTRIB_DESCRIPTION=\"?\\([^\"]*\\)\"?" nil t) (match-string 1))))
     ;; Try uname as fallback
     (condition-case nil
         (string-trim (shell-command-to-string "uname -sr"))
       (error
        "Linux (version unknown)"))))
   ;; macOS
   ((eq system-type 'darwin)
    (condition-case nil
        (let ((version (string-trim (shell-command-to-string "sw_vers -productVersion")))
              (build (string-trim (shell-command-to-string "sw_vers -buildVersion"))))
          (format "macOS %s (Build %s)" version build))
      (error
       "macOS (version unknown)")))
   ;; Windows
   ((eq system-type 'windows-nt)
    (condition-case nil
        (string-trim (shell-command-to-string "ver"))
      (error
       "Windows (version unknown)")))
   ;; Other systems
   (t
    (format "%s (version unknown)" system-type))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced Configuration Diagnostics
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 (defun
  show-system-info () "Show system information in Messages buffer."
  (let ((timestamp (format-time-string "%Y-%m-%d %H:%M:%S"))
        (os-info (get-os-version-info))
        (package-count (if (boundp 'package-activated-list) (length package-activated-list) 0))
        (load-path-count (length load-path)))
    (message "\n=== Emacs Startup Log - %s ===" timestamp)
    (message "Emacs version: %s" emacs-version)
    (message "System: %s %s" system-type system-configuration)
    (message "OS: %s" os-info)
    (message "Load path entries: %d" load-path-count)
    (message "Installed packages: %d" package-count)
    (message "Feature tier: %s\n" (if (boundp 'emacs-feature-tier) emacs-feature-tier "unknown"))
    (message "")))


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (provide 'diagnostics))
;;; diagnostics.el ends here
