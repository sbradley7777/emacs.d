# Troubleshooting Guide

This guide helps resolve common issues you may encounter while using this Emacs configuration.

## Table of Contents

- [Auto-completion Issues](#auto-completion-issues)
- [LSP Server Problems](#lsp-server-problems)
- [Virtual Environment Issues](#virtual-environment-issues)
- [Installation Problems](#installation-problems)
- [Performance Issues](#performance-issues)
- [Package Management Issues](#package-management-issues)
- [Configuration Loading Problems](#configuration-loading-problems)
- [Related Documentation](#related-documentation)

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
1. **Check LSP server**: Slow completion often indicates LSP server issues
2. **Verify virtual environment**: Ensure correct Python environment is active
3. **Restart LSP**: Use `M-x eglot-shutdown` followed by reopening the file
4. **Check system resources**: High CPU/memory usage may impact performance

## LSP Server Problems

### Python LSP Server Not Working

**Symptoms**: No intelligent completion, diagnostics, or go-to-definition in Python files

**Diagnostic Steps**:
1. **Check LSP events**: `M-x eglot-events-buffer` to see LSP communication
2. **View server errors**: `M-x eglot-stderr-buffer` to see server error messages
3. **Verify pylsp installation**: Ensure `pylsp` is available:
   ```bash
   # Check if pylsp is installed
   which pylsp

   # Test pylsp directly
   pylsp --help
   ```

**Common Solutions**:
1. **Install/reinstall pylsp**:
   ```bash
   # User installation
   pip3 install --user python-lsp-server pylsp-mypy python-lsp-ruff mypy ruff

   # System installation (if you have admin privileges)
   sudo pip3 install python-lsp-server pylsp-mypy python-lsp-ruff mypy ruff
   ```

2. **Check PATH**: Ensure `~/.local/bin` is in your PATH:
   ```bash
   # Add to ~/.bash_profile
   export PATH="$HOME/.local/bin:$PATH"
   ```

3. **Restart LSP server**: `M-x eglot-shutdown` followed by `M-x eglot` or reopening the file

4. **Check virtual environment**: Ensure pylsp is installed in the active virtual environment

### LSP Server Crashes

**Symptoms**: LSP server stops working, frequent error messages

**Solutions**:
1. **Check server logs**: `M-x eglot-stderr-buffer` for error details
2. **Update pylsp**: Ensure you have the latest version
3. **Check file permissions**: Ensure Python files and project directories are readable
4. **Restart Emacs**: Sometimes a complete restart resolves persistent issues

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

**Symptoms**: Modeline shows incorrect Python version

**Solutions**:
1. **Refresh environment**: Deactivate and reactivate the virtual environment:
   - `M-x pyvenv-deactivate`
   - `M-x pyvenv-activate`
2. **Check venv Python**: Verify the virtual environment's Python version:
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
4. **Check package repositories**: Verify MELPA and GNU repositories are accessible

### Pre-commit Hook Issues

**Symptoms**: Git commits fail due to pre-commit hook errors

**Solutions**:
1. **Install elisp-autofmt**:
   ```bash
   git clone https://github.com/emacsmirror/elisp-autofmt.git ~/github/elisp-autofmt
   ```
2. **Install pre-commit**:
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
1. **Update Emacs**: Newer versions often have better performance
2. **Check system resources**: Ensure adequate RAM and CPU availability
3. **Disable unnecessary packages**: Comment out optional packages in [`core/packages.el`](core/packages.el)
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

### Package Version Conflicts

**Symptoms**: Package installation fails due to dependency conflicts

**Solutions**:
1. **Update all packages**: `M-x package-list-packages`, then `U` followed by `x`
2. **Clear package cache**: Delete `~/.emacs.d/elpa/` and restart Emacs
3. **Check package pinning**: Review package-archive-priorities in [`core/package-system/repositories.el`](core/package-system/repositories.el)

## Configuration Loading Problems

### Testing Your Configuration

**Before troubleshooting**, run the automated configuration test to get comprehensive diagnostics:

```bash
# Run comprehensive configuration test
~/github/emacs.d/scripts/test-config.sh
```

This test will:
- ✅ Show exactly which modules are failing and why
- ✅ Verify your Emacs version and feature compatibility
- ✅ Display detailed timing and loading information
- ✅ Distinguish between real errors and expected version-related warnings

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

### Version Compatibility Issues

**Symptoms**: Features don't work as expected, version-related errors

**Solutions**:
1. **Check Emacs version**: `M-x emacs-version`
2. **Verify feature tier**: Check the `*Messages*` buffer for feature tier information
3. **Update Emacs**: Consider upgrading to a newer version for better feature support
4. **Check feature availability**: Some features require specific Emacs versions

## Getting Additional Help

If you continue to experience issues:

1. **Check the Messages buffer**: `M-x view-echo-area-messages` for detailed error information
2. **Enable debug mode**: Add `(setq debug-on-error t)` to your configuration temporarily
3. **Test with minimal config**: Start Emacs with `emacs -Q` to test without this configuration
4. **Check system requirements**: Ensure your system meets all requirements in [`README.md`](README.md#requirements)
5. **Report issues**: Consider creating an issue in the repository if problems persist

## Related Documentation

- [`CONTRIBUTING.md`](CONTRIBUTING.md) - Guidelines for contributing to the configuration
- [`FAQ.md`](FAQ.md) - Frequently asked questions about configuration and usage
- [`FEATURES.md`](FEATURES.md) - Detailed feature documentation, version-aware capabilities, and language support
- [`README.md`](README.md) - Main project documentation and setup instructions
- [`STYLEGUIDE.md`](STYLEGUIDE.md) - Code formatting and style standards
