;;; aspell-config.el --- Spell Checking with Aspell -*- lexical-binding: t -*-
;;; Commentary:
;;      Spell checking configuration using flymake-aspell integration.
;;      Provides spell checking for text files and comments/docstrings in code.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INSTALLATION REQUIREMENTS:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Linux (RHEL/Fedora/CentOS):
;;   sudo yum install aspell aspell-en
;;   # or
;;   sudo dnf install aspell aspell-en
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Linux (Debian/Ubuntu):
;;   sudo apt-get install aspell aspell-en
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; macOS (Homebrew):
;;   brew install aspell
;;   # Note: aspell from Homebrew includes English dictionaries by default
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Verify installation:
;;   aspell dump dicts
;;   # Should list "en" or "en_US" in the output
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PERSONAL DICTIONARY (RECOMMENDED):
;;   Aspell may flag technical jargon (Emacs/Python terms) as misspellings.
;;   Create a personal dictionary to reduce false positives:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   1. Create ~/.aspell.en.pws with this format:
;;      personal_ws-1.1 en 0
;;      (First line: header with count, then one word per line)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   2. Add common technical terms (examples):
;;      - Emacs: defun, setq, elisp, magit, eglot, corfu, etc.
;;      - Python: async, kwargs, isinstance, virtualenv, etc.
;;      - File types: json, yaml, toml, etc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   3. Update the count on line 1 to match number of words
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; USAGE:
;;   Spell checking integrates with Flymake and shows errors in the same way as
;;   coding errors.  Misspelled words appear with the same highlighting as Flymake
;;   errors and can be viewed in the Flymake diagnostics buffer (F1).

;;; Code:
(require 'core-utils)
(require 'logging-init)
(require 'core-process-utils)

;; Declare external variables to suppress byte-compiler warnings
(defvar ispell-program-name) ; From ispell.el
(defvar ispell-extra-args) ; From ispell.el
(defvar flymake-aspell-only-comments-and-strings) ; From flymake-aspell.el
(defvar flymake-diagnostic-functions) ; From flymake.el
(defvar flymake-mode) ; From flymake.el
(defvar flymake-aspell) ; From flymake-aspell.el

;; Declare external functions to suppress byte-compiler warnings
(declare-function flymake-start "flymake" (&optional deferred force-diagnostics))
(declare-function use-package "use-package" (name &rest args))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 aspell--config-has-en-dictionary-p ()
 "Check if aspell has the English dictionary installed.
Returns t if \\='en\\=' dictionary is available, nil otherwise.
Checks based on current `default-directory' (local or remote)."
 (when
  (executable-find "aspell" (file-remote-p default-directory))
  (let ((dicts (core-process-run-sync "aspell" nil "dump" "dicts")))
    (when dicts (string-match-p "\\ben\\b" dicts)))))

(defun
 aspell-available-p ()
 "Check if aspell is installed and has English dictionary.
Returns t if both conditions are met, nil otherwise.  Displays appropriate
error message if either condition fails.
Checks based on current `default-directory' (local or remote)."
 (cond
  ((not (executable-find "aspell" (file-remote-p default-directory)))
   (logging-error "The command \"aspell\" was not found - please verify \"aspell\" is installed")
   nil)
  ((not (aspell--config-has-en-dictionary-p))
   (logging-error
    "The \"aspell\" English dictionary was not found - please verify it is installed")
   nil)
  (t
   t)))

(defun
 aspell--config-setup-flymake ()
 "Setup flymake-aspell for current buffer.
Adds flymake-aspell to diagnostics functions without replacing existing backends.
Only runs if flymake-aspell is loaded and buffer is not *scratch*."
 (when
  (and
   (fboundp 'flymake-aspell-setup)
   ;; Skip *scratch* buffer to avoid triggering Emacs security warnings
   ;; about untrusted content when flymake-mode enables built-in checkers
   (not (string= (buffer-name) "*scratch*")))
  (flymake-aspell-setup) (unless flymake-mode (flymake-mode 1))))

(defun
 aspell--config-setup-flymake-prog ()
 "Setup flymake-aspell for `prog-mode' to check comments and strings only.
Only runs if flymake-aspell is loaded and buffer is not *scratch*."
 (when
  (and
   (fboundp 'flymake-aspell-setup)
   ;; Skip *scratch* buffer to avoid triggering Emacs security warnings
   ;; about untrusted content when flymake-mode enables built-in checkers
   (not (string= (buffer-name) "*scratch*")))
  (setq-local flymake-aspell-only-comments-and-strings t) (aspell--config-setup-flymake)))

(defun
 aspell-ensure-backend ()
 "Ensure flymake-aspell backend is active alongside other backends like eglot.
Only runs if flymake-aspell is loaded and backend is missing."
 (when
  (and
   (fboundp 'flymake-aspell--check)
   (not (memq 'flymake-aspell--check flymake-diagnostic-functions)))
  (add-hook 'flymake-diagnostic-functions 'flymake-aspell--check nil t) (flymake-start)))

(defun
 aspell-toggle-backend ()
 "Toggle flymake-aspell backend on/off in current buffer.
Checks current state and enables if disabled, disables if enabled."
 (interactive)
 (if
  (memq 'flymake-aspell--check flymake-diagnostic-functions)
  (progn
   (remove-hook 'flymake-diagnostic-functions 'flymake-aspell--check t)
   (flymake-mode -1)
   (flymake-mode 1)
   (logging-info "Flymake aspell disabled"))
  (progn
   (add-hook 'flymake-diagnostic-functions 'flymake-aspell--check nil t)
   (flymake-start)
   (logging-info "Flymake aspell enabled"))))

(defun
 aspell--config-disable-flymake
 ()
 "Disable flymake-aspell backend in current buffer."
 (interactive)
 (when
  (memq 'flymake-aspell--check flymake-diagnostic-functions)
  (remove-hook 'flymake-diagnostic-functions 'flymake-aspell--check t)
  (flymake-mode -1)
  (flymake-mode 1)
  (logging-info "Flymake aspell disabled")))

(defun
 enable-flymake-aspell () "Enable flymake-aspell backend in current buffer." (interactive)
 (unless
  (memq 'flymake-aspell--check flymake-diagnostic-functions)
  (add-hook 'flymake-diagnostic-functions 'flymake-aspell--check nil t)
  (flymake-start)
  (logging-info "Flymake aspell enabled")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when
 (and (core-check-command-in-path "aspell") (aspell--config-has-en-dictionary-p))
 (logging-config "Configuring spell checking with flymake-aspell")
 (setq ispell-program-name "aspell")
 (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US"))
 (use-package flymake-aspell :demand t)
 (logging-success "Spell checking configured with flymake-aspell (disabled by default)"))

(global-set-key (kbd "C-c f a") 'aspell-toggle-backend)
(global-set-key (kbd "C-c f A") 'aspell--config-disable-flymake)
(provide 'aspell-config)
;;; aspell-config.el ends here
