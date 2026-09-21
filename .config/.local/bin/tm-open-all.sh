#!/bin/bash
# Terminal-toys dashboard: open the full set of CLI eye-candy in kitty
# windows, one per toy. Ported from the Garuda dotfiles tm-open-all.sh
# (old SUPER+CTRL+SHIFT+A binding). Launched by the "Terminal Toys"
# app-launcher entry. Each window gets its own --class so window rules
# can target toys individually later.

launch() { # <title> <class> <kitty args...>
  local title="$1" class="$2"; shift 2
  setsid uwsm-app -- kitty -T "$title" --class "$class" "$@" &>/dev/null &
}

launch asciiquarium asciiquarium -e asciiquarium --transparent
launch cava        cava        -e cava
launch clock       clock       -e tty-clock -c -C 6 -r -s -f "%A, %B, %d"
launch cmatrix     cmatrix     -e cmatrix
[[ -x $HOME/.config/zsh/bash-scripts/pipes ]] && launch pipes pipes -e "$HOME/.config/zsh/bash-scripts/pipes"
[[ -x $HOME/.config/zsh/bash-scripts/rain  ]] && launch rain  rain  -e "$HOME/.config/zsh/bash-scripts/rain"
launch fetch       fetch       -e bash -c 'while true; do clear; fastfetch; echo; echo "any key = refresh · q = quit"; read -rsn1 k; [[ $k == q ]] && break; done'
launch cpufetch    cpufetch    -e bash -c 'while true; do clear; cpufetch; echo; echo "any key = refresh · q = quit"; read -rsn1 k; [[ $k == q ]] && break; done'
launch cbonsai     cbonsai     -e cbonsai --live
