# =============================================================================
# omarchy.zsh
# Curated zsh port of Omarchy's default bash aliases/functions. Kept in sync
# with ~/.local/share/omarchy/default/bash/ (aliases, fns). Sourced from zshrc.
# =============================================================================

# --- Tools ---------------------------------------------------------------
# `c` stays 'clear' in zshrc; use `oc` for opencode.
alias oc='opencode'
alias cx='printf "\033[2J\033[3J\033[H" && claude --permission-mode bypassPermissions'
alias cy='codex -s danger-full-access -a never'
alias d='docker'
alias r='rails'
alias t='tmux attach || tmux new -s Work'
alias ic='tdl oc'
alias ix='tdl cx'
alias icx='tdl oc cx'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
alias n='nvim'

# --- Git -----------------------------------------------------------------
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# --- Directories ---------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# --- Files ---------------------------------------------------------------
open() (
  xdg-open "$@" >/dev/null 2>&1 &
)

if [[ "$TERM" == "xterm-kitty" ]]; then
  ff() { fzf --preview 'case $(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac' "$@" }
else
  ff() { fzf --preview 'bat --style=numbers --color=always {}' "$@" }
fi
eff() { ${EDITOR:-nvim} "$(ff)" }
sff() {
  if [ $# -eq 0 ]; then
    echo "Usage: sff <destination> (e.g. sff host:/tmp/)"
    return 1
  fi
  local file
  file=$(find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff) && [ -n "$file" ] && scp "$file" "$1"
}

# --- Compression ---------------------------------------------------------
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# --- Drives --------------------------------------------------------------
iso2sd() {
  if (( $# < 1 )); then
    echo "Usage: iso2sd <input_file> [output_device]"
    echo "Example: iso2sd ~/Downloads/ubuntu.iso /dev/sda"
    return 1
  fi
  local iso="$1" drive="$2"
  if [[ -z $drive ]]; then
    drive=$(lsblk -dpno NAME | grep -E '/dev/sd' | fzf --prompt="Select drive: ") || { echo "No drive selected"; return 1; }
  fi
  sudo dd bs=4M status=progress oflag=sync if="$iso" of="$drive"
  sudo eject "$drive"
}

format-drive() {
  if (( $# != 2 )); then
    echo "Usage: format-drive <device> <name>"
    echo "Example: format-drive /dev/sda 'My Stuff'"
    return 1
  fi
  echo "WARNING: This will completely erase all data on $1"
  read -rq"?Are you sure? (y/N): " || { echo; return 1; }
  echo
  sudo wipefs -a "$1"
  sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
  sudo parted -s "$1" mklabel gpt
  sudo parted -s "$1" mkpart primary 1MiB 100%
  sudo parted -s "$1" set 1 msftdata on
  local partition="$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
  sudo partprobe "$1" || true
  sudo udevadm settle || true
  sudo mkfs.exfat -n "$2" "$partition"
  echo "Drive $1 formatted as exFAT and labeled '$2'."
}

# --- SSH port forwarding -------------------------------------------------
fip() {
  (( $# < 2 )) && { echo "Usage: fip <host> <port1> [port2] ..."; return 1; }
  local host="$1"; shift
  for port in "$@"; do
    ssh -f -N -L "$port:localhost:$port" "$host" && echo "Forwarding localhost:$port -> $host:$port"
  done
}
dip() {
  (( $# == 0 )) && { echo "Usage: dip <port1> [port2] ..."; return 1; }
  for port in "$@"; do
    pkill -f "ssh.*-L $port:localhost:$port" && echo "Stopped forwarding port $port" || echo "No forwarding on port $port"
  done
}
lip() { pgrep -af "ssh.*-L [0-9]+:localhost:[0-9]+" || echo "No active forwards"; }

# --- Git worktrees -------------------------------------------------------
unalias ga 2>/dev/null
ga() {
  [[ -z "$1" ]] && { echo "Usage: ga <branch>"; return 1; }
  local branch="$1" base="$(basename "$PWD")" wt_path="../${base}--${branch}"
  git worktree add -b "$branch" "$wt_path"
  mise trust "$wt_path"
  cd "$wt_path"
}
unalias gd 2>/dev/null
gd() {
  if gum confirm "Remove worktree and branch?"; then
    local cwd="$(pwd)" worktree="$(basename "$cwd")" root branch
    root="${worktree%%--*}"
    branch="${worktree#*--}"
    if [[ "$root" != "$worktree" ]]; then
      cd "../$root"
      git worktree remove "$cwd" --force || return 1
      git branch -D "$branch"
    fi
  fi
}

# --- Tmux dev layouts ----------------------------------------------------
# Usage: tdl <c|cx|codex|other_ai> [<second_ai>]
tdl() {
  [[ -z $1 ]] && { echo "Usage: tdl <c|cx|codex|other_ai> [<second_ai>]"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tdl."; return 1; }

  local current_dir="${PWD}"
  local editor_pane ai_pane ai2_pane
  local ai="$1"
  local ai2="$2"

  editor_pane="$TMUX_PANE"
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"
  tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"
  ai_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

  if [[ -n $ai2 ]]; then
    ai2_pane=$(tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
    tmux send-keys -t "$ai2_pane" "$ai2" C-m
  fi

  tmux send-keys -t "$ai_pane" "$ai" C-m
  tmux send-keys -t "$editor_pane" "$EDITOR ." C-m
  tmux select-pane -t "$editor_pane"
}

# One tdl window per subdirectory in the current directory.
# Usage: tdlm <c|cx|codex|other_ai> [<second_ai>]
tdlm() {
  [[ -z $1 ]] && { echo "Usage: tdlm <c|cx|codex|other_ai> [<second_ai>]"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tdlm."; return 1; }

  local ai="$1"
  local ai2="$2"
  local base_dir="$PWD"
  local first=true

  tmux rename-session "$(basename "$base_dir" | tr '.:' '--')"

  for dir in "$base_dir"/*/; do
    [[ -d $dir ]] || continue
    local dirpath="${dir%/}"

    if $first; then
      tmux send-keys -t "$TMUX_PANE" "cd '$dirpath' && tdl $ai $ai2" C-m
      first=false
    else
      local pane_id=$(tmux new-window -c "$dirpath" -P -F '#{pane_id}')
      tmux send-keys -t "$pane_id" "tdl $ai $ai2" C-m
    fi
  done
}

# Multi-pane swarm layout running the same command in each pane.
# Usage: tsl <pane_count> <command>
tsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: tsl <pane_count> <command>"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tsl."; return 1; }

  local count="$1"
  local cmd="$2"
  local current_dir="${PWD}"
  local -a panes

  tmux rename-window -t "$TMUX_PANE" "$(basename "$current_dir")"

  panes+=("$TMUX_PANE")

  while (( ${#panes[@]} < count )); do
    local new_pane
    local split_target="${panes[-1]}"
    new_pane=$(tmux split-window -h -t "$split_target" -c "$current_dir" -P -F '#{pane_id}')
    panes+=("$new_pane")
    tmux select-layout -t "${panes[0]}" tiled
  done

  for pane in "${panes[@]}"; do
    tmux send-keys -t "$pane" "$cmd" C-m
  done

  tmux select-pane -t "${panes[0]}"
}

# --- Transcoding ---------------------------------------------------------
transcode-video-1080p() { omarchy-transcode "$1" mp4 1080p; }
transcode-video-4K() { omarchy-transcode "$1" mp4 4k; }
transcode-video-gif() { omarchy-transcode "$1" gif 1080p; }
img2jpg() { omarchy-transcode "$1" jpg high; }
img2jpg-small() { omarchy-transcode "$1" jpg low; }
img2jpg-medium() { omarchy-transcode "$1" jpg medium; }
img2jpg-large() { omarchy-transcode "$1" jpg high; }
img2png() { omarchy-transcode "$1" png high; }
