;;; custom.el --- Emacs Customize Interface Settings -*- lexical-binding: t -*-
;;; Commentary:
;;      This file contains customizations made through Emacs' built-in customize interface.
;;
;;      USAGE:
;;      - Accessed via M-x customize or the Options menu
;;      - Changes made through the customize interface are automatically saved here
;;      - This file is loaded conditionally during startup if it exists
;;      - Kept in .gitignore to preserve personal customizations locally
;;
;;      WHAT'S STORED HERE:
;;      - custom-set-variables: User preferences set through customize interface
;;      - custom-set-faces: Font and color customizations from customize
;;      - All settings use the standard Emacs customize system
;;
;;      NOTE: This is a test file demonstrating the loading mechanism.
;;      Real customize changes will overwrite this content automatically.

(custom-set-variables
 ;; Test variable to show custom.el was loaded
 '(initial-scratch-message
   ";; Custom.el was loaded successfully!\n;; This confirms menu customizations will work.\n\n"))

(custom-set-faces
 ;; No custom faces for this test
 )

;; Display a message to confirm loading
(message "✅ custom.el loaded - menu customizations are working!")
