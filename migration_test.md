# Hyprland Defaults Migration Test Notes

This branch consolidates the desktop configuration on top of the installed
Omarchy defaults. The repository contains only desktop-specific overrides and
keeps the Omarchy default Lua tree as the source of shared functionality.

## Baseline

- Omarchy: `4.0.0.alpha`
- Hyprland: `0.56.1`
- Default Lua tree: `~/.local/share/omarchy/default/hypr/`
- Stow target: `~/.config/hypr/`
- Branch: `hypr-defaults-migration`

The installed defaults are loaded first by `hyprland.lua`. User modules are
loaded afterward. The obsolete `bootstrap.lua` and
`omarchy_preinstalled_bindings` assumptions are not used because they are not
present in this installed Omarchy release.

## Desktop-Specific Behavior

These settings are intentionally retained from the desktop project:

- Acer 34-inch ultrawide at 3440x1440@120 as the primary monitor.
- Samsung monitor in portrait orientation to the left.
- Workspace 1 on `DP-3` and workspace 2 on the Acer monitor by default.
- VRR mode `2`.
- Scrolling layout by default with the project master-layout settings.
- Zero gaps, 3px borders, blur, cyan/green active border, and border-angle
  animation.
- 600ms key repeat delay, numlock, touchpad scrolling, and terminal scrolling
  rules.
- Automatic `hyprsunset` startup with the project temperature profiles.
- `HYPRLAND_NO_EXTRA_SYNC=1` and `COLORTERM=truecolor`.

The monitor definitions are hardware-specific by design and must not be
replaced with generic catch-all rules when this repository is used on the
desktop machine.

## Binding Conflict Policy

Only real conflicts with the installed defaults are unbound. Project behavior
then relocates the displaced functionality where practical:

| Default action | Original key | Project key |
|---|---|---|
| Toggle split | `Super+J` | `Super+Slash` |
| Pseudo window | `Super+P` | `Super+Alt+P` |
| Pop window | `Super+O` | `Super+Shift+O` |
| Workspace layout toggle | `Super+L` | `Super+Backslash` |
| Close window | `Super+W` | `Super+Q` |
| Workspace cycling | `Super+Tab` family | `Super+Comma/Period` |
| Keybindings menu | `Super+K` | `Super+Alt+Slash` |
| Monitor scaling forward | `Super+Slash` | `Super+Shift+Ctrl+Slash` |
| Monitor scaling reverse | `Super+Alt+Slash` | `Super+Shift+Ctrl+Alt+Slash` |
| Dismiss notification | `Super+Comma` | `Super+Alt+Period` |
| Dismiss all notifications | `Super+Shift+Comma` | `Super+Shift+Alt+Period` |

The project intentionally keeps `Super+X` as Omarchy universal cut and uses
`Super+W` for the same cut action after moving close-window to `Super+Q`.
Browser, file-manager, editor, webapp, and other preinstalled app bindings are
not copied into this user file because the installed default loader does not
load that block and the desktop project intentionally does not use them.

## Command Compatibility

The installed commands used by this branch must be checked after every
Omarchy update:

- Volume: `omarchy-swayosd-client --output-volume +2/-2`
- Scaling: `omarchy-hyprland-monitor-scaling-cycle` and `--reverse`
- Window pop: `omarchy-hyprland-window-pop`
- Notifications: `makoctl dismiss` and `makoctl dismiss --all`
- Layout APIs: `hyprctl eval` with `hl.workspace_rule`
- Terminal/Tmux launchers: `omarchy-launch-terminal` and
  `omarchy-launch-terminal-tmux`

Older commands such as `omarchy-audio-output-volume`,
`omarchy-hyprland-monitor-scaling up`, and `omarchy-shell notifications
dismissOne` are not available in this baseline and must not be restored
without verification.

## Validation Checklist

Before stowing:

```bash
git diff --check
luac -p hypromarchy/.config/hypr/*.lua
bash -n hypromarchy/.config/hypr/omarchy-hyprland-workspace-layout-scrolling-master-toggle
```

After stowing and starting Hyprland:

```bash
hyprctl configerrors
hyprctl monitors
hyprctl activeworkspace
hyprctl binds -j
```

Verify:

- Both configured monitors appear at the expected mode, position, scale, and
  transform.
- Workspace 1 and workspace 2 follow their monitor rules.
- VRR is enabled with value `2`.
- `Super+Shift+I` toggles scrolling and master and survives reload.
- `Super+Backslash` toggles Omarchy's dwindle/scrolling layout.
- `Super+Alt+P` activates pseudo mode.
- Both monitor-scaling directions work.
- Both notification dismissal shortcuts work.
- Volume changes use 2% steps.
- `hyprsunset` is running and follows all four profiles.

## Stow Safety

The current `omarchy_scripts/stow-configs.sh` removes its targets before
stowing. Before using it on a live system, back up `~/.config/hypr` and verify
that the backup contains the active configuration. Do not run the script while
the repository is on the wrong branch or while the monitor target is unknown.

## Future Omarchy Alpha Updates

After an Omarchy update:

1. Re-read the installed default `omarchy.lua`, bindings, input, looknfeel,
   helper, and script files.
2. Compare every explicit `hl.unbind` against the new default bindings.
3. Re-check all commands with `command -v` and inspect changed scripts.
4. Check `/usr/share/hypr/stubs/hl.meta.lua` for renamed Lua fields or APIs.
5. Validate monitor fields, workspace-rule fields, VRR, blur, and animation
   parameters before activating the config.
6. Remove any user override that the new default now provides.
7. Test stowing from a backup and update this file with the new versions and
   any changed compatibility decisions.
