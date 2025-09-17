#!/usr/bin/env bash

INPUT="$(grep -m1 '^wallpaper =' ~/.local/state/waypaper/state.ini | cut -d= -f2- | xargs)"

run_hellwal() {
  hellwal -i "$INPUT" -b "$BRIGHTNESS" -n "$DARKNESS" $([ "$NEON" -eq 1 ] && echo -m)
}

defaults() {
  BRIGHTNESS=0.5 DARKNESS=0.5 NEON=1
  run_hellwal
}

menu() {
  printf "Toggle Neon [%s]\nBrightness [%d%%]\nDarkness [%d%%]\nReset Defaults\nExit\n" \
    "$([ $NEON -eq 1 ] && echo ON || echo OFF)" \
    "$(awk -v v="$BRIGHTNESS" 'BEGIN{printf "%d", v*100}')" \
    "$(awk -v v="$DARKNESS" 'BEGIN{printf "%d", v*100}')" |
    rofi -dmenu -i -p "Adjust > "
}

value_menu() {
  seq 0 10 100 | sed 's/$/%/' | rofi -dmenu -i -p "$1"
}

parse_percent() {
  awk -v v="${1%%%}" 'BEGIN{printf "%.2f", v/100}'
}

defaults
while true; do
  choice=$(menu) || exit 0
  [ -z "$choice" ] && exit 0

  case "$choice" in
  "Reset Defaults") defaults ;;
  Toggle*)
    NEON=$((1 - NEON))
    run_hellwal
    ;;
  Brightness*)
    new=$(value_menu Brightness)
    if [ -n "$new" ]; then
      BRIGHTNESS=$(parse_percent "$new")
      run_hellwal
    fi
    ;;
  Darkness*)
    new=$(value_menu Darkness)
    if [ -n "$new" ]; then
      DARKNESS=$(parse_percent "$new")
      run_hellwal
    fi
    ;;
  Exit) exit 0 ;;
  esac
done
