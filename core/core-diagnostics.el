;;; core-diagnostics.el --- System and Configuration Diagnostics -*- lexical-binding: t -*-
;;; Commentary:
;;      System information detection and configuration diagnostics
;;      Provides detailed system context and startup logging for debugging

;;; Code:
(require 'core-logging)
(require 'logging-tables)
(require 'core-constants)
(require 'tree-sitter-utils)
(require 'core-process-utils)

;; Declare external variables to suppress byte-compiler warnings
(defvar core-config-load-results) ; From init.el
(defvar native-comp-enable-subr-trampolines) ; From comp.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 diagnostics-get-os-version-info () "Get operating system version information."
 (cond
  ((eq system-type 'gnu/linux)
   (or
    (when
     (file-readable-p "/etc/os-release")
     (with-temp-buffer
      (insert-file-contents "/etc/os-release")
      (when (re-search-forward "^PRETTY_NAME=\"?\\([^\"]*\\)\"?" nil t) (match-string 1))))
    (when
     (file-readable-p "/etc/lsb-release")
     (with-temp-buffer
      (insert-file-contents "/etc/lsb-release")
      (when (re-search-forward "^DISTRIB_DESCRIPTION=\"?\\([^\"]*\\)\"?" nil t) (match-string 1))))
    (or (core-process-run-sync "uname" nil "-sr") "Linux (version unknown)")))
  ((eq system-type 'darwin)
   (let ((version (core-process-run-sync "sw_vers" nil "-productVersion"))
         (build (core-process-run-sync "sw_vers" nil "-buildVersion")))
     (if
      (and version build) (format "macOS %s (Build %s)" version build) "macOS (version unknown)")))
  ((eq system-type 'windows-nt)
   (or (core-process-run-sync "ver" nil) "Windows (version unknown)"))
  (t
   (format "%s (version unknown)" system-type))))

(defun
 core--diagnostics-count-config-files ()
 "Count total .el configuration files in `user-emacs-directory'.
Includes root-level .el files (init.el, early-init.el, custom.el, local.el, dev.el).
Excludes directories in `core-ignore-on-load' list (local, elpa, configs, etc.).
Returns count of actual configuration files."
 (let ((count 0))
   ;; Count .el files in root of user-emacs-directory
   (setq count (length (directory-files user-emacs-directory nil core-elisp-file-pattern)))
   ;; Count .el files in subdirectories
   (dolist
    (dir (directory-files user-emacs-directory t "^[^.]"))
    (when
     (file-directory-p dir)
     (let ((dir-name (file-name-nondirectory dir)))
       (unless
        (member dir-name core-ignore-on-load)
        ;; Count .el files in this directory
        (setq count (+ count (length (directory-files dir nil core-elisp-file-pattern))))
        ;; Count .el files in subdirectories
        (dolist
         (subdir (directory-files dir t "^[^.]"))
         (when
          (file-directory-p subdir)
          (setq
           count (+ count (length (directory-files subdir nil core-elisp-file-pattern))))))))))
   count))

(defun
 core--diagnostics-count-loaded-modules ()
 "Count successfully loaded configuration modules from `core-config-load-results'.
Returns count of modules with status \\='success."
 (if
  (boundp 'core-config-load-results)
  (cl-count-if (lambda (result) (eq (nth 1 result) 'success)) core-config-load-results)
  0))

(defun
 core--diagnostics-get-native-comp-status ()
 "Get native compilation status as human-readable string.
Returns status like \\='Enabled (Snap mode)\\=' or \\='Disabled\\='."
 (cond
  ((and (boundp 'native-comp-enable-subr-trampolines) (not native-comp-enable-subr-trampolines))
   "Enabled (Snap mode)")
  ((and (fboundp 'native-comp-available-p) (native-comp-available-p))
   "Enabled")
  (t
   "Disabled")))

(defun
 core--diagnostics-show-system-info () "Display system information as a table (non-interactive)."
 (let* ((os-info (diagnostics-get-os-version-info))
        (package-count (if (boundp 'package-activated-list) (length package-activated-list) 0))
        (user-info
         (concat (user-login-name) "@" (or (file-remote-p default-directory 'host) (system-name))))
        (emacs-pid (emacs-pid))
        (treesit-status
         (if
          (and (fboundp 'treesit-available-p) (treesit-available-p)) "Available" "Not available"))
        (headers '("Description" "Value"))
        (rows
         (list
          (list "OS" os-info)
          (list "User@Host" user-info)
          (list "Process ID" (number-to-string emacs-pid))
          (list "Emacs version" emacs-version)
          (list "Configuration" "Modern Emacs 30.2+")
          (list "System" (format "%s %s" system-type system-configuration))
          (list "Display mode" (if (display-graphic-p) "GUI" "Terminal"))
          (list "Installed packages" (number-to-string package-count))
          (list "Tree-sitter" treesit-status))))
   (logging-diagnostic "System Information" (logging-format-table headers rows))))

(defun
 core--diagnostics-show-config-details
 ()
 "Display configuration details as a table (non-interactive)."
 (let* ((config-dir (abbreviate-file-name user-emacs-directory))
        (local-dir (abbreviate-file-name core-emacs-local-dir))
        (total-files (core--diagnostics-count-config-files))
        (loaded-files (core--diagnostics-count-loaded-modules))
        (custom-file-path
         (if (file-exists-p core-custom-file) (abbreviate-file-name core-custom-file) "-"))
        (local-file-path
         (if
          (file-exists-p core-local-config-file)
          (abbreviate-file-name core-local-config-file)
          "-"))
        (dev-file-path
         (if (file-exists-p core-dev-config-file) (abbreviate-file-name core-dev-config-file) "-"))
        (native-comp-status (core--diagnostics-get-native-comp-status))
        (native-cache-dir (abbreviate-file-name core-eln-cache-dir))
        (headers '("Setting" "Value"))
        (rows
         (list
          (list "Config directory" config-dir)
          (list "Local data directory" local-dir)
          (list "Config files total" (number-to-string total-files))
          (list "Config files loaded" (number-to-string loaded-files))
          (list "Custom file" custom-file-path)
          (list "Local config" local-file-path)
          (list "Dev config" dev-file-path)
          (list "Native compilation" native-comp-status)
          (list "Native comp cache" native-cache-dir))))
   (logging-diagnostic "Configuration Details" (logging-format-table headers rows))))

(defun
 core--diagnostics-show-grammars
 ()
 "Display installed tree-sitter grammars as a table (non-interactive)."
 (let ((grammar-count
        (if
         (fboundp 'tree-sitter-count-installed-grammars)
         (tree-sitter-count-installed-grammars)
         0)))
   (if
    (> grammar-count 0)
    (when
     (fboundp 'tree-sitter-get-installed-grammars)
     (let* ((grammars (tree-sitter-get-installed-grammars))
            (headers '("Language" "Grammar File"))
            (rows
             (mapcar
              (lambda
               (grammar)
               (let ((name (plist-get grammar :name))
                     (file (plist-get grammar :file)))
                 (list name (abbreviate-file-name file))))
              grammars)))
       (logging-diagnostic
        (format "Installed Grammars (%d)" grammar-count) (logging-format-table headers rows))))
    (logging-diagnostic "Installed Grammars (0)" (list "No tree-sitter grammars installed")))))

(defun
 diagnostics-show-system
 ()
 "Show system information, configuration details, and installed grammars.
Displays comprehensive system diagnostics including OS info, Emacs configuration,
custom configuration file status, and tree-sitter grammar installations in table format."
 (interactive)
 (logging-info "=== System Diagnostics ===")
 (logging-plain "")
 (core--diagnostics-show-system-info)
 (logging-plain "")
 (core--diagnostics-show-config-details)
 (logging-plain "")
 (core--diagnostics-show-grammars))

(provide 'core-diagnostics)
;;; core-diagnostics.el ends here
