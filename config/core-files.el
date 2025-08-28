;;; core-files.el --- File Handling Configuration -*- lexical-binding: t -*-
;;; Commentary:
;;      File archiving, backups, and autosave settings

(message "Loading core-files.el...")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Don't litter OS with autosaves (~) and backup (#) files. Based on:
;; http://snarfed.org/gnu_emacs_backup_files and
;; http://stackoverflow.com/questions/2020941/emacs-newbie-how-can-i-hide-the-buffer-files-that-emacs-creates
;;
;; Autosave files: ~/.emacs_archive/autosaves/ | Backup files: ~/.emacs_archive/backups/
;; Directories are automatically created if they don't exist.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Stamp time on all files saved.
(require 'time-stamp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Autosave files (example: #foo#) -> ~/.emacs_archive/autosaves/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar autosave-dir (expand-file-name "~/.emacs_archive/autosaves/"))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))
;; Create the autosave directory if it does not exist.
(make-directory autosave-dir t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backup files (example: foo~) -> ~/.emacs_archive/backups/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar backup-dir (expand-file-name "~/.emacs_archive/backups/"))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
;; Create the backups directory if it does not exist.
(make-directory backup-dir t)

;; Various backup preferences.
(setq make-backup-files t)
(setq backup-by-copying t)
(setq backup-by-copying-when-mismatch t)
(setq backup-by-copying-when-linked t)
(setq version-control t)
;; Remove any backups that are either not the 2 oldest copies or the 3 newest copies.
(setq-default delete-old-versions t)
;; Keeps at most 3 copies that are newer than the 2 oldest copies. This means there could be 5 total backups at one time.
(setq kept-new-versions 3)
;; Keeps two old copies that will not be deleted.
(setq kept-old-versions 2)

;; Make this module available for loading with (require 'core-files)
(provide 'core-files)
(message "core-files.el loaded successfully.")
