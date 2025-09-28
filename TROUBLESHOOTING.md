# Troubleshooting Guide

This guide helps resolve common issues you may encounter while using this Emacs configuration.

## Table of Contents

- [Emacs Version Requirements](#emacs-version-requirements)
- [Auto-completion Issues](#auto-completion-issues)
- [Virtual Environment Issues](#virtual-environment-issues)
- [Font and Icon Issues](#font-and-icon-issues)
- [Treemacs Navigation Issues](#treemacs-navigation-issues)
- [Message Logging Issues](#message-logging-issues)
- [Installation Problems](#installation-problems)
- [Performance Issues](#performance-issues)
- [Package Management Issues](#package-management-issues)
- [Configuration Loading Problems](#configuration-loading-problems)
- [Related Documentation](#related-documentation)

## Emacs Version Requirements

**⚠️ FIRST STEP: Verify your Emacs version before troubleshooting anything else.**

This configuration requires **Emacs 30.2 or later** and will not work with earlier versions. This is the only version tested, and using previous versions of Emacs will trigger errors, warnings, fail to load modules or packages, or fail to load the configuration entirely.

### Check Your Emacs Version

**Before troubleshooting any issues, verify you're running Emacs 30.2+:**

```bash
# Check Emacs version from command line
emacs --version

# Or from within Emacs
M-x emacs-version
```

**Expected output:** Should show `GNU Emacs 30.2` or higher.

### Common Version-Related Problems

**Symptoms of using an incompatible Emacs version:**
- Configuration fails to load completely
- Error messages during startup about missing functions or features
- Packages fail to install or load properly
- Modern features like LSP, completion, or diagnostics don't work
- Warning messages about deprecated or unavailable functionality

**Solution:** Upgrade to Emacs 30.2 or later. This configuration is designed exclusively for modern Emacs and utilizes features only available in Emacs 30.2+.

## Auto-completion Issues

### Completion Not Working

**Symptoms**: No completion suggestions appear when typing

**Troubleshooting Steps**:
1. **Test manual completion**: Use `M-x completion-at-point` to verify completions are available
2. **Try different triggers**: Test various completion keybindings:
   - `TAB` - Smart completion (complete when possible, indent otherwise)
   - `C-c TAB` - Manual completion trigger (reliable in all environments)
   - `M-TAB` - Traditional Alt+TAB completion
   - `C-M-i` - Traditional Ctrl+Alt+i completion
3. **Check mode**: Ensure you're in the correct major mode (e.g., `python-mode` for Python files)
4. **Restart completion**: `M-x global-corfu-mode` to toggle completion framework

### Completion Too Slow

**Symptoms**: Long delays before completion suggestions appear

**Solutions**:
1. **Verify virtual environment**: Ensure correct Python environment is active
2. **Check system resources**: High CPU/memory usage may impact performance

## Virtual Environment Issues

### Virtual Environment Not Detected

**Symptoms**: No `[venv: project-name]` in modeline, wrong Python interpreter

**Troubleshooting**:
1. **Check project structure**: Ensure your project has one of these files in the root:
   - `.git/` directory (Git repository)
   - `pyproject.toml` file
   - `requirements.txt` file

2. **Verify venv location**: Virtual environment should be in `project-root/venv/`

3. **Manual activation**: Try `M-x pyvenv-activate` and select your virtual environment

4. **Check venv validity**: Ensure the virtual environment is properly created:
   ```bash
   # Test virtual environment
   source venv/bin/activate
   python --version
   which python
   ```

### Wrong Python Version Displayed

**Symptoms**: Modeline shows incorrect Python interpreter version

**Solutions**:
1. **Refresh environment**: Deactivate and reactivate the virtual environment:
   - `M-x pyvenv-deactivate`
   - `M-x pyvenv-activate`
2. **Check venv Python**: Verify the virtual environment's Python interpreter:
   ```bash
   venv/bin/python --version
   ```
3. **Force modeline update**: `M-x force-mode-line-update`

### Virtual Environment Activation Fails

**Symptoms**: Error messages when trying to activate virtual environment

**Common Causes and Solutions**:
1. **Corrupted virtual environment**: Recreate the virtual environment:
   ```bash
   rm -rf venv
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Permission issues**: Check directory permissions
3. **Path issues**: Ensure virtual environment path doesn't contain spaces or special characters

## Font and Icon Issues

### Icons Not Displaying Properly

**Symptoms**: Boxes, question marks, or missing icons in GUI or terminal mode

**Troubleshooting Steps**:
1. **Check font installation**: Verify fonts are installed in system directory:
   ```bash
   # Linux
   ls ~/.local/share/fonts/ | grep -E '(all-the-icons|NFM)'

   # macOS
   ls ~/Library/Fonts/ | grep -E '(all-the-icons|NFM)'
   ```

2. **Force font installation**: Manually trigger font installation:
   ```elisp
   M-x all-the-icons-install-fonts
   M-x nerd-icons-install-fonts
   ```

3. **Check terminal configuration**: For terminal mode, ensure your terminal uses a Nerd Font:
   - Install a Nerd Font (e.g., "Hack Nerd Font", "FiraCode Nerd Font")
   - Configure your terminal to use the Nerd Font
   - Restart your terminal application

4. **Restart applications**: After font installation, restart:
   - Emacs (to reload font cache)
   - Terminal application (to recognize new fonts)
   - Font cache system: `fc-cache -fv` (Linux)

### Font Installation Fails

**Symptoms**: Error messages during automatic font installation

**Solutions**:
1. **Check directory permissions**: Ensure font directory is writable:
   ```bash
   # Linux
   mkdir -p ~/.local/share/fonts
   chmod 755 ~/.local/share/fonts

   # macOS
   mkdir -p ~/Library/Fonts
   chmod 755 ~/Library/Fonts
   ```

2. **Manual font installation**: Download fonts manually:
   - Visit [all-the-icons fonts](https://github.com/domtronn/all-the-icons.el/tree/master/fonts)
   - Visit [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
   - Copy `.ttf` files to your system font directory

3. **Network issues**: Check internet connectivity for font downloads

### GUI vs Terminal Icon Differences

**Symptoms**: Icons work in GUI but not terminal, or vice versa

**Explanation**: This is expected behavior:
- **GUI mode**: Uses `all-the-icons` theme with graphical icons
- **Terminal mode**: Uses `Default` theme with text-based symbols

**Solutions**:
1. **For better terminal icons**: Install and configure a Nerd Font in your terminal
2. **For GUI consistency**: Ensure `all-the-icons` fonts are properly installed
3. **Theme troubleshooting**: Check which theme is loaded:
   ```elisp
   M-x describe-variable treemacs-theme
   ```

## Treemacs Navigation Issues

### Treemacs Sidebar Not Opening

**Symptoms**: F5 key doesn't open Treemacs, or "Treemacs not available" message

**Troubleshooting Steps**:
1. **Check package installation**: Verify Treemacs packages are installed:
   ```elisp
   M-x package-list-packages
   ```
   Look for: `treemacs`, `treemacs-all-the-icons`, `treemacs-icons-dired`

2. **Manual package installation**: Install missing packages:
   ```elisp
   M-x package-install RET treemacs
   M-x package-install RET treemacs-all-the-icons
   ```

3. **Force load Treemacs**: Manually load the configuration:
   ```elisp
   M-x require RET treemacs-config
   ```

4. **Check function binding**: Verify F5 is bound correctly:
   ```elisp
   M-x describe-key RET F5
   ```

### Treemacs Icons Missing or Corrupted

**Symptoms**: File tree shows text symbols instead of icons in GUI mode

**Solutions**:
1. **Check icon theme**: Verify current theme:
   ```elisp
   M-x describe-variable treemacs-theme
   ```

2. **Reinstall fonts**: See [Font and Icon Issues](#font-and-icon-issues) section

3. **Force theme reload**: Manually set icon theme:
   ```elisp
   M-x treemacs-load-theme RET all-the-icons
   ```

4. **Fallback to default**: Use text-based theme if icons don't work:
   ```elisp
   M-x treemacs-load-theme RET Default
   ```

### Treemacs Performance Issues

**Symptoms**: Slow file tree updates, laggy navigation

**Solutions**:
1. **Check project size**: Large projects with many files may be slow
2. **Disable file watching**: Temporarily disable for large projects:
   ```elisp
   M-x treemacs-filewatch-mode
   ```
3. **Adjust refresh settings**: Increase refresh intervals in Treemacs settings
4. **Exclude large directories**: Add `.gitignore` patterns to exclude build directories

### Treemacs Git Integration Issues

**Symptoms**: Git status not showing in file tree

**Solutions**:
1. **Check Git repository**: Ensure you're in a valid Git repository
2. **Verify Git installation**: `git --version` should work from terminal
3. **Refresh project**: `r` key in Treemacs sidebar to refresh
4. **Check Git integration setting**:
   ```elisp
   M-x describe-variable treemacs-git-integration
   ```

## Message Logging Issues

### Log Files Not Created

**Symptoms**: No message logs in `<emacs-local-dir>/log/` directory

**Troubleshooting Steps**:
1. **Check log directory**: Verify directory exists and is writable:
   ```bash
   ls -la <emacs-local-dir>/log/
   mkdir -p <emacs-local-dir>/log
   ```

2. **Check permissions**: Ensure Emacs can write to log directory:
   ```bash
   chmod 755 <emacs-local-dir>/log
   ```

3. **Test manual logging**: Force a log save:
   ```elisp
   M-x core-save-messages-log
   ```

4. **Check hook installation**: Verify logging hook is installed:
   ```elisp
   M-x describe-variable kill-emacs-hook
   ```

### Log Rotation Not Working

**Symptoms**: Old log files not rotated, or too many log files

**Solutions**:
1. **Check log file count**: Verify rotation settings:
   ```elisp
   M-x describe-variable core-log-max-files
   ```

2. **Manual rotation test**: Test rotation manually:
   ```elisp
   M-x core-rotate-log-files RET messages.log
   ```

3. **File permissions**: Ensure Emacs can rename/move log files:
   ```bash
   chmod 644 <emacs-local-dir>/log/messages.log*
   ```

### Missing Log Content

**Symptoms**: Log files exist but don't contain expected messages

**Solutions**:
1. **Check Messages buffer**: Verify messages exist:
   ```elisp
   M-x view-echo-area-messages
   ```

2. **Force buffer save**: Manually save Messages buffer:
   ```elisp
   M-x core-save-messages-log
   ```

3. **Check buffer content**: Ensure Messages buffer has content before Emacs exit

## Installation Problems

### Symlink Installation Issues

**Symptoms**: Configuration doesn't load after running install script

**Solutions**:
1. **Check symlinks**: Verify symlinks were created correctly:
   ```bash
   ls -la ~/.emacs.d/
   ```
2. **Permissions**: Ensure you have write permissions to `~/.emacs.d/`
3. **Backup existing config**: Move existing `~/.emacs.d/` before installing
4. **Manual installation**: Try the copy method instead of symlinks

### Package Installation Failures

**Symptoms**: Packages fail to install during startup

**Troubleshooting**:
1. **Check network connectivity**: Ensure internet access to package repositories
2. **Update package archives**: `M-x package-refresh-contents`
3. **Manual package installation**: `M-x package-install` for specific packages
4. **Check package repositories**: Verify [MELPA](https://melpa.org/) and [GNU ELPA](https://elpa.gnu.org/) repositories are accessible

### Pre-commit Hook Issues

**Symptoms**: Git commits fail due to [`pre-commit`](https://github.com/pre-commit/pre-commit) hook errors

**Solutions**:
1. **Install [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt)**:
   ```bash
   git clone https://github.com/emacsmirror/elisp-autofmt.git ~/github/elisp-autofmt
   ```
2. **Install [`pre-commit`](https://github.com/pre-commit/pre-commit)**:
   ```bash
   pip install pre-commit  # https://github.com/pre-commit/pre-commit
   pre-commit install
   ```
3. **Skip hooks temporarily** (for urgent commits):
   ```bash
   git commit --no-verify -m "Commit message"
   ```

## Performance Issues

### Slow Startup

**Symptoms**: Emacs takes a long time to start

**Diagnostic Steps**:
1. **Check startup time**: Start Emacs with timing:
   ```bash
   emacs --eval="(message \"Startup time: %.2f seconds\" (float-time (time-subtract (current-time) before-init-time)))"
   ```

2. **Profile startup**: Use the built-in profiler:
   ```elisp
   (require 'profiler)
   (profiler-start 'cpu)
   ;; Restart Emacs
   (profiler-report)
   ```

**Common Solutions**:
1. **Use Emacs 30.2+**: This configuration requires Emacs 30.2+ for optimal performance
2. **Check system resources**: Ensure adequate RAM and CPU availability
3. **Disable unnecessary packages**: Comment out optional packages in [`core/core-packages.el`](core/core-packages.el)
4. **Check network**: Slow package loading may indicate network issues

### High Memory Usage

**Symptoms**: Emacs consumes excessive memory

**Solutions**:
1. **Adjust GC settings**: The configuration automatically optimizes garbage collection
2. **Restart Emacs**: Long-running sessions may accumulate memory
3. **Check for memory leaks**: Use `M-x memory-usage` to identify problematic buffers
4. **Reduce buffer count**: Close unnecessary buffers and files

## Package Management Issues

### Package Signature Verification Failures

**Symptoms**: Packages fail to install due to signature verification errors

**Solutions**:
1. **Update package keys**: `M-x package-refresh-contents`
2. **Import GNU key**:
   ```elisp
   (setq package-check-signature nil)  ; Temporary workaround
   ```
3. **Use HTTPS repositories**: Ensure package repositories use secure connections

### Package Conflicts

**Symptoms**: Package installation fails due to dependency conflicts

**Solutions**:
1. **Update all packages**: `M-x package-list-packages`, then `U` followed by `x`
2. **Clear package cache**: Delete `~/.emacs.d/elpa/` and restart Emacs
3. **Check package pinning**: Review package-archive-priorities in [`core/package-system/repositories.el`](core/package-system/repositories.el)

### Package Metadata Cache Issues

**Symptoms**: Packages fail to install, outdated package lists, or repository errors

**About the Package Metadata Cache**:
The configuration maintains package system state in `~/.emacs.d/local/package-metadata.el`, which stores:
- **package-last-refresh-timestamp**: When package catalogs were last downloaded from repositories (MELPA, GNU ELPA, etc.)
- **package-cache-timestamp**: When the local metadata cache was created
- **package-cache-count**: Number of packages available in the cached catalog

**Solutions**:
1. **Reset package cache**: Delete the metadata file to force fresh repository downloads:
   ```bash
   rm ~/.emacs.d/local/package-metadata.el
   ```
   This is **completely safe** - the file will be automatically recreated on next startup.

2. **Manual refresh**: Force package catalog refresh:
   ```elisp
   M-x package-refresh-contents
   ```

3. **Full package reset**: For persistent issues, reset both cache and packages:
   ```bash
   rm ~/.emacs.d/local/package-metadata.el
   rm -rf ~/.emacs.d/local/elpa/
   ```
   Then restart Emacs to download fresh packages.

## Configuration Loading Problems

### Testing Your Configuration

**Before troubleshooting**, run the automated configuration test to get comprehensive diagnostics:

```bash
# Run comprehensive configuration test
~/github/emacs.d/scripts/test-config.sh
```

This test will:
- ✅ Show exactly which modules are failing and why
- ✅ Verify you're using Emacs 30.2+ as required
- ✅ Display detailed timing and loading information
- ✅ Distinguish between real errors and informational messages

**Manual testing commands**:
```bash
# Test configuration in batch mode
emacs --batch --load ~/.emacs.d/early-init.el --load ~/.emacs.d/init.el --eval "(message \"Test complete\")"

# Interactive debug mode (shows detailed errors)
emacs --debug-init
```

### Module Loading Failures

**Symptoms**: Error messages during startup mentioning specific modules

**Troubleshooting**:
1. **Run configuration test first**: Use `~/github/emacs.d/scripts/test-config.sh` for detailed diagnostics
2. **Check error details**: Look at the `*Messages*` buffer for specific error information
3. **Test individual modules**: Try loading modules manually:
   ```elisp
   (require 'module-name)
   ```
4. **Check file syntax**: Ensure Emacs Lisp syntax is correct in the failing module
5. **Verify file paths**: Ensure all required files exist in the expected locations

### Emacs Version Requirements

**Symptoms**: Features don't work as expected, configuration errors

**Solutions**:
1. **Check Emacs version**: `M-x emacs-version` - must be 30.2+
2. **Verify modern features**: Check the `*Messages*` buffer for feature loading information
3. **Upgrade Emacs**: This configuration requires Emacs 30.2+ exclusively
4. **Check installation**: Ensure you have a complete Emacs 30.2+ installation

## Snap Installation Issues

### Native Compilation Errors

**Symptoms**:
- Persistent startup errors
- `*Async-native-compile-log*` buffer appears on every launch

**Cause**:
Snap-based Emacs installations have sandbox permission issues that prevent native compilation from working correctly.

**Solution**:
This configuration automatically handles this issue by:
- Setting a Snap-compatible native compilation cache path (`~/eln-cache`).
- Disabling deferred compilation to ensure the configuration is loaded before async compilation starts.
- Adding the read-only `/snap/emacs/.*` directory to the `native-comp-deferred-compilation-deny-list` to prevent pointless recompilation attempts.

If you are still experiencing issues, ensure that you have the latest version of this configuration.

## Getting Additional Help

If you continue to experience issues:

1. **Check the Messages buffer**: `M-x view-echo-area-messages` for detailed error information
2. **Enable debug mode**: Add `(setq debug-on-error t)` to your configuration temporarily
3. **Test with minimal config**: Start Emacs with `emacs -Q` to test without this configuration
4. **Check system requirements**: Ensure your system meets all requirements in [`README.md`](README.md#requirements)
5. **Report issues**: Consider creating an issue in the repository if problems persist

## Related Documentation

**For General Help:**
- [`FAQ.md`](FAQ.md) - Common questions and answers
- [`README.md`](README.md) - Setup and installation guide

**For Development Issues:**
- [`CONTRIBUTING.md`](CONTRIBUTING.md) - Development setup and testing procedures
