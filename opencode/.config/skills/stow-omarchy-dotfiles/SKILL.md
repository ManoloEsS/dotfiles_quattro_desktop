---
name: stow-omarchy-dotfiles
description: Safely inventory and deploy this repository's personal configurations on a fresh Omarchy Quattro system using GNU Stow, while preserving Omarchy defaults and backing up conflicts.
---

# Stow Omarchy Dotfiles

Deploy the dotfiles repository to a fresh Omarchy Quattro installation. Treat
the repository as personal overrides on top of the installed Quattro base, not
as a replacement for Omarchy's managed files.

## Safety Rules

- Never edit or overwrite `/usr/share/omarchy/`.
- Never use `rm -rf` on `~/.config`, `~/.config/hypr`, or another broad target.
- Inventory targets before changing them.
- Back up every conflicting regular file or symlink before Stow changes it.
- Do not silently overwrite existing user configuration.
- Do not deploy `legacy/hypr-3.8/`.
- Do not deploy `hypromarchy/.etc/` with Stow. Its correct target is `/etc/`, not `~/.etc/`; require explicit root-approved handling.
- Treat binary/session state as non-portable unless the user explicitly requests it.
- Ask for confirmation before installing packages, changing `/etc`, resetting Omarchy configuration, or restarting the desktop session.

## Repository Root

Resolve the repository root from this skill's location. It is the parent of the
`opencode/` package directory. Do not assume the current working directory.

Read `DOTFILES_INVENTORY.md` before deployment and update it when package
targets change.

## Preflight

Run these checks before modifying files:

```bash
test -f /etc/os-release
command -v omarchy
command -v stow
omarchy version
hyprctl version
```

If GNU Stow is missing, report that and ask before installing it with the
system package manager. Do not install packages silently.

Inventory each package and compare every source path with its `$HOME` target.
Classify each path as:

- absent target: safe to link
- existing regular file: back up, then link
- existing symlink to this repository: already deployed
- existing symlink elsewhere: report and ask before replacing
- directory containing unrelated files: preserve the directory and link only package files
- machine state or secrets: skip unless explicitly approved

## Deployment Order

Deploy home-directory packages only after the preflight:

```text
hypromarchy
tmuxomarchy
zsh
pl10k
wezterm
ghostty
yazi
hyprncspot
mise
opencode
```

The current `omarchy_scripts/stow-configs.sh` is the intended deployment
entrypoint, but verify its package list includes every package selected by the
user before running it. It must back up file conflicts and use the repository
root as its Stow directory.

Skip these unless explicitly requested:

- `hyprncspot/.config/ncspot/userstate.cbor`
- `hypromarchy/.etc/`
- `legacy/`
- `.claude/` unless the user wants Claude skills installed globally

## Hyprland Handling

The `hypromarchy` package uses the Quattro Lua architecture:

- `hyprland.lua` loads Omarchy defaults first, then personal modules.
- Personal modules override only the user's monitors, bindings, appearance, environment, and startup behavior.
- Input settings should remain inherited from the current Quattro base unless the package explicitly adds an input override.
- Quattro shell idle, lock, notification, and OSD behavior must remain enabled.
- Preserve custom `hyprsunset` only when it is present in the selected package.

Before activation:

1. Back up an active `~/.config/hypr/hyprland.conf` if the package uses `hyprland.lua`.
2. Ensure the repository's `hyprland.lua` and personal modules are linked.
3. Verify the Lua configuration against the installed base:

```bash
HOME="$HOME" OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}" \
  hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua"
```

After activation, validate:

```bash
hyprctl reload
hyprctl configerrors
hyprctl monitors
hyprctl workspaces
hyprctl binds
```

If validation fails, stop and report the exact error. Do not reset Hyprland
automatically. Use `omarchy refresh hyprland` only after user confirmation.

## Completion Report

Report:

- Omarchy and Hyprland versions
- Packages deployed and skipped
- Backup directory
- Conflicts found and how each was handled
- Hyprland validation result
- Any manual `/etc` steps still required
