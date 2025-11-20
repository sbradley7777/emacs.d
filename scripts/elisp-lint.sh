#!/bin/bash
#
# elisp-lint.sh - Comprehensive Emacs Lisp linting tool
#
# DESCRIPTION:
#   A comprehensive linting tool for Emacs Lisp files that performs three types of checks:
#   1. Checkdoc - Style and documentation warnings (static analysis)
#   2. Byte-Compile Isolated - Compilation warnings in isolation (Flymake-style)
#   3. Byte-Compile Loaded - Compilation warnings with init.el loaded (integration)
#
# USAGE:
#   elisp-lint.sh [OPTIONS] <path>
#
# ARGUMENTS:
#   <path>        Path to an Emacs Lisp file (.el) or directory
#                 - File: Checks a single .el file
#                 - Directory: Recursively checks all .el files (excluding elpa/)
#
# OPTIONS:
#   -h, --help       Show help message and exit
#   -d, --debug      Enable debug mode (shows commands being executed)
#   -p, --pre-commit Enable pre-commit mode (concise output for hooks)
#
# OUTPUT:
#   The script provides:
#   - Detailed warnings/errors organized by check type
#   - Overall statistics showing files with issues vs total files
#   - Error summary grouped by error type (not exact match)
#   - Exit code 0 if all checks pass, 1 if issues found
#
# EXAMPLES:
#   # Check a single file
#   elisp-lint.sh ~/github/emacs.d/init.el
#
#   # Check all files in a directory
#   elisp-lint.sh ~/github/emacs.d
#
#   # Check with debug output
#   elisp-lint.sh --debug ~/github/emacs.d/features/corfu-config.el
#
# NOTES:
#   - Requires init.el in the target directory (or parent directories for files)
#   - Does not create .elc byte-compiled files
#
# CHECK TYPES:
#   Checkdoc (Static Analysis):
#     - Documentation style checks
#     - Docstring formatting
#     - Comment conventions
#
#   Byte-Compile Isolated (Flymake-style):
#     - Compiles file without loading dependencies
#     - Catches undefined variables, missing functions
#     - Static compilation warnings
#
#   Byte-Compile Loaded (Integration):
#     - Compiles file after loading init.el
#     - Tests integration with full Emacs environment
#     - Catches runtime configuration issues
#
# VERSION:
#   1.0
#
###############################################################################

# Debug mode flag
DEBUG=false

# Pre-commit mode flag (concise output for pre-commit hooks)
PRE_COMMIT_MODE=false

# Pre-commit error counter
PRE_COMMIT_ERROR_COUNT=0

# Patterns to filter out from checkdoc (configured to use 127 char limit, ignore 80 char warnings)
CHECKDOC_FILTER_PATTERNS="Some lines are over 80 columns wide"

# Patterns to filter out from isolated byte-compile (expected errors without init.el)
ISOLATED_FILTER_PATTERNS="Cannot open load file"

# Prints a horizontal separator line (120 '=' characters).
#
# Outputs:
#   Separator line to stdout
print_separator() {
    printf '=%.0s' {1..120}
    echo ""
}

# Replaces home directory path with tilde (~) for cleaner output.
#
# Parameters:
#   path - File path to process
#
# Returns:
#   Path with $HOME replaced by ~
replace_home() {
    local path="$1"
    echo "${path/#$HOME/\~}"
}

# Prints debug message to stderr if DEBUG mode is enabled.
#
# Parameters:
#   message - Debug message text (can be multiple arguments)
#
# Outputs:
#   Debug message to stderr (only if DEBUG=true)
debug() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Prints a single error in file:line:check_type:message format for pre-commit mode.
#
# Parameters:
#   file - File path (absolute path)
#   line - Line number (can be empty)
#   check_type - Type of check (Checkdoc|Byte-Compile-Isolated|Byte-Compile-Loaded)
#   message - Error/warning message
#
# Outputs:
#   Error in file:line:message format to stdout with relative path
print_pre_commit_error() {
    local file="$1"
    local line="$2"
    local check_type="$3"
    local message="$4"
    local display_file

    # In pre-commit mode, show relative path from current directory
    if [ "$PRE_COMMIT_MODE" = true ]; then
        display_file=$(realpath --relative-to="$(pwd)" "$file" 2>/dev/null || echo "$file")
    else
        display_file="$(replace_home "$file")"
    fi

    if [ -n "$line" ]; then
        echo "${display_file}:${line}: ${check_type}: ${message}"
    else
        echo "${display_file}: ${check_type}: ${message}"
    fi
}

# Returns AWK script for formatting checkdoc warnings with indentation.
# Joins "Warning (emacs):" headers with their actual messages.
#
# Returns:
#   AWK script text for processing checkdoc output
get_checkdoc_awk_script() {
    cat << 'AWK_SCRIPT'
/^Warning \(emacs\): $/ {
    in_warning = 1
    next
}
in_warning {
    printf "  %s\n", $0
    in_warning = 0
    next
}
{
    printf "  %s\n", $0
}
AWK_SCRIPT
}

# Returns AWK script for joining multiline byte-compile warnings into single lines.
# This script combines continuation lines into a single indented warning line.
#
# Returns:
#   AWK script text for processing byte-compile output
get_byte_compile_awk_script() {
    cat << 'AWK_SCRIPT'
/^In / {
    if (prev) print prev
    prev = ""
    print $0
    next
}
/:(Warning|Error):/ {
    if (prev) print prev
    prev = "  " $0
    next
}
/^[[:space:]]/ {
    sub(/^[[:space:]]+/, "")
    prev = prev " " $0
    next
}
/^[^[:space:]]/ {
    prev = prev " " $0
    next
}
END {
    if (prev) print prev
}
AWK_SCRIPT
}

# Returns AWK script for joining multiline byte-compile warnings (loaded variant).
# Similar to get_byte_compile_awk_script but with slightly different handling
# for non-Warning/Error lines.
#
# Returns:
#   AWK script text for processing loaded byte-compile output
get_loaded_byte_compile_awk_script() {
    cat << 'AWK_SCRIPT'
/^In / {
    if (prev) print prev
    prev = ""
    print $0
    next
}
/:(Warning|Error):/ {
    if (prev) print prev
    prev = "  " $0
    next
}
/^[[:space:]]/ {
    sub(/^[[:space:]]+/, "")
    prev = prev " " $0
    next
}
{
    if (prev) print prev
    prev = "  " $0
}
END {
    if (prev) print prev
}
AWK_SCRIPT
}

# Runs Emacs checkdoc on a file and returns formatted results.
#
# Parameters:
#   file - Absolute path to .el file
#   display_file - Path with ~ substitution for display
#
# Returns:
#   Checkdoc output with warnings (empty if no warnings)
run_checkdoc_check() {
    local file="$1"
    local display_file="$2"

    debug "Running checkdoc on $display_file"
    debug "Command: emacs --batch --eval \"(setq byte-compile-docstring-max-column 127)\" --eval \"(checkdoc-file \\\"$file\\\")\""

    local checkdoc_result
    if [ "$DEBUG" = true ]; then
        checkdoc_result=$(emacs --batch --eval "(setq byte-compile-docstring-max-column 127)" --eval "(checkdoc-file \"$file\")" 2>&1 | tee /dev/stderr | grep -v -E "(Loading|Loaded)" | grep -v "^$" | grep -v "$CHECKDOC_FILTER_PATTERNS")
    else
        checkdoc_result=$(emacs --batch --eval "(setq byte-compile-docstring-max-column 127)" --eval "(checkdoc-file \"$file\")" 2>&1 | grep -v -E "(Loading|Loaded)" | grep -v "^$" | grep -v "$CHECKDOC_FILTER_PATTERNS")
    fi

    if [ -n "$checkdoc_result" ]; then
        echo "$checkdoc_result" | awk "$(get_checkdoc_awk_script)"
    fi
}

# Runs isolated byte-compile (Flymake-style) without loading init.el.
# This catches static analysis warnings like undefined variables.
# Filters out expected errors using ISOLATED_FILTER_PATTERNS after AWK processing.
#
# Parameters:
#   file - Absolute path to .el file
#   display_file - Path with ~ substitution for display
#
# Returns:
#   Byte-compile warnings (empty if no warnings), excluding filtered patterns
run_isolated_byte_compile() {
    local file="$1"
    local display_file="$2"

    debug "Running isolated byte-compile on $display_file"
    debug "Command: emacs --batch --eval \"(setq byte-compile-dest-file-function (lambda (_) nil))\" --eval \"(byte-compile-file \\\"$file\\\")\""

    local isolated_result
    if [ "$DEBUG" = true ]; then
        isolated_result=$(emacs --batch \
            --eval "(setq byte-compile-dest-file-function (lambda (_) nil))" \
            --eval "(byte-compile-file \"$file\")" 2>&1 | tee /dev/stderr | grep -v -E "(Loading|Loaded)" | grep -v "^$" | \
            awk "$(get_byte_compile_awk_script)" | \
            grep -v "$ISOLATED_FILTER_PATTERNS")
    else
        isolated_result=$(emacs --batch \
            --eval "(setq byte-compile-dest-file-function (lambda (_) nil))" \
            --eval "(byte-compile-file \"$file\")" 2>&1 | grep -v -E "(Loading|Loaded)" | grep -v "^$" | \
            awk "$(get_byte_compile_awk_script)" | \
            grep -v "$ISOLATED_FILTER_PATTERNS")
    fi

    if [ -n "$isolated_result" ]; then
        echo "${isolated_result//$HOME/\~}"
    fi
}

# Runs byte-compile with init.el loaded for integration testing.
# This tests if the file works correctly in the full Emacs environment.
#
# Parameters:
#   file - Absolute path to .el file
#   display_file - Path with ~ substitution for display
#   init_el - Path to init.el file
#
# Returns:
#   Byte-compile warnings (empty if no warnings)
run_loaded_byte_compile() {
    local file="$1"
    local display_file="$2"
    local init_el="$3"

    debug "Running loaded byte-compile on $display_file with init.el"
    debug "Command: emacs --batch --eval \"(load-file \\\"$init_el\\\")\" --eval \"(byte-compile-file \\\"$file\\\")\""

    local loaded_result
    if [ "$DEBUG" = true ]; then
        loaded_result=$(emacs --batch \
            --eval "(load-file \"$init_el\")" \
            --eval "(setq byte-compile-dest-file-function (lambda (_) nil))" \
            --eval "(byte-compile-file \"$file\")" 2>&1 | tee /dev/stderr | grep -v -E "(Loading|Loaded)" | grep -v "^$" | \
            awk "$(get_loaded_byte_compile_awk_script)")
    else
        loaded_result=$(emacs --batch \
            --eval "(load-file \"$init_el\")" \
            --eval "(setq byte-compile-dest-file-function (lambda (_) nil))" \
            --eval "(byte-compile-file \"$file\")" 2>&1 | grep -v -E "(Loading|Loaded)" | grep -v "^$" | \
            awk "$(get_loaded_byte_compile_awk_script)")
    fi

    if [ -n "$loaded_result" ]; then
        echo "${loaded_result//$HOME/\~}"
    fi
}

# Normalizes error messages to generic descriptions for summary grouping.
# Converts specific error instances to generic patterns.
#
# Parameters:
#   error_message - The specific error message to normalize
#   check_type - Type of check (checkdoc|byte-compile)
#
# Returns:
#   Normalized generic error description
normalize_error_message() {
    local msg="$1"
    local check_type="$2"

    if [ "$check_type" = "checkdoc" ]; then
        if [[ $msg =~ should\ appear\ in\ quotes ]]; then
            echo "Lisp symbol should appear in quotes"
        elif [[ $msg =~ two\ spaces\ after\ a\ period ]]; then
            echo "There should be two spaces after a period"
        elif [[ $msg =~ First\ line\ is\ not\ a\ complete\ sentence ]]; then
            echo "First line is not a complete sentence"
        elif [[ $msg =~ First\ sentence\ should ]]; then
            echo "First sentence formatting issue"
        elif [[ $msg =~ should\ appear.*in\ the\ doc\ string ]]; then
            echo "Argument should appear in doc string"
        elif [[ $msg =~ should\ be\ imperative ]]; then
            echo "Probably should be imperative"
        elif [[ $msg =~ The\ footer\ should\ be ]]; then
            echo "The footer should be: (provide 'module)"
        elif [[ $msg =~ Keycode.*embedded\ in\ doc\ string ]]; then
            echo "Keycode embedded in doc string"
        else
            echo "$msg"
        fi
    else
        # byte-compile normalization
        if [[ $msg =~ reference\ to\ free\ variable ]]; then
            echo "reference to free variable"
        elif [[ $msg =~ assignment\ to\ free\ variable ]]; then
            echo "assignment to free variable"
        elif [[ $msg =~ Cannot\ open\ load\ file ]]; then
            echo "Cannot open load file"
        elif [[ $msg =~ Unused\ lexical\ argument ]]; then
            echo "Unused lexical argument"
        elif [[ $msg =~ not\ known\ to\ be\ defined ]]; then
            echo "function not known to be defined"
        elif [[ $msg =~ malformed\ function ]]; then
            echo "malformed function"
        elif [[ $msg =~ is\ a\ malformed ]]; then
            echo "malformed expression"
        else
            echo "$msg"
        fi
    fi
}

# Parses checkdoc output and generates summary entries.
# Extracts error messages, normalizes them, and appends to summary file.
#
# Reads from:
#   $CHECKDOC_OUT - Checkdoc results file
#
# Writes to:
#   $SUMMARY_BY_TYPE - Summary file in format "CheckType|ErrorType|Description"
parse_checkdoc_errors() {
    if [ -f "$CHECKDOC_OUT" ]; then
        grep -v "^---" "$CHECKDOC_OUT" | grep -v "^File:" | grep -v "^$" | while IFS= read -r line; do
            if [[ $line =~ :[0-9]+:\ (.+)$ ]]; then
                msg="${BASH_REMATCH[1]}"
                msg=$(normalize_error_message "$msg" "checkdoc")
                echo "Checkdoc (static)|Note|$msg" >> "$SUMMARY_BY_TYPE"
            else
                echo "Checkdoc (static)|Note|$line" >> "$SUMMARY_BY_TYPE"
            fi
        done
    fi
}

# Parses isolated byte-compile output and generates summary entries.
# Filters out errors using ISOLATED_FILTER_PATTERNS.
#
# Reads from:
#   $ISOLATED_OUT - Isolated byte-compile results file
#
# Writes to:
#   $SUMMARY_BY_TYPE - Summary file
parse_isolated_errors() {
    if [ -f "$ISOLATED_OUT" ]; then
        grep -E ":(Warning|Error):" "$ISOLATED_OUT" | grep -v "$ISOLATED_FILTER_PATTERNS" | while IFS= read -r line; do
            if [[ $line =~ :Warning:\ (.+)$ ]]; then
                desc="${BASH_REMATCH[1]}"
                desc=$(normalize_error_message "$desc" "byte-compile")
                echo "Byte-Compile (isolated)|Warning|$desc" >> "$SUMMARY_BY_TYPE"
            elif [[ $line =~ :Error:\ (.+)$ ]]; then
                desc="${BASH_REMATCH[1]}"
                desc=$(normalize_error_message "$desc" "byte-compile")
                echo "Byte-Compile (isolated)|Error|$desc" >> "$SUMMARY_BY_TYPE"
            fi
        done
    fi
}

# Parses loaded byte-compile output and generates summary entries.
#
# Reads from:
#   $LOADED_OUT - Loaded byte-compile results file
#
# Writes to:
#   $SUMMARY_BY_TYPE - Summary file
parse_loaded_errors() {
    if [ -f "$LOADED_OUT" ]; then
        grep -E ":(Warning|Error):|^[^:]+!$" "$LOADED_OUT" | grep -v "^---" | grep -v "^File:" | while IFS= read -r line; do
            if [[ $line =~ :Warning:\ (.+)$ ]]; then
                desc="${BASH_REMATCH[1]}"
                desc=$(normalize_error_message "$desc" "byte-compile")
                echo "Byte-Compile (loaded)|Warning|$desc" >> "$SUMMARY_BY_TYPE"
            elif [[ $line =~ :Error:\ (.+)$ ]]; then
                desc="${BASH_REMATCH[1]}"
                desc=$(normalize_error_message "$desc" "byte-compile")
                echo "Byte-Compile (loaded)|Error|$desc" >> "$SUMMARY_BY_TYPE"
            elif [[ $line =~ ^[[:space:]]*([^:]+!)$ ]]; then
                desc="${BASH_REMATCH[1]}"
                echo "Byte-Compile (loaded)|Error|$desc" >> "$SUMMARY_BY_TYPE"
            fi
        done
    fi
}

# Displays detailed check results if issues were found.
#
# Parameters:
#   checkdoc_files - Number of files with checkdoc issues
#   isolated_files - Number of files with isolated compile issues
#   loaded_files - Number of files with loaded compile issues
#
# Reads from:
#   $CHECKDOC_OUT, $ISOLATED_OUT, $LOADED_OUT - Result files
display_detailed_results() {
    local checkdoc_files=$1
    local isolated_files=$2
    local loaded_files=$3

    if [ "$checkdoc_files" -gt 0 ]; then
        echo ""
        print_separator
        echo "CHECKDOC WARNINGS (Static Analysis)"
        print_separator
        cat "$CHECKDOC_OUT"
    fi

    if [ "$isolated_files" -gt 0 ]; then
        echo ""
        print_separator
        echo "BYTE-COMPILE ISOLATED (Flymake-style)"
        print_separator
        cat "$ISOLATED_OUT"
    fi

    if [ "$loaded_files" -gt 0 ]; then
        echo ""
        print_separator
        echo "BYTE-COMPILE WITH INIT.EL LOADED"
        print_separator
        cat "$LOADED_OUT"
    fi
}

# Displays overall statistics summary table.
#
# Parameters:
#   total_files, checkdoc_files, isolated_files, loaded_files,
#   checkdoc_count, isolated_count, loaded_count, init_el_found
display_statistics_summary() {
    local total_files=$1
    local checkdoc_files=$2
    local isolated_files=$3
    local loaded_files=$4
    local checkdoc_count=$5
    local isolated_count=$6
    local loaded_count=$7
    local init_el_found=$8

    echo ""
    print_separator
    echo "SUMMARY: Overall Statistics"
    print_separator
    printf "%-46s | %14s | %17s | %16s | %-15s\n" "Check Type" "Files Analyzed" "Files with Issues" "Total Issues" "Status"
    printf "%s-+-%s-+-%s-+-%s-+-%s\n" "$(printf '%.0s-' {1..46})" "$(printf '%.0s-' {1..14})" "$(printf '%.0s-' {1..17})" "$(printf '%.0s-' {1..16})" "$(printf '%.0s-' {1..15})"
    printf "%-46s | %14s | %17s | %16s | %-15s\n" "Checkdoc (static analysis)" "$total_files" "$checkdoc_files" "$checkdoc_count" "$([ "$checkdoc_files" -eq 0 ] && echo '✓ PASS' || echo '✗ FAIL')"
    printf "%-46s | %14s | %17s | %16s | %-15s\n" "Byte-Compile Isolated (Flymake-style)" "$total_files" "$isolated_files" "$isolated_count" "$([ "$isolated_files" -eq 0 ] && echo '✓ PASS' || echo '✗ FAIL')"

    if [ "$init_el_found" -eq 1 ]; then
        printf "%-46s | %14s | %17s | %16s | %-15s\n" "Byte-Compile with init.el loaded" "$total_files" "$loaded_files" "$loaded_count" "$([ "$loaded_files" -eq 0 ] && echo '✓ PASS' || echo '✗ FAIL')"
    else
        printf "%-46s | %14s | %17s | %16s | %-15s\n" "Byte-Compile with init.el loaded" "SKIPPED" "N/A" "N/A" "N/A"
    fi
    print_separator
}

# Displays error breakdown grouped by type.
#
# Reads from:
#   $SUMMARY_BY_TYPE - Summary file with error entries
display_error_summary() {
    if [ -f "$SUMMARY_BY_TYPE" ] && [ -s "$SUMMARY_BY_TYPE" ]; then
        echo ""
        print_separator
        echo "SUMMARY: Errors by Type"
        print_separator
        printf "%-65s | %-25s | %-10s | %8s\n" "Description" "Check Type" "Error Type" "Count"
        printf "%s-+-%s-+-%s-+-%s\n" "$(printf '%.0s-' {1..65})" "$(printf '%.0s-' {1..25})" "$(printf '%.0s-' {1..10})" "$(printf '%.0s-' {1..8})"

        sort "$SUMMARY_BY_TYPE" | uniq -c | sort -rn | while IFS= read -r line; do
            count=$(echo "$line" | awk '{print $1}')
            rest="${line#"${line%%[![:space:]]*}"}"
            rest="${rest#*[0-9] }"
            IFS='|' read -r check_type error_type description <<< "$rest"
            check_type="${check_type#"${check_type%%[![:space:]]*}"}"
            check_type="${check_type%"${check_type##*[![:space:]]}"}"
            error_type="${error_type#"${error_type%%[![:space:]]*}"}"
            error_type="${error_type%"${error_type##*[![:space:]]}"}"
            description="${description#"${description%%[![:space:]]*}"}"
            description="${description%"${description##*[![:space:]]}"}"
            printf "%-65s | %-25s | %-10s | %8s\n" "${description:0:65}" "$check_type" "$error_type" "$count"
        done

        print_separator
    fi
}

# Extracts and prints checkdoc errors in pre-commit format.
#
# Parameters:
#   file - File path
#   checkdoc_result - Raw checkdoc output
#
# Outputs:
#   Errors in file:line:check_type:message format
#
# Side Effects:
#   Increments PRE_COMMIT_ERROR_COUNT for each error printed
print_checkdoc_errors_pre_commit() {
    local file="$1"
    local checkdoc_result="$2"
    local count=0

    while IFS= read -r line; do
        if [[ $line =~ :([0-9]+):\ (.+)$ ]]; then
            local line_num="${BASH_REMATCH[1]}"
            local msg="${BASH_REMATCH[2]}"
            print_pre_commit_error "$file" "$line_num" "Checkdoc" "$msg"
            count=$((count + 1))
        fi
    done < <(echo "$checkdoc_result" | grep -v "^Warning (emacs):")

    PRE_COMMIT_ERROR_COUNT=$((PRE_COMMIT_ERROR_COUNT + count))
}

# Extracts and prints byte-compile errors in pre-commit format.
#
# Parameters:
#   file - File path
#   compile_result - Raw byte-compile output
#   check_type - Type label (Byte-Compile-Isolated or Byte-Compile-Loaded)
#
# Outputs:
#   Errors in file:line:check_type:message format
#
# Side Effects:
#   Increments PRE_COMMIT_ERROR_COUNT for each error printed
print_byte_compile_errors_pre_commit() {
    local file="$1"
    local compile_result="$2"
    local check_type="$3"
    local count=0

    while IFS= read -r line; do
        # Try to extract line number if available (format: :line:Warning: or In function-name:)
        if [[ $line =~ :([0-9]+):(Warning|Error):\ (.+)$ ]]; then
            local line_num="${BASH_REMATCH[1]}"
            local msg="${BASH_REMATCH[3]}"
            print_pre_commit_error "$file" "$line_num" "$check_type" "$msg"
            count=$((count + 1))
        elif [[ $line =~ :(Warning|Error):\ (.+)$ ]]; then
            local msg="${BASH_REMATCH[2]}"
            print_pre_commit_error "$file" "" "$check_type" "$msg"
            count=$((count + 1))
        fi
    done < <(echo "$compile_result" | grep -E ":(Warning|Error):")

    PRE_COMMIT_ERROR_COUNT=$((PRE_COMMIT_ERROR_COUNT + count))
}

# Function to show help
show_help() {
    cat << 'EOF'
Emacs Lisp Comprehensive Checker
==================================

A comprehensive linting tool for Emacs Lisp files that runs three types of checks:
    1. Checkdoc - Style and documentation warnings (static analysis)
    2. Byte-Compile Isolated - Compilation warnings in isolation (Flymake-style)
    3. Byte-Compile Loaded - Compilation warnings with init.el loaded (integration)

USAGE:
    elisp-lint.sh [OPTIONS] <path>

ARGUMENTS:
    <path>        Path to an Emacs Lisp file (.el) or directory
                                - File: Checks a single .el file
                                - Directory: Recursively checks all .el files (excluding elpa/)

OPTIONS:
    -h, --help       Show this help message and exit
    -d, --debug      Enable debug mode (shows commands being executed)
    -p, --pre-commit Enable pre-commit mode (concise file:line:error output)

EXAMPLES:
    # Check a single file
    elisp-lint.sh ~/github/emacs.d/init.el

    # Check all files in a directory
    elisp-lint.sh ~/github/emacs.d

    # Check a specific feature file
    elisp-lint.sh ~/github/emacs.d/features/corfu-config.el

OUTPUT:
    The script provides:
    - Detailed warnings/errors organized by check type
    - Overall statistics showing files with issues vs total files
    - Error summary grouped by error type (not exact match)
    - Exit code 0 if all checks pass, 1 if issues found

NOTES:
    - Requires init.el in the target directory (or parent directories for files)
    - Does not create .elc byte-compiled files

EOF
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -d|--debug)
            DEBUG=true
            shift
            ;;
        -p|--pre-commit)
            PRE_COMMIT_MODE=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Run '$0 --help' for usage information."
            exit 1
            ;;
        *)
            TARGET="$1"
            shift
            ;;
    esac
done

# Check if target argument is provided
if [ -z "$TARGET" ]; then
    echo "Usage: $0 [OPTIONS] <emacs-directory-or-file>"
    echo "Examples:"
    echo "  $0 ~/github/emacs.d"
    echo "  $0 ~/github/emacs.d/init.el"
    echo "  $0 --debug ~/github/emacs.d/init.el"
    echo ""
    echo "Run '$0 --help' for more information."
    exit 1
fi

# Check if target exists
if [ ! -e "$TARGET" ]; then
    echo "Error: '$TARGET' does not exist"
    exit 1
fi

# Searches up directory tree to find init.el file.
#
# Parameters:
#   dir - Starting directory for search
#
# Returns:
#   Path to init.el if found
#
# Exit Code:
#   0 if found, 1 if not found
find_init_el() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/init.el" ]; then
            echo "$dir/init.el"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Temporary files for storing results
RESULTS_DIR=$(mktemp -d)
CHECKDOC_OUT="$RESULTS_DIR/checkdoc.txt"
ISOLATED_OUT="$RESULTS_DIR/isolated.txt"
LOADED_OUT="$RESULTS_DIR/loaded.txt"
STATS_FILE="$RESULTS_DIR/stats.txt"

# Initialize statistics
echo "0 0 0 0 0" > "$STATS_FILE"  # total_files checkdoc_files isolated_files loaded_files init_el_found

# Updates statistics counter at specified index.
#
# Parameters:
#   index - Statistics array index (0=total_files, 1=checkdoc_files,
#           2=isolated_files, 3=loaded_files, 4=init_el_found)
#   increment - Value to add to counter
#
# Side Effects:
#   Updates $STATS_FILE with new counter values
update_stats() {
    local index=$1
    local increment=$2
    local current
    current=$(cat "$STATS_FILE")
    local arr
    read -r -a arr <<< "$current"
    arr[index]=$((arr[index] + increment))
    echo "${arr[@]}" > "$STATS_FILE"
}

# Runs all three check types on a single Emacs Lisp file.
# Executes checkdoc, isolated byte-compile, and loaded byte-compile checks,
# writes results to output files, and updates statistics.
#
# Parameters:
#   file - Absolute path to .el file
#   init_el - Path to init.el (or empty if not found)
#
# Side Effects:
#   - Writes results to $CHECKDOC_OUT, $ISOLATED_OUT, $LOADED_OUT
#   - Updates statistics via update_stats()
#   - Prints "Checking: <file>" message to stdout
check_file() {
    local file="$1"
    local init_el="$2"
    local display_file
    display_file="$(replace_home "$file")"

    # Suppress progress messages in pre-commit mode
    if [ "$PRE_COMMIT_MODE" = false ]; then
        echo "Checking: $display_file"
    fi

    # Run checks
    local checkdoc_result
    local isolated_result
    local loaded_result
    checkdoc_result=$(run_checkdoc_check "$file" "$display_file")
    isolated_result=$(run_isolated_byte_compile "$file" "$display_file")

    if [ -n "$init_el" ] && [ -f "$init_el" ]; then
        loaded_result=$(run_loaded_byte_compile "$file" "$display_file" "$init_el")
    fi

    # In pre-commit mode, print errors immediately
    if [ "$PRE_COMMIT_MODE" = true ]; then
        if [ -n "$checkdoc_result" ]; then
            print_checkdoc_errors_pre_commit "$file" "$checkdoc_result"
        fi
        if [ -n "$isolated_result" ]; then
            print_byte_compile_errors_pre_commit "$file" "$isolated_result" "Byte-Compile-Isolated"
        fi
        if [ -n "$loaded_result" ]; then
            print_byte_compile_errors_pre_commit "$file" "$loaded_result" "Byte-Compile-Loaded"
        fi
    fi

    # Write results to output files and count issues
    local has_checkdoc=0
    local has_isolated=0
    local has_loaded=0

    if [ -n "$checkdoc_result" ]; then
        {
            echo "--- Checkdoc (Static Analysis) ---"
            echo "File: $display_file"
            echo "$checkdoc_result"
            echo ""
        } >> "$CHECKDOC_OUT"
        # Checkdoc results are actual warnings (already filtered), so mark as having issues
        has_checkdoc=1
    fi

    if [ -n "$isolated_result" ]; then
        {
            echo "--- Byte-Compile Isolated (Flymake-style) ---"
            echo "File: $display_file"
            echo "$isolated_result"
            echo ""
        } >> "$ISOLATED_OUT"
        # Only mark as having issues if there are actual Warning/Error lines
        if echo "$isolated_result" | grep -qE ":(Warning|Error):"; then
            has_isolated=1
        fi
    fi

    if [ -n "$loaded_result" ]; then
        {
            echo "--- Byte-Compile With init.el Loaded ---"
            echo "File: $display_file"
            echo "$loaded_result"
            echo ""
        } >> "$LOADED_OUT"
        # Only mark as having issues if there are actual Warning/Error lines or error messages ending with !
        if echo "$loaded_result" | grep -qE ":(Warning|Error):|!$"; then
            has_loaded=1
        fi
    fi

    # Update statistics
    update_stats 0 1  # total files
    update_stats 1 $has_checkdoc
    update_stats 2 $has_isolated
    update_stats 3 $has_loaded
}

# Determine if target is a file or directory
if [ -f "$TARGET" ]; then
    # Single file mode

    # Check if it's a .el file
    if [[ ! "$TARGET" =~ \.el$ ]]; then
        echo "Error: '$TARGET' is not an Emacs Lisp (.el) file"
        rm -rf "$RESULTS_DIR"
        exit 1
    fi

    FILE_DIR=$(dirname "$(realpath "$TARGET")")

    if [[ "$(basename "$TARGET")" == "init.el" ]]; then
        INIT_EL="$TARGET"
        update_stats 4 1
    else
        if INIT_EL=$(find_init_el "$FILE_DIR"); then
            update_stats 4 1
        fi
    fi

    if [ "$PRE_COMMIT_MODE" = false ]; then
        echo "Checking file: $(replace_home "$TARGET")"
        if [ -n "$INIT_EL" ]; then
            echo "Using init.el: $(replace_home "$INIT_EL")"
        else
            echo "Warning: init.el not found (loaded checks will be skipped)"
        fi
        echo ""
    fi

    check_file "$TARGET" "$INIT_EL"

elif [ -d "$TARGET" ]; then
    # Directory mode
    EMACS_DIR="$TARGET"

    # Check if init.el exists
    if [ -f "$EMACS_DIR/init.el" ]; then
        INIT_EL="$EMACS_DIR/init.el"
        update_stats 4 1
    else
        echo "Warning: init.el not found in '$EMACS_DIR' (loaded checks will be skipped)"
        INIT_EL=""
    fi

    if [ "$PRE_COMMIT_MODE" = false ]; then
        echo "Checking Emacs Lisp files in: $(replace_home "$EMACS_DIR")"
        if [ -n "$INIT_EL" ]; then
            echo "Using init.el: $(replace_home "$INIT_EL")"
        fi
        echo ""
    fi

    # Find and check all .el files (excluding elpa/)
    while IFS= read -r file; do
        check_file "$file" "$INIT_EL"
    done < <(find "$EMACS_DIR" -name "*.el" -not -path "*/elpa/*" | sort)
fi

# Read statistics
read -r -a stats < "$STATS_FILE"
total_files=${stats[0]}
checkdoc_files=${stats[1]}
isolated_files=${stats[2]}
loaded_files=${stats[3]}
init_el_found=${stats[4]}

# Count total warnings/errors
checkdoc_count=0
isolated_count=0
loaded_count=0

if [ -f "$CHECKDOC_OUT" ]; then
    checkdoc_count=$(grep -c "^File:" "$CHECKDOC_OUT")
fi

if [ -f "$ISOLATED_OUT" ]; then
    # shellcheck disable=SC2126  # Need grep pipeline for filtering before counting
    isolated_count=$(grep -E "(Warning|Error):" "$ISOLATED_OUT" | grep -v "$ISOLATED_FILTER_PATTERNS" | wc -l)
fi

if [ -f "$LOADED_OUT" ]; then
    # shellcheck disable=SC2126  # Need grep pipeline for filtering before counting
    loaded_count=$(grep -E ":(Warning|Error):|^[[:space:]]*[^:]+!$" "$LOADED_OUT" | grep -v "^---\|^File:" | wc -l)
fi

# Display results based on mode
if [ "$PRE_COMMIT_MODE" = true ]; then
    # Pre-commit mode: Simple final status
    if [ "$PRE_COMMIT_ERROR_COUNT" -gt 0 ]; then
        echo "✗ $PRE_COMMIT_ERROR_COUNT error(s) found in $total_files file(s)"
        rm -rf "$RESULTS_DIR"
        exit 1
    else
        echo "✓ All checks passed"
        rm -rf "$RESULTS_DIR"
        exit 0
    fi
else
    # Normal mode: Detailed output
    # Display detailed results first if there are issues
    display_detailed_results "$checkdoc_files" "$isolated_files" "$loaded_files"

    # Generate error summary by type
    SUMMARY_BY_TYPE=$(mktemp)

    # Parse errors from all check types
    parse_checkdoc_errors
    parse_isolated_errors
    parse_loaded_errors

    # Display summary tables
    display_statistics_summary "$total_files" "$checkdoc_files" "$isolated_files" "$loaded_files" \
        "$checkdoc_count" "$isolated_count" "$loaded_count" "$init_el_found"

    display_error_summary
    # Cleanup summary file
    rm -f "$SUMMARY_BY_TYPE"

    # Cleanup
    rm -rf "$RESULTS_DIR"

    # Exit with error code if any issues found
    if [ "$checkdoc_files" -gt 0 ] || [ "$isolated_files" -gt 0 ] || [ "$loaded_files" -gt 0 ]; then
        exit 1
    else
        echo "All checks passed! ✓"
        exit 0
    fi
fi
