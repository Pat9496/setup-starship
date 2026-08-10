# setup-starship

A standalone, idempotent setup script for the [Starship](https://starship.rs) shell prompt on Linux. Installs the Starship binary and the JetBrainsMono Nerd Font into the user's home directory (no `sudo`), wires up shell initialization, and deploys a bundled `starship.toml` config.

## Usage

```bash
./install.sh
```

Open a new terminal afterwards for the prompt to take effect.

## What it does

1. Installs the `starship` binary to `~/.local/bin` via the official `starship.rs/install.sh` installer.
2. Downloads and installs the JetBrainsMono Nerd Font to `~/.local/share/fonts` and refreshes the font cache.
3. Adds `PATH` and `eval "$(starship init <shell>)"` lines to `~/.bashrc` or `~/.zshrc` (based on `$SHELL`), skipping lines that are already present.
4. Copies `starship.toml` from this repo to `~/.config/starship.toml`, backing up any existing, differing config first.

## Requirements

`curl`, `tar`, `fc-cache`, and `fc-match` must be available on the host.

## Config

`starship.toml` uses a `kinoite` palette and OS/container-aware segments (Fedora/Bazzite, Ubuntu, Debian, Arch, openSUSE; Toolbox/Distrobox/Podman/Docker detection; SSH/Mosh indicators). Edit it before running the script, or edit `~/.config/starship.toml` afterwards and re-run to sync changes back — note the script will overwrite `~/.config/starship.toml` with the repo copy (backing up the previous version) rather than the other way around.

## Credits

- [Starship](https://starship.rs) — the cross-shell prompt this script installs and configures, licensed under [ISC](https://github.com/starship/starship/blob/master/LICENSE).
- [Nerd Fonts](https://www.nerdfonts.com) / [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) — the patched glyph set this script installs so Starship's icons render correctly, licensed under the [SIL Open Font License 1.1](https://github.com/ryanoasis/nerd-fonts/blob/master/LICENSE).
- `starship.toml` in this repo is adapted from the author's own personal dotfiles configuration.

## License

[MIT](LICENSE)
