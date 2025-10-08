;;; modeline-config.el --- Modeline Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Modeline configuration with support for both default Emacs modeline and doom-modeline.
;;      Users can choose which modeline to use via the modeline-config-use-doom-modeline variable.
;;      Set in local.el or custom.el to enable doom-modeline.

(require 'core-constants)
(require 'core-utils)
(require 'core-logging)

(core-utils-with-load-timing
 "modeline-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Configuration Variables
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defvar
  modeline-config-use-doom-modeline t
  "Whether to use doom-modeline instead of the default Emacs modeline.
Set this to nil in local.el to use the default Emacs modeline instead.")

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Default Modeline Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  modeline-config-setup-default
  ()
  "Configure the default Emacs modeline with standard features."
  (core-message-config "Setting up default Emacs modeline")

  ;; Enable column number display in modeline
  (column-number-mode 1)

  ;; Enable line number display in modeline
  (line-number-mode 1)

  ;; Enable buffer size indication in modeline
  (size-indication-mode 1)

  ;; Display the time in modeline with custom format (YYYY-MM-dd HH:MM)
  (setq display-time-format "%Y-%m-%d %H:%M")
  (display-time-mode 1)

  ;; Configure and enable which-function-mode.
  ;; Only enable which-function-mode in programming modes (prevents errors in non-code buffers like treemacs)
  (setq
   which-func-modes
   '(emacs-lisp-mode
     lisp-interaction-mode
     python-mode
     python-ts-mode
     bash-mode
     sh-mode
     c-mode
     c++-mode
     java-mode
     javascript-mode
     typescript-mode
     js-mode
     js2-mode
     go-mode
     rust-mode
     ruby-mode
     perl-mode
     makefile-mode))
  (which-function-mode 1)

  (core-message-success "Default modeline configured"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; doom-modeline Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun
  modeline-config-setup-doom-modeline
  ()
  "Configure and enable doom-modeline."
  (core-message-config "Setting up doom-modeline")

  (use-package
   doom-modeline
   :config
   ;; Icon Configuration
   (setq
    doom-modeline-icon t ; Enable icons
    doom-modeline-major-mode-icon t ; Show major mode icon
    doom-modeline-major-mode-color-icon t ; Colorful major mode icons
    doom-modeline-buffer-state-icon t ; Show buffer state icon
    doom-modeline-buffer-modification-icon t) ; Show buffer modification icon

   ;; Time Display
   (setq display-time-format "%Y-%m-%d %H:%M") ; Format: YYYY-MM-DD HH:MM
   (setq doom-modeline-time t) ; Enable time display (not enabled by default)
   (display-time-mode 1) ; Activate time display

   ;; Git/VCS Status Display
   (setq doom-modeline-vcs-max-length 15) ; Limit branch name length

   ;; Python Environment Display (updated by pyvenv hooks)
   (setq doom-modeline-env-version t doom-modeline-env-enable-python t)

   ;; Modeline Height and Appearance
   (setq
    doom-modeline-height 25 ; Height of the mode-line
    doom-modeline-bar-width 3 ; Width of the mode-line bar
    doom-modeline-hud nil ; Disable HUD-style modeline
    doom-modeline-window-width-limit nil) ; No width limit for displaying info

   ;; Enable doom-modeline
   (doom-modeline-mode 1))

  ;; Add pyvenv-indicator to the main modeline format (after pyvenv-modeline segment is loaded)
  ;; This waits for both doom-modeline and the pyvenv-indicator segment to be available
  (with-eval-after-load
   'pyvenv-modeline
   ;; Left side: bar, buffer info, and basic indicators
   ;; Right side: everything else including pyvenv-indicator
   (doom-modeline-def-modeline
    'main
    '(bar
      workspace-name
      window-number
      modals
      matches
      buffer-info
      remote-host
      buffer-position
      parrot
      selection-info)
    '(pyvenv-indicator
      misc-info
      persp-name
      battery
      grip
      irc
      mu4e
      gnus
      github
      debug
      repl
      lsp
      minor-modes
      input-method
      indent-info
      buffer-encoding
      major-mode
      process
      vcs
      check
      time)))

  (core-message-success "doom-modeline configured and enabled"))


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Modeline Initialization
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (if
  modeline-config-use-doom-modeline
  (modeline-config-setup-doom-modeline)
  (modeline-config-setup-default)))

(provide 'modeline-config)

;;; modeline-config.el ends here
