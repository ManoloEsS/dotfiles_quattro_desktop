#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSHRC="$DOTFILES_DIR/zsh/.zshrc"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

BUNDLED_PLUGINS=(git gh command-not-found vi-mode)

declare -A PLUGIN_REPOS=(
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-completions"]="https://github.com/zsh-users/zsh-completions.git"
    ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab.git"
)

declare -A THEME_REPOS=(
    ["powerlevel10k"]="https://github.com/romkatv/powerlevel10k.git"
)

echo "==> Reading plugins from $ZSHRC..."
PLUGINS_LINE=$(grep '^plugins=' "$ZSHRC" | grep -oP '(?<=plugins=\()[^)]+')
read -ra PLUGINS <<< "$PLUGINS_LINE"

echo "==> Creating OMZ custom directories..."
mkdir -p "$ZSH_CUSTOM/plugins"
mkdir -p "$ZSH_CUSTOM/themes"

echo "==> Installing external plugins..."
for plugin in "${PLUGINS[@]}"; do
    if [[ " ${BUNDLED_PLUGINS[*]} " =~ " ${plugin} " ]]; then
        echo "    [SKIP] $plugin (bundled with OMZ)"
        continue
    fi

    if [[ -n "${PLUGIN_REPOS[$plugin]}" ]]; then
        TARGET_DIR="$ZSH_CUSTOM/plugins/$plugin"
        if [[ -d "$TARGET_DIR/.git" ]]; then
            echo "    [SKIP] $plugin (already installed)"
        else
            echo "    [CLONE] $plugin..."
            git clone "${PLUGIN_REPOS[$plugin]}" "$TARGET_DIR"
        fi
    fi
done

echo "==> Installing themes..."
for theme in "${!THEME_REPOS[@]}"; do
    TARGET_DIR="$ZSH_CUSTOM/themes/$theme"
    if [[ -d "$TARGET_DIR/.git" ]]; then
        echo "    [SKIP] $theme (already installed)"
    else
        echo "    [CLONE] $theme..."
        git clone "${THEME_REPOS[$theme]}" "$TARGET_DIR"
    fi
done

echo "==> Done! Restart your terminal or run: source ~/.zshrc"
