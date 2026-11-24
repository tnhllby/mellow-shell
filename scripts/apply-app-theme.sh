#!/usr/bin/env bash
# Generates app themes from MELLOW's seed colour with matugen and applies the
# ones that changed: kitty, KDE apps (Dolphin, Gwenview), GTK apps and
# Hyprland's borders. Run by AppThemeService when theming.apps is on; the
# installer connects the apps to the generated files.
#
#   apply-app-theme.sh <#rrggbb> <dark|light> <matugen scheme type>
#
# MELLOW_THEME_NO_RELOAD=1 only writes files (no running app is told).
set -euo pipefail

seed=$1 mode=$2 type=$3
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="${XDG_STATE_HOME:-$HOME/.local/state}/mellow/theme"
config="${XDG_CONFIG_HOME:-$HOME/.config}"
data="${XDG_DATA_HOME:-$HOME/.local/share}"

[[ $seed =~ ^#[0-9a-fA-F]{6}$ ]] || { echo "invalid seed: $seed" >&2; exit 2; }
[[ $mode == dark || $mode == light ]] || { echo "invalid mode: $mode" >&2; exit 2; }

tmp="$(mktemp -d)"
trap 'rm -rf -- "${tmp:?}"' EXIT
mkdir -p "$out"

{
    echo '[config]'
    # Terminal colours, pulled towards the seed.
    echo '[config.custom_colors]'
    for c in red:#e5484d green:#46a758 yellow:#e2a336 blue:#3e8fe0 magenta:#b06bd6 cyan:#2fa7b5; do
        echo "${c%%:*} = { color = \"${c#*:}\", blend = true }"
    done
    for f in kitty.conf gtk.css Mellow.colors hyprland.lua; do
        printf '[templates.%s]\ninput_path = "%s"\noutput_path = "%s"\n' \
            "${f//./_}" "$here/templates/$f" "$tmp/out/$f"
    done
} > "$tmp/config.toml"
mkdir "$tmp/out"
matugen color hex "$seed" -q -m "$mode" -t "$type" -c "$tmp/config.toml"

# Copies a generated file if it changed; true when it did.
changed() {
    cmp -s "$tmp/out/$1" "$out/$1" && return 1
    cp "$tmp/out/$1" "$out/$1.new"
    mv "$out/$1.new" "$out/$1"
}

live() { [[ -z ${MELLOW_THEME_NO_RELOAD:-} ]]; }

if changed kitty.conf && live; then
    pkill -USR1 -u "$UID" -x kitty || true
fi

changed gtk.css || true

# kdeglobals holds the user's other KDE settings: only the colour groups change.
if changed Mellow.colors || ! grep -qs '^ColorScheme=Mellow$' "$config/kdeglobals"; then
    mkdir -p "$data/color-schemes" "$config"
    cp "$out/Mellow.colors" "$data/color-schemes/Mellow.colors"
    touch "$config/kdeglobals"
    awk '/^\[/ { skip = /^\[Colors:/ || /^\[WM\]/ } !skip' "$config/kdeglobals" > "$tmp/kdeglobals"
    echo >> "$tmp/kdeglobals"
    awk '/^\[/ { keep = /^\[Colors:/ || /^\[WM\]/ } keep' "$out/Mellow.colors" >> "$tmp/kdeglobals"
    # Written in place, so a symlinked kdeglobals stays one.
    cat -s "$tmp/kdeglobals" > "$config/kdeglobals"
    if command -v kwriteconfig6 >/dev/null; then
        icons=breeze-dark
        [[ $mode == dark ]] || icons=breeze
        kwriteconfig6 --file kdeglobals --group General --key ColorScheme Mellow
        kwriteconfig6 --file kdeglobals --group Icons --key Theme "$icons"
        kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Breeze
    fi
    if live && command -v dbus-send >/dev/null; then
        dbus-send --type=signal /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:0 int32:0 || true
    fi
fi

# GTK theme and light/dark preference (Firefox follows the latter).
if live && command -v gsettings >/dev/null; then
    theme=adw-gtk3
    [[ $mode == light ]] || theme=adw-gtk3-dark
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$mode" || true
    gsettings set org.gnome.desktop.interface gtk-theme "$theme" || true
fi

if changed hyprland.lua && live && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} && -d $config/hypr/mellow ]]; then
    hyprctl reload >/dev/null || true
fi
