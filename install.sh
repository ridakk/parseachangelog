#!/bin/sh
# shellcheck shell=dash
# shellcheck disable=SC2039

# Licensed under the MIT license
# This runs on Unix shells like bash/dash/ksh/zsh.

set -u

APP_NAME="parseachangelog"
APP_VERSION="0.1.3"

# Look for GitHub Enterprise-style base URL first
if [ -n "${PARSEACHANGELOG_INSTALLER_GHE_BASE_URL:-}" ]; then
    INSTALLER_BASE_URL="$PARSEACHANGELOG_INSTALLER_GHE_BASE_URL"
else
    INSTALLER_BASE_URL="${PARSEACHANGELOG_INSTALLER_GITHUB_BASE_URL:-https://github.com}"
fi

if [ -n "${INSTALLER_DOWNLOAD_URL:-}" ]; then
    ARTIFACT_DOWNLOAD_URL="$INSTALLER_DOWNLOAD_URL"
else
    ARTIFACT_DOWNLOAD_URL="${INSTALLER_BASE_URL}/ridakk/parseachangelog/releases/download/v${APP_VERSION}"
fi

PRINT_VERBOSE=${INSTALLER_PRINT_VERBOSE:-0}
PRINT_QUIET=${INSTALLER_PRINT_QUIET:-0}

if [ -n "${PARSEACHANGELOG_NO_MODIFY_PATH:-}" ]; then
    NO_MODIFY_PATH="$PARSEACHANGELOG_NO_MODIFY_PATH"
else
    NO_MODIFY_PATH=${INSTALLER_NO_MODIFY_PATH:-0}
fi

if [ "${PARSEACHANGELOG_DISABLE_UPDATE:-0}" = "1" ]; then
    INSTALL_UPDATER=0
else
    INSTALL_UPDATER=1
fi

UNMANAGED_INSTALL="${PARSEACHANGELOG_UNMANAGED_INSTALL:-}"
if [ -n "${UNMANAGED_INSTALL}" ]; then
    NO_MODIFY_PATH=1
    INSTALL_UPDATER=0
fi

AUTH_TOKEN="${PARSEACHANGELOG_GITHUB_TOKEN:-}"

# Helper functions
say() {
    if [ "0" = "$PRINT_QUIET" ]; then
        echo "$1"
    fi
}

say_verbose() {
    if [ "1" = "$PRINT_VERBOSE" ]; then
        echo "$1"
    fi
}

warn() {
    if [ "0" = "$PRINT_QUIET" ]; then
        local red
        local reset
        red=$(tput setaf 1 2>/dev/null || echo '')
        reset=$(tput sgr0 2>/dev/null || echo '')
        say "${red}WARN${reset}: $1" >&2
    fi
}

err() {
    if [ "0" = "$PRINT_QUIET" ]; then
        local red
        local reset
        red=$(tput setaf 1 2>/dev/null || echo '')
        reset=$(tput sgr0 2>/dev/null || echo '')
        say "${red}ERROR${reset}: $1" >&2
    fi
    exit 1
}

need_cmd() {
    if ! check_cmd "$1"; then
        err "need '$1' (command not found)"
    fi
}

check_cmd() {
    command -v "$1" > /dev/null 2>&1
    return $?
}

assert_nz() {
    if [ -z "$1" ]; then
        err "assert_nz $2"
    fi
}

ensure() {
    if ! "$@"; then
        err "command failed: $*"
    fi
}

ignore() {
    "$@"
}

# Downloader function
downloader() {
    if check_cmd curl; then
        _dld=curl
    elif check_cmd wget; then
        _dld=wget
    else
        _dld='curl or wget'
    fi

    if [ "$1" = --check ]; then
        need_cmd "$_dld"
    elif [ "$_dld" = curl ]; then
        if [ -n "${AUTH_TOKEN:-}" ]; then
            curl -sSfL --header "Authorization: Bearer ${AUTH_TOKEN}" "$1" -o "$2"
        else
            curl -sSfL "$1" -o "$2"
        fi
    elif [ "$_dld" = wget ]; then
        if [ -n "${AUTH_TOKEN:-}" ]; then
            wget --header "Authorization: Bearer ${AUTH_TOKEN}" "$1" -O "$2"
        else
            wget "$1" -O "$2"
        fi
    else
        err "Unknown downloader"
    fi
}

# Detect OS and architecture
detect_os_arch() {
    local _ostype
    local _cputype
    local _arch

    _ostype="$(uname -s)"
    _cputype="$(uname -m)"

    case "$_ostype" in
        Linux)
            _ostype=linux
            ;;
        Darwin)
            _ostype=darwin
            ;;
        MINGW* | MSYS* | CYGWIN*)
            _ostype=windows
            ;;
        *)
            err "unsupported OS: $_ostype"
            ;;
    esac

    case "$_cputype" in
        x86_64 | x64)
            _cputype=amd64
            ;;
        arm64 | aarch64)
            _cputype=arm64
            ;;
        *)
            err "unsupported CPU type: $_cputype"
            ;;
    esac

    _arch="${_ostype}-${_cputype}"
    echo "$_arch"
}

# Main installation function
install() {
    local _arch
    _arch=$(detect_os_arch)

    say "Installing $APP_NAME for $_arch..."

    # Create temporary directory
    local _dir
    _dir=$(mktemp -d)
    local _file
    _file="${_dir}/${APP_NAME}.tar.gz"

    # Download the binary
    local _url
    _url="${ARTIFACT_DOWNLOAD_URL}/${APP_NAME}-${_arch}.tar.gz"
    say_verbose "Downloading from $_url"
    say_verbose "to $_file"

    ensure mkdir -p "$_dir"
    if ! downloader "$_url" "$_file"; then
        say "failed to download $_url"
        say "this may be a standard network error, but it may also indicate"
        say "that $APP_NAME's release process is not working. When in doubt"
        say "please feel free to open an issue!"
        exit 1
    fi

    # Extract the archive
    ensure tar xf "$_file" -C "$_dir"
    
    # Find the binary in the extracted directory
    local _bin_path
    _bin_path=$(find "$_dir" -type f -name "$APP_NAME" -o -name "$APP_NAME.exe" | head -n 1)
    
    if [ -z "$_bin_path" ]; then
        err "Could not find $APP_NAME binary in the downloaded archive"
    fi

    say_verbose "Found binary at $_bin_path"

    if [ "$NO_MODIFY_PATH" = "0" ]; then
        local _install_path
        _install_path="/usr/local/bin"
        ensure mkdir -p "$_install_path"
        ensure cp "$_bin_path" "$_install_path/${APP_NAME}"
        ensure chmod +x "$_install_path/${APP_NAME}"
        say "Installed $APP_NAME to $_install_path/${APP_NAME}"
    else
        say "Binary is available at $_bin_path"
    fi

    # Cleanup
    ignore rm -rf "$_dir"
}

# Run the installation
install "$@" || exit 1 