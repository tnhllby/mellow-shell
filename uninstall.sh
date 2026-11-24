#!/usr/bin/env bash
# Reverses install.sh: MELLOW's Hyprland files, app theming, the
# ~/.config/quickshell/mellow symlink and, after asking, the fonts. Installed
# packages, enabled services, the default browser and MELLOW's own settings
# stay. Changed files are first copied to ~/.local/state/mellow/backup/<time>/.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/setup-lib.sh
source "$REPO/scripts/setup-lib.sh"

if command -v qs >/dev/null && qs list -p "$REPO" >/dev/null 2>&1; then
    info "Stopping running MELLOW instance"
    qs kill -p "$REPO" || warn "could not stop MELLOW; stop it manually"
fi

# Hyprland: the line first, so it never requires missing files.
remove_block "$HYPR/hyprland.lua"
if [[ -d $HYPR/mellow ]]; then
    remove_hypr_parts
    rmdir -- "$HYPR/mellow" 2>/dev/null || warn "$HYPR/mellow holds other files; left there"
    info "Removed MELLOW's Hyprland files"
fi

# App theming.
before="$STATE/before-theming"
if [[ -d $before ]]; then
    if [[ -s $MELLOW_CONFIG ]] && command -v jq >/dev/null; then
        set_config theming apps false
    fi
    remove_block "$CONFIG_HOME/kitty/kitty.conf"
    remove_block "$CONFIG_HOME/gtk-3.0/gtk.css"
    remove_block "$CONFIG_HOME/gtk-4.0/gtk.css"

    # Give kdeglobals its old colours back; other KDE settings stay as they are now.
    kde="$CONFIG_HOME/kdeglobals"
    if [[ -e $kde ]]; then
        backup "$kde"
        {
            awk '/^\[/ { skip = /^\[Colors:/ || /^\[WM\]/ } !skip' "$kde"
            if [[ -e $before/kdeglobals ]]; then
                awk '/^\[/ { keep = /^\[Colors:/ || /^\[WM\]/ } keep' "$before/kdeglobals"
            fi
        } | cat -s | write_file "$kde"
        if command -v kwriteconfig6 >/dev/null && command -v kreadconfig6 >/dev/null; then
            for entry in General:ColorScheme Icons:Theme KDE:widgetStyle; do
                group=${entry%%:*} key=${entry#*:} old=""
                if [[ -e $before/kdeglobals ]]; then
                    old="$(kreadconfig6 --file "$before/kdeglobals" --group "$group" --key "$key")"
                fi
                if [[ -n $old ]]; then
                    kwriteconfig6 --file "$kde" --group "$group" --key "$key" "$old"
                else
                    kwriteconfig6 --file "$kde" --group "$group" --key "$key" --delete
                fi
            done
        fi
    fi
    if command -v gsettings >/dev/null; then
        for key in color-scheme gtk-theme; do
            [[ ! -s $before/$key ]] || gsettings set org.gnome.desktop.interface "$key" "$(cat "$before/$key")" || true
        done
    fi
    for file in "${DATA_HOME:?}/color-schemes/Mellow.colors" \
        "${STATE:?}"/theme/{kitty.conf,gtk.css,Mellow.colors,hyprland.lua} \
        "${STATE:?}"/before-theming/{kdeglobals,color-scheme,gtk-theme}; do
        [[ ! -e $file ]] || rm -- "${file:?}"
    done
    rmdir -- "$STATE/theme" "$before" 2>/dev/null || true
    info "Removed app theming"
fi

if [[ -L $LINK && $(readlink -f "$LINK") == "$REPO" ]]; then
    rm -- "${LINK:?}"
    info "Removed $LINK"
elif [[ -e $LINK ]]; then
    warn "$LINK does not point to this repository; left untouched"
fi

if [[ -d $FONT_DIR ]] && confirm "Remove MELLOW fonts in $FONT_DIR?"; then
    for file in "${FONT_DIR:?}"/{*.ttf,*.txt}; do
        [[ ! -e $file ]] || rm -- "${file:?}"
    done
    rmdir -- "$FONT_DIR" 2>/dev/null || warn "$FONT_DIR holds other files; left there"
    fc-cache -f >/dev/null 2>&1 || true
    info "Removed fonts"
fi

info "Uninstalled."
[[ ! -d $BACKUP ]] || info "Changed files were kept in $BACKUP"
