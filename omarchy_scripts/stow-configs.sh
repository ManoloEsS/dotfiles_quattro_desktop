#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.local/state/dotfiles-omarchy/backups/$(date +%Y%m%d-%H%M%S)"

echo "==> Checking for stow..."
if ! command -v stow &> /dev/null; then
    echo "Error: stow is not installed. Please install it with: pacman -S stow"
    exit 1
fi

backup_conflicts() {
    local pkg="$1"
    local source rel target target_dir

    while IFS= read -r -d '' source; do
        rel="${source#"$DOTFILES_DIR/$pkg/"}"
        target="$HOME/$rel"

        if [[ "$pkg" == "hypromarchy" && "$rel" == .etc/* ]]; then
            continue
        fi
        if [[ "$pkg" == "hyprncspot" && "$rel" == .config/ncspot/userstate.cbor ]]; then
            continue
        fi

        if [[ ! -f "$target" && ! -L "$target" ]]; then
            continue
        fi

        if [[ -L "$target" && "$(readlink -f "$target")" == "$source" ]]; then
            continue
        fi

        target_dir="$BACKUP_DIR/$(dirname "$rel")"
        mkdir -p "$target_dir"
        mv "$target" "$target_dir/"
        echo "        Backed up $target to $target_dir/"
    done < <(find "$DOTFILES_DIR/$pkg" \( -type f -o -type l \) -print0)
}

echo "==> Stowing configs..."
echo "    Backups will be stored in $BACKUP_DIR when conflicts are found."

for pkg in hypromarchy hyprncspot tmuxomarchy wezterm ghostty yazi zsh pl10k mise opencode pi; do
    echo "    Processing $pkg..."

    backup_conflicts "$pkg"

    echo "        Stowing $pkg..."
    if [[ "$pkg" == "hypromarchy" ]]; then
        stow -v --no-folding --ignore='^\.etc(/|$)' -t "$HOME" -d "$DOTFILES_DIR" "$pkg"
    elif [[ "$pkg" == "hyprncspot" ]]; then
        stow -v --no-folding --ignore='^\.config/ncspot/userstate\.cbor$' -t "$HOME" -d "$DOTFILES_DIR" "$pkg"
    else
        stow -v --no-folding -t "$HOME" -d "$DOTFILES_DIR" "$pkg"
    fi
done

echo "==> Done!"
