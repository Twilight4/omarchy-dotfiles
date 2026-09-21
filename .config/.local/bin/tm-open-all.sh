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

# Any-key refresh loop — space/enter re-runs the tool fresh (e.g. after a
# resize), q closes the window. Other stdin bytes (kitty's replies to the
# tool's terminal queries) are swallowed. The tool runs with an empty FIFO
# as stdin: rain/pipes pace their animation with `read -t <timeout>`, and
# any byte arriving on the shared pty made those reads return early, which
# sped the animation up several-fold. The FIFO guarantees full timeouts.
LOOP='D=""; trap "rm -f \$D" EXIT HUP TERM; while true; do clear; D=$(mktemp -u /tmp/toy.XXXXXX); mkfifo "$D"; exec 9<>"$D"; "$@" <"$D" & p=$!; while :; do IFS= read -rsn1 k || exit; if [[ $k == q ]]; then kill $p 2>/dev/null; wait $p 2>/dev/null; rm -f "$D"; exit; fi; [[ $k == " " || -z $k ]] && break; done; kill $p 2>/dev/null; wait $p 2>/dev/null; rm -f "$D"; done'

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
