#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARSHIP_BIN_DIR="$HOME/.local/bin"
FONT_DIR="$HOME/.local/share/fonts"
CONFIG_DIR="$HOME/.config"
CONFIG_FILE="$CONFIG_DIR/starship.toml"
SOURCE_CONFIG="$SCRIPT_DIR/starship.toml"
TMP_DIR="$(mktemp -d)"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

PALETTES=(kinoite bazzite silverblue nord dracula gruvbox catppuccin)
DEFAULT_PALETTE="kinoite"

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

choose_palette() {
    if [[ ! -t 0 ]]; then
        printf 'Not running interactively; defaulting to "%s" palette.\n' "$DEFAULT_PALETTE" >&2
        echo "$DEFAULT_PALETTE"
        return
    fi

    printf 'Choose a starship color palette:\n' >&2

    local PS3="Palette [$DEFAULT_PALETTE]: "
    local opt choice=""
    select opt in "${PALETTES[@]}"; do
        choice="${opt:-$DEFAULT_PALETTE}"
        break
    done

    choice="${choice:-$DEFAULT_PALETTE}"

    if ! contains_element "$choice" "${PALETTES[@]}"; then
        choice="$DEFAULT_PALETTE"
    fi

    echo "$choice"
}

trap cleanup EXIT

require_command curl
require_command tar
require_command fc-cache
require_command fc-match

if [[ ! -f "$SOURCE_CONFIG" ]]; then
    printf 'starship.toml not found next to %s\n' "$0" >&2
    exit 1
fi

selected_palette="$(choose_palette)"
printf 'Using "%s" palette.\n' "$selected_palette"

mkdir -p "$STARSHIP_BIN_DIR"
mkdir -p "$FONT_DIR"
mkdir -p "$CONFIG_DIR"

curl -fsSL https://starship.rs/install.sh | sh -s -- -b "$STARSHIP_BIN_DIR" -y

curl -fL "$FONT_URL" -o "$TMP_DIR/JetBrainsMono.tar.xz"
mkdir -p "$TMP_DIR/JetBrainsMono"
tar -xf "$TMP_DIR/JetBrainsMono.tar.xz" -C "$TMP_DIR/JetBrainsMono"
find "$TMP_DIR/JetBrainsMono" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp -f {} "$FONT_DIR/" \;

fc-cache -f "$FONT_DIR"

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
fc-match "JetBrainsMono Nerd Font" >/dev/null
