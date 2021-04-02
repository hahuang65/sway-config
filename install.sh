#!/bin/sh

if [ $(uname) = "Linux" ]; then
  mkdir -p "${HOME}/.config/sway"
  mkdir -p "${HOME}/.config/environment.d"
  ln -sf "${PWD}/config" "${HOME}/.config/sway/"
  ln -sf "${PWD}/wlroots.conf" "${HOME}/.config/environment.d/"
fi
