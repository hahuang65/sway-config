#!/bin/sh

if [ $(uname) = "Linux" ]; then
  mkdir -p "${HOME}/.config/sway"
  mkdir -p "${HOME}/.config/environment.d"
  mkdir -p "${HOME}/.config/systemd/user"
  ln -sf "${PWD}/config" "${HOME}/.config/sway/"
  ln -sf "${PWD}/wlroots.conf" "${HOME}/.config/environment.d/"
  ln -sf "${PWD}/sway-session.target" "${HOME}/.config/systemd/user/sway-session.target"
  sudo ln -sf "${PWD}/10-systemd" "/etc/sway/config.d/10-systemd"
fi
