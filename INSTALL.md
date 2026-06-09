# Installation Guide — Fresh macOS Setup

Step-by-step setup for this Emacs configuration on a fresh macOS machine.
For Linux or other platforms, adapt the package manager commands accordingly.

## Prerequisites

- **macOS** with [Homebrew](https://brew.sh) installed
- **Emacs 30.2+** installed via Homebrew (`brew install emacs`)
- **iTerm2** (recommended terminal — sets `COLORTERM=truecolor` automatically)

> See [README.md](README.md) for Emacs version requirements and why 30.2+ is required.

---

## Step 1 — Clone and Install Config Files

Follow the instructions in [README.md](README.md#installation) or [scripts/README.md](scripts/README.md)
to clone the repository and run the installer.

The development (symlink) install is recommended:

```bash
git clone <your-repository-url> ~/github/emacs.d
cd ~/github/emacs.d
chmod +x scripts/install.sh
./scripts/install.sh
```

---

## Step 2 — Homebrew Tools

Install system tools that back the Flymake and Eglot integrations:

```bash
brew install aspell shellcheck marksman taplo
```

| Tool | Purpose |
|---|---|
| `aspell` | Spell checking (flymake-aspell) |
| `shellcheck` | Bash/shell script linting |
| `marksman` | Markdown LSP server |
| `taplo` | TOML LSP server |

`clangd` for C/C++ LSP comes with the Xcode command-line tools
(`xcode-select --install`), which Homebrew typically installs as a dependency.

---

## Step 3 — Python Tools

Homebrew Python enforces [PEP 668](https://peps.python.org/pep-0668/) and
blocks `pip install --user`. Use [pipx](https://pipx.pypa.io/) instead — it
manages an isolated venv per tool and places the binary in `~/.local/bin`.

```bash
brew install pipx
pipx ensurepath
```

Then install the Python tools:

```bash
pipx install python-lsp-server
pipx inject python-lsp-server python-lsp-ruff
pipx install ruff
pipx install yamllint
```

| Tool | Purpose |
|---|---|
| `python-lsp-server` (pylsp) | Python LSP server |
| `python-lsp-ruff` | Ruff plugin for pylsp (must be injected, not installed separately) |
| `ruff` | Python linting via Flymake |
| `yamllint` | YAML standalone linter |

**Note:** `pipx inject` adds `python-lsp-ruff` into the pylsp venv so it can
act as a plugin. Installing it as a separate `pipx install` will not work.

Ensure `~/.local/bin` is in your PATH (added automatically by `pipx ensurepath`):

```bash
echo $PATH | grep -o '\S*local/bin\S*'
```

---

## Step 4 — Node.js Tools (Optional)

Several dual-backend linters require npm. These are optional — the config
silently skips any tool that is not installed.

| Tool | Purpose | Install |
|---|---|---|
| `yaml-language-server` | YAML LSP | `npm install -g yaml-language-server` |
| `vscode-langservers-extracted` | JSON LSP | `npm install -g vscode-langservers-extracted` |
| `markdownlint-cli` | Markdown linting | `npm install -g markdownlint-cli` |

> **Note:** The `markdownlint-cli` package provides the `markdownlint` binary
> that the Flymake registry expects. The Ruby `mdl` gem listed in some
> references uses a different binary name and will not be detected.

If you skip npm, marksman (Step 2) still provides Markdown LSP support.

---

## Step 5 — Tree-sitter Grammars

Tree-sitter grammars must be compiled and installed from inside Emacs.
Run this command once after the first startup:

```
M-x treesit-auto-install-all
```

This installs all grammars that `treesit-auto` knows about (60+ languages) into
`~/.emacs.d/local/tree-sitter/`. It takes a few minutes on first run.

Alternatively, grammars install automatically the first time you open a file
of that type — `treesit-auto` will prompt or install silently depending on your
settings.

---

## Step 6 — iTerm2 Terminal Setup

### True Color (COLORTERM)

iTerm2 sets `COLORTERM=truecolor` automatically for every session. No shell
profile change is needed when using iTerm2.

If you use a different terminal, add this to `~/.bashrc` or `~/.zshrc`:

```bash
export COLORTERM=truecolor
```

For SSH sessions, this must also be set on the **remote host's** shell config.

### Nerd Font Icons

The config installs `NFM.ttf` (Symbols Nerd Font Mono) automatically to
`~/Library/Fonts/` on startup. It is a symbols-only font — no text characters
— so it must be configured as a secondary non-ASCII font alongside your
preferred coding font.

**iTerm2 setup:**

1. iTerm2 → Settings → Profiles → Text
2. Leave **Font** as your preferred coding font (Monaco, Menlo, etc.)
3. Check **"Use a different font for non-ASCII text"**
4. Set the second font to **"Symbols Nerd Font Mono"**

This gives normal text via your preferred font and Nerd Font icons (treemacs,
modeline, dashboard) via the symbols font.

---

## Step 7 — Forge Authentication (GitHub / GitLab)

Required for Forge to fetch issues and pull requests. Magit works without it.

See [GIT.md](GIT.md) for the complete setup including:
- Adding `[emacs-forge]` sections to `~/.gitconfig`
- Creating a personal access token
- Writing credentials to `~/.authinfo`

---

## Step 8 — Verify

Run the test script to confirm all modules load successfully:

```bash
~/github/emacs.d/scripts/test-config.sh
```

Then start Emacs and check the startup log for errors:

```
M-x view-messages
```

Or open the log file directly at `~/.emacs.d/local/log/messages.log`.

A clean startup shows `65 successful, 0 failed` in the configuration loading
summary. Any `❌` entries indicate a module that failed to load.

---

## Reference

| Document | Purpose |
|---|---|
| [README.md](README.md) | Project overview and config file structure |
| [LINTING.md](LINTING.md) | Full linting tool reference and architecture |
| [GIT.md](GIT.md) | Magit and Forge setup |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Common errors and fixes |
| [KEYMAP.md](KEYMAP.md) | Keybinding reference |
