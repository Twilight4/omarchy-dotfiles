#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Fetches the official (Garuda) dotfiles repo and deploys ONLY the config
# trees shared by both rices. The Omarchy-specific configs (hypr, omarchy,
# kitty, imv, gtk) come from THIS repo and are never touched here; the
# Garuda-desktop-specific trees (hypr Garuda flavor, waybar, rofi, swaync,
# wlogout, sddm theme, wal) are cloned but NOT deployed.
#
# NOTE: the official zsh .zshenv redirects XDG_DATA_HOME to
# ~/.config/.local/share and XDG_CACHE_HOME to ~/.config/.local/share/cache.
# Omarchy's own state lives under ~/.local/state (XDG_STATE_HOME, unchanged)
# so its toggles/migrations are safe — but fonts installed by Omarchy's
# font picker into ~/.local/share/fonts are invisible to shells started
# under that redirect. install-fonts.sh therefore installs into the
# redirected dir, which terminal apps (kitty/p10k) do see.

info "Fetching official dotfiles..."

OFFICIAL_DIR="${OFFICIAL_DIR:-$HOME/desktop/workspace/dotfiles}"
OFFICIAL_REMOTE_SSH="git@github.com:Twilight4/dotfiles.git"
OFFICIAL_REMOTE_HTTPS="https://github.com/Twilight4/dotfiles.git"

if [[ -d $OFFICIAL_DIR/.git ]]; then
    info "Official repo present, updating: $OFFICIAL_DIR"
    git -C "$OFFICIAL_DIR" pull --ff-only || warn "git pull failed — using existing checkout."
elif [[ -d $OFFICIAL_DIR ]]; then
    warn "$OFFICIAL_DIR exists but is not a git repo — skipping fetch."
else
    git clone "$OFFICIAL_REMOTE_SSH" "$OFFICIAL_DIR" \
        || git clone "$OFFICIAL_REMOTE_HTTPS" "$OFFICIAL_DIR" \
        || { err "Could not clone the official dotfiles repo."; return 1; }
fi
[[ -d $OFFICIAL_DIR/.config ]] || { err "Official repo has no .config dir."; return 1; }

ok "Official dotfiles at $OFFICIAL_DIR"

# Config trees shared by both rices. Extend this list, not the copies.
shared_configs=(
    zsh          # shell (aliases, p10k, functions, scripts)
    emacs        # primary editor (literate config.org)
    git          # gitconfig + delta pager
    btop         # system monitor
    mpv          # media player
    yazi         # file manager (TUI)
    zathura      # document viewer
    bat          # bat + bat-extras config
    cava         # audio visualizer
    fontconfig   # font rendering preferences
    lsd          # ls replacement theme/icons
    neofetch     # fetch tool (their tracked config.conf)
)

info "Deploying shared configs from the official repo..."
for d in "${shared_configs[@]}"; do
    src="$OFFICIAL_DIR/.config/$d"
    dst="$HOME/.config/$d"
    [[ -d $src ]] || { warn "Not in official repo, skipping: $d"; continue; }
    mkdir -p "$dst"
    cp -a "$src/." "$dst/"
    ok "Deployed ~/.config/$d"
done

# User scripts (emacs-pager, notify-log, omp-stt-transcribe, cp-* profiles).
# Non-destructive copy; existing files with the same name are overwritten by
# the tracked versions.
if [[ -d $OFFICIAL_DIR/.config/.local/bin ]]; then
    mkdir -p "$HOME/.config/.local/bin"
    cp -a "$OFFICIAL_DIR/.config/.local/bin/." "$HOME/.config/.local/bin/"
    ok "Deployed ~/.config/.local/bin user scripts"
fi
