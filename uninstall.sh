#!/usr/bin/env bash
# Reverses install.sh: removes the ~/.config/quickshell/mellow symlink and,
# after asking, the fonts in ~/.local/share/fonts/mellow. Quickshell itself is
# left installed (remove it with `sudo pacman -Rns quickshell` if you want).
# Hyprland configuration is never touched; remove any autostart line you added.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINK="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/mellow"
FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/mellow"

info() { printf '\033[1;36m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

if command -v qs >/dev/null && qs list -p "$REPO" >/dev/null 2>&1; then
    info "Stopping running MELLOW instance"
    qs kill -p "$REPO" || warn "could not stop MELLOW; stop it manually"
fi

if [[ -L $LINK && $(readlink -f "$LINK") == "$REPO" ]]; then
    rm "$LINK"
    info "Removed $LINK"
elif [[ -e $LINK ]]; then
    warn "$LINK does not point to this repository; left untouched"
fi

if [[ -d $FONT_DIR ]]; then
    read -r -p "Remove MELLOW fonts in $FONT_DIR? [y/N] " reply
    if [[ $reply =~ ^[Yy]$ ]]; then
        rm -r -- "$FONT_DIR"
        fc-cache -f >/dev/null 2>&1 || true
        info "Removed fonts"
    fi
fi

info "Uninstalled. Remove any MELLOW autostart line you added to Hyprland."
