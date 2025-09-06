# Frequently Asked Questions

This document answers common questions about the Emacs configuration, its features, and usage.

## Table of Contents

- [General Configuration](#general-configuration)
- [Installation and Setup](#installation-and-setup)
- [Features and Functionality](#features-and-functionality)
- [Python Development](#python-development)
- [Performance and Optimization](#performance-and-optimization)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Related Documentation](#related-documentation)

## General Configuration

### Q: What makes this configuration different from others?

**A:** This configuration focuses on several key principles:
- **Version-aware adaptation**: Automatically optimizes features based on your Emacs version
- **Minimal dependencies**: Uses built-in Emacs features when possible
- **Performance optimization**: Startup times optimized for daily use
- **Professional development**: Comprehensive Python development environment with LSP integration
- **Automated quality**: Pre-commit hooks and formatting ensure consistent code quality

### Q: What Emacs versions are supported?

**A:** The configuration supports Emacs 26.0.50 and later, with automatic feature detection:
- **Modern (30.2+)**: Full feature set with maximum performance
- **Current (27.x)**: Modern features with compatibility adjustments
- **Stable (26.x)**: Core features with conservative settings
- **Legacy (24.x)**: Basic functionality (limited support)

### Q: How does the configuration determine my Emacs capabilities?

**A:** The configuration uses version-aware feature detection ([`core/core-constants.el`](core/core-constants.el)) to automatically set:
- Garbage collection thresholds optimized for your version
- UI features (line numbers, native compilation)
- Performance optimizations
- Memory management settings

### Q: Is this configuration suitable for beginners?

**A:** Yes! The configuration is designed to work out-of-the-box with sensible defaults. However, it's also comprehensive enough for professional development. New users can start with basic features and gradually explore advanced capabilities.

## Installation and Setup

### Q: Should I use the development installation (symlinks) or standard installation (copy)?

**A:** Choose based on your needs:
- **Development installation (symlinks)**: Use if you want to modify the configuration itself, test changes, or contribute improvements
- **Standard installation (copy)**: Use for regular daily use without configuration development

### Q: Can I install this alongside my existing Emacs configuration?

**A:** Not directly. This is a complete configuration replacement. To test:
1. Backup your existing `~/.emacs.d/` directory
2. Install this configuration
3. If you want to revert, restore your backup

### Q: How do I verify my installation is working correctly?

**A:** Use the included configuration test script:

```bash
# Quick configuration test
~/github/emacs.d/scripts/test-config.sh
```

**What the test shows:**
- ✅ Which Emacs version is being used (important for alias detection)
- ✅ Module loading status and timing information
- ✅ Feature tier compatibility (modern/current/stable/legacy)
- ✅ Detailed diagnostics for any failures

**Expected results:**
- **All modules successful**: Configuration is working perfectly
- **Some version-related warnings**: Normal for older Emacs versions (configuration adapts automatically)
- **Network/package warnings**: Normal in batch mode (packages work when needed)

**Manual testing alternatives:**
```bash
# Interactive debug mode (shows detailed errors)
emacs --debug-init

# Simple batch test
emacs --batch --load ~/.emacs.d/init.el --eval "(message \"Configuration loaded\")"
```

For comprehensive testing documentation and troubleshooting, see [`scripts/TESTING.md`](scripts/TESTING.md).

### Q: What if I want to use only parts of this configuration?

**A:** The modular structure allows selective use:
- Copy individual modules from [`core/`](core/), [`features/`](features/), or [`lang/`](lang/) directories
- Modify [`init.el`](init.el) to load only desired modules
- See [CONTRIBUTING.md](CONTRIBUTING.md) for guidance on customization

### Q: Do I need to install external dependencies?

**A:** For basic functionality, no external dependencies are required. For enhanced features:
- **Python development**: Requires `python-lsp-server` and related tools
- **Code formatting**: Requires [`elisp-autofmt`](https://github.com/emacsmirror/elisp-autofmt)
- **Pre-commit hooks**: Requires `pre-commit` Python package

See [README.md](README.md#requirements) for complete requirements.

## Features and Functionality

### Q: How does the auto-completion system work?

**A:** The configuration uses [Corfu](https://github.com/minad/corfu) for universal completion:
- **Automatic triggers**: Completion appears after 1 character (200ms delay)
- **Multiple activation methods**: `TAB`, `C-c TAB`, `M-TAB`, `C-M-i`
- **Smart behavior**: `TAB` completes when possible, indents otherwise
- **Context-aware**: Uses LSP servers, built-in completion, and mode-specific sources

See [FEATURES.md](FEATURES.md#auto-completion-system) for detailed information.

### Q: What programming languages are supported?

**A:** Current language support includes:
- **Python**: Full development environment with LSP, virtual environments, and debugging
- **Emacs Lisp**: Enhanced development with formatting and evaluation
- **YAML**: Structure-aware editing and completion

The modular design makes it easy to add support for additional languages.

### Q: How does the theme system work?

**A:** The configuration uses the [Zenburn theme](https://github.com/bbatsov/zenburn-emacs) ([`themes/themes.el`](themes/themes.el)) with:
- Low-contrast, eye-friendly colors optimized for long coding sessions
- Custom black background override for enhanced contrast
- Automatic theme loading during startup
- Easy customization through Zenburn's color override system

### Q: Can I disable specific features?

**A:** Yes! The modular structure allows easy feature control:
- Comment out unwanted modules in [`init.el`](init.el)
- Individual features can be disabled in their respective configuration files
- Use [`use-package`](https://www.gnu.org/software/emacs/manual/html_mono/use-package.html) `:disabled t` to temporarily disable specific packages

## Python Development

### Q: How does virtual environment detection work?

**A:** Virtual environment detection ([`lang/python/pyvenv-config.el`](lang/python/pyvenv-config.el)) works by:
1. **Project root detection**: Searches upward for `.git/`, `pyproject.toml`, or `requirements.txt`
2. **Virtual environment location**: Looks for `venv/` directory in project root
3. **Automatic activation**: Activates environment when opening Python files
4. **Version detection**: Displays Python version in modeline

### Q: Can I use different virtual environment names or locations?

**A:** Currently, the configuration expects virtual environments to be named `venv` in the project root. For custom setups:
- Use manual activation: `M-x pyvenv-activate`
- Modify the detection logic in [`lang/python/pyvenv-config.el`](lang/python/pyvenv-config.el)
- Consider using `M-x pyvenv-workon` for system-wide virtual environments

### Q: What LSP features are available for Python?

**A:** The [Eglot](https://github.com/joaotavora/eglot) + [`python-lsp-server`](https://github.com/python-lsp/python-lsp-server) integration provides:
- **Intelligent completion**: Context-aware suggestions with type hints
- **Real-time diagnostics**: Syntax errors, linting, and type checking
- **Code navigation**: Go to definition (`M-.`), find references (`M-?`)
- **Refactoring**: Symbol renaming (`C-c C-r`), code actions (`C-c C-a`)
- **Documentation**: Hover information and signature help

### Q: How do I configure linting tools (mypy, ruff)?

**A:** The configuration automatically detects and uses installed tools:
1. **Install tools**: `pip install mypy ruff pylsp-mypy python-lsp-ruff`
2. **Automatic detection**: Tools are automatically prioritized when available
3. **Configuration**: Use standard config files (`~/.mypy.ini`, `pyproject.toml`)

See [FEATURES.md](FEATURES.md#python-development-environment) for detailed setup.

## Performance and Optimization

### Q: Why does Emacs start quickly with this configuration?

**A:** Several optimizations contribute to fast startup:
- **Early initialization** ([`early-init.el`](early-init.el)): Optimizations before package loading
- **Garbage collection tuning**: Deferred GC during startup
- **Deferred loading**: Non-essential packages loaded on-demand
- **Version-aware optimization**: Settings optimized for your Emacs version

### Q: How does the configuration handle long-running Emacs sessions?

**A:** The configuration includes long-session optimizations:
- **Dynamic GC adjustment**: Automatically increases GC thresholds for long sessions
- **Memory management**: Version-aware heap optimization
- **Performance monitoring**: Load time tracking for configuration modules

### Q: Can I monitor performance and resource usage?

**A:** Yes, several tools are available:
- **Startup timing**: Check the `*Messages*` buffer for module load times
- **Memory usage**: Use `M-x memory-usage` to see buffer memory consumption
- **GC statistics**: Monitor garbage collection in the `*Messages*` buffer
- **Profiling**: Use Emacs built-in profiler for detailed analysis

## Customization

### Q: How do I add my own customizations?

**A:** The configuration provides several customization points:
- **User directory**: Add personal functions to [`user/functions.el`](user/functions.el)
- **Aliases**: Add command aliases to [`user/aliases.el`](user/aliases.el)
- **Package additions**: Add packages to [`core/packages.el`](core/packages.el)
- **Key bindings**: Extend [`core/keybindings.el`](core/keybindings.el)

### Q: Can I override default settings?

**A:** Yes, you can override settings in several ways:
- **Modify configuration files**: Edit existing modules to change defaults
- **Add local configuration**: Create additional files in the [`user/`](user/) directory
- **Use hooks**: Add customizations via mode hooks
- **Override variables**: Set variables after package loading

### Q: How do I add support for a new programming language?

**A:** To add language support:
1. **Create language module**: Add a new file in the [`lang/`](lang/) directory
2. **Configure packages**: Add language-specific packages and configuration
3. **Load module**: Add the new module to [`init.el`](init.el)
4. **Follow conventions**: Use the style from existing language modules

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Q: Can I use a different completion framework?

**A:** While the configuration is optimized for [Corfu](https://github.com/minad/corfu), you can switch to alternatives:
- **Disable Corfu**: Comment out the corfu configuration in [`features/completion.el`](features/completion.el)
- **Add alternative**: Configure your preferred completion framework
- **Test thoroughly**: Ensure LSP integration works with your chosen framework

## Troubleshooting

### Q: What should I do if something doesn't work?

**A:** Follow this troubleshooting sequence:
1. **Check the Messages buffer**: Look for error messages and warnings
2. **Verify requirements**: Ensure all dependencies are installed
3. **Test in isolation**: Try the problematic feature in isolation
4. **Consult documentation**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for specific issues
5. **Start with minimal config**: Test with `emacs -Q` to isolate issues

### Q: How do I report bugs or request features?

**A:** When reporting issues:
1. **Reproduce the issue**: Ensure you can consistently reproduce the problem
2. **Gather information**: Include Emacs version, OS, and error messages
3. **Check existing issues**: Search for similar reported problems
4. **Provide context**: Include relevant configuration details
5. **Follow guidelines**: See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

### Q: Can I get help with specific problems?

**A:** Several resources are available:
- **Documentation**: Check all documentation files for guidance
- **Error messages**: Use `M-x toggle-debug-on-error` for detailed error information
- **Community help**: Consider asking in Emacs community forums or channels
- **Self-diagnosis**: Use built-in Emacs diagnostic tools

## Getting More Help

If your question isn't answered here:
1. **Search the documentation**: Use your browser's search function across all documentation files
2. **Check configuration comments**: Many modules include inline documentation
3. **Explore the code**: The modular structure makes it easy to understand specific features
4. **Test incrementally**: Load modules individually to understand their behavior

## Related Documentation

- [`CONTRIBUTING.md`](CONTRIBUTING.md) - Guidelines for contributing to the configuration
- [`FEATURES.md`](FEATURES.md) - Detailed feature documentation, version-aware capabilities, and language support
- [`KEYMAP.md`](KEYMAP.md) - Comprehensive keybinding reference and command documentation
- [`README.md`](README.md) - Main project documentation and setup instructions
- [`STYLEGUIDE.md`](STYLEGUIDE.md) - Code formatting and style standards
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Solutions for common issues and debugging guides
