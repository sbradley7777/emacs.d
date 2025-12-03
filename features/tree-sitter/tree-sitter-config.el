;;; tree-sitter-config.el --- Tree-sitter Grammar Management Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      Configures tree-sitter grammar installation and loading paths.
;;      Ensures grammars are installed to ~/.emacs.d/local/tree-sitter instead of the default location.

;;; Code:
(require 'core-constants)
(require 'core-utils)
(require 'core-logging)
(require 'features-constants)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(logging-config
 "Tree-sitter grammar directory: %s" (abbreviate-file-name features-treesit-grammars-dir))
(setq treesit-extra-load-path (list features-treesit-grammars-dir))
(logging-config
 "treesit-extra-load-path: %s" (mapcar #'abbreviate-file-name treesit-extra-load-path))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core--treesit-reload-buffers-for-language (lang)
 "Reload all buffers that could use the newly installed LANG grammar.
Switches buffers from regular mode to tree-sitter mode when grammar becomes available.
Dynamically discovers mode mappings from treesit-auto configuration."
 (when-let* ((mode-info (treesit-utils-get-mode-mapping lang))
             (regular-mode (nth 0 mode-info))
             (ts-mode (nth 1 mode-info)))
   (let ((reloaded-count 0)
         (buffers-to-reload '()))
     ;; First pass: collect all buffers that need reloading
     (dolist
      (buffer (buffer-list))
      (with-current-buffer
       buffer
       (when
        (and
         (buffer-file-name) (or (eq major-mode regular-mode) (eq major-mode ts-mode)))
        (push buffer buffers-to-reload))))
     ;; Second pass: reload collected buffers
     (dolist
      (buffer buffers-to-reload)
      (with-current-buffer
       buffer
       (let ((file-name (buffer-file-name))
             (point-pos (point))
             (window-start-pos
              (when (get-buffer-window buffer) (window-start (get-buffer-window buffer)))))
         (condition-case err
             (progn
              (revert-buffer nil t t)
              ;; Force mode switch if still in regular mode after revert
              (when (eq major-mode regular-mode) (funcall ts-mode)) (goto-char point-pos)
              (when
               window-start-pos (set-window-start (get-buffer-window buffer) window-start-pos))
              (setq reloaded-count (1+ reloaded-count)))
           (error
            (logging-warning
             "Failed to reload buffer %s: %s" file-name (error-message-string err)))))))
     (when
      (> reloaded-count 0)
      (logging-success
       "Reloaded %d buffer%s to use %s tree-sitter mode"
       reloaded-count
       (if (= reloaded-count 1) "" "s")
       lang)))))

(advice-add
 'treesit-install-language-grammar
 :around
 (lambda
  (orig-fun lang &optional out-dir)
  "Install tree-sitter grammars to custom directory and reload relevant buffers.
Uses features-treesit-grammars-dir unless OUT-DIR is explicitly provided.
After successful installation, automatically reloads buffers to use the new grammar."
  (let ((install-dir (or out-dir features-treesit-grammars-dir)))
    (logging-info "Installing %s grammar to: %s" lang (abbreviate-file-name install-dir))
    (funcall orig-fun lang install-dir)
    ;; After successful installation, reload buffers that can use this grammar
    (when
     (treesit-language-available-p lang)
     (logging-success "%s grammar installed successfully" lang)
     (core--treesit-reload-buffers-for-language lang)))))

(logging-success "Tree-sitter grammar management configured")
(logging-info "Grammars will install to: %s" (abbreviate-file-name features-treesit-grammars-dir))
(provide 'tree-sitter-config)
;;; tree-sitter-config.el ends here
