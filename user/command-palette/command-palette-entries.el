;;; command-palette-entries.el --- Command Palette Data Structures and Accessors -*- lexical-binding: t -*-
;;; Commentary:
;; Data structures and accessor functions for command palette.
;;
;; This module defines the core data structures used throughout the
;; command palette system and provides accessor functions to work with them.
;;
;; DATA STRUCTURES:
;;
;; 1. Command Palette Item (cons cell):
;;    Format: (NAME . SYMBOL)
;;    - NAME: Human-readable description string (e.g., "Find File")
;;    - SYMBOL: Command symbol (e.g., `find-file)
;;
;; 2. Persistence Configuration (alist of plists):
;;    Format: ((DATA-KEY . PLIST) ...)
;;    Each plist contains:
;;      :variable     - Runtime variable holding the data
;;      :saved-var    - Variable name used in saved file
;;      :file         - File path constant for storage
;;      :data-type    - Type of data structure (ring or list)
;;      :description  - Human-readable description
;;      :default      - Default value constant (or nil)
;;
;; ACCESSOR FUNCTIONS:
;;
;; Item accessors:
;;   - command-palette-item-name      - Get command name from item
;;   - command-palette-item-symbol    - Get command symbol from item
;;   - command-palette-create-item    - Create item from name and symbol
;;
;; Config accessors:
;;   - command-palette-config-variable     - Get :variable from config
;;   - command-palette-config-saved-var    - Get :saved-var from config
;;   - command-palette-config-file         - Get :file from config
;;   - command-palette-config-data-type    - Get :data-type from config
;;   - command-palette-config-description  - Get :description from config
;;   - command-palette-config-default      - Get :default from config

;;; Code:
(require 'command-palette-constants)
(require 'command-palette-defaults)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Structures
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst
 command-palette--persistence-configs
 `((history
    :variable user--command-palette-history
    :saved-var command-palette-saved-history
    :file command-palette-history-file
    :data-type ring
    :description "execution history"
    :default nil)
   (favorites
    :variable user-command-palette-favorites
    :saved-var command-palette-saved-favorites
    :file command-palette-favorites-file
    :data-type list
    :description "favorites list"
    :default ,command-palette-default-favorites)
   (diagnostics
    :variable user-command-palette-diagnostics
    :saved-var command-palette-saved-diagnostics
    :file command-palette-diagnostics-file
    :data-type list
    :description "diagnostics list"
    :default ,command-palette-default-diagnostics))
 "Configuration for persistent data storage.
Each entry defines:
  :variable     - Runtime variable holding the data
  :saved-var    - Variable name used in saved file
  :file         - File path constant for storage
  :data-type    - Type of data structure (ring or list)
  :description  - Human-readable description
  :default      - Default value constant (or nil for history)")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Item Accessors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette-item-name (item)
 "Get command name (string) from command palette ITEM.
ITEM is a cons cell in format (NAME . SYMBOL)."
 (car item))

(defun
 command-palette-item-symbol (item)
 "Get command symbol from command palette ITEM.
ITEM is a cons cell in format (NAME . SYMBOL)."
 (cdr item))

(defun
 command-palette-create-item (name symbol)
 "Create command palette item from NAME (string) and SYMBOL.
Returns cons cell in format (NAME . SYMBOL)."
 (cons name symbol))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Config Accessors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun
 command-palette-config-variable
 (config)
 "Get :variable property from persistence CONFIG plist."
 (plist-get config :variable))

(defun
 command-palette-config-saved-var
 (config)
 "Get :saved-var property from persistence CONFIG plist."
 (plist-get config :saved-var))

(defun
 command-palette-config-file
 (config)
 "Get :file property from persistence CONFIG plist."
 (plist-get config :file))

(defun
 command-palette-config-data-type
 (config)
 "Get :data-type property from persistence CONFIG plist."
 (plist-get config :data-type))

(defun
 command-palette-config-description
 (config)
 "Get :description property from persistence CONFIG plist."
 (plist-get config :description))

(defun
 command-palette-config-default
 (config)
 "Get :default property from persistence CONFIG plist."
 (plist-get config :default))

(provide 'command-palette-entries)
;;; command-palette-entries.el ends here
