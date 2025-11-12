;;; core-diagnostics.el --- System and Configuration Diagnostics -*- lexical-binding: t -*-
;;; Commentary:
;;      System information detection and configuration diagnostics
;;      Provides detailed system context and startup logging for debugging

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'tree-sitter-utils)
(require 'core-process-utils)
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
     (or (core-process-run-sync "uname" nil "-sr") "Linux (version unknown)")))
   ;; macOS
   ((eq system-type 'darwin)
    (let ((version (core-process-run-sync "sw_vers" nil "-productVersion"))
          (build (core-process-run-sync "sw_vers" nil "-buildVersion")))
      (if
       (and version build)
       (format "macOS %s (Build %s)" version build)
       "macOS (version unknown)")))
   ;; Windows
   ((eq system-type 'windows-nt)
    (or (core-process-run-sync "ver" nil) "Windows (version unknown)"))
   ;; Other systems
   (t
    (format "%s (version unknown)" system-type))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced Configuration Diagnostics
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  diagnostics-show-system-info () "Show system information in Messages buffer."
  (let ((lines nil)
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
        ;; Tree-sitter diagnostic information
        (treesit-available (fboundp 'treesit-available-p))
        (treesit-status
         (if
          (and (fboundp 'treesit-available-p) (treesit-available-p)) "Available" "Not available"))
        (treesit-grammar-count
         (if
          (fboundp 'treesit-utils-count-installed-grammars)
          (treesit-utils-count-installed-grammars)
          0))
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
             "Configuration"
             "Tree-sitter"
             "Installed grammars")))))
    (push
     (format "%s: %s" (format (concat "%-" (number-to-string max-width) "s") "OS") os-info) lines)
    (push
     (format
      "%s: %s" (format (concat "%-" (number-to-string max-width) "s") "User@Host") user-info)
     lines)
    (push
     (format
      "%s: %d" (format (concat "%-" (number-to-string max-width) "s") "Process ID") emacs-pid)
     lines)
    (push
     (format
      "%s: %s"
      (format (concat "%-" (number-to-string max-width) "s") "Emacs version")
      emacs-version)
     lines)
    (push
     (format
      "%s: Modern Emacs 30.2+"
      (format (concat "%-" (number-to-string max-width) "s") "Configuration"))
     lines)
    (push
     (format
      "%s: %s %s"
      (format (concat "%-" (number-to-string max-width) "s") "System")
      system-type
      system-configuration)
     lines)
    (push
     (format
      "%s: %s"
      (format (concat "%-" (number-to-string max-width) "s") "Display mode")
      (if (display-graphic-p) "GUI" "Terminal"))
     lines)
    (push
     (format
      "%s: %d"
      (format (concat "%-" (number-to-string max-width) "s") "Load path entries")
      load-path-count)
     lines)
    (push
     (format
      "%s: %d"
      (format (concat "%-" (number-to-string max-width) "s") "Installed packages")
      package-count)
     lines)
    (push
     (format
      "%s: %s"
      (format (concat "%-" (number-to-string max-width) "s") "Tree-sitter")
      treesit-status)
     lines)
    (push
     (format
      "%s: %d"
      (format (concat "%-" (number-to-string max-width) "s") "Installed grammars")
      treesit-grammar-count)
     lines)
    ;; Add individual grammar details if any are installed
    (when
     (> treesit-grammar-count 0)
     (when
      (fboundp 'treesit-utils-get-installed-grammars)
      (let ((grammars (treesit-utils-get-installed-grammars)))
        (dolist
         (grammar grammars)
         (let ((name (plist-get grammar :name))
               (file (plist-get grammar :file)))
           (push (format "  - %s (%s)" name (abbreviate-file-name file)) lines))))))
    (core-message-diagnostic "Emacs Startup Log" (nreverse lines))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; External Dependencies Diagnostics
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defvar
  diagnostics-external-dependencies-results
  nil
  "Store results from the last external dependencies check.")

 (defun
  diagnostics-check-executable (name &optional description optional)
  "Check if executable NAME is available.
DESCRIPTION is optional user-friendly name for the tool.
OPTIONAL marks the tool as optional (warning instead of error)."
  (let ((desc (or description name)))
    (if
     (executable-find name) (list :status 'ok :message (format "%s found" desc) :tool name)
     (list
      :status (if optional 'warning 'error)
      :message (format "%s not found" desc)
      :tool name))))

 (defun
  diagnostics-check-font (font-name) "Check if FONT-NAME is installed and available."
  (if
   (find-font (font-spec :name font-name))
   (list :status 'ok :message (format "Font '%s' installed" font-name) :font font-name)
   (list :status 'warning :message (format "Font '%s' not found" font-name) :font font-name)))
 (defun
  diagnostics-check-package (package-symbol) "Check if PACKAGE-SYMBOL is installed and loadable."
  (cond
   ((featurep package-symbol)
    (list
     :status 'ok
     :message (format "Package '%s' loaded" package-symbol)
     :package package-symbol))
   ((locate-library (symbol-name package-symbol))
    (list
     :status 'ok
     :message (format "Package '%s' available" package-symbol)
     :package package-symbol))
   (t
    (list
     :status 'error
     :message (format "Package '%s' not found" package-symbol)
     :package package-symbol))))

 (defun
  diagnostics-check-tramp-path ()
  "Check if TRAMP remote PATH is properly configured.
Only checks when working on a remote file."
  (when
   (file-remote-p default-directory)
   (if
    (and (boundp 'tramp-remote-path) (member 'tramp-own-remote-path tramp-remote-path))
    (list :status 'ok :message "TRAMP remote PATH configured")
    (list :status 'warning :message "TRAMP remote PATH may not use remote user's PATH"))))
 (defun
  diagnostics-check-lsp-servers () "Check LSP server availability for configured languages."
  (let ((results nil))
    (push (diagnostics-check-executable "pylsp" "Python LSP (pylsp)" t) results)
    (push (diagnostics-check-executable "clangd" "C/C++ LSP (clangd)" t) results)
    (push (diagnostics-check-executable "bash-language-server" "Bash LSP" t) results)
    (push (diagnostics-check-executable "vscode-json-language-server" "JSON LSP" t) results)
    (push (diagnostics-check-executable "yaml-language-server" "YAML LSP" t) results)
    (push (diagnostics-check-executable "taplo" "TOML LSP (taplo)" t) results)
    (push (diagnostics-check-executable "marksman" "Markdown LSP (marksman)" t) results)
    results))

 (defun
  diagnostics-check-nerd-fonts () "Check if Nerd Fonts are installed."
  (let ((font-dir (expand-file-name "~/.local/share/fonts/")))
    (if
     (and (file-directory-p font-dir) (directory-files font-dir nil "NFM\\.ttf$"))
     (list :status 'ok :message "Nerd Fonts installed")
     (list :status 'warning :message "Nerd Fonts not found in ~/.local/share/fonts/"))))
 (defun
  diagnostics-show-external-dependencies ()
  "Check and display status of external dependencies.
Validates tools and resources not managed by Emacs package system:
- Language interpreters (Python, etc.)
- LSP servers
- System fonts
- TRAMP configuration (when working remotely)"
  (interactive)
  (let ((all-results nil)
        (all-lines nil)
        (ok-count 0)
        (warning-count 0)
        (error-count 0))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; External Dependencies
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Python
    (push (diagnostics-check-executable "python3" "Python 3") all-results)

    ;; LSP Servers
    (dolist (result (diagnostics-check-lsp-servers)) (push result all-results))

    ;; Fonts
    (push (diagnostics-check-nerd-fonts) all-results)

    ;; TRAMP Configuration (only when working remotely)
    (let ((tramp-result (diagnostics-check-tramp-path)))
      (when tramp-result (push tramp-result all-results)))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Build Lines
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (dolist
     (result (reverse all-results))
     (pcase (plist-get result :status)
       ('ok
        (push (format "✅  %s" (plist-get result :message)) all-lines)
        (setq ok-count (1+ ok-count)))
       ('warning
        (push (format "⚠️  %s" (plist-get result :message)) all-lines)
        (setq warning-count (1+ warning-count)))
       ('error
        (push (format "❌  %s" (plist-get result :message)) all-lines)
        (setq error-count (1+ error-count)))))

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Summary
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (push " " all-lines)
    (push "=== Summary ===" all-lines)
    (let ((format-str "%-22s"))
      (push (format (concat "✅  " format-str " %d") "Passed" ok-count) all-lines)
      (when
       (> warning-count 0)
       (push (format (concat "⚠️  " format-str " %d") "Warnings" warning-count) all-lines))
      (when
       (> error-count 0)
       (push (format (concat "❌  " format-str " %d") "Errors" error-count) all-lines)))
    (setq diagnostics-external-dependencies-results all-results)
    (core-message-diagnostic "External Dependencies" (nreverse all-lines))
    all-results))

 (defun
  diagnostics-show-all
  ()
  "Show complete diagnostics: system info and external dependencies."
  (interactive)
  (let ((suggest-key-bindings nil))
    (diagnostics-show-system-info)
    (diagnostics-show-external-dependencies)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )
(provide 'core-diagnostics)
;;; core-diagnostics.el ends here
