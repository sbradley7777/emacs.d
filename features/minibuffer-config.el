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
 ;; - Buffers (b): All open buffers (filtered by consult-buffer-filter)
 ;; - Files (f): Recent files from recentf-list (limited to 10 most recent)
 ;; - Registers (r): File and buffer registers
 ;; - Project Buffers (p): Buffers belonging to current project (if in a project)
 ;;
 ;; The following sources are available in Consult but excluded:
 ;; - Bookmarks (not needed)
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
 ;; - <b - Show only buffers
 ;; - <f - Show only recent files (10 most recent)
 ;; - <r - Show only registers
 ;; - <p - Show only project buffers (if in a project)
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

  ;; Customize which sources appear in consult-buffer
  ;; By default, many sources are hidden (marked with :hidden t)
  ;; We'll customize to show project sources and limit recent files
  (with-eval-after-load
   'consult
   ;; Customize buffer sources for a cleaner interface
   (setq
    consult-buffer-sources
    '(consult--source-buffer
      consult--source-recent-file consult--source-file-register consult--source-project-buffer))

   ;; Assign unique narrowing key to project buffer source. By default it shares 'b' with regular buffers, causing conflicts
   (plist-put consult--source-project-buffer :narrow ?p)
   (plist-put consult--source-project-buffer :hidden nil)

   ;; Limit recent files shown to 10
   (plist-put
    consult--source-recent-file
    :items
    (lambda
     ()
     (let ((ht (consult--buffer-file-hash))
           (items (mapcar #'consult--fast-abbreviate-file-name recentf-list)))
       (seq-take (seq-remove (lambda (x) (gethash x ht)) items) 10))))

   (core-message-config "Consult buffer sources customized: projects visible, 10 recent files")))

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Custom Buffer Sources (Optional)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; You can add custom sources to consult-buffer for specific use cases.
 ;; Examples of custom sources you might want to add:
 ;;
 ;; Example 1: Python buffers only (narrow with <y)
 ;; (with-eval-after-load 'consult
 ;;   (defvar consult--source-python-buffer
 ;;     (list :name "Python Buffer"
 ;;           :narrow ?y
 ;;           :category 'buffer
 ;;           :face 'consult-buffer
 ;;           :history 'buffer-name-history
 ;;           :state #'consult--buffer-state
 ;;           :items (lambda ()
 ;;                    (consult--buffer-query
 ;;                     :mode 'python-mode
 ;;                     :as #'buffer-name)))
 ;;     "Python buffer source for `consult-buffer'.")
 ;;   (add-to-list 'consult-buffer-sources 'consult--source-python-buffer 'append))
 ;;
 ;; Example 2: Org-mode buffers (narrow with <o)
 ;; (with-eval-after-load 'consult
 ;;   (defvar consult--source-org-buffer
 ;;     (list :name "Org Buffer"
 ;;           :narrow ?o
 ;;           :category 'buffer
 ;;           :face 'consult-buffer
 ;;           :history 'buffer-name-history
 ;;           :state #'consult--buffer-state
 ;;           :items (lambda ()
 ;;                    (consult--buffer-query
 ;;                     :mode 'org-mode
 ;;                     :as #'buffer-name)))
 ;;     "Org buffer source for `consult-buffer'.")
 ;;   (add-to-list 'consult-buffer-sources 'consult--source-org-buffer 'append))
 ;;
 ;; Example 3: Project-specific files (narrow with <j for project)
 ;; You can also create sources for specific project directories, file types, etc.
 ;;
 ;; To activate: Uncomment the examples above or create your own following the same pattern.
 ;; Source properties:
 ;; - :name - Display name in the minibuffer
 ;; - :narrow - Single character key for narrowing (must be unique)
 ;; - :category - Type of completion (buffer, file, etc.)
 ;; - :items - Function that returns list of candidates
 ;; - :state - Preview/action function
 ;; - :face - Face for displaying candidates

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Buffer Filtering Configuration
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; Define buffer name patterns to hide from consult-buffer.
 ;; This keeps buffer lists clean by filtering out side panels, internal buffers,
 ;; and other UI elements that you don't typically want to switch to.
 ;;
 ;; Note: You can still access these buffers via M-x switch-to-buffer
 ;; or by typing their full name in consult-buffer.
 (defconst
  minibuffer-config-ignored-buffer-patterns
  '(
    ;; Utility buffers
    "\\*Command Palette\\*" "\\*Flymake diagnostics.*\\*" "\\*Messages\\*" "\\*Completions\\*"
    ;; Common UI buffers
    "\\*scratch\\*" "\\*dashboard\\*" "\\*Buffer List\\*"
    ;; Language server protocol buffers
    "\\*eglot.*\\*" "\\*EGLOT.*\\*"
    ;; Internal buffers (starting with space)
    "\\` "
    ;; Magit buffers (uncomment if using Magit)
    ;; "^magit"
    ;; Help/info buffers (uncomment if desired)
    ;; "\\*Help\\*"
    ;; "\\*info\\*"
    )
  "List of regexp patterns for buffer names to hide from consult-buffer.
Each pattern is matched against buffer names. Matching buffers are excluded
from consult-buffer completion.

Patterns included:
- Command Palette: Side window for command history
- Flymake diagnostics: Diagnostic output window
- Messages: Emacs message log
- Completions: Completion candidates popup
- scratch: Default scratch buffer
- dashboard: Startup screen
- Buffer List: Buffer list window
- eglot: Language server protocol buffers
- Buffers starting with space: Internal Emacs buffers

To add more patterns, simply add regexp strings to this list.")

 (with-eval-after-load
  'consult
  ;; Use the constant for buffer filtering
  (setq consult-buffer-filter minibuffer-config-ignored-buffer-patterns)

  (core-message-config
   "Buffer filtering configured - hiding %d buffer patterns from consult-buffer"
   (length minibuffer-config-ignored-buffer-patterns))))
(provide 'minibuffer-config)
;;; minibuffer-config.el ends here
