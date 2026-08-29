#!/usr/bin/env bash
# Shared helpers for the .install modules. Sourced by install.sh — never run
# directly. Modules inherit `set -euo pipefail` from install.sh, so helpers
# signal failure via exit codes, not `exit`.
#
# Trimmed port of the official dotfiles library.sh. Differences:
# - yay only (Omarchy ships yay; paru is not installed)
# - no package-rot retry net (small, curated package set)

#-------------------------------------------------------------------- logging
# Plain ANSI; respects NO_COLOR (https://no-color.org). No logging framework —
# these run once, interactively, from a TTY.
if [[ -z "${NO_COLOR:-}" ]]; then
    _C_INFO=$'\033[34m' _C_OK=$'\033[32m' _C_WARN=$'\033[33m' _C_ERR=$'\033[31m' _C_OFF=$'\033[0m'
else
    _C_INFO='' _C_OK='' _C_WARN='' _C_ERR='' _C_OFF=''
fi
info() { printf '%s:: %s%s\n' "$_C_INFO" "$*" "$_C_OFF"; }
ok()   { printf '%s:: %s%s\n' "$_C_OK" "$*" "$_C_OFF"; }
warn() { printf '%sWARN: %s%s\n' "$_C_WARN" "$*" "$_C_OFF"; }
err()  { printf '%sERROR: %s%s\n' "$_C_ERR" "$*" "$_C_OFF" >&2; }

#--------------------------------------------------------- package detection
# Exit-code based: `pacman -Qq` is locale- and color-proof.
_isInstalled() { pacman -Qq "$1" &>/dev/null; }

# Keep only names that actually exist in the repos or AUR (`yay -Si` covers
# both); warn (on stderr, so stdout stays a clean package list for the
# caller's mapfile) about the rotten ones instead of killing the batch.
# Prints the valid names.
_filterAvailable() {
    local pkg
    for pkg in "$@"; do
        if yay -Si "$pkg" &>/dev/null; then
            printf '%s\n' "$pkg"
        else
            warn "Package not found in repos/AUR, skipping: $pkg" >&2
        fi
    done
}

#--------------------------------------------------------- package install
# Installs only what's missing (`yay --needed`); dedups arguments first.
_installPackages() {
    local -a unique missing
    local -A seen=()
    local pkg
    for pkg in "$@"; do
        [[ -n ${seen[$pkg]:-} ]] && continue
        seen[$pkg]=1
        _isInstalled "$pkg" || missing+=("$pkg")
    done
    ((${#missing[@]})) || { info "All packages already installed."; return 0; }
    mapfile -t unique < <(_filterAvailable "${missing[@]}")
    ((${#unique[@]})) || return 0
    yay -S --needed --noconfirm "${unique[@]}"
}

#------------------------------------------------------- package uninstall
# Removes only what's actually installed — re-runs and fresh installs where
# the bloat was never present are safe no-ops.
_uninstallPackages() {
    local -a installed=()
    local pkg
    for pkg in "$@"; do
        _isInstalled "$pkg" && installed+=("$pkg")
    done
    ((${#installed[@]})) || { info "No bloat packages present."; return 0; }
    yay -Rns --noconfirm "${installed[@]}"
}
