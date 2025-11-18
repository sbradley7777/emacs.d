;;; themes-constants.el --- Theme Configuration Constants -*- lexical-binding: t -*-
;;; Commentary:
;; This file contains constants used across various theme modules.
;; Constants are prefixed with 'themes-' to avoid naming conflicts.

;;; Code:
(require 'core-utils)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 themes-region-background "#264F78"
 "Background color for selected region (text selection).
Blue-tinted background that contrasts with hl-line highlighting.")

(defconst
 themes-doom-treemacs-theme "doom-atom"
 "Default treemacs theme for doom-themes integration.
Controls the icon set and styling for the treemacs file explorer.")

(defconst
 themes-modeline-height 25
 "Height of the doom-modeline in pixels.
Affects the overall vertical size of the status bar at the bottom of each window.")

(defconst
 themes-modeline-bar-width 3
 "Width of the doom-modeline bar in pixels.
The colored vertical bar on the left side indicating buffer state (modified, read-only, etc.).")

(defconst
 themes-modeline-vcs-max-length 15
 "Maximum character length for VCS branch names in modeline.
Longer branch names will be truncated to prevent modeline overflow.")
(provide 'themes-constants)
;;; themes-constants.el ends here
