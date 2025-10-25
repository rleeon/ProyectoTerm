#!/bin/bash
#   ______   __  __  __ ____      ___           _     _           
#  | __ ) \ / / |  \/  |  _ \    |_ _|_ __  ___(_) __| | ___ _ __ 
#  |  _ \\ V /  | |\/| | |_) |    | || '_ \/ __| |/ _` |/ _ \ '__|
#  | |_) || |   | |  | |  _ < _   | || | | \__ \ | (_| |  __/ |   
#  |____/ |_|   |_|  |_|_| \_(_) |___|_| |_|___/_|\__,_|\___|_|   
                                                               
TERMINAL="xterm"

NEO="neofetch --ascii_distro"

DISTROS=("arch" "debian" "fedora" "gentoo" "ubuntu" "manjaro" "opensuse" "void" "alpine" "pop_os" "elementary" "kali" "parrot" "slackware" "nixos")

SCREEN_WIDTH=1920 # Estos cuatro parametros estan para simplemente modificar el tamaño de las ventanas que saltan.
SCREEN_HEIGHT=1080 # -  
WINDOW_WIDTH=600 # --
WINDOW_HEIGHT=400 # ---
DELAY=1  # segundos entre movimientos Modificalo al gusto

MAX_X=$((SCREEN_WIDTH - WINDOW_WIDTH))
MAX_Y=$((SCREEN_HEIGHT - WINDOW_HEIGHT))

random_position() {
  echo "$((RANDOM % MAX_X)) $((RANDOM % MAX_Y))"
}

declare -a WIN_IDS=()

for distro in "${DISTROS[@]}"; do
  $TERMINAL -T "$distro" -geometry 80x24 -e bash -c "$NEO $distro --colors 7 7 7 7 7 7; exec bash" &
  sleep 0.3

  for i in {1..10}; do
    WIN_ID=$(xdotool search --name "$distro" | tail -1)
    if [ -n "$WIN_ID" ]; then
      WIN_IDS+=("$WIN_ID")
      read X Y <<< "$(random_position)"
      xdotool windowmove "$WIN_ID" "$X" "$Y"
      break
    fi
    sleep 0.2
  done
done

while true; do
  sleep "$DELAY"
  for WIN_ID in "${WIN_IDS[@]}"; do
    read X Y <<< "$(random_position)"
    xdotool windowmove "$WIN_ID" "$X" "$Y"
  done
done
