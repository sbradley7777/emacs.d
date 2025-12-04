;;; treemacs-utils.el --- Treemacs Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;      Utility functions for treemacs configuration.
;;      Handles theme loading and custom file icon management.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'logging-init)

;; Declare external variables to suppress byte-compiler warnings
(defvar nerd-icons-extension-icon-alist) ; From nerd-icons.el

;; Declare external functions to suppress byte-compiler warnings
(declare-function treemacs-load-theme "treemacs-themes" (theme-name))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 treemacs-nerd-icons-file-icon-mappings
 '(("makefile" nerd-icons-sucicon "nf-seti-makefile" :face nerd-icons-dorange)
   ("gnumakefile" nerd-icons-sucicon "nf-seti-makefile" :face nerd-icons-dorange)
   ("license" nerd-icons-sucicon "nf-seti-license" :face nerd-icons-blue)
   ("licence" nerd-icons-sucicon "nf-seti-license" :face nerd-icons-blue)
   ("copying" nerd-icons-sucicon "nf-seti-license" :face nerd-icons-blue)
   ("pyproject.toml" nerd-icons-sucicon "nf-custom-toml" :face nerd-icons-yellow)
   (".pre-commit-config.yaml" nerd-icons-devicon "nf-dev-git_merge" :face nerd-icons-dred)
   (".gitlab-ci.yml" nerd-icons-mdicon "nf-md-gitlab" :face nerd-icons-orange))
 "Custom file icon mappings for treemacs nerd-icons theme.
Each entry is a list of (FILENAME ICON-FUNCTION ICON-NAME :face FACE).
FILENAME must be lowercase (treemacs downcases filenames before lookup).
These are added to nerd-icons-extension-icon-alist for treemacs to use.

To browse available icons: \\[nerd-icons-insert]")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 treemacs--apply-nerd-icons-file-icons ()
 "Apply custom file icon mappings to nerd-icons extension list.
This function should be called before loading the treemacs nerd-icons theme.
Adds lowercase filename entries to nerd-icons-extension-icon-alist which treemacs
uses for exact filename matching (after downcasing the filename)."
 (when
  (require 'nerd-icons nil t)
  (dolist
   (icon-spec treemacs-nerd-icons-file-icon-mappings)
   (add-to-list 'nerd-icons-extension-icon-alist icon-spec))
  (logging-config
   "Applied %d custom file icon mappings" (length treemacs-nerd-icons-file-icon-mappings))))

(defun
 treemacs-load-user-theme (theme-name)
 "Load specified treemacs THEME-NAME with custom icons if applicable.
THEME-NAME can be \"nerd-icons\", \"Default\", or nil for default behavior.
When using nerd-icons theme, custom file icons are automatically applied."
 (cond
  ;; Nerd Icons theme with custom file icons
  ((and (string= theme-name "nerd-icons") (package-installed-p 'treemacs-nerd-icons))
   (treemacs--apply-nerd-icons-file-icons)
   (require 'treemacs-nerd-icons)
   (treemacs-load-theme "nerd-icons")
   (logging-success
    "Treemacs nerd-icons theme loaded with %d custom file icons"
    (length treemacs-nerd-icons-file-icon-mappings)))

  ;; Default theme
  ((string= theme-name "Default")
   (treemacs-load-theme "Default")
   (logging-success "Treemacs Default theme loaded"))

  ;; Invalid or nil theme
  (t
   (logging-warning "Invalid treemacs theme: %s. Using default." theme-name))))
(provide 'treemacs-utils)
;;; treemacs-utils.el ends here
