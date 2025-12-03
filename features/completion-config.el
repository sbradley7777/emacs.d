;;; completion-config.el --- Core Auto-Completion Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;;      Modern auto-completion framework using Corfu.
;;;      Provides universal auto-completion for all modes and languages.

;;; Code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completion System Components
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This file configures an auto-completion framework composed of several
;; packages that work together:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1. Corfu (The UI):
;;    - The front-end that displays completion candidates in a pop-up menu. It
;;      is responsible only for the user interface.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2. completion-at-point (The Manager):
;;    - A built-in Emacs command that orchestrates the completion process. When
;;      triggered (e.g., by TAB), it asks various "backends" for suggestions
;;      and gives the final list to Corfu to display.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3. Cape (The Local Expert / Generalist Backend):
;;    - Provides simple but effective completion backends. For example,
;;      `cape-dabbrev` provides completions from words already present in your
;;      open buffers.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4. Language-Specific Backends (Optional Language Intelligence):
;;    - Various packages can provide intelligent, context-aware completions
;;      for specific programming languages. Examples include LSP clients
;;      (like eglot), dedicated language packages (like jedi.el for Python),
;;      or IDE-like packages (like elpy). These backends provide completions
;;      based on a deep understanding of the code structure and semantics.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; --- Completion Flow with Language Backends ---
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; When a language-specific backend is active, the completion process is:
;; 1. User presses TAB, triggering `completion-at-point`.
;; 2. `completion-at-point` asks all backends for suggestions.
;; 3. Language backend provides intelligent completions based on code analysis.
;; 4. Cape provides simple text-based completions from the buffer.
;; 5. Emacs combines the results, prioritizing the language-specific suggestions.
;; 6. Corfu displays the final, context-aware list to the user.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'core-constants)
(require 'features-constants)
(require 'logging-init)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

 (logging-config "Corfu auto-completion configured successfully")

 ;; Add debugging information
 (logging-debug "Corfu global mode enabled: %s" (if global-corfu-mode "YES" "NO"))
 (logging-debug "Corfu auto setting: %s" corfu-auto)
 (logging-debug "Corfu auto delay: %s" corfu-auto-delay)
 (logging-debug "Corfu auto prefix: %s" corfu-auto-prefix))

(use-package
 corfu-terminal
 :after corfu
 :config
 (unless (display-graphic-p) (corfu-terminal-mode +1))
 (logging-config "Corfu terminal support enabled"))

(with-eval-after-load
 'corfu

 ;; In GUI mode: use popupinfo (child frame popup)
 (when
  (display-graphic-p)
  (require 'corfu-popupinfo)
  (corfu-popupinfo-mode 1)
  (setq
   corfu-popupinfo-delay
   (cons
    core-ui-instant-feedback-delay
    core-ui-instant-feedback-delay)) ; Initial delay 0.1s, then 0.1s between candidates

  ;; Add keybindings to manually toggle documentation in completion menu
  (define-key corfu-map (kbd "M-d") #'corfu-popupinfo-toggle) ; Alt+d to toggle
  (define-key corfu-map (kbd "M-n") #'corfu-popupinfo-scroll-down) ; Alt+n scroll down
  (define-key corfu-map (kbd "M-p") #'corfu-popupinfo-scroll-up) ; Alt+p scroll up

  (logging-config "Corfu documentation popup enabled (GUI mode)")
  (logging-debug "Popupinfo keybindings: M-d (toggle), M-n/M-p (scroll)"))

 ;; In terminal mode: use echo (shows documentation in echo area/minibuffer)
 (unless
  (display-graphic-p)
  (require 'corfu-echo)
  (corfu-echo-mode 1)
  (setq
   corfu-echo-delay
   (cons
    core-ui-instant-feedback-delay
    core-ui-instant-feedback-delay)) ; Initial delay 0.1s, then 0.1s between candidates
  (logging-config "Corfu documentation echo enabled (terminal mode)")
  (logging-debug "Documentation appears in echo area (minibuffer)")))

(use-package
 kind-icon
 :after corfu
 :config
 (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter)
 (logging-config "Corfu completion icons enabled"))

(add-hook 'completion-at-point-functions #'cape-dabbrev)
(add-hook 'completion-at-point-functions #'cape-file)
(provide 'completion-config)
;;; completion-config.el ends here
