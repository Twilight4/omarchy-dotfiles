# omarchy-dotfiles

Rice layer for a [Omarchy](https://omacom.io) install — Twilight4's Omarchy
flavored desktop, kept separate from the official (Garuda) dotfiles repo to
isolate the two rices and minimize conflicts.

It does **not** replace Omarchy's defaults — it adopts them (quickshell
bar/launcher/notifications/OSD, aether theme builder, plymouth, hyprpicker,
satty, imv, gpu-screen-recorder, ufw, power-profiles-daemon) and layers only
what differs on top.

## What it owns

| Path | Content |
|---|---|
| `.config/hypr/` | Hyprland Lua configs (Omarchy 4 layout) + Bibata cursor block |
| `.config/omarchy/` | quickshell `shell.json` layout, hooks, branding, extensions, `themed/` |
| `.config/kitty/`, `.config/imv/` | terminal + image viewer |
| `.config/gtk-3.0/`, `.config/gtk-4.0/` | Bibata cursor settings |
| `.config/.install/` | the install chain (below) |

Shell plugin *code* is not tracked — `setup-plugins.sh` re-clones the three
quickshell plugins from their git remotes.

## Install

From a running Hyprland session on a stock Omarchy install:

```sh
git clone git@github.com:Twilight4/omarchy-dotfiles.git ~/desktop/workspace/omarchy-dotfiles
~/desktop/workspace/omarchy-dotfiles/.config/.install/install.sh
```

Run it from anywhere except inside `~/.config` itself.

## What the install chain does

1. **remove-bloat** — launches Omarchy's own "Remove > Preinstalls" action
   (the SUPER+SPACE menu script, interactive gum confirm) *first*, then this
   rice's own drops: unused preinstalls (1password, spotify, signal,
   typora, localsend, …), the pre-v4 stack (waybar, mako, walker, swayosd,
   hypridle/hyprlock), evince (zathura instead) and shell/browser swaps
   (alacritty→kitty, chromium→zen). Guarded: only installed packages are
   touched.
2. **install-packages** — the delta only: kitty, Bibata cursor, zen-browser,
   cliamp-bin + gnome-calculator (official replacements for what the
   preinstall remover drops) + the official-dotfiles toolset (zsh/p10k
   stack, emacs, texlive, CLI tools, user apps). Everything Omarchy already
   ships is excluded.
3. **deploy-configs** — non-destructive copy of the tracked configs into
   `~/.config` (never `rm -rf`; `omarchy-update` keeps working).
4. **fetch-official-dotfiles** — clone/pull `Twilight4/dotfiles` and deploy
   the shared trees (`zsh emacs git btop mpv yazi zathura bat fontconfig
   lsd`) + user scripts; then the **Omarchy zsh bridge**: `~/.local/bin`
   on PATH (Omarchy's agent CLIs / mise stubs) and XDG symlinks so the
   official `.zshenv`'s `XDG_DATA_HOME` redirect keeps Omarchy's
   `~/.local/share/{fonts,applications,icons}` visible.
5. **zsh / cursor / plugins / cleanup-homedir** — default shell, Bibata via
   gsettings + hyprctl, plugin re-clones, XDG home skeleton (`~/.local` and
   `~/.cache` left intact for Omarchy).
6. **run-post-install** — runs the official repo's `post-install.sh`
   (same 15-step workflow as the Garuda install), then prints the
   completion message. Changes apply live; no reboot needed.

## Relationship to the official repo

The official repo ([dotfiles](https://github.com/Twilight4/dotfiles)) stays
the source of truth for everything shared between both machines (zsh, emacs,
git, …). This repo only tracks the Omarchy-specific layer and pulls the
shared parts in at install time — edit shared configs in the official repo,
Omarchy-specific ones here.
