# Dotfiles Inventory

This repository contains user configuration packages for an Omarchy Quattro
desktop. Stow targets are relative to `$HOME` unless noted otherwise.

## Packages

| Package | Intended target | Status | Conflict or deployment note |
| --- | --- | --- | --- |
| `hypromarchy` | `~/.config/hypr/` | Active Quattro package | Overrides user Hyprland files while loading defaults from `/usr/share/omarchy/default/hypr/`. Preserve unmanaged files. |
| `hypromarchy/.etc` | `/etc/` | Not Stow-safe | Stow would place this at `~/.etc/`, not `/etc/`. Apply manually with root approval. |
| `hyprncspot` | `~/.config/ncspot/` | Optional | `userstate.cbor` is machine/session state and should not normally be deployed. |
| `tmuxomarchy` | `~/.tmux.conf`, `~/.config/tmux/` | Active Quattro package | Replaces user tmux files; preserve existing files in a backup first. |
| `wezterm` | `~/.wezterm.lua` | Optional | No direct Omarchy conflict, but only relevant when WezTerm is selected as the terminal. |
| `ghostty` | `~/.config/ghostty/` | Missing from legacy Stow script | Add to deployment inventory explicitly. |
| `yazi` | `~/.config/yazi/` | Optional | User theme, flavor, and keymap configuration. |
| `zsh` | `~/.zshrc`, `~/.config/zsh/` | Active user package | May replace Omarchy shell additions; inspect before deployment. |
| `pl10k` | `~/.p10k.zsh` | Optional | Loaded by the Zsh configuration. |
| `mise` | `~/.config/mise/` | Optional | Missing from legacy Stow script. |
| `opencode` | `~/.config/opencode.json`, `~/.config/skills/` | Optional | User-level agent configuration and skills; may conflict with existing global skills. |
| `pi` | `~/.pi/agent/extensions/` | Optional | Pi TUI common-patterns extension; use `/reload` after changes. |
| `.claude` | `~/.claude/` | Manual/optional | Not included by the legacy Stow script; contains Claude project skills. |

## Non-Deployable Content

- `legacy/hypr-3.8/` is reference material only. Never deploy it on Quattro.
- `omarchy_scripts/` contains deployment and setup scripts, not Stow packages.
- `mise/MISE_GUIDE.md` is documentation.
- Binary/session state such as `hyprncspot/.config/ncspot/userstate.cbor` should be reviewed before copying to a new machine.

## Omarchy Conflicts

- Never modify `/usr/share/omarchy/`; it is the managed Omarchy installation.
- `~/.config/hypr/hyprland.lua` must be the active entrypoint for the Quattro package. If `hyprland.conf` exists and is active, back it up before switching.
- The Hyprland package intentionally overrides monitors, bindings, appearance, environment, startup, and `hyprsunset` settings.
- Hyprland defaults, theme modules, shell, idle, lock, notifications, and OSD remain Omarchy-managed unless explicitly listed in the package.
- Run `omarchy refresh hyprland` before deployment only when the user explicitly wants to reset the generated user base files; never run it after Stow without checking symlinks.
