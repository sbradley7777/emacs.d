;;; minibuffer-config.el --- Minibuffer Completion Enhancement -*- lexical-binding: t -*-

;;; Commentary:
;;      Modern minibuffer completion stack using Vertico, Orderless, Marginalia, and Consult.
;;      Provides enhanced command/file/buffer navigation with fuzzy matching and rich annotations.
;;
;; PACKAGE ARCHITECTURE:
;; ---------------------
;; This configuration integrates four complementary packages that work together to create
;; a powerful minibuffer completion experience:
;;
;; 1. Orderless (Matching Engine):
;;    - Provides flexible, space-separated fuzzy matching
;;    - Lets you type non-contiguous characters to find matches
;;    - Example: "buf li" matches "buffer-list", "build-library", etc.
;;    - Works underneath all completion UIs, powering the search
;;
;; 2. Vertico (UI/Display Layer):
;;    - Displays completion candidates in a vertical list
;;    - Shows more candidates at once (default: 15)
;;    - Provides smooth cycling through options
;;    - Pure UI - relies on Orderless for matching
;;
;; 3. Marginalia (Annotation Layer):
;;    - Adds contextual information to completion candidates
;;    - Shows file sizes, modification times, keybindings, documentation
;;    - Makes it easier to identify the right choice
;;    - Works alongside Vertico to enrich the display
;;
;; 4. Consult (Enhanced Commands):
;;    - Provides powerful replacement commands (consult-buffer, consult-line, etc.)
;;    - Adds live preview while browsing candidates
;;    - Integrates with all three packages above
;;    - Uses Vertico for display, Orderless for matching, Marginalia for annotations
;;
;; HOW THEY WORK TOGETHER:
;; ------------------------
;; When you press C-x b (consult-buffer):
;; 1. Consult shows buffer list and provides live preview
;; 2. Vertico displays candidates vertically with cycling
;; 3. Orderless matches your fuzzy input against buffer names
;; 4. Marginalia shows buffer size, mode, and file path
;;
;; Example flow: C-x b → type "py ma" → matches "python-mode.el", shows file size
;;
;; COMPARISON TO CORFU:
;; --------------------
;; Note: This stack is distinct from Corfu (configured in completion-config.el):
;; - Corfu: In-buffer completion (code, text while typing)
;; - Vertico stack: Minibuffer completion (commands, files, buffers via M-x or C-x)
;; Both systems complement each other for a complete completion experience.
(require 'core-utils)
(require 'theme-doom-1337-constants)
(core-utils-with-load-timing
 "minibuffer-config.el"
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Orderless - Flexible Fuzzy Matching Engine
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Orderless enables space-separated fuzzy matching for all completion scenarios.
 ;; Instead of requiring exact prefix matches, you can type any parts of the target
 ;; in any order. For example, "buf lis" matches "buffer-list" and "list-buffers".
 (use-package
  orderless
  :config
  (setq
   completion-styles
   '(orderless basic)
   completion-category-defaults
   nil
   completion-category-overrides
   '((file (styles partial-completion))))
  (core-message-config "Orderless fuzzy matching configured"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Vertico - Vertical Minibuffer Completion UI
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Vertico provides a clean, vertical interface for minibuffer completion.
 ;; It replaces Emacs' default horizontal completion display with a vertical list
 ;; that shows more candidates at once and is easier to navigate.
 (use-package
  vertico
  :init (vertico-mode)
  :config
  (setq vertico-cycle t vertico-count 15)
  (core-message-config "Vertico vertical completion enabled"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Vertico Extensions
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Vertico provides several optional extensions that enhance functionality.
 ;; These are built-in to vertico but need to be explicitly loaded.
 ;;
 ;; vertico-directory:
 ;; - Provides Ido-like directory navigation in file completion
 ;; - DEL (backspace) goes up one directory level
 ;; - RET on a directory enters it immediately
 ;; - Auto-cleanup of trailing slashes for better UX
 ;; - Essential for efficient file navigation
 ;;
 ;; vertico-mouse:
 ;; - Adds mouse support for scrolling and selection
 ;; - Click on candidates to select them
 ;; - Scroll wheel navigation through candidates
 ;; - Particularly useful in GUI mode
 ;; - Works in terminal too (if terminal supports mouse)
 (with-eval-after-load
  'vertico
  ;; Load vertico-directory for enhanced file navigation
  (require 'vertico-directory)
  ;; Enable DEL to go up directory in file paths
  (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word)
  ;; Load vertico-mouse for mouse support
  (require 'vertico-mouse)
  (vertico-mouse-mode)
  (core-message-config "Vertico extensions enabled: directory navigation and mouse support"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Visual Enhancements - Custom Faces (Doom-1337 Optimized)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Enhanced faces for better visual distinction and readability in minibuffer completion.
 ;; These colors are optimized for doom-1337 theme, using the theme's existing accent colors
 ;; for consistency and proper contrast against the dark background.
 (with-eval-after-load
  'vertico
  (custom-set-faces
   ;; Highlight current selection with a distinct background (subtle blue-gray)
   '(vertico-current ((t (:background "#3a3f5a" :extend t :weight bold))))))
 (with-eval-after-load
  'orderless
  (custom-set-faces
   ;; Use doom-1337's accent colors for match highlighting - each search term gets distinct color
   ;; Primary face uses shared search highlight color for consistency with isearch/query-replace
   `(orderless-match-face-0 ((t (:foreground ,doom-1337-search-highlight-color :weight bold))))
   `(orderless-match-face-1 ((t (:foreground ,doom-1337-color-purple :weight bold))))
   `(orderless-match-face-2 ((t (:foreground ,doom-1337-color-cyan :weight bold))))
   `(orderless-match-face-3 ((t (:foreground ,doom-1337-color-blue :weight bold))))))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Marginalia - Rich Minibuffer Annotations
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Marginalia enriches minibuffer completion by adding contextual information
 ;; to each candidate. This metadata appears in the right margin of the Vertico display.
 (use-package
  marginalia
  :init (marginalia-mode)
  :config (core-message-config "Marginalia annotations enabled"))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Consult - Enhanced Minibuffer Commands with Live Preview
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Consult provides powerful replacement commands for common Emacs operations.
 ;; See user-keybindings.el for keybindings (C-x b, C-s, M-y, M-g g).
 ;; All commands integrate with Vertico, Orderless, and Marginalia.
 ;;
 ;; CONSULT-BUFFER SOURCES AND NARROWING:
 ;; --------------------------------------
 ;; consult-buffer combines multiple sources of candidates, each with a narrowing key.
 ;; The sources come from `consult-buffer-sources` which includes:
 ;;
 ;; Active Sources (visible categories in consult-buffer):
 ;; - Filtered Buffers (d): Open buffers with filtered patterns excluded (custom source)
 ;; - Project Buffers (p): Project buffers with filtered patterns excluded (if in a project)
 ;; - All Buffers (b): All open buffers (no filtering)
 ;; - Files (f): Recent files from recentf-list (limited to 10 most recent)
 ;;
 ;; The following sources are available in Consult but excluded:
 ;; - Bookmarks (not needed)
 ;; - Registers (not needed)
 ;; - Project recent files (was showing non-project files)
 ;; - Hidden buffers (starting with space)
 ;; - Modified buffers (buffers with unsaved changes)
 ;; - Other buffers (from other frames/windows)
 ;;
 ;; The "File" category shows recent files from `recentf-list`, which is managed by
 ;; recentf-mode (enabled in core-ui.el). The list includes:
 ;; - Recently opened files (limited to 10 via consult-buffer-recent-file-limit)
 ;; - Files are saved to ~/.emacs.d/local/recentf
 ;; - List persists across Emacs sessions
 ;; - Automatically cleaned up (non-existent files removed on startup)
 ;;
 ;; NARROWING FEATURE:
 ;; -------------------
 ;; Press "<" followed by a key to narrow to a specific source:
 ;; - <d - Show only filtered buffers (default, excludes utility/internal buffers)
 ;; - <p - Show only project buffers (filtered, if in a project)
 ;; - <b - Show all buffers (unfiltered, includes everything)
 ;; - <f - Show only recent files (10 most recent)
 ;; - Press "<" again to remove narrowing and show all sources
 ;;
 ;; INTEGRATION:
 ;; -------------
 ;; All consult commands automatically benefit from:
 ;; - Vertico's vertical display (shows more candidates)
 ;; - Orderless fuzzy matching (type any parts in any order)
 ;; - Marginalia's annotations (file sizes, modes, keybindings)
 (use-package
  consult
  :config (setq consult-preview-key 'any consult-narrow-key "<")
  ;; Customize consult-line to pre-fill with symbol at point
  (consult-customize
   consult-line
   :add-history (seq-some #'thing-at-point '(region symbol))
   :initial (thing-at-point 'symbol))

  ;; Customize which sources appear in consult-buffer
  (with-eval-after-load
   'consult
   ;; Customize buffer sources for a cleaner interface
   (setq
    consult-buffer-sources
    '(consult--source-filtered-buffer
      consult--source-project-buffer consult--source-buffer consult--source-recent-file))

   (core-message-config "Consult buffer sources and preview customization configured")))

 ;; Load custom consult sources (defines filtering patterns and customizes sources)
 (require 'consult-sources))
(provide 'minibuffer-config)
;;; minibuffer-config.el ends here
