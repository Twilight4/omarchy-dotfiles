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

# Any-key refresh loop — space/enter re-run the tool fresh (e.g. after a
# resize), q closes the window. All other stdin bytes are swallowed: kitty's
# replies to terminal queries (ESC sequences from fastfetch/tput cursor
# reports) must not count as keypresses, or the tool re-runs in a tight loop
# (flicker). Animations are killed and restarted; one-shots just exit.
LOOP='while true; do clear; "$@" & p=$!; while :; do IFS= read -rsn1 k || exit; if [[ $k == q ]]; then kill $p 2>/dev/null; wait $p 2>/dev/null; exit; fi; [[ $k == " " || -z $k ]] && break; done; kill $p 2>/dev/null; wait $p 2>/dev/null; done'

# Native TUIs: redraw on resize and quit on q themselves.
launch asciiquarium asciiquarium -e asciiquarium --transparent
launch cava        cava        -e cava
launch clock       clock       -e tty-clock -c -C 6 -r -s -f "%A, %B, %d"
launch cmatrix     cmatrix     -e cmatrix

[[ -x $HOME/.config/zsh/bash-scripts/pipes ]] && launch pipes pipes -e bash -c "$LOOP" _ "$HOME/.config/zsh/bash-scripts/pipes"
[[ -x $HOME/.config/zsh/bash-scripts/rain  ]] && launch rain  rain  -e bash -c "$LOOP" _ "$HOME/.config/zsh/bash-scripts/rain"
launch fetch       fetch       -o font_size=5 -e bash -c "$LOOP" _ fastfetch
launch cpufetch    cpufetch    -o font_size=7 -e bash -c "$LOOP" _ cpufetch
launch cbonsai     cbonsai     -e bash -c "$LOOP" _ cbonsai --live
