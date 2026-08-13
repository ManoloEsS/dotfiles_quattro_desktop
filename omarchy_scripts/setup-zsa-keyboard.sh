#!/usr/bin/env bash
set -euo pipefail

RULE_FILE=/etc/udev/rules.d/50-zsa.rules

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo $0 [username]" >&2
  exit 1
fi

TARGET_USER="${SUDO_USER:-${1:-}}"
if [[ -z "$TARGET_USER" || "$TARGET_USER" == root ]] || ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "Usage: sudo $0 <username>" >&2
  echo "Example: sudo $0 $USER" >&2
  exit 1
fi

if getent group plugdev >/dev/null; then
  echo "==> plugdev group already exists"
else
  echo "==> Creating plugdev group"
  groupadd plugdev
fi

usermod -aG plugdev "$TARGET_USER"

echo "==> Installing $RULE_FILE"
if [[ -e "$RULE_FILE" ]]; then
  backup="$RULE_FILE.backup.$(date +%Y%m%d-%H%M%S)"
  cp -a "$RULE_FILE" "$backup"
  echo "    Existing rule backed up to $backup"
fi

cat > "$RULE_FILE" <<'EOF'
# ZSA keyboards: Oryx live training and Keymapp access
KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0660", GROUP="plugdev", TAG+="uaccess"
KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0660", GROUP="plugdev", TAG+="uaccess"

# ZSA WebUSB access (including Moonlander)
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", MODE="0660", GROUP="plugdev", TAG+="uaccess"

# Moonlander and Planck EZ DFU flashing
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0660", GROUP="plugdev", SYMLINK+="stm32_dfu", TAG+="uaccess"

# Voyager DFU flashing
SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE="0660", GROUP="plugdev", SYMLINK+="ignition_dfu", TAG+="uaccess"
EOF

udevadm control --reload-rules
udevadm trigger --subsystem-match=hidraw
udevadm settle

echo "==> Done. Unplug and reconnect the keyboard, then log out/in (or reboot)."
echo "    Verify with: id -nG"
echo "    The user '$TARGET_USER' must show plugdev."
