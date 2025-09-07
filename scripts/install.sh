#!/usr/bin/env bash
# Description: A script that create symlinks to the emacs configuration files.

# Enhanced Emacs configuration installer with better error handling and validation
set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EMACS_DIR="$HOME/.emacs.d"
BACKUP_DIR="/tmp/emacs.d.backup.$(date +%Y%m%d-%H%M%S)"

# Centralized logging function with color-coded output levels
# Takes log level as first argument, message as remaining arguments
# Outputs INFO/SUCCESS to stdout, WARN/ERROR to stderr with appropriate colors
log() {
    local level=$1
    shift
    case $level in
        INFO) printf "${BLUE}[INFO]${NC} %s\n" "$*" ;;
        WARN) printf "${YELLOW}[WARN]${NC} %s\n" "$*" ;;
        ERROR) printf "${RED}[ERROR]${NC} %s\n" "$*" >&2 ;;
        SUCCESS) printf "${GREEN}[SUCCESS]${NC} %s\n" "$*" ;;
    esac
}


# Verifies Emacs is installed and checks version compatibility
# Exits with error code 1 if Emacs not found in PATH
# Exits with error code 1 if version is below required 30.2
check_emacs() {
    if ! command -v emacs &> /dev/null; then
        log ERROR "Emacs is not installed or not in PATH"
        exit 1
    fi
    local version
    version=$(emacs --version | head -n1 | grep -oE '[0-9]+\.[0-9]+')
    log INFO "Found Emacs version: $version"
    # Check for minimum version (30.2)
    if printf '%s\n' "30.2" "$version" | sort -V | head -n1 | grep -q "30.2"; then
        log SUCCESS "Emacs version is compatible"
    else
        log ERROR "Emacs version $version is not compatible (required: 30.2+)"
        log ERROR "This configuration requires Emacs 30.2 or later"
        exit 1
    fi
}


# Validates that all required repository files and directories exist
# Checks for essential structure: init.el, core/, features/, lang/, themes/, user/
# Exits with error code 1 if any required components are missing
validate_repo() {
    log INFO "Validating repository structure..."
    local required_files=("init.el" "early-init.el" "core" "features" "lang" "themes" "user")
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [[ ! -e "$REPO_DIR/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log ERROR "Missing required files/directories: ${missing_files[*]}"
        exit 1
    fi
    log SUCCESS "Repository structure is valid"
}



# Creates selective backups of existing files that would be overwritten
# Backs up only files/directories that conflict with repository symlinks
# Places backups in /tmp directory with timestamp to avoid conflicts
# Preserves unmanaged files in ~/.emacs.d that don't conflict with repo structure
backup_existing() {
    local files_to_backup=("init.el" "early-init.el" "core" "features" "lang" "themes" "user")
    local backed_up_files=()
    local backup_needed=false

    # First check if any files need backing up
    for file in "${files_to_backup[@]}"; do
        local file_path="$EMACS_DIR/$file"
        if [[ -e "$file_path" ]]; then
            backup_needed=true
            break
        fi
    done

    if [[ "$backup_needed" = true ]]; then
        if mkdir -p "$BACKUP_DIR"; then
            log INFO "Created backup directory: $BACKUP_DIR"
        else
            log ERROR "Failed to create backup directory: $BACKUP_DIR"
            exit 1
        fi

        for file in "${files_to_backup[@]}"; do
            local file_path="$EMACS_DIR/$file"
            if [[ -e "$file_path" ]]; then
                if cp -r "$file_path" "$BACKUP_DIR/"; then
                    backed_up_files+=("$file")
                    if rm -rf "$file_path"; then
                        log SUCCESS "Backed up and removed: $file"
                    else
                        log ERROR "Failed to remove $file after backup"
                        exit 1
                    fi
                else
                    log ERROR "Failed to backup $file"
                    exit 1
                fi
            fi
        done

        log SUCCESS "Backed up conflicting files: ${backed_up_files[*]}"
        log INFO "Backup location: $BACKUP_DIR"
    else
        log INFO "No conflicting files found to backup"
    fi
}


# Creates ~/.emacs.d directory if needed and establishes symbolic links to repository files
# Links core files (init.el) and directories (core, features, lang, themes, user)
# Uses force flag (-f) to overwrite any existing symlinks
# Warns about missing source files but continues with available ones
# Exits with error code 1 if critical symlinks fail (directory creation always succeeds)
create_symlinks() {
    log INFO "Creating symlinks in existing .emacs.d directory..."
    mkdir -p "$EMACS_DIR"
    log SUCCESS "Ensured .emacs.d directory exists"

    local links=(
        "init.el:init.el"
        "early-init.el:early-init.el"
        "core:core"
        "features:features"
        "lang:lang"
        "themes:themes"
        "user:user"
    )
    for link in "${links[@]}"; do
        local src="${link%%:*}"
        local dest="${link##*:}"
        local src_path="$REPO_DIR/$src"
        local dest_path="$EMACS_DIR/$dest"
        if [[ -e "$src_path" ]]; then
            if ln -sf "$src_path" "$dest_path"; then
                log SUCCESS "Created symlink: $dest -> $src_path"
            else
                log ERROR "Failed to create symlink for $dest"
                exit 1
            fi
        else
            log WARN "Source file/directory not found: $src_path (skipping)"
        fi
    done
}


# Verifies that all expected symlinks were created and point to valid targets
# Checks each symlink exists, is actually a symlink, and target file/directory exists
# Reports success for valid links, warns about non-symlinks, errors on broken links
# Exits with error code 1 if any symlinks are broken (point to non-existent targets)
verify_installation() {
    log INFO "Verifying installation..."
    local expected_links=("init.el" "early-init.el" "core" "features" "lang" "themes" "user")
    local broken_links=()
    for link in "${expected_links[@]}"; do
        local link_path="$EMACS_DIR/$link"
        if [[ -L "$link_path" ]]; then
            if [[ -e "$link_path" ]]; then
                log SUCCESS "✓ $link symlink is valid"
            else
                broken_links+=("$link")
            fi
        else
            log WARN "✗ $link is not a symlink"
        fi
    done
    if [[ ${#broken_links[@]} -gt 0 ]]; then
        log ERROR "Broken symlinks found: ${broken_links[*]}"
        exit 1
    fi
}


# Tests whether Emacs can successfully load the new configuration
# Runs Emacs in batch mode to load init.el without starting GUI
# Uses proper shell quoting for the Emacs Lisp eval expression
# Reports success if configuration loads cleanly, warns if errors detected
test_configuration() {
    log INFO "Testing configuration loading..."

    # Capture the output and exit code for better diagnostics
    local temp_output
    temp_output=$(mktemp)
    local exit_code

    # Test if Emacs can load the configuration without errors
    if emacs --batch --load "$EMACS_DIR/init.el" --eval '(message "Configuration loaded successfully")' >"$temp_output" 2>&1; then
        log SUCCESS "Configuration loads without errors"
        # Clean up temp file
        rm -f "$temp_output"
    else
        exit_code=$?
        log WARN "Configuration test returned exit code $exit_code"

        # Check if it's likely a package-related issue
        if grep -q -E "(package|melpa|install|download|network|timeout)" "$temp_output" 2>/dev/null; then
            log WARN "Detected package/network-related warnings (this is often normal on first run)"
            log INFO "Try running: emacs --batch --load \"$EMACS_DIR/init.el\" --eval '(message \"Test\")'"
            # Clean up temp file since we're not providing it for debugging
            rm -f "$temp_output"
        else
            log WARN "Configuration may have issues. Output saved to: $temp_output"
            log INFO "To debug, check the output file above or run: emacs --debug-init"
            # Keep temp file for debugging (user is informed of location)
        fi

        # Don't fail the installation for configuration warnings
        log INFO "Installation continues - configuration warnings don't prevent usage"
    fi
}


# Displays comprehensive help information about script usage and options
# Lists all available command-line flags and their purposes
# Explains the installation process step-by-step for user understanding
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -h, --help      Show this help message
    --no-backup     Skip backing up conflicting files
    --no-test       Skip configuration testing
    --force         Force installation even if validation fails

This script will:
1. Check for Emacs installation
2. Validate repository structure
3. Backup conflicting files to /tmp (unless --no-backup)
4. Create symlinks from ~/.emacs.d to this repository (init.el, early-init.el, core/, features/, lang/, themes/, user/)
5. Verify the installation
6. Test configuration loading (unless --no-test)

Note: This script preserves existing ~/.emacs.d and only backs up files
that would conflict with the repository symlinks (init.el, early-init.el, core/, features/, etc.).

EOF
}

# Parse command line arguments
# Processes command-line options to control script behavior
# Sets boolean flags for --no-backup, --no-test, --force options
# Displays help and exits for -h/--help, errors on unknown options
NO_BACKUP=false
NO_TEST=false
FORCE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        --no-backup)
            NO_BACKUP=true
            shift
            ;;
        --no-test)
            NO_TEST=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            log ERROR "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done


# Main installation orchestration function
# Coordinates all installation steps in proper sequence
# Respects command-line flags to skip backup/testing as requested
# Provides comprehensive logging of installation progress and final status
main() {
    log INFO "Starting Emacs configuration installation..."
    log INFO "Repository: $REPO_DIR"
    log INFO "Target: $EMACS_DIR"
    check_emacs
    if ! validate_repo && [[ "$FORCE" != true ]]; then
        log ERROR "Repository validation failed. Use --force to override."
        exit 1
    fi
    if [[ "$NO_BACKUP" != true ]]; then
        backup_existing
    fi
    create_symlinks
    verify_installation
    if [[ "$NO_TEST" != true ]]; then
        test_configuration
    fi
    log SUCCESS "Installation completed successfully!"
    log INFO "You can now start Emacs or restart if already running"
    log INFO "To debug configuration issues, run: emacs --debug-init"
}

# Execute main function with all passed arguments
main "$@"
