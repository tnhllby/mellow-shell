#!/usr/bin/env bash
# MELLOW installer for Arch Linux + Hyprland.
#
# Steps (all opt-in through flags, or all of them with no flags):
#   --deps   install Quickshell from the Arch repos (pacman, needs sudo)
#   --fonts  download Google Sans Flex, Roboto Flex, Roboto Mono and
#            Material Symbols Rounded into ~/.local/share/fonts/mellow (no sudo)
#   --link   symlink this repository to ~/.config/quickshell/mellow so that
#            `qs -c mellow` starts it
#
# Never touches Hyprland configuration and never enables autostart: it prints
# the line to add yourself. Undo everything with ./uninstall.sh.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
LINK="$CONFIG_HOME/quickshell/mellow"
FONT_DIR="$DATA_HOME/fonts/mellow"

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

DRY_RUN=0
ASSUME_YES=0
DO_DEPS=0
DO_FONTS=0
DO_LINK=0

info() { printf '\033[1;36m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

run() {
    if ((DRY_RUN)); then
        printf '   [dry-run] %s\n' "$*"
    else
        "$@"
    fi
}

confirm() {
    ((ASSUME_YES)) && return 0
    local reply
    read -r -p "$1 [y/N] " reply
    [[ $reply =~ ^[Yy]$ ]]
}

usage() {
    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
    cat <<EOF

Usage: ./install.sh [--deps] [--fonts] [--link] [--dry-run] [-y]
  (no step flags = all steps)
  --dry-run  print what would happen without changing anything
  -y         do not ask for confirmation
EOF
}

while (($#)); do
    case $1 in
        --deps) DO_DEPS=1 ;;
        --fonts) DO_FONTS=1 ;;
        --link) DO_LINK=1 ;;
        --dry-run) DRY_RUN=1 ;;
        -y | --yes) ASSUME_YES=1 ;;
        -h | --help) usage; exit 0 ;;
        *) die "unknown option: $1 (see --help)" ;;
    esac
    shift
done
if ((!DO_DEPS && !DO_FONTS && !DO_LINK)); then
    DO_DEPS=1 DO_FONTS=1 DO_LINK=1
fi

preflight() {
    ((EUID != 0)) || die "run as your normal user, not root (sudo is used only for pacman)"
    command -v pacman >/dev/null || die "pacman not found: this installer supports Arch Linux only"
    [[ -f $REPO/shell.qml ]] || die "shell.qml not found next to install.sh"
    command -v Hyprland >/dev/null || command -v hyprland >/dev/null ||
        warn "Hyprland is not installed; MELLOW requires it"
}

install_deps() {
    info "Dependencies"
    # matugen generates wallpaper colour schemes in Wallpaper Studio; ddcutil
    # controls external monitor brightness (both optional).
    local missing=()
    command -v qs >/dev/null || missing+=(quickshell)
    command -v matugen >/dev/null || missing+=(matugen)
    command -v ddcutil >/dev/null || missing+=(ddcutil)
    if [ ${#missing[@]} -eq 0 ]; then
        info "Quickshell, matugen and ddcutil already installed"
    elif confirm "Install ${missing[*]} with sudo pacman?"; then
        run sudo pacman -S --needed "${missing[@]}"
    else
        warn "skipped ${missing[*]}"
    fi
    # ddcutil needs the i2c-dev module and access to /dev/i2c-*; not changed here.
    if ! id -nG | grep -qw i2c; then
        warn "External monitor brightness needs i2c access. To enable it:"
        warn "  sudo modprobe i2c-dev; echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf"
        warn "  sudo groupadd -f i2c; sudo usermod -aG i2c \"\$USER\"   (then log in again)"
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

next_steps() {
    cat <<EOF

$(info "Done.")
Start MELLOW manually:    qs -c mellow           (or: qs -p "$REPO")
Stop it:                  qs kill -c mellow      (or Ctrl+C in its terminal)
Logs:                     qs log -c mellow

Autostart is NOT enabled. To enable it yourself, add to Hyprland:
  hyprland.conf:   exec-once = qs -c mellow
  hyprland.lua:    hl.on("hyprland.start", function() hl.exec_cmd("qs -c mellow") end)
Stop any other bar/shell (waybar, another Quickshell config) first, or
their panels will stack with MELLOW's.
EOF
}

preflight
((DRY_RUN)) && info "dry run: nothing will be changed"
((DO_DEPS)) && install_deps
((DO_FONTS)) && install_fonts
((DO_LINK)) && link_shell
next_steps
