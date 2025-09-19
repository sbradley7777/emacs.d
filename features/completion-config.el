;;; completion-config.el --- Core Auto-Completion Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;;      Modern auto-completion framework using Corfu.
;;;      Provides universal auto-completion for all modes and languages.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completion System Components
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This file configures an auto-completion framework composed of several
;; packages that work together:
;;
;; 1. Corfu (The UI):
;;    - The front-end that displays completion candidates in a pop-up menu. It
;;      is responsible only for the user interface.
;;
;; 2. completion-at-point (The Manager):
;;    - A built-in Emacs command that orchestrates the completion process. When
;;      triggered (e.g., by TAB), it asks various "backends" for suggestions
;;      and gives the final list to Corfu to display.
;;
;; 3. Cape (The Local Expert / Generalist Backend):
;;    - Provides simple but effective completion backends. For example,
;;      `cape-dabbrev` provides completions from words already present in your
;;      open buffers.
;;
;; 4. Eglot + Pylsp (The Language Specialist Backend):
;;    - Eglot is a client for the Language Server Protocol (LSP) that
;;      communicates with a language server like `pylsp` (for Python). This
;;      backend provides intelligent, context-aware completions based on a
;;      deep understanding of the code.
;;
;; --- Completion Flow with Eglot ---
;;
;; When Eglot and a language server are active, the completion process is:
;; 1. User presses TAB, triggering `completion-at-point`.
;; 2. `completion-at-point` asks all backends for suggestions.
;; 3. Eglot asks the language server (e.g., `pylsp`) for intelligent completions.
;; 4. Cape provides simple text-based completions from the buffer.
;; 5. Emacs combines the results, prioritizing the language server's suggestions.
;; 6. Corfu displays the final, context-aware list to the user.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'features-constants)
(require 'core-utils)

(core-utils-with-load-timing
 "completion-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Corfu Auto-Completion Framework
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


 (use-package
  corfu
  :init
  ;; Enable corfu globally for all buffers
  (global-corfu-mode)

  :config
  ;; Auto-completion settings
  (setq
   corfu-auto t ; Enable automatic completion
   corfu-auto-delay features-corfu-auto-delay ; Short delay before showing completions
   corfu-auto-prefix features-corfu-auto-prefix ; Start completing after N characters
   corfu-cycle t ; Enable cycling through candidates with TAB
   corfu-preview-current 'insert ; Preview current candidate
   corfu-preselect 'prompt ; Preselect based on prompt
   corfu-on-exact-match nil) ; Don't auto-complete on exact match

  ;; Configure TAB for completion and indentation
  (setq tab-always-indent 'complete)

  ;; Performance optimizations
  (setq
   corfu-min-width features-corfu-min-width ; Minimum popup width
   corfu-max-width features-corfu-max-width ; Maximum popup width
   corfu-count features-corfu-count) ; Maximum number of candidates shown

  ;; Key bindings for Corfu UI (robust for GUI and terminal)
  (define-key corfu-map (kbd "TAB") #'corfu-next) ; Terminal-friendly
  (define-key corfu-map (kbd "<tab>") #'corfu-next) ; GUI-friendly
  (define-key corfu-map (kbd "S-TAB") #'corfu-previous) ; Terminal-friendly
  (define-key corfu-map (kbd "<backtab>") #'corfu-previous) ; GUI-friendly
  (define-key corfu-map (kbd "RET") #'corfu-insert) ; Terminal-friendly
  (define-key corfu-map (kbd "<return>") #'corfu-insert) ; GUI-friendly

  ;; Global key bindings for manual completion trigger
  (global-set-key (kbd "C-c TAB") #'completion-at-point) ; Ctrl+c then TAB
  (global-set-key (kbd "M-TAB") #'completion-at-point) ; Alt+TAB (traditional)
  (global-set-key (kbd "C-M-i") #'completion-at-point) ; Ctrl+Alt+i (traditional alternative)

  (message "⚙️  Corfu auto-completion configured successfully")

  ;; Add debugging information
  (message "🛠️  Corfu global mode enabled: %s" (if global-corfu-mode "YES" "NO"))
  (message "🛠️  Corfu auto setting: %s" corfu-auto)
  (message "🛠️  Corfu auto delay: %s" corfu-auto-delay)
  (message "🛠️  Corfu auto prefix: %s" corfu-auto-prefix))

 ;; Add cape backends for in-buffer completion
 (add-hook 'completion-at-point-functions #'cape-dabbrev)
 (add-hook 'completion-at-point-functions #'cape-file)

 ;; Make this module available for loading with (require 'completion-config)
 (provide 'completion-config))
