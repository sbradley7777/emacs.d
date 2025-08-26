;;; core-editing.el --- Editing Behavior Configuration
;;; Commentary:
;;      Tabs, spaces, and general editing preferences

(message "Loading core-editing.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tabs and Spaces Preferences:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; - http://www.emacswiki.org/emacs/NoTabs
(setq-default indent-tabs-mode nil)

(provide 'core-editing)
(message "core-editing.el loaded successfully.")