# setup-starship

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](setup-starship.sh)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)

A standalone, idempotent setup script for the [Starship](https://starship.rs) shell prompt on Linux. Installs the Starship binary and a selectable Nerd Font (JetBrainsMono, FiraCode, or Hack) into the user's home directory (no `sudo`), wires up shell initialization, and deploys a bundled `starship.toml` config.

[Deutsche Version](README.de.md)

## Table of Contents

- [Usage](#usage)
- [What it does](#what-it-does)
- [Requirements](#requirements)
- [Config](#config)
- [Credits](#credits)
- [License](#license)

## Usage

```bash
chmod +x setup-starship.sh  # only needed if the executable bit didn't survive how you got this file
./setup-starship.sh
```

You'll be prompted to pick a color palette (defaults to `kinoite` — press Enter to accept it, or run non-interactively for the same result) and a Nerd Font. The interactive prompt always defaults to `JetBrainsMono` (press Enter to install it); unattended/non-interactive runs instead auto-pick whichever of `JetBrainsMono`/`FiraCode`/`Hack` is already installed, if exactly one of them is, otherwise they also default to `JetBrainsMono`. If the font you end up with is already installed, the download/extraction step is skipped. Open a new terminal afterwards for the prompt to take effect.

For unattended/automated runs, the font choice can be passed on the command line to skip the interactive prompt: `--font <name>`, `--font=<name>`, or `-f <name>`, where `<name>` is `JetBrainsMono`, `FiraCode`, or `Hack`. The palette prompt always stays interactive (or falls back to `kinoite` when not interactive).

## What it does

1. Prompts you to choose a color palette: `kinoite`, `bazzite`, `silverblue`, `nord`, `dracula`, `gruvbox`, `catppuccin`; and a Nerd Font: `JetBrainsMono`, `FiraCode`, `Hack`.
2. Installs the `starship` binary to `~/.local/bin` via the official `starship.rs/install.sh` installer.
3. Downloads and installs the chosen Nerd Font to `~/.local/share/fonts` and refreshes the font cache — skipped if that font is already installed.
4. Adds `PATH` and `eval "$(starship init <shell>)"` lines to `~/.bashrc` or `~/.zshrc` (based on `$SHELL`), skipping lines that are already present.
5. Copies `starship.toml` from this repo to `~/.config/starship.toml` with the `palette` line set to your chosen palette, backing up any existing, differing config first.
6. If [chezmoi](https://www.chezmoi.io) is installed and already initialized for your user, adds `~/.config/starship.toml` and the shell RC file it touched (`~/.bashrc` or `~/.zshrc`) to chezmoi so they stay tracked in your dotfiles. For each file, the script checks if chezmoi already manages it: if not, it runs `chezmoi add`; if already managed (such as a template), it runs `chezmoi re-add` instead to avoid a hang caused by chezmoi's confirmation prompt when stdout is redirected. The chezmoi invocation also passes `--no-tty` as a second line of defense, so it fails immediately if it tries to prompt. This step is entirely optional and silently skipped if chezmoi isn't installed or hasn't been initialized yet — a failure on either file just prints a warning and leaves that file as-is, never affecting the rest of the install.

## Requirements

`curl`, `tar`, `fc-cache`, and `fc-match` must be available on the host.

## Config

`starship.toml` ships with OS/container-aware segments (Fedora/Bazzite, Ubuntu, Debian, Arch, openSUSE; Toolbox/Distrobox/Podman/Docker detection with container name where available; SSH/Mosh indicators) and 7 selectable color palettes: `kinoite` and `silverblue` (icy Fedora blues), `bazzite` (purple/pink gaming-OS accent), and four widely-used terminal schemes — `nord`, `dracula`, `gruvbox` (dark variant), `catppuccin` (Mocha flavor). The detected OS icon is always shown in that distro's own brand color (Fedora blue, Bazzite purple, Ubuntu orange, Debian magenta-red, Arch cyan-blue, openSUSE green) regardless of the chosen palette, with the machine name next to it in a slightly darker shade of that same brand color and in regular (non-bold) weight. Bazzite reuses the Fedora logo glyph (no dedicated Bazzite icon exists in Nerd Fonts) but gets its own distinct color rather than sharing Fedora's blue. The `[directory]` module shows a folder icon before the path, truncates to the last 6 path components, and marks truncated paths with `…/`. The `[time]` module shows a clock icon before the time. Edit `starship.toml` before running the script to add or tweak a palette, or edit `~/.config/starship.toml` afterwards and re-run to sync changes back — note the script overwrites `~/.config/starship.toml` with the repo copy (backing up the previous version if it differs) rather than the other way around.

## Credits

- [Starship](https://starship.rs) — the cross-shell prompt this script installs and configures, licensed under [ISC](https://github.com/starship/starship/blob/master/LICENSE).
- [Nerd Fonts](https://www.nerdfonts.com) — the patched glyph set with selectable base fonts ([JetBrains Mono](https://github.com/JetBrains/JetBrainsMono), [Fira Code](https://github.com/tonsky/FiraCode), [Hack](https://github.com/source-foundry/Hack)) this script installs so Starship's icons render correctly, licensed under the [SIL Open Font License 1.1](https://github.com/ryanoasis/nerd-fonts/blob/master/LICENSE).
- [Nord](https://www.nordtheme.com), [Dracula](https://draculatheme.com), [Gruvbox](https://github.com/morhetz/gruvbox), and [Catppuccin](https://catppuccin.com) — the color values for the `nord`, `dracula`, `gruvbox`, and `catppuccin` palettes come from these projects' published palettes.
- `starship.toml` in this repo is adapted from the author's own personal dotfiles configuration.

## License

[MIT](LICENSE)
