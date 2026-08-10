# setup-starship

A standalone, idempotent setup script for the [Starship](https://starship.rs) shell prompt on Linux. Installs the Starship binary and the JetBrainsMono Nerd Font into the user's home directory (no `sudo`), wires up shell initialization, and deploys a bundled `starship.toml` config.

## Usage

```bash
chmod +x setup-starship.sh  # only needed if the executable bit didn't survive how you got this file
./setup-starship.sh
```

You'll be prompted to pick a color palette (defaults to `kinoite` if you skip the prompt or run non-interactively). Open a new terminal afterwards for the prompt to take effect.

## What it does

1. Prompts you to choose a color palette: `kinoite`, `bazzite`, `silverblue`, `nord`, `dracula`, `gruvbox`, `catppuccin`.
2. Installs the `starship` binary to `~/.local/bin` via the official `starship.rs/install.sh` installer.
3. Downloads and installs the JetBrainsMono Nerd Font to `~/.local/share/fonts` and refreshes the font cache.
4. Adds `PATH` and `eval "$(starship init <shell>)"` lines to `~/.bashrc` or `~/.zshrc` (based on `$SHELL`), skipping lines that are already present.
5. Copies `starship.toml` from this repo to `~/.config/starship.toml` with the `palette` line set to your chosen palette, backing up any existing, differing config first.

## Requirements

`curl`, `tar`, `fc-cache`, and `fc-match` must be available on the host.

## Config

`starship.toml` ships with OS/container-aware segments (Fedora/Bazzite, Ubuntu, Debian, Arch, openSUSE; Toolbox/Distrobox/Podman/Docker detection with container name where available; SSH/Mosh indicators) and 7 selectable color palettes: `kinoite` and `silverblue` (icy Fedora blues), `bazzite` (purple/pink gaming-OS accent), and four widely-used terminal schemes — `nord`, `dracula`, `gruvbox` (dark variant), `catppuccin` (Mocha flavor). Edit `starship.toml` before running the script to add or tweak a palette, or edit `~/.config/starship.toml` afterwards and re-run to sync changes back — note the script overwrites `~/.config/starship.toml` with the repo copy (backing up the previous version if it differs) rather than the other way around.

## Credits

- [Starship](https://starship.rs) — the cross-shell prompt this script installs and configures, licensed under [ISC](https://github.com/starship/starship/blob/master/LICENSE).
- [Nerd Fonts](https://www.nerdfonts.com) / [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) — the patched glyph set this script installs so Starship's icons render correctly, licensed under the [SIL Open Font License 1.1](https://github.com/ryanoasis/nerd-fonts/blob/master/LICENSE).
- [Nord](https://www.nordtheme.com), [Dracula](https://draculatheme.com), [Gruvbox](https://github.com/morhetz/gruvbox), and [Catppuccin](https://catppuccin.com) — the color values for the `nord`, `dracula`, `gruvbox`, and `catppuccin` palettes come from these projects' published palettes.
- `starship.toml` in this repo is adapted from the author's own personal dotfiles configuration.

## License

[MIT](LICENSE)
