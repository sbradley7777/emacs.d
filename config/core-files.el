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

;; Backup preferences configuration
(setq make-backup-files t                    ; Enable backup files
      backup-by-copying t                    ; Copy files instead of renaming
      backup-by-copying-when-mismatch t      ; Copy when ownership/permissions would change
      backup-by-copying-when-linked t        ; Copy when file has multiple hard links
      version-control t)                     ; Enable numbered backups
;; Backup version management - maintains 5 total backups (2 old + 3 new)
(setq-default delete-old-versions t)         ; Remove backups outside the 2 oldest/3 newest range
(setq kept-new-versions 3                    ; Keep 3 newest backup versions
      kept-old-versions 2)                   ; Keep 2 oldest backup versions

;; Make this module available for loading with (require 'core-files)
(provide 'core-files)
(message "core-files.el loaded successfully.")
