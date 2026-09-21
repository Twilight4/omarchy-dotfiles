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
launch musikcube   musikcube   -e musikcube
[[ -x $HOME/.config/zsh/bash-scripts/pipes ]] && launch pipes pipes -e "$HOME/.config/zsh/bash-scripts/pipes"
[[ -x $HOME/.config/zsh/bash-scripts/rain  ]] && launch rain  rain  -e "$HOME/.config/zsh/bash-scripts/rain"
launch fetch       fetch       --hold -e fastfetch
launch cpufetch    cpufetch    --hold -e cpufetch
launch fireplace   fireplace   -e fireplace
launch cbonsai     cbonsai     -e cbonsai --live
