;;; aspell-config.el --- Spell Checking with Aspell -*- lexical-binding: t -*-
;;; Commentary:
;;      Spell checking configuration using flymake-aspell integration.
;;      Provides spell checking for text files and comments/docstrings in code.
;;
;; INSTALLATION REQUIREMENTS:
;;
;; Linux (RHEL/Fedora/CentOS):
;;   sudo yum install aspell aspell-en
;;   # or
;;   sudo dnf install aspell aspell-en
;;
;; Linux (Debian/Ubuntu):
;;   sudo apt-get install aspell aspell-en
;;
;; macOS (Homebrew):
;;   brew install aspell
;;   # Note: aspell from Homebrew includes English dictionaries by default
;;
;; Verify installation:
;;   aspell dump dicts
;;   # Should list "en" or "en_US" in the output
;;
;; PERSONAL DICTIONARY (RECOMMENDED):
;;   Aspell may flag technical jargon (Emacs/Python terms) as misspellings.
;;   Create a personal dictionary to reduce false positives:
;;
;;   1. Create ~/.aspell.en.pws with this format:
;;      personal_ws-1.1 en 0
;;      (First line: header with count, then one word per line)
;;
;;   2. Add common technical terms (examples):
;;      - Emacs: defun, setq, elisp, magit, eglot, corfu, etc.
;;      - Python: async, kwargs, isinstance, virtualenv, etc.
;;      - File types: json, yaml, toml, etc.
;;
;;   3. Update the count on line 1 to match number of words
;;
;; USAGE:
;;   Spell checking integrates with Flymake and shows errors in the same way as
;;   coding errors. Misspelled words appear with the same highlighting as Flymake
;;   errors and can be viewed in the Flymake diagnostics buffer (F1).

;;; Code:
(require 'core-utils)
(require 'core-logging)
(core-utils-with-load-timing
 "aspell-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Helper Functions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  aspell-has-en-dictionary-p ()
  "Check if aspell has the English dictionary installed.
Returns t if 'en' dictionary is available, nil otherwise."
  (when
   (executable-find "aspell")
   (let ((dicts (shell-command-to-string "aspell dump dicts")))
     (string-match-p "\\ben\\b" dicts))))
 (defun
  aspell-available-p ()
  "Check if aspell is installed and has English dictionary.
Returns t if both conditions are met, nil otherwise. Displays appropriate
error message if either condition fails."
  (cond
   ((not (executable-find "aspell"))
    (core-message-error
     "The command \"aspell\" was not found - please verify \"aspell\" is installed")
    nil)
   ((not (aspell-has-en-dictionary-p))
    (core-message-error
     "The \"aspell\" English dictionary was not found - please verify it is installed")
    nil)
   (t
    t)))
 (defun
  aspell-setup-flymake ()
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
  aspell-setup-flymake-prog ()
  "Setup flymake-aspell for prog-mode to check comments and strings only.
Only runs if flymake-aspell is loaded and buffer is not *scratch*."
  (when
   (and
    (fboundp 'flymake-aspell-setup)
    ;; Skip *scratch* buffer to avoid triggering Emacs security warnings
    ;; about untrusted content when flymake-mode enables built-in checkers
    (not (string= (buffer-name) "*scratch*")))
   (setq-local flymake-aspell-only-comments-and-strings t) (aspell-setup-flymake)))
 (defun
  aspell-ensure-backend ()
  "Ensure flymake-aspell backend is active alongside other backends like eglot.
Only runs if flymake-aspell is loaded and backend is missing."
  (when
   (and
    (fboundp 'flymake-aspell--check)
    (not (memq 'flymake-aspell--check flymake-diagnostic-functions)))
   (add-hook 'flymake-diagnostic-functions 'flymake-aspell--check nil t) (flymake-start)))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Interactive Commands
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  toggle-flymake-aspell ()
  "Toggle flymake-aspell backend on/off in current buffer.
Checks current state and enables if disabled, disables if enabled."
  (interactive)
  (if
   (memq 'flymake-aspell--check flymake-diagnostic-functions)
   (progn
    (remove-hook 'flymake-diagnostic-functions 'flymake-aspell--check t)
    (flymake-mode -1)
    (flymake-mode 1)
    (core-message-info "Flymake aspell disabled"))
   (progn
    (add-hook 'flymake-diagnostic-functions 'flymake-aspell--check nil t)
    (flymake-start)
    (core-message-info "Flymake aspell enabled"))))
 (defun
  disable-flymake-aspell () "Disable flymake-aspell backend in current buffer." (interactive)
  (when
   (memq 'flymake-aspell--check flymake-diagnostic-functions)
   (remove-hook 'flymake-diagnostic-functions 'flymake-aspell--check t)
   (flymake-mode -1)
   (flymake-mode 1)
   (core-message-info "Flymake aspell disabled")))
 (defun
  enable-flymake-aspell () "Enable flymake-aspell backend in current buffer." (interactive)
  (unless
   (memq 'flymake-aspell--check flymake-diagnostic-functions)
   (add-hook 'flymake-diagnostic-functions 'flymake-aspell--check nil t)
   (flymake-start)
   (core-message-info "Flymake aspell enabled")))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Keybindings
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (global-set-key (kbd "C-c f a") 'toggle-flymake-aspell)
 (global-set-key (kbd "C-c f A") 'disable-flymake-aspell)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Aspell Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (when
  (and (core-utils-check-command-in-path "aspell") (aspell-has-en-dictionary-p))
  (core-message-config "Configuring spell checking with flymake-aspell")
  (setq ispell-program-name "aspell")
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US"))
  (use-package flymake-aspell :demand t)
  (core-message-success "Spell checking configured with flymake-aspell (disabled by default)")))
(provide 'aspell-config)
;;; aspell-config.el ends here
