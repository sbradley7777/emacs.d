#!/bin/bash
# Description: Test Emacs configuration in batch mode with comprehensive output and diagnostics

# Source user's bash configuration to pick up aliases (like emacs alias)
# Try common locations for bash configuration files
# shellcheck disable=SC1090
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
elif [ -f ~/.bash_profile ]; then
    # shellcheck disable=SC1090
    source ~/.bash_profile
elif [ -f ~/.profile ]; then
    # shellcheck disable=SC1090
    source ~/.profile
fi

# Enable alias expansion in scripts
shopt -s expand_aliases

# Properly expand the tilde to the user's home directory
EMACS_DIR="$(eval echo ~/github/emacs.d)"

# Detect which Emacs binary will be used
EMACS_BINARY=$(type emacs 2>/dev/null | head -1 || echo "emacs not found")
EMACS_VERSION=$(emacs --version 2>/dev/null | head -1 || echo "Unknown version")

echo "🧪 Testing Emacs configuration..."
echo "📁 Configuration directory: $EMACS_DIR"
echo "🔧 Using Emacs binary: $EMACS_BINARY"
echo "📋 Emacs version: $EMACS_VERSION"
echo ""

# Run Emacs in batch mode with configuration test
# Load early-init.el first, then init.el to match normal startup sequence
emacs --batch \
    --load "$EMACS_DIR/early-init.el" \
    --load "$EMACS_DIR/init.el" \
    --eval "(progn \
    (message \"\\n=== CONFIGURATION TEST COMPLETE ===\") \
    (message \"Exit code: %s\" (if (and (boundp 'config-load-results) \
    (> (length config-load-results) 0) \
    (cl-every (lambda (result) (eq (nth 1 result) 'success)) config-load-results)) \
    \"0 (SUCCESS)\" \"1 (FAILURE)\")) \
    (message \"Total modules loaded: %s\" (if (boundp 'config-load-results) \
    (length config-load-results) \"unknown\")) \
    (kill-emacs (if (and (boundp 'config-load-results) \
    (> (length config-load-results) 0) \
    (cl-every (lambda (result) (eq (nth 1 result) 'success)) config-load-results)) \
    0 1)))"

# Capture exit code
EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Configuration test PASSED"
else
    echo "❌ Configuration test FAILED (exit code: $EXIT_CODE)"
fi

exit $EXIT_CODE
