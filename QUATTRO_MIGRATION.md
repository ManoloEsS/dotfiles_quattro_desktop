# Omarchy quattro desktop migration

Ported from `dotfiles_omarchy_desktop` (Omarchy 3.8 / master) to Omarchy quattro (4.0).

The 3.8 Hyprland configs are preserved for reference under `legacy/hypr-3.8/`.

## What changed

| Area | 3.8 | quattro (this repo) |
|------|-----|---------------------|
| Hyprland config | `.conf` (hyprlang, sourced) | `.lua` (Hyprland ≥ 0.55 deprecated hyprlang) |
| Bar / launcher / notifications / idle / lock | waybar, walker, mako, hypridle, hyprlock, swayosd | Quickshell "Omarchy shell" (`~/.config/omarchy/shell.json`) |
| Volume OSD | swayosd | `omarchy-audio-output-volume` (new OSD) |
| Tmux config | dual file (`.tmux.conf` + `.config/tmux/tmux.conf`) | single consolidated `.tmux.conf` (quattro defaults + personal additions) |

## Files in `hypromarchy/.config/hypr/`

- `hyprland.lua` — current Quattro entry point plus `require("hypr.envs")` and `hl.config({ misc = { vrr = 2 } })`; Quattro default bindings remain enabled unless a personal binding replaces them.
- `monitors.lua` — GDK_SCALE 1; Acer ultrawide + Samsung portrait (bitdepth 10, sdrbrightness 0.85, transform 1); workspace 1 uses the Samsung description and workspace 2 uses the Acer description (default).
- `bindings.lua` — personal bind set (HJKL, comma/period workspaces, relocated defaults, master/scrolling layout keys, 2% volume steps, yazi/tmux launchers) with targeted unbinds only for conflicting Quattro defaults.
- Input settings — inherited from the current Quattro base configuration; no repository override is installed.
- `looknfeel.lua` — gaps 0, border 3, cyan→green gradient, default `scrolling` layout, blur, master block, borderangle animation.
- `autostart.lua` — auto-starts `hyprsunset` (profiles in `hypr/hyprsunset.conf`).
- `envs.lua` — `HYPRLAND_NO_EXTRA_SYNC=1`, `COLORTERM=truecolor`.
- `omarchy-hyprland-workspace-layout-scrolling-master-toggle` — toggles **scrolling ↔ master** (unique; quattro's built-in only does dwindle ↔ scrolling). Persists the rule to `~/.local/state/omarchy/workspace-layouts/` and applies via `hyprctl eval`.
- `hyprsunset.conf`, `xdph.conf`, `wallpapers/` — unchanged, still active.

## Files in `tmuxomarchy/`

- `.tmux.conf` (and an identical `.config/tmux/tmux.conf` for stow) — quattro defaults (keeps the `-N` names and the new `?` keybindings popup) plus:
  - `set -g update-environment "SSH_CONNECTION SSH_CLIENT SSH_TTY DISPLAY"`
  - `set -ag terminal-overrides ",*:Ms=\E]52;%p1%s;%p2%s\007"` (OSC52 clipboard)
  - TPM block (tpm, tmux-sensible, tmux-resurrect, copycat, tmux-open, tmux-yank)
- `bind q` now reloads `~/.tmux.conf` (single source of truth) instead of the old second file.

## Installing on a fresh quattro system

1. Install Omarchy quattro (ISO or `omarchy upgrade to quattro` on 3.8).
2. Clone/copy this repo and run `omarchy_scripts/stow-configs.sh`. Conflicting files are backed up under `~/.local/state/dotfiles-omarchy/backups/`; unmanaged Quattro files are preserved.
3. The workspace-layout toggle is linked into `~/.config/hypr/` and is referenced there directly by `bindings.lua`.
4. `omarchy theme set "Tokyo Night"` (or whatever theme) so themed files regenerate with Quattro templates.
5. Install tmux plugins once: `prefix + I` in a running tmux.

## Validation checklist

- `hyprctl configerrors` → clean.
- `hyprctl binds` → spot-check HJKL, comma/period, SUPER+Q/W/X, volume keys.
- `omarchy menu keybindings --print` → confirm descriptions.
- `hyprctl monitors` → both displays at the expected scale/positions.
- `hyprctl activeworkspace` → layout on a master workspace reports `master`.
- Tmux: start a session, `prefix + q` reloads without error, `prefix + ?` opens the keybindings popup, TPM plugins installed.
- Nightlight: `hyprsunset` running (`pgrep -x hyprsunset`), profiles from `hyprsunset.conf` active.

## Known caveats / deferred

- **Idle behavior**: Quattro's native shell idle and lock behavior is used; the legacy `hypridle.conf` listeners are intentionally not migrated.
- **Monitor scaling**: `omarchy-hyprland-monitor-scaling-cycle` was retired in quattro (only `up`/`down` remain). `SUPER + SHIFT + CTRL + SLASH` is now bound to `omarchy-hyprland-monitor-scaling up`.
- **Lua parameters**: monitor, workspace, blur, scrolling, and border-animation parameters have been verified against the installed Quattro/Hyprland 0.56 configuration verifier.
- **Super+W and Super+X**: both are universal cut; `SUPER+Q` closes the window.
- **Tmux "Work" session**: `SUPER + ALT + RETURN` uses quattro's `omarchy-launch-terminal-tmux` (session named `Work`), replacing the old `helper` session name.
- **Application binds**: Quattro defaults remain enabled except where they conflict with personal bindings.
- **TMUX plugin dir**: the vendored `plugins/` tree under `tmuxomarchy/.config/tmux/plugins/` is copied onto disk but gitignored (the original accidentally tracked it as gitlinks). TPM installs/manages plugins to `~/.tmux/plugins/` on first run (`prefix + I`). `tmux-sensible` may override `default-terminal` — verify the status bar still looks right after TPM install.
