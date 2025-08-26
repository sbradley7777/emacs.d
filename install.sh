#!/bin/bash

# Emacs Configuration Installer
# This script creates symlinks from ~/.emacs.d/ to this repository's configuration files

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the absolute path of this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMACS_DIR="$HOME/.emacs.d"

echo -e "${BLUE}Emacs Configuration Installer${NC}"
echo "=================================="
echo -e "Repository path: ${BLUE}$SCRIPT_DIR${NC}"
echo -e "Target path: ${BLUE}$EMACS_DIR${NC}"
echo

# Function to backup existing files/directories
backup_if_exists() {
    local target="$1"
    local backup_suffix=".backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -e "$target" ]]; then
        echo -e "${YELLOW}Backing up existing $target to $target$backup_suffix${NC}"
        mv "$target" "$target$backup_suffix"
        return 0
    fi
    return 1
}

# Function to create symlink with removal of existing files/directories
create_symlink() {
    local source="$1"
    local target="$2"
    local target_name="$(basename "$target")"
    
    echo -e "${BLUE}Processing $target_name...${NC}"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        echo -e "${RED}ERROR: Source $source does not exist!${NC}"
        exit 1
    fi
    
    # Create ~/.emacs.d directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Check if target exists
    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            echo -e "${GREEN}✓ $target_name already correctly symlinked${NC}"
            return 0
        else
            echo -e "${YELLOW}Removing existing $target${NC}"
            rm -rf "$target"
        fi
    fi
    
    # Create the symlink
    echo -e "${BLUE}Creating symlink: $target -> $source${NC}"
    ln -s "$source" "$target"
    echo -e "${GREEN}✓ Successfully created symlink for $target_name${NC}"
}

# Function to create symlink with backup (alternative approach)
create_symlink_with_backup() {
    local source="$1"
    local target="$2"
    local target_name="$(basename "$target")"
    
    echo -e "${BLUE}Processing $target_name...${NC}"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        echo -e "${RED}ERROR: Source $source does not exist!${NC}"
        exit 1
    fi
    
    # Create ~/.emacs.d directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file/directory if it exists and is not already a symlink to our source
    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            echo -e "${GREEN}✓ $target_name already correctly symlinked${NC}"
            return 0
        else
            backup_if_exists "$target"
        fi
    fi
    
    # Create the symlink
    echo -e "${BLUE}Creating symlink: $target -> $source${NC}"
    ln -s "$source" "$target"
    echo -e "${GREEN}✓ Successfully created symlink for $target_name${NC}"
}

echo "Starting installation..."
echo

# Create symlinks for all configuration directories
create_symlink "$SCRIPT_DIR/config" "$EMACS_DIR/config"
create_symlink "$SCRIPT_DIR/lang" "$EMACS_DIR/lang"
create_symlink "$SCRIPT_DIR/themes" "$EMACS_DIR/themes"
create_symlink "$SCRIPT_DIR/custom" "$EMACS_DIR/custom"

# Create symlink for init.el file
create_symlink "$SCRIPT_DIR/init.el" "$EMACS_DIR/init.el"

# Optional: Create symlink for site-lisp directory (for backward compatibility)
# Uncomment the line below if you want to keep the old site-lisp structure
# create_symlink "$SCRIPT_DIR/site-lisp" "$EMACS_DIR/site-lisp"

echo
echo -e "${GREEN}Installation completed successfully!${NC}"
echo
echo "Your Emacs configuration is now symlinked to this repository."
echo "The following directories have been symlinked:"
echo "  • ~/.emacs.d/config/  → Configuration modules"
echo "  • ~/.emacs.d/lang/    → Language-specific settings"
echo "  • ~/.emacs.d/themes/  → Theme configuration"
echo "  • ~/.emacs.d/custom/  → Custom functions and settings"
echo "  • ~/.emacs.d/init.el  → Main configuration file"
echo
echo "Any changes made to files in this repository will be reflected in your Emacs configuration."
echo
echo -e "${YELLOW}Note: Existing files/directories were removed to create clean symlinks.${NC}"
echo -e "${YELLOW}The old site-lisp directory is not symlinked - you can manually remove it when ready.${NC}"
