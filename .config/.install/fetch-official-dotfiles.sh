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
# The redirect is kept, and neutralized below (see "Omarchy XDG bridge") so
# content Omarchy installs into the standard dirs stays visible.
#
# Excluded from the shared list on purpose: tools Omarchy itself rices/themes
# (neofetch via its own fetch identity, cava via theme colors) and the
# Garuda-desktop trees (waybar, rofi, swaync, wlogout, sddm, wal).

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
    fontconfig   # font rendering preferences
    lsd          # ls replacement theme/icons
    cliamp       # music player playlists (config.toml stays local)
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

# OMP (oh-my-pi) agent config. Tracked in the official repo under
# .config/omp/ but lives at ~/.omp/ — copy only the tracked files, never the
# runtime state (agent.db, sessions, node_modules).
if [[ -d $OFFICIAL_DIR/.config/omp ]]; then
    for f in agent/config.yml agent/mcp.json agent/models.yml \
             plugins/package.json plugins/omp-plugins.lock.json; do
        src="$OFFICIAL_DIR/.config/omp/$f"
        [[ -f $src ]] || continue
        mkdir -p "$HOME/.omp/$(dirname "$f")"
        cp -a "$src" "$HOME/.omp/$f"
    done
    ok "Deployed ~/.omp agent config (config.yml, mcp.json, models.yml, plugins)"
fi

#------------------------------------------------------- omarchy zsh bridge
# Three Omarchy-specific patches to the freshly deployed zsh config. All are
# idempotent and re-applied on every install run (the official repo's
# .zshenv may be re-deployed over them).
ZSHENV="$HOME/.config/zsh/.zshenv"

# 1) PATH: Omarchy installs user-local binaries (agent CLIs, mise stubs:
#   omp, pi, claude, gh, codex, ...) into ~/.local/bin — the official
#   .zshenv doesn't put it on PATH.
if [[ -f $ZSHENV ]] && ! grep -q 'omarchy-dotfiles: local bin' "$ZSHENV"; then
    {
        echo ''
        echo '# omarchy-dotfiles: local bin (omarchy agent CLIs / mise stubs)'
        echo 'export PATH="$HOME/.local/bin:$PATH"'
    } >> "$ZSHENV"
    ok "Added ~/.local/bin to PATH in .zshenv"
fi

# 2) XDG bridge: keep the official XDG_DATA_HOME redirect (~/.config/.local/
#   share) but make Omarchy's standard-dir content visible through it via
#   symlinks — fonts (font picker), applications (webapp/TUI .desktop
#   entries), icons (user themes/cursors).
for sub in fonts applications icons; do
    std="$HOME/.local/share/$sub"
    red="$HOME/.config/.local/share/$sub"
    mkdir -p "$std" "$(dirname "$red")" # ln won't create the redirect parent
    if [[ -L $red ]]; then
        continue # already bridged
    fi
    if [[ -e $red ]]; then
        # Real dir in the way: merge its contents into the standard dir,
        # then replace with the symlink.
        cp -a "$red/." "$std/" && rm -rf "$red"
    fi
    ln -s "$std" "$red"
    ok "Bridged ~/.config/.local/share/$sub -> ~/.local/share/$sub"
done
# 3) mise bridge: /usr/share/omarchy/default/bash/env-bootstrap hardcodes
#    ~/.local/share/mise/shims on PATH (login shells + uwsm session), but the
#    XDG redirect moves mise's real data dir. Symlink the standard path at the
#    redirect so zsh (XDG set) and bash/ssh (XDG unset) share one tool tree —
#    otherwise they drift and stale shims report "not a valid shim".
std="$HOME/.local/share/mise"
red="$HOME/.config/.local/share/mise"
if [[ -d $std && ! -L $std ]]; then
    if [[ -d $red ]]; then
        mv "$std" "$std.pre-xdg-$(date +%Y%m%d%H%M%S)" # both trees exist: archive the stale one
    else
        mkdir -p "$(dirname "$red")"
        mv "$std" "$red" # adopt the pre-XDG tree as the real one
    fi
fi
mkdir -p "$red" # a dangling symlink resolves once mise installs its first tool
if [[ ! -L $std ]]; then
    mkdir -p "$(dirname "$std")" # ln won't create the standard-dir parent
    ln -s "$red" "$std"
    ok "Bridged ~/.local/share/mise -> ~/.config/.local/share/mise"
fi
