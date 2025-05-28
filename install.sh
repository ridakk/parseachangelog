#!/bin/sh
# shellcheck shell=dash
# shellcheck disable=SC2039

# Licensed under the MIT license
# This runs on Unix shells like bash/dash/ksh/zsh.

set -e

APP_NAME="parseachangelog"
APP_VERSION="0.1.5"

# Default values
PARSEACHANGELOG_INSTALL_DIR=${PARSEACHANGELOG_INSTALL_DIR:-"/usr/local/bin"}
PARSEACHANGELOG_INSTALLER_GHE_BASE_URL=${PARSEACHANGELOG_INSTALLER_GHE_BASE_URL:-"https://github.com"}
PARSEACHANGELOG_INSTALLER_REPO=${PARSEACHANGELOG_INSTALLER_REPO:-"ridakk/parseachangelog"}
PARSEACHANGELOG_INSTALLER_VERSION=${PARSEACHANGELOG_INSTALLER_VERSION:-"latest"}
PARSEACHANGELOG_NO_MODIFY_PATH=${PARSEACHANGELOG_NO_MODIFY_PATH:-"0"}
INSTALLER_PRINT_VERBOSE=${INSTALLER_PRINT_VERBOSE:-"0"}

# Function to print verbose messages
verbose() {
    if [ "$INSTALLER_PRINT_VERBOSE" = "1" ]; then
        echo "$1"
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if we need sudo
needs_sudo() {
    if [ ! -w "$PARSEACHANGELOG_INSTALL_DIR" ]; then
        return 0
    fi
    return 1
}

# Function to get the latest version
get_latest_version() {
    if command_exists curl; then
        curl -s "${PARSEACHANGELOG_INSTALLER_GHE_BASE_URL}/${PARSEACHANGELOG_INSTALLER_REPO}/releases/latest" | grep -o '"tag_name": ".*"' | sed 's/"tag_name": "//;s/"//'
    elif command_exists wget; then
        wget -qO- "${PARSEACHANGELOG_INSTALLER_GHE_BASE_URL}/${PARSEACHANGELOG_INSTALLER_REPO}/releases/latest" | grep -o '"tag_name": ".*"' | sed 's/"tag_name": "//;s/"//'
    else
        echo "Error: Neither curl nor wget is installed. Please install one of them and try again."
        exit 1
    fi
}

# Function to detect OS and architecture
detect_os_arch() {
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    
    case $ARCH in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        armv7l) ARCH="arm" ;;
    esac
    
    verbose "Detected OS: $OS, Architecture: $ARCH"
}

# Function to download and install
download_and_install() {
    local version=$1
    local temp_dir=$(mktemp -d)
    local download_url="${PARSEACHANGELOG_INSTALLER_GHE_BASE_URL}/${PARSEACHANGELOG_INSTALLER_REPO}/releases/download/v${version}/parseachangelog_${OS}_${ARCH}.tar.gz"
    
    verbose "Downloading from: $download_url"
    
    # Download
    if command_exists curl; then
        curl -L "$download_url" -o "$temp_dir/parseachangelog.tar.gz"
    else
        wget -O "$temp_dir/parseachangelog.tar.gz" "$download_url"
    fi
    
    # Extract
    tar -xzf "$temp_dir/parseachangelog.tar.gz" -C "$temp_dir"
    
    # Install
    verbose "Installing to: $PARSEACHANGELOG_INSTALL_DIR"
    if needs_sudo; then
        verbose "Using sudo to install"
        sudo cp "$temp_dir/parseachangelog" "$PARSEACHANGELOG_INSTALL_DIR/parseachangelog"
        sudo chmod +x "$PARSEACHANGELOG_INSTALL_DIR/parseachangelog"
    else
        cp "$temp_dir/parseachangelog" "$PARSEACHANGELOG_INSTALL_DIR/parseachangelog"
        chmod +x "$PARSEACHANGELOG_INSTALL_DIR/parseachangelog"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Main installation process
main() {
    verbose "Starting installation..."
    
    # Detect OS and architecture
    detect_os_arch
    
    # Get version
    if [ "$PARSEACHANGELOG_INSTALLER_VERSION" = "latest" ]; then
        PARSEACHANGELOG_INSTALLER_VERSION=$(get_latest_version)
    fi
    verbose "Installing version: $PARSEACHANGELOG_INSTALLER_VERSION"
    
    # Download and install
    download_and_install "$PARSEACHANGELOG_INSTALLER_VERSION"
    
    # Add to PATH if needed
    if [ "$PARSEACHANGELOG_NO_MODIFY_PATH" = "0" ]; then
        if ! echo "$PATH" | grep -q "$PARSEACHANGELOG_INSTALL_DIR"; then
            echo "Adding $PARSEACHANGELOG_INSTALL_DIR to PATH"
            echo "export PATH=\"$PARSEACHANGELOG_INSTALL_DIR:\$PATH\"" >> "$HOME/.profile"
            echo "export PATH=\"$PARSEACHANGELOG_INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
        fi
    fi
    
    echo "Installation complete! parseachangelog is now available."
    echo "You may need to restart your shell or run 'source ~/.profile' to use parseachangelog."
}

# Run main
main
