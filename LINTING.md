# Code Linting and Diagnostics

## Overview

This configuration uses **Flymake** (built-in syntax checker) and **Eglot** (built-in LSP client) to provide real-time code diagnostics and linting across multiple languages.

**Flymake** runs standalone linters that check syntax, style, and common errors.

**Eglot** integrates with Language Server Protocol (LSP) servers to provide semantic analysis, code intelligence, and additional diagnostics.

Both systems work together to give you comprehensive feedback while you code.

## Architecture Patterns

The configuration uses three different patterns depending on the language and available tools:

### Standalone-only

Uses a dedicated linter that checks your code without requiring a language server.

**What you get:**
- Fast, focused syntax and style checking
- Specific rule violations with error codes
- No external server process required
- Works immediately without project setup

**When used:**
- Language has excellent standalone linter but no stable LSP (Bash with `shellcheck`)
- Built-in Emacs checkers are sufficient (Emacs Lisp with `checkdoc`)

**Examples:** Bash (`shellcheck`), Emacs Lisp (`checkdoc` + `byte-compile`)

### LSP-only

Uses a Language Server Protocol server that provides comprehensive analysis.

**What you get:**
- Semantic analysis (understands code meaning, not just syntax)
- Real-time diagnostics as you type
- Code intelligence features (completion, navigation, refactoring)
- Project-wide analysis and type checking
- Schema validation (for JSON, YAML, TOML)

**When used:**
- Language has a comprehensive LSP server that includes linting
- LSP provides superior diagnostics compared to standalone tools
- Semantic analysis is more valuable than fast syntax-only checking

**Examples:** Python (`pylsp` with `ruff` plugin), C/C++ (`clangd`), TOML (`taplo`)

### Dual Backend

Runs both a standalone linter AND an LSP server simultaneously.

**What you get:**
- **Standalone linter:** Fast syntax and style rule checking
- **LSP server:** Deep semantic analysis and schema validation
- **Combined feedback:** Both sets of diagnostics appear together
- **Best of both:** Quick style fixes + intelligent semantic errors

**When used:**
- Both tools provide complementary value
- Linter catches style issues LSP might miss
- LSP provides semantic analysis linter can't do

**How it works:**
Both backends run independently and report diagnostics to the same buffer. You see all issues from both sources simultaneously without conflicts.

**Examples:**
- **YAML:** `yamllint` checks style rules, `yaml-language-server` validates schemas
- **JSON:** `jsonlint` checks syntax, `vscode-json-languageserver` validates against JSON schemas
- **Markdown:** `mdl` checks markdown style, `marksman` provides cross-reference and link checking

## Language Support

The table below shows the backend pattern used for each language. See the [Architecture Patterns](#architecture-patterns) section above for detailed explanations of **Standalone-only**, **LSP-only**, and **Dual Backend** patterns.

| Language | Mode(s) | Backend Pattern | Standalone Tool | LSP Server |
|----------|---------|-----------------|-----------------|------------|
| **Python** | `python-mode`, `python-ts-mode` | **LSP-only** | - | [`pylsp`](https://github.com/python-lsp/python-lsp-server) (with [`ruff`](https://github.com/python-lsp/python-lsp-ruff) plugin) |
| **YAML** | `yaml-mode`, `yaml-ts-mode` | **Dual Backend** | [`yamllint`](https://github.com/adrienverge/yamllint) | [`yaml-language-server`](https://github.com/redhat-developer/yaml-language-server) |
| **JSON** | `js-json-mode`, `json-ts-mode` | **Dual Backend** | [`jsonlint`](https://github.com/zaach/jsonlint) | [`vscode-json-languageserver`](https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server) |
| **Markdown** | `markdown-mode`, `markdown-ts-mode` | **Dual Backend** | [`mdl`](https://github.com/markdownlint/markdownlint) (markdownlint) | [`marksman`](https://github.com/artempyanykh/marksman) |
| **Bash/Shell** | `sh-mode`, `bash-ts-mode`, `sh-ts-mode` | **Standalone** | [`shellcheck`](https://github.com/koalaman/shellcheck) | - |
| **C** | `c-mode`, `c-ts-mode` | **LSP-only** | - | [`clangd`](https://github.com/llvm/llvm-project/tree/main/clang-tools-extra/clangd) |
| **C++** | `c++-mode`, `c++-ts-mode` | **LSP-only** | - | [`clangd`](https://github.com/llvm/llvm-project/tree/main/clang-tools-extra/clangd) |
| **TOML** | `toml-mode`, `toml-ts-mode` | **LSP-only** | - | [`taplo`](https://github.com/tamasfe/taplo) |
| **Emacs Lisp** | `emacs-lisp-mode` | **None** | Built-in (`checkdoc`, `byte-compile`) | - |
| **Makefile** | `makefile-mode`, `makefile-gmake-mode` | **None** | - | - |

**Notes:**
- All tools are **optional** - the configuration automatically detects and enables only what's installed
- **Tree-sitter modes** (`*-ts-mode`) are used automatically when the grammar is available
- **Bash**: `bash-language-server` is currently disabled due to issues in v5.6.0

## Required Tools Summary

### Standalone Linters

| Tool | Language | Repository |
|------|----------|------------|
| `yamllint` | YAML | [`adrienverge/yamllint`](https://github.com/adrienverge/yamllint) |
| `jsonlint` | JSON | [`zaach/jsonlint`](https://github.com/zaach/jsonlint) |
| `mdl` | Markdown | [`markdownlint/markdownlint`](https://github.com/markdownlint/markdownlint) |
| `shellcheck` | Bash/Shell | [`koalaman/shellcheck`](https://github.com/koalaman/shellcheck) |

### LSP Servers

| Tool | Language | Repository |
|------|----------|------------|
| `pylsp` | Python | [`python-lsp/python-lsp-server`](https://github.com/python-lsp/python-lsp-server) |
| `python-lsp-ruff` | Python (plugin) | [`python-lsp/python-lsp-ruff`](https://github.com/python-lsp/python-lsp-ruff) |
| `yaml-language-server` | YAML | [`redhat-developer/yaml-language-server`](https://github.com/redhat-developer/yaml-language-server) |
| `vscode-json-languageserver` | JSON | [`microsoft/vscode`](https://github.com/microsoft/vscode/tree/main/extensions/json-language-features/server) |
| `marksman` | Markdown | [`artempyanykh/marksman`](https://github.com/artempyanykh/marksman) |
| `clangd` | C/C++ | [`llvm/llvm-project`](https://github.com/llvm/llvm-project/tree/main/clang-tools-extra/clangd) |
| `taplo` | TOML | [`tamasfe/taplo`](https://github.com/tamasfe/taplo) |
| `bash-language-server` | Bash/Shell | [`bash-lsp/bash-language-server`](https://github.com/bash-lsp/bash-language-server) |

## How It Works

### Automatic Detection

All linters and LSP servers are **optional**. The configuration automatically:

1. Checks if the tool binary exists in PATH
2. Enables the backend only if the tool is available
3. Silently skips tools that aren't installed

No configuration changes are needed - just install the tools you want to use.

### Dual Backend Pattern

Languages with dual backends (YAML, JSON, Markdown) run both linters simultaneously:

- **Standalone linter** checks syntax and style rules
- **LSP server** provides semantic analysis and additional features (like schema validation)

Both backends report diagnostics together in the same buffer, giving you the most comprehensive feedback.

### Local and Remote Files

The configuration works seamlessly with both local and remote files:

- **Local files**: Tools run on your local machine
- **Remote files** (via TRAMP/SSH): LSP servers run on the remote host
- PATH is checked appropriately for each environment

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#lsp-and-tool-executable-issues) for details on PATH configuration.

## Checking Active Backends

### View Running Backends

To see which diagnostics backends are active in the current buffer:

```
M-x flymake-running-backends
```

This shows all active Flymake diagnostic sources.

### View Diagnostics

Press `F1` to toggle the Flymake diagnostics window showing all errors and warnings.

### Navigate Errors

- `F2` - Jump to previous diagnostic
- `F3` - Jump to next diagnostic
- `M-g n` - Jump to next diagnostic (alternative)
- `M-g p` - Jump to previous diagnostic (alternative)

See [KEYMAP.md](KEYMAP.md#diagnostic-and-error-checking) for complete keybinding reference.

## Customization

### Adding New Languages

To add LSP support for additional languages, add to your `local.el`:

```elisp
;; Example: Add Rust LSP support
(with-eval-after-load 'eglot-registry
  (setq features-eglot-lsp-server-registry
        (append features-eglot-lsp-server-registry
                (list (eglot-registry-create-server
                       'rust-analyzer
                       "Rust Language Server"
                       '(rust-mode rust-ts-mode)
                       :binary "rust-analyzer"
                       :priority 100
                       :url "https://rust-analyzer.github.io/")))))
```

The LSP server will automatically activate when the binary is found in PATH.

### Disabling Backends

To disable specific backends, you can remove them from the mode hooks in your `local.el`:

```elisp
;; Example: Disable `yamllint` for YAML files
(remove-hook 'yaml-mode-hook 'yaml-setup-common)
```

## Troubleshooting

### Tool Not Found

If a linter or LSP server isn't working:

1. **Verify the tool is installed**:
   ```bash
   which yamllint
   which pylsp
   ```

2. **Check PATH configuration**:
   - Ensure `~/.local/bin` is in your PATH for pip-installed tools
   - For remote files, check PATH on the remote host

3. **Check Messages buffer**:
   - Look for "LSP command found" or "not found" messages
   - Open with `M-x view-messages`

### LSP Connection Issues

If LSP isn't connecting:

1. **Check the `*eglot-events*` buffer** for detailed LSP communication logs
2. **Verify LSP server is executable** on the target host (local or remote)
3. **Check timeout settings** in [features/eglot/eglot-constants.el](features/eglot/eglot-constants.el)

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#lsp-and-tool-executable-issues) for detailed troubleshooting steps.

## Adding New Language Support

To add Flymake and LSP support for a new language, follow this standard pattern:

### 1. Create Language Config File

Create `lang/{language}/{language}-config.el` following the standard structure:

```elisp
;;; language-config.el --- Language Mode Configuration -*- lexical-binding: t -*-
;;; Commentary:
;; Description of language support

;;; Code:
(require 'core-utils)
(require 'core-logging)
(require 'lang-utils')
(require 'flymake-lang-setup)

;; Define setup function(s)
(defun language-setup-common ()
  "Common setup for language-mode."
  (lang-setup-full 'language-indent-offset 2)
  ;; Choose ONE of the backend setup functions below
  )

;; Register mode hooks
(add-hook 'language-mode-hook 'language-setup-common)

;; Log configuration loaded
(core-message-lang-loaded "Language" "language-mode")
(provide 'language-config)
;;; language-config.el ends here
```

### 2. Register Backend (if using standalone linter)

Add entry to `features/flymake/flymake-registry.el`:

```elisp
(defconst flymake-backend-registry
  '(...
    (flymake-collection-linter
     "Linter Name"
     (language-mode language-ts-mode)
     :abbreviation "f-c-l"
     :type direct
     :binary "linter-binary")
    ...))
```

**Required properties:**
- `:abbreviation` - Short identifier for diagnostics buffer (e.g., "f-c-l")
- `:type` - Backend type: `direct`, `loader-based`, or `lsp`
- `:binary` - Expected binary name for validation (e.g., "yamllint")

### 3. Choose Backend Setup Function

Select the appropriate backend setup based on available tools.
Binary names are automatically looked up from the registry.

#### Option A: Standalone linter only
```elisp
(flymake-lang-setup-direct-backend 'flymake-collection-linter)
```
**Use when:** Language has a standalone linter but no LSP server

#### Option B: Package with -load function
```elisp
(flymake-lang-setup-package-loader 'flymake-tool-load)
```
**Use when:** Flymake package provides a `-load` function that handles setup

#### Option C: LSP diagnostics only
```elisp
(flymake-lang-setup-lsp-backend)
```
**Use when:** Language only has LSP server diagnostics (no standalone linter)

#### Option D: Both linter and LSP (dual backend)
```elisp
(flymake-lang-setup-dual-backend 'flymake-collection-linter)
```
**Use when:** Both standalone linter and LSP provide complementary value

### 4. Configure LSP Server (if using LSP)

Add entry to `features/eglot/eglot-registry.el`:

```elisp
(eglot-registry-create-server
 'lsp-server-symbol
 "Language Name Language Server"
 '(language-mode language-ts-mode)
 :binary "lsp-server-binary"
 :priority 100
 :url "https://github.com/project/lsp-server")
```

Add this entry to the `features-eglot-lsp-server-registry` list constant.

### 5. Update Documentation

Add language to the table in this file (LINTING.md) under [Language Support](#language-support).

### Backend Function Selection Guide

The `flymake-lang-setup-dual-backend` function automatically detects function type:
- Functions ending with `-load` → treated as package loaders
- All other functions → treated as direct backends

**Direct backends** get eglot hook to persist after eglot starts.
**Package loaders** do NOT get eglot hook (they manage persistence internally).

For more details, see the decision tree documentation in `features/flymake/flymake-lang-setup.el`.

## Related Documentation

- [FEATURES.md](FEATURES.md) - Complete feature list including language support details
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Detailed troubleshooting for PATH and tool installation
- [KEYMAP.md](KEYMAP.md) - Keybindings for diagnostics navigation
- [README.md](README.md) - Project overview and installation
