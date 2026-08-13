#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARSHIP_BIN_DIR="$HOME/.local/bin"
FONT_DIR="$HOME/.local/share/fonts"
CONFIG_DIR="$HOME/.config"
CONFIG_FILE="$CONFIG_DIR/starship.toml"
SOURCE_CONFIG="$SCRIPT_DIR/starship.toml"
TMP_DIR="$(mktemp -d)"

PALETTES=(kinoite bazzite silverblue nord dracula gruvbox catppuccin)
DEFAULT_PALETTE="kinoite"

FONTS=(JetBrainsMono FiraCode Hack)
DEFAULT_FONT="JetBrainsMono"

shell_name="$(basename "${SHELL:-bash}")"
case "$shell_name" in
  zsh) rc_file="$HOME/.zshrc" ;;
  *)   rc_file="$HOME/.bashrc" ;;
esac

cleanup() {
    rm -rf "$TMP_DIR"
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf 'Missing required command: %s\n' "$1" >&2
        exit 1
    fi
}

add_line_once() {
    local line="$1"
    local file="$2"

    touch "$file"

    if ! grep -qxF "$line" "$file"; then
        printf '\n%s\n' "$line" >> "$file"
    fi
}

contains_element() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

prompt_choice() {
    local prompt="$1"
    local default="$2"
    shift 2
    local -a options=("$@")

    local i=1 opt
    for opt in "${options[@]}"; do
        printf '%d) %s\n' "$i" "$opt" >&2
        i=$((i + 1))
    done

    local choice="" reply
    while true; do
        printf '%s' "$prompt" >&2
        if ! IFS= read -r reply; then
            choice="$default"
            break
        fi

        if [[ -z "$reply" ]]; then
            choice="$default"
            break
        fi

        if [[ "$reply" =~ ^[0-9]+$ ]] && (( reply >= 1 && reply <= ${#options[@]} )); then
            choice="${options[$((reply - 1))]}"
            break
        fi

        if contains_element "$reply" "${options[@]}"; then
            choice="$reply"
            break
        fi

        printf 'Invalid choice: "%s"\n' "$reply" >&2
    done

    echo "$choice"
}

font_installed() {
    fc-list : family 2>/dev/null | grep -qF "$1 Nerd Font"
}

detect_installed_font() {
    local name found="" count=0
    for name in "${FONTS[@]}"; do
        if font_installed "$name"; then
            found="$name"
            count=$((count + 1))
        fi
    done
    if [[ "$count" -eq 1 ]]; then
        echo "$found"
        return 0
    fi
    return 1
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [-f|--font NAME] [-h|--help]

  -f, --font NAME   Nerd Font to install non-interactively (skips the prompt).
                    Valid values: ${FONTS[*]}
  -h, --help        Show this help and exit.
EOF
}

choose_palette() {
    if [[ ! -t 0 ]]; then
        printf 'Not running interactively; defaulting to "%s" palette.\n' "$DEFAULT_PALETTE" >&2
        echo "$DEFAULT_PALETTE"
        return
    fi

    printf 'Choose a starship color palette:\n' >&2

    local choice=""
    choice="$(prompt_choice "Palette [$DEFAULT_PALETTE]: " "$DEFAULT_PALETTE" "${PALETTES[@]}")"

    if ! contains_element "$choice" "${PALETTES[@]}"; then
        choice="$DEFAULT_PALETTE"
    fi

    echo "$choice"
}

choose_font() {
    local installed_font=""
    installed_font="$(detect_installed_font)" || installed_font=""
    local default_font="$DEFAULT_FONT"
    [[ -n "$installed_font" ]] && default_font="$installed_font"

    if [[ ! -t 0 ]]; then
        if [[ -n "$installed_font" ]]; then
            printf 'Not running interactively; "%s Nerd Font" is already installed, keeping it.\n' "$installed_font" >&2
        else
            printf 'Not running interactively; defaulting to "%s" font.\n' "$default_font" >&2
        fi
        echo "$default_font"
        return
    fi

    if [[ -n "$installed_font" ]]; then
        printf 'Detected "%s Nerd Font" already installed.\n' "$installed_font" >&2
    fi

    printf 'Choose a Nerd Font to install:\n' >&2

    local choice=""
    choice="$(prompt_choice "Font [$default_font]: " "$default_font" "${FONTS[@]}")"

    if ! contains_element "$choice" "${FONTS[@]}"; then
        choice="$default_font"
    fi

    echo "$choice"
}

selected_font=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--font)
            if [[ $# -lt 2 ]]; then
                printf 'Error: %s requires a value.\n' "$1" >&2
                exit 1
            fi
            selected_font="$2"
            shift 2
            ;;
        --font=*)
            selected_font="${1#*=}"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unrecognized argument: %s\n' "$1" >&2
            exit 1
            ;;
    esac
done

if [[ -n "$selected_font" ]] && ! contains_element "$selected_font" "${FONTS[@]}"; then
    printf 'Invalid font: "%s". Valid choices: %s\n' "$selected_font" "${FONTS[*]}" >&2
    exit 1
fi

trap cleanup EXIT

require_command curl
require_command tar
require_command fc-cache
require_command fc-match
require_command fc-list

if [[ ! -f "$SOURCE_CONFIG" ]]; then
    printf 'starship.toml not found next to %s\n' "$0" >&2
    exit 1
fi

selected_palette="$(choose_palette)"
printf 'Using "%s" palette.\n' "$selected_palette"

if [[ -z "$selected_font" ]]; then
    selected_font="$(choose_font)"
fi
printf 'Using "%s" Nerd Font.\n' "$selected_font"

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${selected_font}.tar.xz"

mkdir -p "$STARSHIP_BIN_DIR"
mkdir -p "$FONT_DIR"
mkdir -p "$CONFIG_DIR"

curl -fsSL https://starship.rs/install.sh | sh -s -- -b "$STARSHIP_BIN_DIR" -y

if font_installed "$selected_font"; then
    printf '"%s Nerd Font" is already installed; skipping download.\n' "$selected_font"
else
    curl -fL "$FONT_URL" -o "$TMP_DIR/${selected_font}.tar.xz"
    mkdir -p "$TMP_DIR/${selected_font}"
    tar -xf "$TMP_DIR/${selected_font}.tar.xz" -C "$TMP_DIR/${selected_font}"
    find "$TMP_DIR/${selected_font}" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp -f {} "$FONT_DIR/" \;

    fc-cache -f "$FONT_DIR"
fi

FINAL_CONFIG="$TMP_DIR/starship.toml"
sed "s/^palette = \".*\"\$/palette = \"$selected_palette\"/" "$SOURCE_CONFIG" > "$FINAL_CONFIG"

# Compared against FINAL_CONFIG (post-substitution), not SOURCE_CONFIG, so re-runs
# with the same chosen palette don't create a spurious backup every time.
if [[ -f "$CONFIG_FILE" ]] && ! cmp -s "$FINAL_CONFIG" "$CONFIG_FILE"; then
    cp -f "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d%H%M%S)"
fi
cp -f "$FINAL_CONFIG" "$CONFIG_FILE"

add_line_once 'export PATH="$HOME/.local/bin:$PATH"' "$rc_file"
add_line_once "eval \"\$(starship init $shell_name)\"" "$rc_file"

"$STARSHIP_BIN_DIR/starship" --version >/dev/null
fc-match "$selected_font Nerd Font" >/dev/null

chezmoi_track() {
    if ! command -v chezmoi >/dev/null 2>&1; then
        printf 'chezmoi not installed; skipping chezmoi tracking.\n'
        return 0
    fi

    local source_path=""
    if ! source_path="$(chezmoi source-path 2>/dev/null)" || [[ -z "$source_path" ]] || [[ ! -d "$source_path" ]]; then
        printf 'chezmoi not initialized; skipping chezmoi tracking.\n'
        return 0
    fi

    if [[ -z "$(find "$source_path" -mindepth 1 -print -quit 2>/dev/null)" ]]; then
        printf 'chezmoi not initialized; skipping chezmoi tracking.\n'
        return 0
    fi

    local file
    for file in "$CONFIG_FILE" "$rc_file"; do
        if chezmoi add "$file" >/dev/null 2>&1; then
            printf 'Added "%s" to chezmoi.\n' "$file"
        else
            printf 'Warning: "chezmoi add %s" failed; leaving it untracked.\n' "$file" >&2
        fi
    done
}

chezmoi_track
