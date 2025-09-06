# Configuration Testing Guide

This guide provides comprehensive information about testing your Emacs configuration, including automated scripts, manual testing methods, and understanding test limitations.

## Table of Contents

- [Quick Start](#quick-start)
- [Test Script Features](#test-script-features)
- [Usage Examples](#usage-examples)
- [Understanding Test Results](#understanding-test-results)
- [Manual Testing Methods](#manual-testing-methods)
- [Test Limitations](#test-limitations)
- [Troubleshooting](#troubleshooting)
- [CI/CD Integration](#cicd-integration)
- [Related Documentation](#related-documentation)

## Quick Start

### Run the Configuration Test

```bash
# Quick configuration test
~/github/emacs.d/scripts/test-config.sh
```

**What it does:**
- ✅ Detects and uses your configured Emacs binary (including aliases)
- ✅ Loads your complete configuration in batch mode
- ✅ Reports which modules loaded successfully and which failed
- ✅ Shows detailed timing information for performance analysis
- ✅ Provides comprehensive diagnostics and version information
- ✅ Returns proper exit codes (0 = success, 1 = failure) for automation

## Test Script Features

### Alias Detection
The script automatically sources your shell configuration to detect aliases:
- Sources `~/.bashrc`, `~/.bash_profile`, or `~/.profile`
- Enables alias expansion in the script context
- Shows exactly which Emacs binary is being used
- Handles snap packages, custom installations, and system packages

### Version Compatibility
- **Modern (30.2+)**: Full feature set with optimized performance
- **Current (27.x)**: Modern features with compatibility adjustments
- **Stable (26.x)**: Core features with conservative settings
- **Legacy (24.x)**: Basic functionality for older installations

### Comprehensive Diagnostics
- System information (OS, architecture)
- Load path verification
- Package availability and status
- Module loading results with timing
- Feature tier detection
- Performance benchmarks

## Usage Examples

### Basic Testing

```bash
# Standard configuration test
~/github/emacs.d/scripts/test-config.sh

# View just the summary (pipe through tail)
~/github/emacs.d/scripts/test-config.sh | tail -10
```

### Command Line Alternatives

```bash
# One-liner test with full Messages buffer output
emacs --batch --load ~/github/emacs.d/early-init.el --load ~/github/emacs.d/init.el --eval "(progn (message \"=== CONFIGURATION TEST COMPLETE ===\") (message \"Messages buffer contents:\") (with-current-buffer \"*Messages*\" (message \"%s\" (buffer-string))) (kill-emacs (if (> (length config-load-results) 0) (if (cl-every (lambda (result) (eq (nth 1 result) 'success)) config-load-results) 0 1) 1)))"

# Simple test without Messages buffer
emacs --batch --load ~/github/emacs.d/early-init.el --load ~/github/emacs.d/init.el --eval "(message \"Configuration test complete\")" 2>&1

# Test just init.el (without early-init.el)
emacs --batch --load ~/github/emacs.d/init.el --eval "(message \"Init test complete\")"
```

### Automated Testing

```bash
# Test and capture exit code
if ~/github/emacs.d/scripts/test-config.sh; then
    echo "✅ Configuration is valid"
else
    echo "❌ Configuration has issues"
    exit 1
fi

# Silent test (only show failures)
~/github/emacs.d/scripts/test-config.sh >/dev/null 2>&1 && echo "PASS" || echo "FAIL"
```

## Understanding Test Results

### Successful Output Example

```
🧪 Testing Emacs configuration...
📁 Configuration directory: ~/github/emacs.d
🔧 Using Emacs binary: emacs is aliased to `/snap/bin/emacs -nw'
📋 Emacs version: GNU Emacs 30.2

=== Configuration Loading Summary ===
    ✅  System and configuration diagnostics (0.000s)
    ✅  Package system setup (0.247s)
    ✅  Package declarations (0.007s)
    ✅  Basic UI setup (0.012s)
    ✅  Theme configuration (0.008s)
    ✅  Editing preferences (0.009s)
    ✅  File handling (0.000s)
    ✅  Global keybindings (0.001s)
    ✅  Auto-completion framework (0.004s)
    ✅  General LSP configuration (0.001s)
    ✅  Flymake configuration (0.000s)
    ✅  Rainbow delimiters for better code readability (0.001s)
    ✅  Visual indentation guides (0.001s)
    ✅  Emacs Lisp development (0.004s)
    ✅  YAML file support (0.001s)
    ✅  Python core editing (0.000s)
    ✅  Python virtual environments (0.027s)
    ✅  Python LSP (eglot) configuration (0.000s)
    ✅  Python development tools (0.000s)
    ✅  Custom helper functions (0.000s)
    ✅  Function aliases and shortcuts (0.002s)
    🛠️  Total: 21 successful, 0 failed (0.326s total)
====================================

✅ Emacs feature tier: modern (version 30.2)
✅  init.el loaded successfully.

=== CONFIGURATION TEST COMPLETE ===
Exit code: 0 (SUCCESS)
Total modules loaded: 21

✅ Configuration test PASSED
```

### Expected Warnings (Normal)

**Package download failures:**
```
❌  Failed to install which-key: https://stable.melpa.org/packages/which-key-3.6.0.tar: Bad Request
Failed to download 'gnu' archive.
```
- **Why**: Batch mode often has restricted network access
- **Impact**: None - packages are already installed locally
- **Action**: No action needed

**Version compatibility issues:**
```
❌  Failed to load Editing preferences: Symbol's function definition is void: global-display-fill-column-indicator-mode
```
- **Why**: Feature requires Emacs 27+ but you're running 26.x
- **Impact**: Configuration adapts automatically
- **Action**: Consider upgrading Emacs for full feature set

**use-package unavailable:**
```
⚠️  use-package unavailable: Cannot open load file: No such file or directory, use-package
Skipping corfu configuration (use-package unavailable)
```
- **Why**: Package system couldn't initialize use-package in batch mode
- **Impact**: Core functionality still works; advanced features skipped
- **Action**: Normal in batch mode; works fine in interactive mode

### Issues Requiring Attention

**Syntax errors:**
```
❌  Failed to load Custom helper functions: Invalid read syntax: ")"
```
- **Why**: Emacs Lisp syntax error in the file
- **Action**: Check file syntax, ensure balanced parentheses

**Missing files:**
```
❌  Failed to load Python core editing: Cannot open load file: No such file or directory, core
```
- **Why**: Required file missing or incorrect path
- **Action**: Verify file exists and load-path is correct

**Permission errors:**
```
❌  Failed to load Package system setup: Permission denied
```
- **Why**: File permission issues
- **Action**: Check file permissions, ensure readable

## Manual Testing Methods

### Interactive Testing

```bash
# Start Emacs with debug information
emacs --debug-init

# Start Emacs with minimal setup
emacs -Q --load ~/github/emacs.d/init.el

# Check syntax without loading
emacs --batch --eval "(check-parens)" ~/github/emacs.d/init.el
```

### Individual Module Testing

```elisp
;; Test individual modules in Emacs
(require 'completion)           ; Test completion module
(require 'python-config)        ; Test Python configuration
(describe-function 'corfu-mode) ; Check if function is available

;; Check feature availability
(if (featurep 'completion)
    (message "Completion module loaded")
  (message "Completion module not available"))
```

### Package Verification

```elisp
;; Check package status
(package-installed-p 'corfu)        ; Check if package is installed
(require 'corfu)                    ; Try to load package
(describe-variable 'package-alist)  ; See all installed packages
```

## Test Limitations

Understanding what the test script **cannot** validate is crucial for comprehensive testing:

### Batch Mode Constraints

**What it can't test:**
- **Interactive features**: User input, prompts, interactive commands
- **GUI elements**: Window management, mouse interactions, visual themes
- **Key bindings**: Actual keypress handling and complex key sequences
- **Modal behavior**: How modes interact with user actions and state changes

**Why:** Batch mode (`--batch`) runs Emacs without display or interactive session.

### Runtime Behavior Gaps

**Missing coverage:**
- **Package functionality after loading**: Tests loading but not actual functionality
- **LSP server communication**: Can't test real language server connections
- **Auto-completion behavior**: Tests framework loading but not completion quality
- **File operations**: Opening, editing, saving files in real scenarios
- **Performance under load**: Only tests startup, not sustained usage

**Why:** Script only tests initialization phase, not ongoing operation.

### Network and External Dependencies

**What's not validated:**
- **Package installation from repositories**: Network issues are expected/ignored
- **LSP server availability**: External language servers aren't tested
- **External tool integration**: Git hooks, formatters, linters in real workflows
- **Virtual environment detection**: Python venv auto-switching in projects

**Why:** Batch mode often runs in restricted environments; external tools may not be available.

### User Environment Specifics

**Untested scenarios:**
- **Custom user modifications**: Changes in `~/.emacs.d/custom_prefs.el`
- **System-specific integration**: Font availability, clipboard, system themes
- **User workflow patterns**: Real usage loads and patterns
- **Multi-buffer scenarios**: Complex buffer and window management

**Why:** Test runs in isolation without user customizations or realistic usage.

### Performance Under Load

**Missing insights:**
- **Memory usage over time**: Only shows startup memory, not long-term patterns
- **Performance degradation**: Behavior with many open files/buffers
- **Package conflicts**: Runtime conflicts appearing during extended use
- **GC pressure**: Real-world garbage collection under working loads

**Why:** Single initialization doesn't simulate sustained usage patterns.

### Integration Testing Gaps

**What's not covered:**
- **Cross-feature interactions**: How completion, LSP, and features work together
- **Error recovery**: Configuration handling and recovery from runtime errors
- **State persistence**: Session management, recent files, project history
- **Workflow continuity**: Moving between files, projects, development tasks

## Troubleshooting

### Wrong Emacs Version Being Used

**Problem**: Test shows system Emacs (e.g., 26.1) instead of your preferred version (e.g., 30.2)

**Solution**:
1. **Check your alias**: `alias | grep emacs`
2. **Verify which binary**: `which emacs`
3. **Check script sourcing**: The script sources `~/.bashrc` - if you use different shell config, update the script
4. **Manual override**: Edit the script to use specific path

### Network-Related Warnings

**Problem**: Package download failures, repository timeouts

**Expected behavior**: These warnings are normal in batch mode
- Configuration works offline
- Packages are already installed locally
- Network restrictions don't affect core functionality

**Action**: No action needed unless you see actual module loading failures

### Version Compatibility Issues

**Problem**: Features fail due to Emacs version differences

**Analysis**:
- Check which tier your version provides: `emacs --version`
- Modern (30.2+): Full features
- Current (27.x): Most features with compatibility
- Stable (26.x): Core features only
- Legacy (24.x): Basic functionality

**Solutions**:
- **Upgrade Emacs**: For full feature set
- **Accept limitations**: Configuration adapts automatically
- **Check alternatives**: Some features have fallbacks

### Performance Issues

**Problem**: Configuration loads slowly or test times out

**Diagnosis**:
```bash
# Test with timing details
~/github/emacs.d/scripts/test-config.sh | grep "seconds"

# Test individual modules
emacs --batch --load ~/github/emacs.d/core/package-system/manager.el --eval "(message \"Package manager test\")"
```

**Solutions**:
- Check network connectivity for package downloads
- Verify disk I/O isn't bottlenecked
- Consider disabling slow modules for testing


## Related Documentation

- **Installation**: See [README.md](../README.md#installation) for setup instructions
- **Script Details**: See [README.md](README.md#configuration-testing) for script overview
- **Troubleshooting**: See [TROUBLESHOOTING.md](../TROUBLESHOOTING.md#testing-your-configuration) for issue resolution
- **Features**: See [FEATURES.md](../FEATURES.md) for detailed feature documentation
- **Development**: See [CONTRIBUTING.md](../CONTRIBUTING.md) for development guidelines
