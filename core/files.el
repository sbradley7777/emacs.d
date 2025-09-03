;;; files.el --- File Handling Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      File archiving, backups, and autosave settings

(require 'core-constants)

(defvar config-load-start-time (current-time))
(message "🔄  Loading files.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Don't litter OS with autosaves (~) and backup (#) files. Based on:
;; http://snarfed.org/gnu_emacs_backup_files and
;; http://stackoverflow.com/questions/2020941/emacs-newbie-how-can-i-hide-the-buffer-files-that-emacs-creates
;;
;; Autosave files: ~/.emacs.d/autosaves/ | Backup files: ~/.emacs.d/backups/
;; Directories are automatically created if they don't exist.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Stamp time on all files saved.
(require 'time-stamp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Autosave files (example: #foo#) -> ~/.emacs.d/autosaves/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosaves/"))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))
;; Create the autosave directory if it does not exist.
(make-directory autosave-dir t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backup files (example: foo~) -> ~/.emacs.d/backups/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar backup-dir (expand-file-name "~/.emacs.d/backups/"))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
;; Create the backups directory if it does not exist.
(make-directory backup-dir t)

;; Enhanced backup preferences configuration
(setq
 make-backup-files t ; Enable backup files
 backup-by-copying t ; Copy files instead of renaming (don't unlink hardlinks)
 backup-by-copying-when-mismatch t ; Copy when ownership/permissions would change
 backup-by-copying-when-linked t ; Copy when file has multiple hard links
 version-control t ; Enable numbered backups
 delete-old-versions t ; Delete excess backup files silently
 kept-old-versions core-kept-old-versions ; Number of old versions to keep
 kept-new-versions core-kept-new-versions) ; Number of new versions to keep

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
 log-backup-operation
 (file)
 "Log when a backup file is created for FILE."
 (when file (message "💾  Backup created for: %s" (file-name-nondirectory file))))

(defun
 log-auto-save-operation () "Log when an auto-save operation occurs."
 (when buffer-file-name (message "💾  Auto-saved: %s" (file-name-nondirectory buffer-file-name))))

;; Hook into backup operations
(add-hook
 'before-save-hook
 (lambda
  ()
  (when
   (and buffer-file-name make-backup-files (file-exists-p buffer-file-name))
   (log-backup-operation buffer-file-name))))

;; Hook into auto-save operations
(add-hook 'auto-save-hook 'log-auto-save-operation)

;; Make this module available for loading with (require 'files)
(provide 'files)
(message
 "files.el loaded (%.2fs)" (float-time (time-subtract (current-time) config-load-start-time)))
