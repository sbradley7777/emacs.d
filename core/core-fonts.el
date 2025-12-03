;;; core-fonts.el --- Font Management and Installation -*- lexical-binding: t -*-
;;; Commentary:
;;      Centralized font management for icon packages and typography.
;;      Handles automatic installation and verification of required fonts.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      IMPORTANT: Package installation (via package.el) only installs Emacs Lisp code.
;;      Font installation is a separate step that downloads actual font files (.ttf, .otf)
;;      to your system font directory (~/.local/share/fonts/) so icons are visible.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      FONT INSTALLATION DETAILS:
;;      - Fonts are installed SYSTEM-WIDE, not just for Emacs
;;      - Location: ~/.local/share/fonts/ (Linux) or ~/Library/Fonts/ (macOS)
;;      - Available to ALL applications after installation (terminals, browsers, etc.)
;;      - Your terminal can use these fonts if configured (e.g., set iTerm2 font to "Hack Nerd Font")
;;      - Emacs uses fonts directly for icon display in buffers and UI elements
;;      - Terminal integration requires manual font configuration in terminal settings

;;; Code:
(require 'core-constants)
(require 'core-logging)

;; Declare external functions to suppress byte-compiler warnings
(declare-function package-installed-p "package" (package &optional min-version))
(declare-function nerd-icons-install-fonts "nerd-icons" (&optional silent))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar
 core--fonts-system-font-directory
 (cond
  ((eq system-type 'darwin)
   "~/Library/Fonts/")
  ((or (eq system-type 'gnu/linux) (eq system-type 'linux))
   "~/.local/share/fonts/")
  (t
   "~/.fonts/"))
 "System font installation directory.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 core--fonts-file-exists-p (filename)
 "Check if font file exists in system font directory.
FILENAME should be the font file name (e.g., \\='NFM.ttf\\=')."
 (file-exists-p (expand-file-name filename core--fonts-system-font-directory)))

(defun
 core--fonts-install-nerd-icons ()
 "Install nerd-icons fonts if not already installed.
Uses fast file-based check instead of font system queries."
 (when
  (package-installed-p 'nerd-icons)
  (condition-case err
      (progn
       (require 'nerd-icons)
       (unless
        (core--fonts-file-exists-p "NFM.ttf")
        (logging-package "Installing nerd-icons fonts...")
        (nerd-icons-install-fonts t)
        (logging-success "nerd-icons fonts installed successfully")))
    (error
     (logging-warning
      "nerd-icons package not ready for font installation: %s" (error-message-string err))))))

(defun
 core--fonts-check-nerd-icons () "Check if nerd-icons fonts are properly installed."
 (if
  (core--fonts-file-exists-p "NFM.ttf")
  (logging-success "nerd-icons fonts are available")
  (logging-warning "nerd-icons fonts not found - may need installation")))

;; Install fonts automatically after packages are available
(core--fonts-install-nerd-icons)
(logging-config "Font management system loaded - supports nerd-icons")
(provide 'core-fonts)
;;; core-fonts.el ends here
