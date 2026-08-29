#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Installs ONLY the delta on top of a stock Omarchy install:
#   1. rice picks that differ from Omarchy defaults
#   2. the official-dotfiles toolset that Omarchy doesn't ship
#
# Runs AFTER remove-bloat.sh (which launches Omarchy's preinstall remover
# first), so packages dropped there that this rice still wants come back
# from the official variants: cliamp-bin (not omarchy's cliamp) and
# gnome-calculator (instead of omacalc).
#
# Everything Omarchy already ships is deliberately excluded — including the
# rice tools we keep as Omarchy's: quickshell (omarchy dep: bar/launcher/
# notifications/OSD/idle+lock), aether (theme builder), plymouth (boot
# splash), hyprpicker (color picker), satty (screenshot annotation), imv
# (image viewer), gpu-screen-recorder (screen recording — wf-recorder is NOT
# used by Omarchy's capture scripts), yaru icon theme, ufw + ufw-docker,
# power-profiles-daemon, swaybg, grim/slurp, wl-clipboard.
# Web apps (google-maps-desktop & friends) install via Omarchy's webapp
# scripts (`omarchy-webapp-install`), not from here.
#
# Deliberately NOT installed (rice/system conflicts with Omarchy's stack):
#   waybar, rofi/wofi, swaync, wob, wlogout, nwg-dock-hyprland, swappy,
#   swayimg (imv instead), scrot, aylurs-gtk-shell, sddm-git/pixie-sddm-git,
#   kvantum-qt5 (omarchy migration removes it), graphite gtk theme +
#   gtk-engine-murrine + python-pywal (aether themes own appearance),
#   ananicy-cpp/nohang/cpupower/zenpower3-dkms/irqbalance/acpid
#   (power-profiles-daemon), firewalld (ufw), apparmor, tealdeer (tldr),
#   eza (removed in remove-bloat.sh; lsd instead), trizen (yay),
#   qt5/qt6 support packages (quickshell owns the Qt stack).

info "Installing delta packages..."

packages=(
    # ---- rice picks -----------------------------------------------------
    "kitty"                    # terminal (alacritty removed in remove-bloat.sh)
    "bibata-cursor-theme"      # cursor theme, same as official dotfiles
    "zen-browser-bin"          # browser (chromium removed in remove-bloat.sh)
    "cliamp-bin"               # official variant; omarchy's cliamp preinstall
                               # is dropped by the preinstall remover first

    # ---- touch stack (2-in-1 panel) -------------------------------------
    "wvkbd"                    # on-screen keyboard (wvkbd-mobintl)
    "iio-sensor-proxy"         # accelerometer -> monitor-sensor (auto-rotate)

    # ---- shell (official dotfiles zsh + p10k) ---------------------------
    "zsh"
    "zsh-autosuggestions"
    "zsh-completions"
    "zsh-history-substring-search"
    "zsh-syntax-highlighting"
    "thefuck"
    "lsd"
    "fasd"
    "pkgfile"

    # ---- editor / dev ---------------------------------------------------
    "emacs-git"
    "go-task"
    "act"
    "git-delta"
    "texlive-binextra"
    "texlive-bin"
    "texlive-basic"
    "texlive-latexextra"
    "texlive-plaingeneric"
    "texlive-fontsrecommended"
    "words"
    "hunspell"
    "hunspell-en_us"
    "hunspell-pl"
    "rlwrap"
    "ruby-pkg-config"
    "python-click"
    "python-click-aliases"
    "python-tomlkit"
    "python-scapy"
    "python-requests"
    "python-pip"
    "ngrok"
    "cronie"

    # ---- files / CLI ----------------------------------------------------
    "yazi"
    "trash-cli"
    "duf"
    "ncdu"
    "sd"
    "pv"
    "xcp"
    "xh"
    "grc"
    "translate-shell"
    "qrencode"
    "chafa"
    "perl-image-exiftool"
    "xdg-ninja-git"
    "wget"
    "net-tools"
    "speedtest-cli"
    "proxychains-ng"
    "freerdp2"
    "acpi"
    "udiskie"
    "usbutils"
    "udev-block-notify-git"
    "mtools"
    "pfetch"
    "cpufetch"
    "macchina"
    "onefetch"
    "cheat"
    "ddgr"
    "dog"

    # ---- media ----------------------------------------------------------
    "mpv-mpris"
    "yt-dlp"
    "noise-suppression-for-voice-git"

    # ---- desktop extras -------------------------------------------------
    "zathura"
    "zathura-pdf-poppler"
    "wlr-randr-git"
    "yad"
    "zenity"
    "nautilus-open-any-terminal"
    "nautilus-image-converter"
    "nautilus-admin-gtk4"
    "gnome-calculator"         # replaces omacalc (dropped by the remover)
    "gnome-clocks"
    "gnome-maps"
    "gnome-weather"

    # ---- user apps ------------------------------------------------------
    "ferdium-bin"
    "freetube"
    "torbrowser-launcher"
    "onionshare"
    "privatebin-cli"

    # ---- terminal toys --------------------------------------------------
    "fortune-mod"
    "tty-clock"
    "cowsay"
    "figlet"
    "lolcat"
    "cbonsai"
    "cmatrix-git"
    "smassh-bin"
)

_installPackages "${packages[@]}"

ok "Delta packages installed."
