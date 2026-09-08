#!/bin/sh

remove_legacy_script_link() {
  script_name=$1
  script_link="${HOME}/.scripts/${script_name}"
  legacy_target="${LEGACY_SCRIPT_DIR}/${script_name}"

  if [ -L "$script_link" ] && [ "$(readlink "$script_link")" = "$legacy_target" ]; then
    rm -- "$script_link"
  fi
}

link_dock_script() {
  dock_link="${HOME}/.scripts/dock"

  if [ ! -e "$dock_link" ] && [ ! -L "$dock_link" ]; then
    ln -s "${PWD}/scripts/dock" "$dock_link"
  fi
}

if [ "$(uname)" = "Linux" ]; then
  mkdir -p "${HOME}/.config/sway"
  mkdir -p "${HOME}/.config/environment.d"
  mkdir -p "${HOME}/.config/systemd/user"
  mkdir -p "${HOME}/.scripts"
  ln -sf "${PWD}/config" "${HOME}/.config/sway/"
  ln -sfn "${PWD}/scripts" "${HOME}/.config/sway/scripts"
  ln -sf "${PWD}/wlroots.conf" "${HOME}/.config/environment.d/"
  ln -sf "${PWD}/sway-session.target" "${HOME}/.config/systemd/user/sway-session.target"

  if [ -d "${PWD}/../scripts/linux" ]; then
    LEGACY_SCRIPT_DIR=$(CDPATH= cd -- "${PWD}/../scripts/linux" && pwd)
    for script_name in scratchpad notepad docs dock; do
      remove_legacy_script_link "$script_name"
    done
  fi

  link_dock_script
  sudo ln -sf "${PWD}/10-systemd" "/etc/sway/config.d/10-systemd"
fi
