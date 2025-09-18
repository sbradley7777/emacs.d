;;; python-utils.el --- Python Utility Functions -*- lexical-binding: t -*-
;;; Commentary:
;;;      General utility functions for Python development support,
;;;      including both local and remote contexts.

(require 'core-utils)
(require 'python-constants)

(core-utils-with-load-timing
 "python-utils.el") ;; End of core-utils-with-load-timing

;; Make this module available for loading
(provide 'python-utils)
