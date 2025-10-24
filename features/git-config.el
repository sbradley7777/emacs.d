;;; git-config.el --- Git Integration Configuration -*- lexical-binding: t -*-

;;; Commentary:
;;      Configuration for magit and forge integration.
;;      Provides git interface and GitHub/GitLab integration within Emacs.
(require 'core-utils)
(core-utils-with-load-timing
 "git-config.el"

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Magit Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun
  git-config-magit-display-buffer-side
  (buffer)
  "Display BUFFER in side window sized to fit longest line."
  (let ((win-width
         (with-current-buffer
          buffer
          (save-excursion
           (goto-char (point-min))
           (let ((max-len 0))
             (while
              (re-search-forward
               "^\\(?:modified\\|new file\\|deleted\\|renamed\\)\\s-+\\(.+\\)$" nil t)
              (setq max-len (max max-len (+ 12 (length (match-string 1))))))
             (if (> max-len 0) (min (floor (* (frame-width) 0.8)) (max 60 (+ max-len 5))) 60))))))
    (display-buffer
     buffer `(display-buffer-in-side-window (side . right) (window-width . ,win-width)))))

 (defun
  git-config-format-magit-buffer
  ()
  "Format Magit buffer with word-wrapped lines and proper padding."
  (let ((inhibit-read-only t)
        (win-width (window-width)))
    (save-excursion
     (goto-char (point-min))
     (while
      (re-search-forward "^\\(Head:\\|Merge:\\|Push:\\|Pull:\\)\\s-+" nil t)
      (let* ((label-end (point))
             (line-end (line-end-position))
             (fill-prefix (make-string (current-column) ?\s))
             (fill-column (- win-width 2)))
        (when
         (> (- line-end (line-beginning-position)) fill-column)
         (fill-region-as-paragraph label-end line-end)))))))

 (use-package
  magit
  :defer t
  :config
  (setq magit-display-buffer-function #'git-config-magit-display-buffer-side)
  (advice-add 'magit-status-refresh-buffer :after #'git-config-format-magit-buffer)
  (core-message-config "Magit configured for git integration"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Forge Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (use-package
  forge
  :after magit
  :config (core-message-config "Forge configured for GitHub/GitLab integration")))
(provide 'git-config)
;;; git-config.el ends here
