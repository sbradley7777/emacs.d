;;; init.el --- Emacs Configuration Entry Point -*- lexical-binding: t -*-
;;; Commentary:
;;      Main entry point for Emacs configuration.
;;      Loads configuration modules in the correct order.

;;; Code:
;; Declare external variables to suppress byte-compiler warnings
(defvar default-file-name-handler-alist) ; Defined in early-init.el
(defvar which-func-update-delay) ; From which-func.el
(defvar native-comp-deferred-compilation-deny-list) ; From comp.el

;; Variables from core-constants.el
(defvar core-ignore-on-load)
(defvar core-elisp-file-pattern)
(defvar core-gc-long-session-threshold)
(defvar core-gc-percentage-normal)
(defvar core-gc-normal-threshold)
(defvar core-idle-update-delay-normal)
(defvar core-gc-check-threshold)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar init-start-time (current-time) "Time when Emacs initialization started.")
(defvar core-config-load-results '() "List of configuration loading results for diagnostics.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Directory auto-detection function
(defun
 init--auto-detect-config-directories ()
 "Automatically detect all directories containing .el files for `load-path'.
Recursively searches subdirectories and excludes directories in core-ignore-on-load.
Returns a list of absolute directory paths suitable for adding to `load-path'."
 (let ((all-dirs '()))
   (dolist
    (dir (directory-files user-emacs-directory t "^[^.]"))
    (when
     (file-directory-p dir)
     (let ((dir-name (file-name-nondirectory dir)))
       (unless
        (member dir-name core-ignore-on-load)
        ;; Check if this directory has .el files
        (when (directory-files dir t core-elisp-file-pattern) (push dir all-dirs))
        ;; Recursively check subdirectories for .el files
        (dolist
         (subdir (directory-files dir t "^[^.]"))
         (when
          (and
           (file-directory-p subdir) (directory-files subdir t core-elisp-file-pattern))
          (push subdir all-dirs)))))))
   (nreverse all-dirs)))

(defun
 init--configure-native-comp-for-snap
 ()
 "Exclude the read-only Snap directory from native compilation."
 (add-to-list 'native-comp-deferred-compilation-deny-list "/snap/emacs/.*"))

(defun
 init--show-config-diagnostics () "Display configuration loading diagnostics."
 (let ((total-time (float-time (time-subtract (current-time) init-start-time)))
       (successful 0)
       (failed 0)
       (lines nil))
   (dolist
    (result (reverse core-config-load-results))
    (let ((_name (nth 0 result))
          (status (nth 1 result))
          (time (nth 2 result))
          (desc (nth 3 result)))
      (if
       (eq status 'success)
       (progn (core-increment-counter successful) (push (format "✅  %s (%.3fs)" desc time) lines))
       (core-increment-counter failed)
       (push (format "❌  %s (%.3fs) - %s" desc time (nth 4 result)) lines))))
   (push " " lines)
   (push "=== Summary ===" lines)
   (push
    (format "🛠️  Total: %d successful, %d failed (%.3fs total)" successful failed total-time)
    lines)
   (core-message-diagnostic "Configuration Loading Summary" (nreverse lines))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ensure early-init.el is loaded (for batch mode compatibility)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; In interactive mode, early-init.el loads automatically before init.el
;; In batch mode, it doesn't load automatically, so we load it here if needed
(unless
 (boundp 'core-emacs-local-dir) (load (expand-file-name "early-init.el" user-emacs-directory)))
;; Note: logging utilities are now loaded in early-init.el, so we can use them immediately
(core-message-loading "Loading init.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance optimizations for faster startup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Restore normal performance values after startup is complete
(add-hook
 'emacs-startup-hook
 (lambda
  ()
  ;; Restore normal garbage collection settings
  (setq
   gc-cons-threshold core-gc-normal-threshold ; Normal operation threshold
   gc-cons-percentage core-gc-percentage-normal) ; Normal GC percentage
  ;; Restore file name handlers (disabled in early-init.el for faster startup)
  (setq file-name-handler-alist default-file-name-handler-alist)
  ;; Restore normal input processing
  (setq which-func-update-delay core-idle-update-delay-normal) ; Faster idle updates for responsiveness
  (core-message-success "Emacs startup complete. Performance settings restored.")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load Path Auto-Detection System
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This system automatically discovers and adds configuration directories to Emacs' load-path.
;; It eliminates the need to manually maintain a list of directories when new modules are added.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Process:
;; 1. Use core constants loaded by early-init.el to access core-ignore-on-load list
;; 2. Scan all directories in user-emacs-directory for .el files
;; 3. Include nested directories (e.g., lang/python, core/package-system)
;; 4. Exclude runtime directories defined in core-ignore-on-load constant:
;;    - "configs"  : Template configuration files, not active modules
;;    - "local"    : Runtime data (package cache, recentf, etc.)
;; 5. Add discovered directories to load-path for module loading
;; Apply auto-detection: discover and add configuration directories to load-path
(mapc (lambda (dir) (add-to-list 'load-path dir)) (init--auto-detect-config-directories))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration Validation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Validate that early-init.el properly set up required variables
(unless
 (boundp 'default-file-name-handler-alist)
 (core-message-warning
  "default-file-name-handler-alist not set by early-init.el - performance may be suboptimal")
 (setq default-file-name-handler-alist file-name-handler-alist))
;; Validate that early-init performance optimizations were applied
(unless
 (> gc-cons-threshold core-gc-check-threshold)
 (core-message-warning "GC threshold not optimized by early-init.el - startup may be slower"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Native Compilation Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Defer native compilation configuration until the system is fully initialized.
;; This prevents startup errors caused by trying to modify variables that
;; have not yet been defined. This hook-based approach is the most robust way
;; to configure native compilation.
(add-hook 'native-comp-init-hook #'init--configure-native-comp-for-snap)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load configuration loading infrastructure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'core-config-loader)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load configuration modules with declarative dependencies via :after keyword
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 1: Foundation Layer - System Infrastructure
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-load-module features-constants :description "Feature module configuration constants")
(core-load-module
 tree-sitter-utils
 :after features-constants
 :description "Tree-sitter utility functions")
(core-load-module
 core-diagnostics
 :after tree-sitter-utils
 :description "System and configuration diagnostics")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 2: Package and Resource Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-load-module core-packages :description "Package system setup and declarations")
(core-load-module core-fonts :description "Font management")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 3: User Interface Layer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-load-module core-ui :after core-packages :description "Basic UI setup")
(core-load-module core-gui-mode :after core-ui :description "GUI mode configuration")
(core-load-module themes-config :after core-packages :description "Theme configuration")
(core-load-module modeline-config :after core-packages :description "Modeline configuration")
(core-load-module modeline-segments :after modeline-config :description "Custom modeline segments")
(core-load-module
 modeline-faces
 :after modeline-config
 :description "Modeline face customizations")
(core-load-module themes-utils :after themes-config :description "Theme utilities")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 4: Core Editing and File Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-load-module core-editing :description "Editing preferences")
(core-load-module core-files :description "File handling")
(core-load-module
 core-logging-utils
 :after core-files
 :description "Log file writing and rotation utilities")
(core-load-module core-logging-buffers :description "Messages and debug buffer logging")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 5: Enhanced Features (Optional Components)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-load-module completion-config :after core-packages :description "Auto-completion framework")
(core-load-module
 minibuffer-config
 :after core-packages
 :description "Minibuffer completion with Vertico stack")
(core-load-module tramp-constants :description "TRAMP configuration constants")
(core-load-module tramp-utils :after tramp-constants :description "TRAMP utility functions")
(core-load-module tramp-config :after tramp-utils :description "TRAMP remote file access")
(core-load-module
 tree-sitter-config
 :after (tree-sitter-utils core-packages)
 :description "Tree-sitter grammar management")
(core-load-module
 flymake-registry
 :after core-packages
 :description "Flymake backend registry and validation")
(core-load-module flymake-config :after flymake-registry :description "Flymake configuration")
(core-load-module flymake-utils :after flymake-config :description "Flymake utility functions")
(core-load-module aspell-config :after flymake-utils :description "Spell checking with aspell")
(core-load-module diff-hl-config :after core-packages :description "Git diff highlighting")
(core-load-module git-constants :description "Git configuration constants")
(core-load-module git-config :after git-constants :description "Magit and forge git integration")
(core-load-module forge-constants :description "Forge configuration constants")
(core-load-module
 forge-utils
 :after (git-utils git-forge-config forge-constants)
 :description "Forge configuration utilities and diagnostics")
(core-load-module
 forge-markdown
 :after forge-utils
 :description "Forge markdown rendering functions")
(core-load-module
 forge-issue-links
 :after forge-markdown
 :description "Append raw URLs to forge issues for terminal clickability")
(core-load-module
 forge-config
 :after forge-markdown
 :description "Forge markdown rendering and customizations")
(core-load-module
 forge-authinfo
 :after (forge-utils git-forge-config)
 :description "Interactive authinfo generator for forge hosts")
(core-load-module forge-issues :after git-config :description "Forge issue management commands")
(core-load-module
 git-sync
 :after (git-utils git-config forge-config)
 :description "Automatic Git and Forge synchronization")
(core-load-module
 rainbow-delimiters-config
 :after core-packages
 :description "Rainbow delimiters for better code readability")
(core-load-module
 highlight-indent-guides-config
 :after core-packages
 :description "Visual indentation guides")
(core-load-module
 dimmer-config
 :after core-packages
 :description "Dim inactive windows for visual focus")
(core-load-module
 imenu-list-config
 :after (core-packages completion-config)
 :description "Symbol sidebar navigation")
(core-load-module breadcrumbs-config :after core-packages :description "Breadcrumb navigation")
(core-load-module treemacs-utils :description "Treemacs utility functions")
(core-load-module
 treemacs-config
 :after (core-packages treemacs-utils)
 :description "Project tree navigation")
(core-load-module dired-config :after core-packages :description "Dired with nerd icons")
(core-load-module dashboard-config :after core-packages :description "Dashboard startup screen")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 6: Language-Specific Configurations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-load-module bash-config :description "Bash/shell script support")
(core-load-module c-config :description "C/C++ language support")
(core-load-module lisp-config :description "Emacs Lisp development")
(core-load-module yaml-config :after core-packages :description "YAML file support")
(core-load-module toml-config :after core-packages :description "TOML file support")
(core-load-module json-config :description "JSON file support")
(core-load-module markdown-config :after core-packages :description "Markdown file support")
(core-load-module makefile-config :description "Makefile support")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 7: Python Development Stack (Complex Dependencies)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-load-module python-config :description "Python configuration")
(core-load-module python-constants :description "Python configuration constants")
(core-load-module
 pyvenv-utils
 :after python-constants
 :description "Python virtual environment utilities")
(core-load-module
 pyvenv-config
 :after (pyvenv-utils core-packages)
 :description "Python virtual environments")
(core-load-module
 pyvenv-remote
 :after pyvenv-config
 :description "Python virtual environments TRAMP support")
(core-load-module
 pyvenv-modeline
 :after pyvenv-config
 :description "Python virtual environment modeline indicator")
(core-load-module eglot-config :after python-config :description "Eglot LSP integration")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Phase 8: User Customizations (Final Layer)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(core-load-module user-utils :description "User utility functions")
(core-load-module user-aliases :after user-utils :description "Function aliases and shortcuts")
(core-load-module user-keybindings :after user-utils :description "User keybindings")
(core-load-module
 command-palette
 :after user-aliases
 :description "Command palette with M-x history tracking")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom settings via emacs menu system
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use standard Emacs convention for custom settings
(setq custom-file core-custom-file)
;; Load custom settings if the file exists
(when (file-exists-p custom-file) (load custom-file 'noerror))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Local user configuration (not version controlled)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load optional local configuration file for user-specific settings
(when
 (file-exists-p core-local-config-file)
 (core-message-loading "Loading local.el...")
 (load core-local-config-file 'noerror)
 (core-message-success "local.el loaded successfully"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Development configuration (not version controlled)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load optional development configuration file for testing new configurations
(when
 (file-exists-p core-dev-config-file)
 (core-message-debug "Loading dev.el...")
 (load core-dev-config-file 'noerror)
 (core-message-success "dev.el loaded successfully"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization complete - show diagnostics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Display detailed loading diagnostics
(init--show-config-diagnostics)
;; Show system diagnostics (after all packages loaded)
(diagnostics-show-system)
;; Show version-aware configuration status
(core-message-success "Emacs %s configuration loaded successfully" emacs-version)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Memory Management Strategy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Manual GC approach chosen for light usage patterns (typically < 10 buffers):
;; - Automatic timers add unnecessary overhead for minimal memory pressure
;; - Emacs' built-in GC triggers are sufficient for light buffer usage
;; - Manual optimization available via M-x optimize-gc-for-long-session if needed
;; - This approach avoids over-optimization complexity for predictable, light workflows
(core-message-success "init.el loaded successfully.")
(provide 'init)
;;; init.el ends here
