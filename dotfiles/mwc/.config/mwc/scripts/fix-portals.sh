#!/usr/bin/env bash

sleep 1
dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=mwc

packages=(xdg-desktop-portal-wlr xdg-desktop-portal-gtk xdg-desktop-portal)
killall -q "${packages[@]}"

sleep 1
paths=($(guix build "${packages[@]}"))

for i in "${!paths[@]}"; do
  "${paths[i]}/libexec/${packages[i]}" &
  sleep 1
done
