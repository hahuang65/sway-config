#/bin/sh

if [ $(uname) = "Linux" ]; then
  mkdir -p "${HOME}/.config/sway"
  ln -sf "${PWD}/config" "${HOME}/.config/sway/"
fi
