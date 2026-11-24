#!/usr/bin/env bash
# MELLOW installer for Arch Linux + Hyprland (0.57 or newer, Lua config).
#
# Steps (choose with flags, or all of them with no flags):
#   --deps   packages MELLOW needs, and their services (pacman/systemctl, sudo)
#   --apps   kitty, Firefox (made the default browser), Dolphin, Gwenview
#   --fonts  Google Sans Flex, Roboto Flex, Roboto Mono and Material Symbols
#            Rounded into ~/.local/share/fonts/mellow (no sudo)
#   --link   symlink this repository to ~/.config/quickshell/mellow
#   --hypr   Hyprland: keybindings, environment and blur rule; autostart and
#            matching window decorations are asked about
#   --theme  connect kitty, KDE and GTK apps to MELLOW's colours
#
# Every changed file is first copied to ~/.local/state/mellow/backup/<time>/.
# Undo with ./uninstall.sh.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/setup-lib.sh
source "$REPO/scripts/setup-lib.sh"

GF="https://github.com/google/fonts/raw/main/ofl"
MS="https://github.com/google/material-design-icons/raw/master"
# family|file name|url
FONTS=(
    "Google Sans Flex|GoogleSansFlex.ttf|$GF/googlesansflex/GoogleSansFlex%5BROND,opsz,slnt,wdth,wght%5D.ttf"
    "Roboto Flex|RobotoFlex.ttf|$GF/robotoflex/RobotoFlex%5BGRAD,XOPQ,XTRA,YOPQ,YTAS,YTDE,YTFI,YTLC,YTUC,opsz,slnt,wdth,wght%5D.ttf"
    "Roboto Mono|RobotoMono.ttf|$GF/robotomono/RobotoMono%5Bwght%5D.ttf"
    "Material Symbols Rounded|MaterialSymbolsRounded.ttf|$MS/variablefont/MaterialSymbolsRounded%5BFILL,GRAD,opsz,wght%5D.ttf"
)
LICENSES=(
    "OFL-GoogleSansFlex.txt|$GF/googlesansflex/OFL.txt"
    "OFL-RobotoFlex.txt|$GF/robotoflex/OFL.txt"
    "OFL-RobotoMono.txt|$GF/robotomono/OFL.txt"
    "LICENSE-MaterialSymbols.txt|$MS/LICENSE"
)

STEPS=(deps apps fonts link hypr theme)
declare -A DO=()

usage() {
    sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
    cat <<USAGE

Usage: ./install.sh [--deps] [--apps] [--fonts] [--link] [--hypr] [--theme] [--dry-run] [-y]
  --dry-run  print what would happen without changing anything
  -y         answer yes to everything (including autostart and decorations)
USAGE
}

while (($#)); do
    case $1 in
        --deps | --apps | --fonts | --link | --hypr | --theme) DO[${1#--}]=1 ;;
        --dry-run) DRY_RUN=1 ;;
        -y | --yes) ASSUME_YES=1 ;;
        -h | --help) usage; exit 0 ;;
        *) die "unknown option: $1 (see --help)" ;;
    esac
    shift
done
if ((${#DO[@]} == 0)); then
    for step in "${STEPS[@]}"; do DO[$step]=1; done
fi

preflight() {
    ((EUID != 0)) || die "run as your normal user, not root (sudo is used only for packages and services)"
    command -v pacman >/dev/null || die "pacman not found: this installer supports Arch Linux only"
    [[ -f $REPO/shell.qml ]] || die "shell.qml not found next to install.sh"
}

installed() { pacman -Qq "$1" >/dev/null 2>&1; }

# Installs the missing ones of the given packages.
packages() {
    local missing=() name
    for name in "$@"; do
        installed "$name" || missing+=("$name")
    done
    if ((${#missing[@]} == 0)); then
        info "  all installed"
    elif confirm "Install ${missing[*]} with sudo pacman?"; then
        run sudo pacman -S --needed "${missing[@]}"
    else
        warn "skipped ${missing[*]}"
    fi
}

install_deps() {
    info "Packages for MELLOW"
    local list=(
        hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
        matugen ddcutil jq curl fontconfig libnotify xdg-utils
        pipewire wireplumber networkmanager bluez bluez-utils upower
        # App theming: KDE and GTK apps.
        plasma-integration breeze breeze-icons kconfig adw-gtk-theme
        gsettings-desktop-schemas dconf archlinux-xdg-menu
    )
    # Any Quickshell build is fine, and these conflict with alternatives.
    command -v qs >/dev/null || list+=(quickshell)
    if installed pulseaudio; then
        warn "pulseaudio is installed: MELLOW's volume control needs pipewire-pulse instead"
    else
        list+=(pipewire-pulse)
    fi
    if installed tlp || installed tuned-ppd || installed auto-cpufreq; then
        info "  another power manager is installed; skipping power-profiles-daemon"
    else
        list+=(power-profiles-daemon)
    fi
    packages "${list[@]}"
    enable_services

    # ddcutil needs the i2c-dev module and access to /dev/i2c-*; not changed here.
    if ! id -nG | grep -qw i2c; then
        warn "External monitor brightness needs i2c access. To enable it:"
        warn "  sudo modprobe i2c-dev; echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf"
        warn "  sudo groupadd -f i2c; sudo usermod -aG i2c \"\$USER\"   (then log in again)"
    fi
}

enable_services() {
    local units=() unit other=""
    for unit in bluetooth power-profiles-daemon; do
        if systemctl cat "$unit" >/dev/null 2>&1 && ! systemctl is-enabled -q "$unit" 2>/dev/null; then
            units+=("$unit")
        fi
    done
    # Two network managers at once break the connection.
    if ! systemctl is-enabled -q NetworkManager 2>/dev/null; then
        for unit in systemd-networkd iwd dhcpcd connman; do
            if systemctl is-enabled -q "$unit" 2>/dev/null; then
                other=$unit
            fi
        done
        if [[ -n $other ]]; then
            warn "$other manages the network; MELLOW's Wi-Fi controls need NetworkManager (not changed)"
        else
            units+=(NetworkManager)
        fi
    fi
    if ((${#units[@]})) && confirm "Enable the services ${units[*]}?"; then
        run sudo systemctl enable --now "${units[@]}" || warn "could not enable every service"
    fi
}

install_apps() {
    info "Applications"
    packages kitty firefox dolphin gwenview
    if ((DRY_RUN)) || installed firefox; then
        backup "$CONFIG_HOME/mimeapps.list"
        run xdg-settings set default-web-browser firefox.desktop ||
            warn "could not make Firefox the default browser"
    fi
}

install_fonts() {
    info "Fonts -> $FONT_DIR"
    command -v curl >/dev/null || die "curl is required to download fonts"
    command -v fc-list >/dev/null || die "fontconfig (fc-list) is required"
    run mkdir -p "$FONT_DIR"

    local entry family file url changed=0 installed
    installed="$(fc-list : family | tr ',' '\n')"
    for entry in "${FONTS[@]}"; do
        IFS='|' read -r family file url <<<"$entry"
        if grep -qxF "$family" <<<"$installed"; then
            info "  $family already installed"
            continue
        fi
        info "  downloading $family"
        run curl -fL --retry 2 -o "$FONT_DIR/$file" "$url"
        changed=1
    done
    if ((changed)); then
        for entry in "${LICENSES[@]}"; do
            IFS='|' read -r file url <<<"$entry"
            run curl -fsL --retry 2 -o "$FONT_DIR/$file" "$url" || warn "could not fetch $file"
        done
        run fc-cache -f "$FONT_DIR"
    fi
}

link_shell() {
    info "Shell config -> $LINK"
    if [[ -L $LINK ]]; then
        if [[ $(readlink -f "$LINK") == "$REPO" ]]; then
            info "  already linked"
            return
        fi
        die "$LINK is a symlink to $(readlink -f "$LINK"); remove it first"
    fi
    [[ ! -e $LINK ]] || die "$LINK already exists and is not a symlink; refusing to overwrite it"
    run mkdir -p "$(dirname "$LINK")"
    run ln -s "$REPO" "$LINK"
}

setup_hypr() {
    info "Hyprland -> $HYPR/mellow"
    local part parts=(keybinds environment blur)
    if confirm "Start MELLOW together with Hyprland?"; then
        parts+=(autostart)
    fi
    if confirm "Let MELLOW set gaps, rounding, blur and border colours of windows?"; then
        parts+=(decoration)
    fi

    if [[ ! -e $HYPR/hyprland.lua ]]; then
        if [[ ! -e /usr/share/hypr/hyprland.lua ]]; then
            warn "no example hyprland.lua found; is Hyprland 0.57 installed? Skipped"
            return
        fi
        if [[ -e $HYPR/hyprland.conf ]]; then
            warn "Hyprland 0.57 no longer reads hyprland.conf; creating hyprland.lua (your old file is kept but unused)"
        fi
        run mkdir -p "$HYPR"
        run cp /usr/share/hypr/hyprland.lua "$HYPR/hyprland.lua"
    fi

    remove_hypr_parts
    run mkdir -p "$HYPR/mellow"
    for part in "${parts[@]}"; do
        run cp "$REPO/hypr/$part.lua" "$HYPR/mellow/$part.lua"
    done
    {
        echo "-- Written by MELLOW's install.sh; run it again to change the parts."
        for part in "${parts[@]}"; do echo "require(\"mellow.$part\")"; done
    } | write_file "$HYPR/mellow/init.lua"
    add_block "$HYPR/hyprland.lua" end "-- " "" 'require("mellow.init")'

    if ! ((DRY_RUN)) && command -v Hyprland >/dev/null; then
        local result
        result="$(Hyprland --verify-config -c "$HYPR/hyprland.lua" 2>&1 || true)"
        if [[ $result == *"config ok"* ]]; then
            info "  Hyprland accepts the configuration"
        else
            warn "Hyprland reports a problem with $HYPR/hyprland.lua:"
            sed -n '/Config parsing result/,$p' <<<"$result" >&2
            warn "undo with ./uninstall.sh, or restore $BACKUP"
        fi
    fi
}

setup_theme() {
    info "App colours"
    if ! ((DRY_RUN)) && ! { command -v matugen && command -v jq; } >/dev/null; then
        warn "matugen and jq are needed (./install.sh --deps); skipped"
        return
    fi
    # Kept once, for uninstall.sh.
    local before="$STATE/before-theming" key value
    if [[ ! -d $before ]] && ! ((DRY_RUN)); then
        mkdir -p "$before"
        [[ ! -e $CONFIG_HOME/kdeglobals ]] || cp -L "$CONFIG_HOME/kdeglobals" "$before/kdeglobals"
        if command -v gsettings >/dev/null; then
            for key in color-scheme gtk-theme; do
                if value="$(gsettings get org.gnome.desktop.interface "$key" 2>/dev/null)"; then
                    printf '%s\n' "$value" > "$before/$key"
                fi
            done
        fi
    fi
    add_block "$CONFIG_HOME/kitty/kitty.conf" end "# " "" "include $STATE/theme/kitty.conf"
    # GTK only reads an @import at the top of the file.
    local v
    for v in 3.0 4.0; do
        add_block "$CONFIG_HOME/gtk-$v/gtk.css" start "/* " " */" "@import url(\"file://$STATE/theme/gtk.css\");"
    done
    set_config theming apps true

    # First theme now; MELLOW keeps it up to date afterwards.
    local seed mode=dark
    seed="$(sed -n 's/.*property string seed: "\(#[0-9a-fA-F]*\)".*/\1/p' "$REPO/core/ColorScheme.qml")"
    if [[ -s $STATE/theme.json ]] && ! ((DRY_RUN)); then
        seed="$(jq -r --arg d "$seed" '.scheme.seed // $d' "$STATE/theme.json" 2>/dev/null || echo "$seed")"
        mode="$(jq -r 'if .mode == "light" then "light" else "dark" end' "$STATE/theme.json" 2>/dev/null || echo dark)"
    fi
    run "$REPO/scripts/apply-app-theme.sh" "$seed" "$mode" scheme-tonal-spot || warn "could not generate the first theme"
}

next_steps() {
    cat <<NEXT

$(info "Done.")
Start MELLOW:  qs -c mellow        Stop it:  qs kill -c mellow        Logs:  qs log -c mellow
Stop any other bar, shell or notification program first (waybar, dunst, mako, ...).
Log out and back in so Dolphin and Gwenview pick up the new environment.
NEXT
}

preflight
((DRY_RUN)) && info "dry run: nothing will be changed"
[[ -z ${DO[deps]:-} ]] || install_deps
[[ -z ${DO[apps]:-} ]] || install_apps
[[ -z ${DO[fonts]:-} ]] || install_fonts
[[ -z ${DO[link]:-} ]] || link_shell
# Theme first: the window borders read its colours.
[[ -z ${DO[theme]:-} ]] || setup_theme
[[ -z ${DO[hypr]:-} ]] || setup_hypr
next_steps
