# setup-starship

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](setup-starship.sh)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)

Ein eigenständiges, idempotentes Setup-Skript für die [Starship](https://starship.rs)-Shell-Eingabeaufforderung unter Linux. Installiert die Starship-Binärdatei und einen wählbaren Nerd Font (JetBrainsMono, FiraCode oder Hack) im Benutzerverzeichnis (ohne `sudo`), richtet die Shell-Initialisierung ein und stellt eine gebündelte `starship.toml`-Konfiguration bereit.

[English version](README.md)

## Inhaltsverzeichnis

- [Verwendung](#verwendung)
- [Was das Skript tut](#was-das-skript-tut)
- [Anforderungen](#anforderungen)
- [Konfiguration](#konfiguration)
- [Danksagungen](#danksagungen)
- [Lizenz](#lizenz)

## Verwendung

```bash
chmod +x setup-starship.sh  # only needed if the executable bit didn't survive how you got this file
./setup-starship.sh
```

Das Skript fordert zur Auswahl einer Farbpalette (Standardwert: `kinoite` — Enter-Taste zur Bestätigung oder Ausführung ohne Benutzerinteraktion für das gleiche Ergebnis) und eines Nerd Fonts auf. Der interaktive Dialog setzt immer `JetBrainsMono` als Standard (Enter-Taste zur Installation); unbeaufsichtigte oder nicht-interaktive Läufe wählen stattdessen automatisch einen der bereits installierten Fonts aus `JetBrainsMono`/`FiraCode`/`Hack`, falls genau eines davon vorhanden ist, ansonsten wird auch hier `JetBrainsMono` als Standard verwendet. Falls der ausgewählte Font bereits installiert ist, entfällt der Download- und Extraktionsschritt. Nach der Ausführung muss ein neues Terminal geöffnet werden, damit die Eingabeaufforderung wirksam wird.

Für unbeaufsichtigte oder automatisierte Läufe kann die Font-Auswahl über die Befehlszeile übergeben werden, um den interaktiven Dialog zu überspringen: `--font <name>`, `--font=<name>` oder `-f <name>`, wobei `<name>` `JetBrainsMono`, `FiraCode` oder `Hack` ist. Der Dialog zur Palettenauswahl bleibt immer interaktiv (oder wechselt zu `kinoite` bei fehlender Benutzerinteraktion).

## Was das Skript tut

1. Aufforderung zur Auswahl einer Farbpalette: `kinoite`, `bazzite`, `silverblue`, `nord`, `dracula`, `gruvbox`, `catppuccin`; und eines Nerd Fonts: `JetBrainsMono`, `FiraCode`, `Hack`.
2. Installation der `starship`-Binärdatei in `~/.local/bin` über das offizielle `starship.rs/install.sh`-Installationsprogramm.
3. Download und Installation des ausgewählten Nerd Fonts in `~/.local/share/fonts` und Aktualisierung des Font-Speichers — wird übersprungen, falls der Font bereits installiert ist.
4. Hinzufügen von `PATH`- und `eval "$(starship init <shell>)"`-Zeilen zu `~/.bashrc` oder `~/.zshrc` (basierend auf `$SHELL`), wobei bereits vorhandene Zeilen übersprungen werden.
5. Kopieren von `starship.toml` aus diesem Repository zu `~/.config/starship.toml` mit der `palette`-Zeile auf die ausgewählte Palette gesetzt, wobei eine vorhandene, abweichende Konfiguration zuvor gesichert wird.
6. Falls [chezmoi](https://www.chezmoi.io) installiert und bereits für den Benutzer initialisiert ist, werden `~/.config/starship.toml` und die Shell-RC-Datei, die das Skript geändert hat (`~/.bashrc` oder `~/.zshrc`), zu chezmoi hinzugefügt, damit diese in den Dotfiles verfolgbar bleiben. Für jede Datei prüft das Skript, ob chezmoi diese bereits verwaltet: Falls nicht, wird `chezmoi add` ausgeführt; falls bereits verwaltet (z. B. als Template), wird stattdessen `chezmoi re-add` ausgeführt, um einen Aufhänger durch chezmois Bestätigungsaufforderung bei umgeleiteter Standardausgabe zu vermeiden. Der chezmoi-Aufruf übergibt auch `--no-tty` als zweite Verteidigungslinie, sodass das Skript sofort fehlschlägt, falls es versucht, eine Eingabeaufforderung zu zeigen. Dieser Schritt ist völlig optional und wird automatisch übersprungen, falls chezmoi nicht installiert oder noch nicht initialisiert ist — ein Fehler bei einer der Dateien druckt nur eine Warnung und lässt die Datei unverändert, ohne den Rest der Installation zu beeinflussen.

## Anforderungen

`curl`, `tar`, `fc-cache` und `fc-match` müssen auf dem Host verfügbar sein.

## Konfiguration

`starship.toml` wird mit betriebssystem- und Container-bewussten Segmenten ausgeliefert (Fedora/Bazzite, Ubuntu, Debian, Arch, openSUSE; Toolbox/Distrobox/Podman/Docker-Erkennung mit Container-Namen falls verfügbar; SSH-/Mosh-Indikatoren) und 7 wählbaren Farbpaletten: `kinoite` und `silverblue` (kühle Fedora-Blautöne), `bazzite` (Purple/Pink Gaming-OS-Akzent) und vier weit verbreitete Terminal-Schemata — `nord`, `dracula`, `gruvbox` (dunkle Variante), `catppuccin` (Mocha-Variante). Das erkannte Betriebssystem-Symbol wird immer in der Markenfarbe dieser Distribution angezeigt (Fedora-Blau, Bazzite-Purple, Ubuntu-Orange, Debian-Magentarot, Arch-Cyan-Blau, openSUSE-Grün), unabhängig von der ausgewählten Palette, mit dem Computernamen daneben in einer etwas dunkleren Nuance derselben Markenfarbe und in regulärem (nicht fettgedrucktem) Gewicht. Bazzite verwendet das Fedora-Logo-Glyphe erneut (es gibt kein eigenes Bazzite-Symbol in Nerd Fonts), erhält aber eine eigene, charakteristische Farbe anstelle des Fedora-Blaus. Das `[directory]`-Modul zeigt ein Ordnersymbol vor dem Pfad, kürzt auf die letzten 6 Pfadkomponenten und markiert gekürzte Pfade mit `…/`. Das `[time]`-Modul zeigt ein Uhrsymbol vor der Uhrzeit. Zur Anpassung ist `starship.toml` vor dem Ausführen des Skripts zu bearbeiten, um eine Palette hinzuzufügen oder zu optimieren; alternativ kann `~/.config/starship.toml` danach bearbeitet und das Skript erneut ausgeführt werden, um Änderungen zu synchronisieren. Das Skript überschreibt hierbei `~/.config/starship.toml` mit der Repository-Kopie (Sicherung der vorherigen Version, falls unterschiedlich), nicht umgekehrt.

## Danksagungen

- [Starship](https://starship.rs) — die Shell-unabhängige Eingabeaufforderung, die das Skript installiert und konfiguriert, lizenziert unter [ISC](https://github.com/starship/starship/blob/master/LICENSE).
- [Nerd Fonts](https://www.nerdfonts.com) — der gepatchtete Glyphensatz mit wählbaren Basis-Fonts ([JetBrains Mono](https://github.com/JetBrains/JetBrainsMono), [Fira Code](https://github.com/tonsky/FiraCode), [Hack](https://github.com/source-foundry/Hack)), den das Skript installiert, damit Starships Symbole korrekt dargestellt werden, lizenziert unter der [SIL Open Font License 1.1](https://github.com/ryanoasis/nerd-fonts/blob/master/LICENSE).
- [Nord](https://www.nordtheme.com), [Dracula](https://draculatheme.com), [Gruvbox](https://github.com/morhetz/gruvbox) und [Catppuccin](https://catppuccin.com) — die Farbwerte für die `nord`-, `dracula`-, `gruvbox`- und `catppuccin`-Paletten stammen aus den veröffentlichten Paletten dieser Projekte.
- `starship.toml` in diesem Repository ist an die persönliche Dotfiles-Konfiguration des Autors angepasst.

## Lizenz

[MIT](LICENSE)
