#!/bin/bash
set -e

echo "==> Updating package database..."
sudo pacman -Syu --noconfirm

echo "==> Installing zsh and lsd from official repos..."
sudo pacman -S --noconfirm zsh lsd

echo "==> Installing yazi, wezterm-git, and zen-browser-bin from AUR..."
yay -S --noconfirm yazi wezterm-git zen-browser-bin

echo "==> Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "==> Note: TPM (tmux plugin manager) is included in tmuxomarchy config..."
echo "    Run ./omarchy_scripts/stow-configs.sh to symlink it, then:"
echo "    - Start tmux and press prefix + I (capital I) to install tmux plugins"

echo "==> Setting zsh as default shell..."
chsh -s /bin/zsh

echo "==> Done! Please restart your terminal."
