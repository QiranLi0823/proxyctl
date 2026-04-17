#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default repository URL (can be overridden with REPO_URL env variable)
REPO_URL=${REPO_URL:-"https://raw.githubusercontent.com/qiranli0823/proxyctl/main"}
SCRIPT_URL="$REPO_URL/proxyctl.sh"

# Installation path
LOCAL_INSTALL_PATH="$HOME/bin/px"

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        # Fallback to checking $SHELL environment variable
        case "$SHELL" in
            *zsh) echo "zsh" ;;
            *bash) echo "bash" ;;
            *) echo "unknown" ;;
        esac
    fi
}

get_shell_config() {
    local shell_type="$1"
    case "$shell_type" in
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        *)
            echo "$HOME/.bashrc"
            ;;
    esac
}

alias_exists() {
    local config_file="$1"
    local alias_name="$2"
    grep -q "alias $alias_name=" "$config_file" 2>/dev/null
}

add_alias() {
    local config_file="$1"
    local script_path="$2"

    # Create config file if it doesn't exist
    if [ ! -f "$config_file" ]; then
        touch "$config_file"
    fi

    # Check if alias already exists
    if alias_exists "$config_file" "px"; then
        warn "Alias 'px' already exists in $config_file"
        warn "To update it, manually edit $config_file and change the alias path to:"
        warn "  alias px='source $script_path'"
        return 1
    fi

    # Add alias
    echo "" >> "$config_file"
    echo "# Proxy tool alias (installed $(date))" >> "$config_file"
    echo "alias px='source $script_path'" >> "$config_file"
    info "Added alias 'px' to $config_file"

    return 0
}

test_installation() {
    local script_path="$1"
    if [ -x "$script_path" ]; then
        info "Script is executable: $script_path"
        return 0
    else
        error "Script is not executable: $script_path"
        return 1
    fi
}

download_script() {
    local url="$1"
    local output_path="$2"

    info "Downloading proxy tool from: $url"

    if command -v curl >/dev/null 2>&1; then
        curl -sSL "$url" -o "$output_path"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$output_path"
    else
        error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    if [ $? -ne 0 ]; then
        error "Failed to download script from $url"
        exit 1
    fi

    chmod +x "$output_path"
    info "Script downloaded and made executable: $output_path"
}

remove_alias() {
    local config_file="$1"
    local alias_name="$2"

    if [ ! -f "$config_file" ]; then
        warn "Configuration file not found: $config_file"
        return 1
    fi

    if alias_exists "$config_file" "$alias_name"; then
        # Remove the alias line and any preceding comment
        sed -i '/^# Proxy tool alias/,/alias $alias_name=/d' "$config_file" 2>/dev/null || \
        sed -i "/alias $alias_name=/d" "$config_file"
        info "Removed alias '$alias_name' from $config_file"
        return 0
    else
        warn "Alias '$alias_name' not found in $config_file"
        return 1
    fi
}

uninstall_proxyctl() {
    info "Starting Proxyctl uninstallation..."

    # Dry-run mode
    if [ "$DRY_RUN" = true ]; then
        info "DRY RUN - No changes will be made"
        info "Would uninstall from auto-detected location"
        info "Would remove alias 'px' from shell configuration"
        exit 0
    fi

    # Try to auto-detect installation
    if [ -f "$LOCAL_INSTALL_PATH" ]; then
        INSTALL_PATH="$LOCAL_INSTALL_PATH"
        info "Found local installation at: $INSTALL_PATH"
    else
        error "Could not find proxy tool installation in $LOCAL_INSTALL_PATH."
        exit 1
    fi

    # Remove the script
    rm -f "$INSTALL_PATH"
    info "Removed script: $INSTALL_PATH"

    # Remove empty parent directory
    local parent_dir=$(dirname "$INSTALL_PATH")
    if [ -d "$parent_dir" ] && [ -z "$(ls -A "$parent_dir" 2>/dev/null)" ]; then
        rmdir "$parent_dir" 2>/dev/null && info "Removed empty directory: $parent_dir"
    fi

    # Remove alias from shell config
    SHELL_TYPE=$(detect_shell)
    CONFIG_FILE=$(get_shell_config "$SHELL_TYPE")
    remove_alias "$CONFIG_FILE" "px"

    info "Uninstallation completed! ✨"
    echo ""
    info "To apply changes, reload your shell configuration:"
    echo "  source $CONFIG_FILE"
}

show_usage() {
    cat << EOF
Proxyctl Installer/Uninstaller

Usage: $0 [OPTIONS]

Options:
  -d, --dry-run    Show what would be done without making changes
  -u, --uninstall  Uninstall from auto-detected location
  -h, --help       Show this help message

Environment variables:
  REPO_URL         Override the repository URL (default: $REPO_URL)

Installation:
  # Install locally (to ~/bin/px)
  curl -sSL $REPO_URL/install.sh | bash

Uninstallation:
  # Uninstall from auto-detected location
  curl -sSL $REPO_URL/install.sh | bash -s -- --uninstall

EOF
}

# Parse command line arguments
DRY_RUN=false
UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -u|--uninstall)
            UNINSTALL=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main installation
main() {
    # Check if uninstall mode is set
    if [ "$UNINSTALL" = true ]; then
        uninstall_proxyctl
        exit 0
    fi

    info "Starting Proxyctl installation..."

    INSTALL_PATH="$LOCAL_INSTALL_PATH"
    # Ensure ~/bin exists
    mkdir -p "$(dirname "$INSTALL_PATH")"
    # Add ~/bin to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        warn "\$HOME/bin is not in your PATH. Adding it to your shell configuration..."
        if [ "$DRY_RUN" = false ]; then
            SHELL_TYPE=$(detect_shell)
            CONFIG_FILE=$(get_shell_config "$SHELL_TYPE")
            echo '' >> "$CONFIG_FILE"
            echo '# Add ~/bin to PATH' >> "$CONFIG_FILE"
            echo 'export PATH="$HOME/bin:$PATH"' >> "$CONFIG_FILE"
            info "Added \$HOME/bin to PATH in $CONFIG_FILE"
        fi
    fi
    info "Installing locally to: $INSTALL_PATH"

    if [ "$DRY_RUN" = true ]; then
        info "DRY RUN - No changes will be made"
        info "Would download script from: $SCRIPT_URL"
        info "Would install to: $INSTALL_PATH"
        info "Would add alias 'px' to shell configuration"
        exit 0
    fi

    # Download and install the script
    download_script "$SCRIPT_URL" "$INSTALL_PATH"

    # Detect shell and add alias
    SHELL_TYPE=$(detect_shell)
    CONFIG_FILE=$(get_shell_config "$SHELL_TYPE")

    info "Detected shell: $SHELL_TYPE"
    info "Using configuration file: $CONFIG_FILE"

    add_alias "$CONFIG_FILE" "$INSTALL_PATH"

    # Test the installation
    if test_installation "$INSTALL_PATH"; then
        info "Installation completed successfully! 🎉"
        echo ""
        info "To start using the proxy tool:"
        echo ""
        echo "  1. Reload your shell configuration:"
        echo "     source $CONFIG_FILE"
        echo ""
        echo "  2. Start the proxy:"
        echo "     px on"
        echo ""
        echo "  3. For more options:"
        echo "     px"
        echo ""
        warn "Note: The 'px' command must be sourced to work properly."
        warn "      The alias has been set up to do this automatically."
    else
        error "Installation test failed!"
        exit 1
    fi
}

# Run main function
main "$@"