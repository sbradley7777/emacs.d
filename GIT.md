# Git Integration Guide

This guide covers the setup and usage of Git integration in Emacs using Magit and Forge.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
  - [Step 1: Configure Forge Hosts](#step-1-configure-forge-hosts-gitconfig)
  - [Step 2: Create Access Tokens](#step-2-create-access-tokens)
  - [Step 3: Configure Authentication](#step-3-configure-authentication-authinfo)
  - [Step 4: Verify Setup](#step-4-verify-setup)
- [Automatic Features](#automatic-features)
- [Usage](#usage)
  - [Basic Magit Workflows](#basic-magit-workflows)
  - [Forge Operations](#forge-operations)
  - [Keybindings](#keybindings)
- [Advanced Configuration](#advanced-configuration)
- [Troubleshooting](#troubleshooting)

## Overview

This configuration provides comprehensive Git integration through two main packages:

**Magit** - A complete Git porcelain within Emacs:
- Visual interface for Git operations (commit, branch, merge, rebase, etc.)
- Interactive staging and unstaging
- Commit history browsing
- Branch management
- Advanced Git operations

**Forge** - Work with Git forges (GitHub, GitLab, etc.) from within Magit:
- Browse and create issues
- Manage pull requests
- View and comment on code reviews
- Fetch repository data (issues, PRs, notifications)
- Markdown rendering with clickable links

### Configuration Architecture

All forge hosts are configured via `~/.gitconfig` for centralized management. This eliminates dependency on CLI tools like `gh` or `glab` and provides a unified configuration interface.

**Automatic username configuration**: When you open a file in a git repository, the forge username is automatically set in the repository-local `.git/config` file, ensuring clean per-repository configuration.

## Quick Start

For GitHub.com users who want to get started quickly:

### 1. Add GitHub configuration to `~/.gitconfig`:

```ini
[emacs-forge "github.com"]
    apihost = api.github.com
    webhost = github.com
    type = github
    user = YOUR_GITHUB_USERNAME
```

### 2. Create a GitHub personal access token:

- Visit: https://github.com/settings/tokens
- Click "Generate new token (classic)"
- Required scopes: `repo`, `user`, `read:org`
- Copy the generated token

### 3. Add credentials to `~/.authinfo`:

```bash
echo "machine api.github.com login YOUR_GITHUB_USERNAME^forge password YOUR_TOKEN" >> ~/.authinfo
chmod 600 ~/.authinfo
```

**Important**: The `^forge` suffix is required by the Forge package.

### 4. Restart Emacs or reload configuration:

```elisp
M-x forge-gitconfig-populate-forge-alist-from-gitconfig
```

### 5. Test it:

Open a file in a GitHub repository and run:
```elisp
M-x magit-status    ; View repository status
M-x forge-pull      ; Fetch issues and PRs
```

## Detailed Setup

### Step 1: Configure Forge Hosts (`~/.gitconfig`)

Add forge host configurations to your `~/.gitconfig` file. Each forge requires four pieces of information:

#### Configuration Format

```ini
[emacs-forge "HOSTNAME"]
    apihost = API_HOST_URL
    webhost = WEB_HOST_URL
    type = FORGE_TYPE
    user = YOUR_USERNAME
```

**Field Descriptions:**
- `HOSTNAME` - The git host (e.g., `github.com`, `gitlab.example.com`)
- `apihost` - API endpoint URL
- `webhost` - Web interface URL
- `type` - Forge type: `github`, `gitlab`, `gitea`, `gogs`, or `bitbucket`
- `user` - Your username on this forge

#### GitHub (Public)

```ini
[emacs-forge "github.com"]
    apihost = api.github.com
    webhost = github.com
    type = github
    user = YOUR_USERNAME
```

#### GitHub Enterprise

```ini
[emacs-forge "github.enterprise.example"]
    apihost = github.enterprise.example/api/v3
    webhost = github.enterprise.example
    type = github
    user = YOUR_USERNAME
```

#### GitLab (Public)

```ini
[emacs-forge "gitlab.com"]
    apihost = gitlab.com/api/v4
    webhost = gitlab.com
    type = gitlab
    user = YOUR_USERNAME
```

#### GitLab (Self-Hosted)

```ini
[emacs-forge "gitlab.example.com"]
    apihost = gitlab.example.com/api/v4
    webhost = gitlab.example.com
    type = gitlab
    user = YOUR_USERNAME
```

#### Other Forges

For Gitea, Gogs, and Bitbucket, use the same pattern with appropriate API paths and type values.

### Step 2: Create Access Tokens

Each forge requires a personal access token for API authentication.

#### GitHub

**URL**: https://github.com/settings/tokens (or `https://YOUR_GITHUB_ENTERPRISE/settings/tokens`)

**Steps**:
1. Click "Generate new token (classic)"
2. Add a descriptive note (e.g., "Emacs Forge")
3. Select scopes:
   - `repo` - Full control of private repositories
   - `user` - Read user profile data
   - `read:org` - Read organization data
4. Click "Generate token"
5. **Copy the token immediately** (you won't see it again)

**Required Scopes**: `repo`, `user`, `read:org`

#### GitLab

**URL**: https://gitlab.com/-/profile/personal_access_tokens (or `https://YOUR_GITLAB_INSTANCE/-/profile/personal_access_tokens`)

**Steps**:
1. Enter token name (e.g., "Emacs Forge")
2. Set expiration date (optional but recommended)
3. Select scopes:
   - `api` - Access API
   - `read_api` - Read API
   - `read_user` - Read user information
4. Click "Create personal access token"
5. **Copy the token immediately**

**Required Scopes**: `api`, `read_api`, `read_user`

#### Security Best Practices

- Use tokens with minimal necessary permissions
- Set expiration dates for tokens
- Rotate tokens periodically
- Never commit tokens to version control
- Use separate tokens for different machines/purposes

### Step 3: Configure Authentication (`~/.authinfo`)

Forge reads authentication credentials from `~/.authinfo` ([`features/forge/forge-authinfo.el`](features/forge/forge-authinfo.el)).

#### Format

```
machine APIHOST login USERNAME^forge password TOKEN
```

**Important**:
- The `^forge` suffix on the username is **required**
- `APIHOST` must match the `apihost` value from your `~/.gitconfig`
- File must have secure permissions (600)

#### Manual Method

Add entries manually to `~/.authinfo`:

```bash
# GitHub
echo "machine api.github.com login YOUR_USERNAME^forge password YOUR_GITHUB_TOKEN" >> ~/.authinfo

# GitLab
echo "machine gitlab.com/api/v4 login YOUR_USERNAME^forge password YOUR_GITLAB_TOKEN" >> ~/.authinfo

# Set secure permissions
chmod 600 ~/.authinfo
```

#### Automatic Method (Recommended)

Use the interactive authinfo generator to create entries automatically:

```elisp
M-x forge-authinfo-generate-entries
```

**How it works**:
1. Reads all `[emacs-forge]` sections from `~/.gitconfig`
2. Checks which hosts are missing credentials in `~/.authinfo`
3. Prompts for tokens for each missing host
4. Automatically appends entries to `~/.authinfo`
5. Sets correct file permissions (600)

**Benefits**:
- Correct format guaranteed
- Automatic `^forge` suffix addition
- Prevents duplicate entries
- Secure file permissions

#### File Permissions

The `~/.authinfo` file must have restrictive permissions:

```bash
chmod 600 ~/.authinfo
```

If permissions are incorrect, you may see authentication errors.

### Step 4: Verify Setup

#### Check Configuration Loaded

After adding hosts to `~/.gitconfig`, restart Emacs or run:

```elisp
M-x forge-gitconfig-populate-forge-alist-from-gitconfig
```

You should see messages indicating forge hosts were added.

#### Test Forge Pull

1. Open a file in a git repository tracked by one of your configured forges
2. Run: `M-x magit-status` (or press your configured keybinding)
3. Press `N r` or run: `M-x forge-pull`

**Expected behavior**:
- First time: Creates local database, fetches issues/PRs (may take a moment)
- Subsequent times: Updates with latest data from forge

#### Common Success Indicators

- No authentication errors
- Issues and PRs appear in Magit status buffer
- Forge data stored in `~/.emacs.d/local/forge-database.sqlite`

#### Initial Setup Tips

- **First run takes time**: Initial `forge-pull` downloads all repository data
- **Database location**: `~/.emacs.d/local/forge-database.sqlite`
- **Force refresh**: Delete database file to start fresh (you'll need to re-run `forge-pull`)

## Automatic Features

### Repository-Local Username Configuration

When you open any file in a git repository, the configuration automatically ([`features/git/git-forge-config.el`](features/git/git-forge-config.el)):

1. **Detects the repository's forge host** from `remote.origin.url`
2. **Looks up the username** from the matching `[emacs-forge]` section in `~/.gitconfig`
3. **Sets the username** in the repository-local `.git/config`
4. **Only configures the relevant host** for this specific repository

**Example**:

Repository: `git@gitlab.example.com:team/project.git`

Automatically adds to `.git/config`:
```ini
[gitlab "gitlab.example.com/api/v4"]
    user = YOUR_USERNAME
```

**Benefits**:
- No manual per-repository configuration needed
- Clean `.git/config` files (only relevant hosts configured)
- Works automatically via `find-file-hook`
- Backup safety check before `forge-pull` operations

**How It Works**:

The `forge-gitconfig-setup-repo-on-file-open` function runs on `find-file-hook`:
- Checks if you're in a git repository
- Loads Magit if not already loaded
- Determines the forge host from remote URL
- Configures username if not already set

**Manual Trigger** (rarely needed):
```elisp
M-x forge-gitconfig-set-repo-username
```

## Usage

### Automatic Synchronization

The configuration automatically synchronizes Git and Forge data when you open files in a repository ([`features/git/git-sync.el`](features/git/git-sync.el)).

#### How Automatic Sync Works

**When you open any file in a git repository:**
1. The configuration detects if this repository has been synced this session
2. If not synced yet, it automatically:
   - Fetches Git refs (branches, tags, commits) via `magit-fetch-all`
   - Pulls Forge data (issues, PRs, comments) via Forge API
3. Marks the repository as synced for this session
4. Subsequent file opens in the same repository skip the sync

**Messages you'll see:**
```
ℹ️  Initiated sync for repository: ~/project-name
ℹ️  Fetching Git data for: ~/project-name
ℹ️  Fetching Forge data for: ~/project-name
✅  Forge data fetched for: ~/project-name
```

**Note**: Magit fetch runs in the background and shows progress in the modeline ("Fetching..." → "Fetching...done").

#### Manual Synchronization

**Trigger sync on demand:**
```elisp
M-x git-sync-repository
```

Use this when:
- You want to refresh Git and Forge data during your session
- You've made changes in another client (web UI, git command line)
- You want to check for new issues or PRs without opening a new file

**Benefits:**
- **Always up-to-date** - Start working with latest Git refs and Forge data
- **No manual fetching** - Automatic background updates
- **Network efficient** - Only syncs once per repository per session
- **Non-blocking** - Continue working while sync happens in background

### Basic Magit Workflows

#### View Repository Status

```elisp
M-x magit-status
```

Opens the Magit status buffer showing:
- Current branch
- Uncommitted changes (staged/unstaged)
- Recent commits
- Stashes
- Unpushed/unpulled commits

#### Common Magit Operations

In the Magit status buffer:
- `s` - Stage file/hunk under cursor
- `u` - Unstage file/hunk under cursor
- `c c` - Create commit (opens commit message buffer)
- `P p` - Push to remote
- `F p` - Pull from remote
- `b b` - Switch branch
- `b c` - Create new branch
- `l l` - View commit log
- `d d` - View diff

#### Staging and Committing

1. **Stage changes**: Navigate to a file/hunk and press `s`
2. **Review staged changes**: Press `TAB` to expand/collapse diffs
3. **Commit**: Press `c c`, write message, press `C-c C-c` to commit
4. **Push**: Press `P p` to push to remote

### Forge Operations

#### Fetch Issues and Pull Requests

```elisp
M-x forge-pull
```

Or in Magit status buffer: `N r`

Downloads latest issues, PRs, and other forge data to local database.

#### List Issues

```elisp
M-x user-git-issues
```

Or press the configured keybinding (e.g., `F10`).

**Features** ([`features/git/git-utils.el`](features/git/git-utils.el)):
- Opens issues list in side window (30% width by default)
- Press again to toggle width (30% → 50% → 30%)
- Navigate with `n`/`p`, press `RET` to open issue
- Press `q` to close window

#### Browse Issues and Pull Requests

In the Magit status buffer:
- `N l i` - List issues
- `N l p` - List pull requests
- `N c i` - Create new issue
- `N c p` - Create new pull request

#### View and Edit Issues

1. Navigate to an issue in the list
2. Press `RET` to open
3. View rendered markdown with clickable links (GUI mode)
4. Edit, comment, or close issues

#### Markdown Rendering

Issues and PRs display with ([`features/forge/forge-markdown.el`](features/forge/forge-markdown.el)):
- **Syntax highlighting** for code blocks
- **Clickable links** (GUI mode only)
- **Formatted headers, lists, and emphasis**
- **Word wrapping** for readability

### Keybindings

For a complete list of keybindings, see [`KEYMAP.md`](KEYMAP.md).

**Magit Status**:
- Access via `M-x magit-status` or configured keybinding

**Forge Operations** (in Magit status buffer):
- `N r` - Forge pull (fetch data)
- `N l i` - List issues
- `N l p` - List pull requests
- `N c i` - Create issue
- `N c p` - Create pull request

**Custom Commands**:
- `F10` - Toggle issues window (`user-git-issues`)

## Advanced Configuration

### Multiple Forge Instances

You can configure multiple forge instances in `~/.gitconfig`:

```ini
[emacs-forge "github.com"]
    apihost = api.github.com
    webhost = github.com
    type = github
    user = personal-username

[emacs-forge "github.enterprise.work"]
    apihost = github.enterprise.work/api/v3
    webhost = github.enterprise.work
    type = github
    user = work-username

[emacs-forge "gitlab.com"]
    apihost = gitlab.com/api/v4
    webhost = gitlab.com
    type = gitlab
    user = gitlab-username
```

Each requires a corresponding entry in `~/.authinfo`.

### Custom Display Settings

#### Magit Window Width

The default side window width is controlled by `features-side-window-compact-width` in [`features/features-constants.el`](features/features-constants.el).

To customize, add to your `local.el`:

```elisp
(setq features-side-window-compact-width 0.4)  ; 40% of frame width
```

#### Issues Window Toggle Widths

The `user-git-issues` command toggles between 30% and 50% width by default. To customize, modify the function in [`features/git/git-utils.el`](features/git/git-utils.el).

### Automatic Configuration Functions

These functions are called automatically but can be invoked manually if needed:

```elisp
;; Populate forge-alist from ~/.gitconfig
M-x git-forge-config-populate-forge-alist-from-gitconfig

;; Set username in current repository's .git/config
M-x git-forge-config-set-repo-username

;; Generate ~/.authinfo entries interactively
M-x forge-authinfo-generate-entries
```

## Troubleshooting

### Authentication Errors

**Symptom**: "Authentication failed" or "Invalid credentials" errors

**Solutions**:
1. Verify `~/.authinfo` has correct format:
   - Username has `^forge` suffix
   - APIHOST matches `~/.gitconfig` exactly
   - File permissions are 600
2. Check token is still valid (not expired or revoked)
3. Verify token has required scopes
4. Ensure no extra whitespace in `~/.authinfo` entries

**Test authentication**:
```bash
# Check file permissions
ls -la ~/.authinfo

# Verify format (should show 600 or -rw-------)
cat ~/.authinfo  # Review entries (be careful with tokens visible)
```

### Forge Host Not Found

**Symptom**: "No forge repository found" or similar errors

**Solutions**:
1. Verify `[emacs-forge]` section exists in `~/.gitconfig`
2. Check section name matches repository's git host exactly
3. Run: `M-x git-forge-config-populate-forge-alist-from-gitconfig`
4. Restart Emacs if configuration was just added

**Check forge-alist**:
```elisp
M-: forge-alist  ; View currently configured forge hosts
```

### Username Not Set in Repository

**Symptom**: Prompted for username when running `forge-pull`

**Solutions**:
1. Check `~/.gitconfig` has `user = YOUR_USERNAME` in `[emacs-forge]` section
2. Manually trigger: `M-x git-forge-config-set-repo-username`
3. Verify repository has `remote.origin.url` configured:
   ```bash
   git config remote.origin.url
   ```

### First Forge Pull Fails

**Symptom**: Error on first `forge-pull` in a repository

**Solutions**:
1. Ensure repository is tracked by forge:
   ```elisp
   M-x forge-add-repository
   ```
2. Check repository URL matches a configured forge host
3. Verify network connectivity to forge
4. Check token permissions include `repo` access

### Database Issues

**Symptom**: Stale data, corrupted database, or persistent errors

**Solutions**:
1. Delete forge database and re-fetch:
   ```bash
   rm ~/.emacs.d/local/forge-database.sqlite
   ```
2. Re-run `forge-pull` in your repository
3. Check disk space in `~/.emacs.d/local/`

### Network and Proxy Issues

**Symptom**: Connection timeouts or network errors

**Solutions**:
1. Check network connectivity:
   ```bash
   curl -I https://api.github.com
   ```
2. Configure proxy if needed (in `~/.gitconfig`):
   ```ini
   [http]
       proxy = http://proxy.example.com:8080
   ```
3. Verify firewall allows HTTPS to forge hosts

### GUI vs Terminal Mode Differences

**Symptom**: Missing clickable links or rendering issues

**Note**: Clickable link support in forge markdown rendering is only available in GUI mode. Terminal mode shows plain text with formatting but without interactive links.

**Workaround**: Use GUI Emacs for full forge markdown rendering, or manually copy/paste URLs from terminal.

### gitconfig Lock Errors

**Symptom**: "could not lock config file ~/.gitconfig: File exists"

**Solutions**:
1. Check for stale lock file:
   ```bash
   ls -la ~/.gitconfig.lock
   ```
2. Remove if stale:
   ```bash
   rm ~/.gitconfig.lock
   ```
3. Ensure no other git processes are running

### Getting More Help

For issues not covered here:
- Check [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) for general Emacs configuration issues
- Check [`FAQ.md`](FAQ.md) for frequently asked questions
- Review the [Forge manual](https://magit.vc/manual/forge.html)
- Review the [Magit manual](https://magit.vc/manual/magit.html)
- Check forge host configuration in [`features/git/git-config.el`](features/git/git-config.el) and [`features/git/git-forge-config.el`](features/git/git-forge-config.el) (inline documentation)

### Enable Debug Messages

To see detailed forge operations:
```elisp
(setq forge-debug t)
```

Messages will appear in the `*Messages*` buffer.
