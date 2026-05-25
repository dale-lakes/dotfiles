#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -euo pipefail

BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TARGET_DIR="${DOTFILES_BIN_DIR:-$HOME/.local/bin}"

mkdir -p "$TARGET_DIR"

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

link_file() {
  local src=$1 dst=$2 current_src backup_path

  current_src="$(readlink "$dst" 2>/dev/null || true)"
  if [ -L "$dst" ] && [ "$current_src" = "$src" ]; then
    printf '  [ OK ] linked %s\n' "$dst"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    backup_path="$(next_backup_path "$dst")"
    mv "$dst" "$backup_path"
    printf '  [ OK ] backed up %s to %s\n' "$dst" "$backup_path"
  fi

  ln -s "$src" "$dst"
  printf '  [ OK ] linked %s to %s\n' "$src" "$dst"
}

for src in "$BIN_DIR"/*; do
  [ -f "$src" ] || continue
  [ "$(basename "$src")" = "install.sh" ] && continue

  dst="$TARGET_DIR/$(basename "$src")"
  link_file "$src" "$dst"
done
