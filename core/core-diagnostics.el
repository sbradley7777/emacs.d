;;; core-diagnostics.el --- System and Configuration Diagnostics -*- lexical-binding: t -*-
;;; Commentary:
;;      System information detection and configuration diagnostics
;;      Provides detailed system context and startup logging for debugging


(core-utils-with-load-timing
 "core-diagnostics.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Operating System Detection
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  diagnostics-get-os-version-info () "Get operating system version information."
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

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced Configuration Diagnostics
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 (defun
  diagnostics-show-system-info () "Show system information in Messages buffer."
  (let ((timestamp (format-time-string "%Y-%m-%d %H:%M:%S"))
        (os-info (diagnostics-get-os-version-info))
        (package-count (if (boundp 'package-activated-list) (length package-activated-list) 0))
        (load-path-count (length load-path))
        ;; Additional diagnostic information
        (user-info
         (concat (user-login-name) "@" (or (file-remote-p default-directory 'host) (system-name))))
        (emacs-pid (emacs-pid))
        (startup-time
         (if
          (boundp 'before-init-time)
          (format
           "%.3fs" (float-time (time-subtract after-init-time before-init-time)))
          "unknown"))
        ;; Calculate maximum label width for alignment
        (max-width
         (apply
          'max
          (mapcar
           'length
           '("Emacs version"
             "System"
             "OS"
             "Display mode"
             "User@Host"
             "Process ID"
             "Startup time"
             "Load path entries"
             "Installed packages"
             "Configuration")))))
    (core-message-plain "\n=== Emacs Startup Log - %s ===" timestamp)
    (core-message-plain
     "%s: %s" (format (concat "%-" (number-to-string max-width) "s") "OS") os-info)
    (message
     "%s: %s" (format (concat "%-" (number-to-string max-width) "s") "User@Host") user-info)
    (message
     "%s: %d" (format (concat "%-" (number-to-string max-width) "s") "Process ID") emacs-pid)
    (message
     "%s: %s"
     (format (concat "%-" (number-to-string max-width) "s") "Emacs version")
     emacs-version)
    (message
     "%s: Modern Emacs 30.2+"
     (format (concat "%-" (number-to-string max-width) "s") "Configuration"))
    (core-message-plain "")
    (message
     "%s: %s %s"
     (format (concat "%-" (number-to-string max-width) "s") "System")
     system-type
     system-configuration)
    (message
     "%s: %s"
     (format (concat "%-" (number-to-string max-width) "s") "Display mode")
     (if (display-graphic-p) "GUI" "Terminal"))
    (message
     "%s: %d"
     (format (concat "%-" (number-to-string max-width) "s") "Load path entries")
     load-path-count)
    (message
     "%s: %d\n"
     (format (concat "%-" (number-to-string max-width) "s") "Installed packages")
     package-count)))


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (provide 'core-diagnostics))
;;; core-diagnostics.el ends here
