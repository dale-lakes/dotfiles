#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -euo pipefail

KITTY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
SOURCE_DIR="$KITTY_DIR/kitty"
TARGET_DIR="$CONFIG_HOME/kitty"

mkdir -p "$CONFIG_HOME"

next_backup_path() {
  local dst=$1 backup counter

  backup="${dst}.backup"
  counter=1
  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="${dst}.backup.${counter}"
    counter=$((counter + 1))
  done

  printf '%s' "$backup"
}

current_src="$(readlink "$TARGET_DIR" 2>/dev/null || true)"
if [ -L "$TARGET_DIR" ] && [ "$current_src" = "$SOURCE_DIR" ]; then
  printf '  [ OK ] linked %s\n' "$TARGET_DIR"
  exit 0
fi

if [ -e "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
  backup_path="$(next_backup_path "$TARGET_DIR")"
  mv "$TARGET_DIR" "$backup_path"
  printf '  [ OK ] backed up %s to %s\n' "$TARGET_DIR" "$backup_path"
fi

ln -s "$SOURCE_DIR" "$TARGET_DIR"
printf '  [ OK ] linked %s to %s\n' "$SOURCE_DIR" "$TARGET_DIR"
