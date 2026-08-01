#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -A TARGETS=(
    ["hypromarchy"]="$HOME/.config/hypr"
    ["hyprncspot"]="$HOME/.config/ncspot"
    ["tmuxomarchy"]="$HOME/.config/tmux $HOME/.tmux.conf"
    ["wezterm"]="$HOME/.wezterm.lua"
    ["yazi"]="$HOME/.config/yazi"
    ["zsh"]="$HOME/.zshrc"
    ["pl10k"]="$HOME/.p10k.zsh"
)

echo "==> Checking for stow..."
if ! command -v stow &> /dev/null; then
    echo "Error: stow is not installed. Please install it with: pacman -S stow"
    exit 1
fi

echo "==> Stowing configs..."

for pkg in hypromarchy hyprncspot tmuxomarchy wezterm yazi zsh pl10k; do
    echo "    Processing $pkg..."

    for target in ${TARGETS[$pkg]}; do
        if [[ -e "$target" ]]; then
            echo "        Removing $target..."
            rm -rf "$target"
        fi
    done

    echo "        Stowing $pkg..."
    stow -v -t "$HOME" -d "$DOTFILES_DIR" "$pkg"
done

echo "==> Done!"
