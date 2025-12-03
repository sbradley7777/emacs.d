;;; makefile-config.el --- Makefile Language Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Makefile mode support and configuration for Makefiles with proper tab handling

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'lang-utils)
(require 'make-mode)
(require 'highlight-indent-guides)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 makefile-setup-common-settings
 ()
 "Configure common Makefile settings required by all Make variants."
 (setq
  indent-tabs-mode t ; Use tabs (required by Make syntax)
  tab-width core-tab-width ; Set tab width for better readability
  show-trailing-whitespace t)) ; Show trailing whitespace clearly

(defun
 makefile-validate-tabs
 ()
 "Check if Makefile use proper tabs for recipe indentation."
 (interactive)
 (save-excursion
  (goto-char (point-min))
  (let ((tab-recipe-count 0)
        (space-recipe-count 0))
    ;; Look for recipe lines (lines that start with whitespace after a target)
    (while
     (re-search-forward "^\\([[:space:]]+\\)" nil t)
     (let ((indent (match-string 1)))
       (if
        (string-match-p "\t" indent)
        (core-increment-counter tab-recipe-count)
        (when (string-match-p "^ +" indent) (core-increment-counter space-recipe-count)))))

    (cond
     ((> space-recipe-count 0)
      (logging-warning
       "Warning: Found %d recipe lines with spaces instead of tabs!" space-recipe-count))
     ((> tab-recipe-count 0)
      (logging-success
       "Makefile syntax valid: %d recipe lines properly use tabs" tab-recipe-count))
     (t
      (logging-info "No recipe lines detected in this Makefile"))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Makefile mode configuration (built-in mode)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File associations for Makefile variants
(lang-register-file-extensions 'makefile-mode "\\(?:Makefile\\|makefile\\)\\'" "\\.mk\\'")
(lang-register-file-extensions 'makefile-gmake-mode "GNUmakefile\\'")

;; Makefile-specific configuration
(add-hook
 'makefile-mode-hook
 (lambda
  ()
  "Configure Makefile mode settings with proper tab handling."
  ;; CRITICAL: Makefiles REQUIRE tabs for recipe indentation
  (makefile-setup-common-settings)
  (setq whitespace-style '(face tabs trailing tab-mark))
  (whitespace-mode 1)

  ;; Electric indentation settings
  (electric-indent-mode 1)

  ;; Makefile-specific editing enhancements
  (setq makefile-electric-keys t) ; Enable electric keys (automatic formatting)
  (setq makefile-query-by-make-minus-q t) ; Use make -q for target queries
  ))

;; Defer loading of indentation guides until makefile-mode is active
(with-eval-after-load
 'make-mode
 (add-hook
  'makefile-mode-hook
  (lambda () "Enable visual feedback for proper Make syntax." (highlight-indent-guides-mode 1))))

;; Additional configuration for different Makefile variants
(add-hook 'makefile-gmake-mode-hook #'makefile-setup-common-settings)
(add-hook 'makefile-bsdmake-mode-hook #'makefile-setup-common-settings)

;; Key bindings for common Makefile operations
(with-eval-after-load
 'make-mode
 ;; Bind common Make operations
 (define-key makefile-mode-map (kbd "C-c C-c") 'compile) ; Run make
 (define-key makefile-mode-map (kbd "C-c C-t") 'makefile-pickup-targets) ; Refresh target list
 (define-key makefile-mode-map (kbd "C-c C-f") 'makefile-pickup-filenames-as-targets)) ; Add files as targets

;; Enhanced target navigation and compilation
(with-eval-after-load
 'make-mode
 ;; Set compilation command to use make
 (add-hook
  'makefile-mode-hook
  (lambda
   () "Set up compilation for Makefiles." (set (make-local-variable 'compile-command) "make "))))

;; Automatically validate Makefile syntax when opening
(add-hook
 'makefile-mode-hook
 (lambda () "Validate Makefile syntax on open." (run-with-timer 1 nil 'makefile-validate-tabs)))
(provide 'makefile-config)
;;; makefile-config.el ends here
