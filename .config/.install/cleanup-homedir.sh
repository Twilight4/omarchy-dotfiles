#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
# Modified copy of the official dotfiles cleanup-homedir.sh.
#
# Omarchy-specific changes vs the original:
# - ~/.local is NEVER moved or deleted: Omarchy 4 keeps its state under
#   ~/.local/state/omarchy (toggles, migration stamps) and themes/migrations
#   rely on the standard XDG dirs. The original script's
#   `rm -rf ~/.local` + ~/.local/share*/state* move loops would break it.
# - ~/.cache is left in place for the same reason (running session apps).
# - The stock-file removals (~/.bash*, capitalized XDG dirs, ...) are kept.

read -rp "This will tidy the \$HOME directory (create XDG skeleton, relocate stray dotfiles). Press any key to continue or Ctrl+C to exit..." -n 1 -s
echo

# Create necessary directories
directories=(
    ~/{documents,downloads,desktop,videos,music,pictures}
    ~/pictures/{dcim,screenshots}
    ~/documents/pdfs
    ~/desktop/{workspace,projects,server}
    ~/.ssh
    ~/.config/.local/share/gnupg
    ~/.config/.local/share/gnupg/private-keys-v1.d
    ~/.config/.local/share/cargo
    ~/.config/.local/share/go
    ~/.config/.local/share/mpd/playlists
    ~/.config/.local/state/less/history
    ~/.config/.local/share/nimble
    ~/.config/.local/share/pki
)

for directory in "${directories[@]}"; do
    if [[ ! -d "$directory" ]]; then
        info "Creating directory: $directory..."
        mkdir -p "$directory"
    fi
done

if [ ! -d "/opt/tools" ]; then
  sudo mkdir -p /opt/tools
fi

# Function to move a file or directory if it exists
move_if_exists() {
    if [ -e "$1" ]; then
        mv -v "$1" "$2"
    fi
}

# Gnupg fix
chmod 700 ~/.config/.local/share/gnupg/private-keys-v1.d

# Move directories and files if they exist
move_if_exists ~/.gnupg ~/.config/.local/share/gnupg
move_if_exists ~/.cargo ~/.config/.local/share/cargo
move_if_exists ~/go ~/.config/.local/share/go
move_if_exists ~/.lesshst ~/.config/.local/state/less/history
move_if_exists ~/.nimble ~/.config/.local/share/nimble
move_if_exists ~/.pki ~/.config/.local/share/pki
move_if_exists ~/node_modules ~/.config
move_if_exists ~/package.json ~/.config/node_modules/package.json
move_if_exists ~/package-lock.json ~/.config/node_modules/package-lock.json

# Remove replaced stock files/dirs: the setup uses lowercase XDG dirs
# (~/documents, ...) and ZDOTDIR-based shell configs under ~/.config, so
# these are dead weight. All rm calls use -f so a re-run with nothing left
# to delete does not error under set -e. User-owned — no sudo needed.
rm -vf ~/.bash*
rm -vrf ~/Documents ~/Pictures ~/Desktop ~/Downloads ~/Templates ~/Music ~/Videos ~/Public
rm -vf ~/.viminfo ~/.zsh* ~/.zcompdump* ~/.dircolors ~/.Xresources ~/.gtkrc-2.0 ~/.gitconfig

ok "Home directory tidied (~/.local and ~/.cache left intact for Omarchy)."
