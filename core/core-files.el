;;; core-files.el --- File Handling Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      File archiving, backups, and autosave settings

;;; Code:
(require 'core-constants)
(require 'core-logging)

;; Declare external variables to suppress byte-compiler warnings
(defvar project-list-file) ; From project.el
(defvar transient-history-file) ; From transient.el
(defvar forge-database-file) ; From forge.el

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Don't litter OS with autosaves (~) and backup (#) files. Based on:
;; http://snarfed.org/gnu_emacs_backup_files and
;; http://stackoverflow.com/questions/2020941/emacs-newbie-how-can-i-hide-the-buffer-files-that-emacs-creates
;;
;; Autosave files: ~/.emacs.d/local/autosaves/ | Backup files: ~/.emacs.d/local/backups/
;; Directories are automatically created if they don't exist.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Stamp time on all files saved.
(require 'time-stamp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Autosave files (example: #foo#) -> ~/.emacs.d/local/autosaves/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq auto-save-list-file-prefix (expand-file-name "saves-" core-files-auto-save-list-dir))
(setq auto-save-file-name-transforms `((".*" ,core-files-autosave-dir t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backup files (example: foo~) -> ~/.emacs.d/local/backups/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq backup-directory-alist (list (cons ".*" core-files-backup-dir)))

;; Enhanced backup preferences configuration
(setq
 make-backup-files t ; Enable backup files
 backup-by-copying t ; Copy files instead of renaming (don't unlink hardlinks)
 backup-by-copying-when-mismatch t ; Copy when ownership/permissions would change
 backup-by-copying-when-linked t ; Copy when file has multiple hard links
 version-control t ; Enable numbered backups
 delete-old-versions t ; Delete excess backup files silently
 kept-old-versions core-kept-old-versions ; Number of old versions to keep
 kept-new-versions core-kept-new-versions ; Number of new versions to keep
 backup-enable-predicate (lambda (_) t)) ; Always enable backups for all files

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project list file -> ~/.emacs.d/local/projects.el
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq project-list-file core-projects-file)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Transient history file -> ~/.emacs.d/local/transient/history.el
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq transient-history-file core-transient-history-file)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Forge database file -> ~/.emacs.d/local/forge-database.sqlite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq forge-database-file core-forge-db-file)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enhanced auto-save configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; More frequent auto-saving for better data protection
(setq
 auto-save-interval core-auto-save-interval ; Auto-save every N keystrokes
 auto-save-timeout core-auto-save-timeout) ; Auto-save after N seconds of idle time

;; Auto-save files in the same directory structure but in our autosaves folder
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backup and Auto-save Logging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add helpful logging messages for backup and auto-save operations
(defun
 core-files-log-backup-operation (_file) "Log when a backup file is created for FILE."
 ; (when _file (core-message-info "Backup created for: %s" (file-name-nondirectory _file)))
 )

(defun
 core-files-log-auto-save-operation () "Log when an auto-save operation occurs."
 ; (when buffer-file-name (core-message-info "Auto-saved: %s" (file-name-nondirectory buffer-file-name)))
 )
;; Hook into backup operations
(add-hook
 'before-save-hook
 (lambda
  ()
  (when
   (and buffer-file-name make-backup-files (file-exists-p buffer-file-name))
   (core-files-log-backup-operation buffer-file-name))))

;; Hook into auto-save operations
(add-hook 'auto-save-hook #'core-files-log-auto-save-operation)
(provide 'core-files)
;;; core-files.el ends here
