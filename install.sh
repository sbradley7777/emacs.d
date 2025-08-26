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

# Function to create symlink
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

# Create symlink for site-lisp directory
create_symlink "$SCRIPT_DIR/site-lisp" "$EMACS_DIR/site-lisp"

# Create symlink for init.el file
create_symlink "$SCRIPT_DIR/init.el" "$EMACS_DIR/init.el"

echo
echo -e "${GREEN}Installation completed successfully!${NC}"
echo
echo "Your Emacs configuration is now symlinked to this repository."
echo "Any changes made to files in this repository will be reflected in your Emacs configuration."
echo
echo -e "${YELLOW}Note: Backed up files are saved with timestamps and can be restored if needed.${NC}"
