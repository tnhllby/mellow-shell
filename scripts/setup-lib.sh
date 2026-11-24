# Shared by install.sh and uninstall.sh (sourced, not run).
: "${HOME:?HOME is not set}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/mellow"
LINK="$CONFIG_HOME/quickshell/mellow"
FONT_DIR="$DATA_HOME/fonts/mellow"
HYPR="$CONFIG_HOME/hypr"
MELLOW_CONFIG="$CONFIG_HOME/mellow/config.json"
BACKUP="$STATE/backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
ASSUME_YES=0

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
    ((ASSUME_YES || DRY_RUN)) && return 0
    local reply
    read -r -p "$1 [y/N] " reply || return 1
    [[ $reply =~ ^[Yy]$ ]]
}

# Keeps a copy of a file before it is changed (once per run).
backup() {
    [[ -e $1 ]] || return 0
    local copy="$BACKUP/${1#/}"
    [[ ! -e $copy ]] || return 0
    run mkdir -p "$(dirname "$copy")"
    run cp -L -- "$1" "$copy"
}

# write_file <path>: replaces it with stdin, keeping a symlink a symlink.
write_file() {
    local content
    content="$(cat; echo x)"
    if ((DRY_RUN)); then
        printf '   [dry-run] write %s\n' "$1"
        return
    fi
    mkdir -p "$(dirname "$1")"
    printf '%s' "${content%x}" > "$1"
}

# without_block <path>: prints the file without MELLOW's marked block.
without_block() {
    [[ -e $1 ]] || return 0
    awk '/>>> mellow >>>/ { skip = 1 } !skip; /<<< mellow <<</ { skip = 0 }' "$1"
}

# add_block <path> <start|end> <comment open> <comment close> <line>
# Adds MELLOW's marked block, replacing an earlier one.
add_block() {
    local path=$1 where=$2 open=$3 close=$4 line=$5 block rest next
    block="$open>>> mellow >>>$close"$'\n'"$line"$'\n'"$open<<< mellow <<<$close"
    rest="$(without_block "$path")"
    next="$rest${rest:+$'\n'}$block"
    [[ $where == end ]] || next="$block${rest:+$'\n'}$rest"
    if [[ -e $path && "$(cat "$path")" == "$next" ]]; then
        info "  $path already set up"
        return
    fi
    backup "$path"
    printf '%s\n' "$next" | write_file "$path"
    info "  $path"
}

# Removes MELLOW's block; a file that held nothing else is deleted.
remove_block() {
    local path=$1 rest
    grep -qs '>>> mellow >>>' "$path" || return 0
    backup "$path"
    rest="$(without_block "$path")"
    if [[ -z ${rest//[[:space:]]/} && ! -L $path ]]; then
        rm -- "${path:?}"
    else
        printf '%s\n' "$rest" | write_file "$path"
    fi
    info "Removed MELLOW from $path"
}

# Removes MELLOW's files from Hyprland's configuration (only those it installs).
remove_hypr_parts() {
    local part file
    for part in init keybinds environment blur autostart decoration; do
        file="${HYPR:?}/mellow/$part.lua"
        [[ -e $file ]] || continue
        backup "$file"
        run rm -- "${file:?}"
    done
}

# set_config <group> <name> <json value>: one setting in MELLOW's config.json.
set_config() {
    local now='{}' next
    if [[ -s $MELLOW_CONFIG ]]; then
        now="$(cat "$MELLOW_CONFIG")"
    fi
    if ! next="$(jq --arg g "$1" --arg n "$2" --argjson v "$3" '.[$g][$n] = $v' <<<"$now" 2>/dev/null)"; then
        warn "$MELLOW_CONFIG is not valid; set $1.$2 to $3 yourself"
        return
    fi
    backup "$MELLOW_CONFIG"
    printf '%s\n' "$next" | write_file "$MELLOW_CONFIG"
}
