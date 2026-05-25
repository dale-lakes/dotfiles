#!/usr/bin/env bash

set -e

BIN_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TARGET_DIR="$HOME/.local/bin"

mkdir -p "$TARGET_DIR"

for src in "$BIN_DIR"/*; do
  [ -f "$src" ] || continue
  [ "$(basename "$src")" = "install.sh" ] && continue

  dst="$TARGET_DIR/$(basename "$src")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    printf '  [ OK ] linked %s\n' "$dst"
    continue
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.backup"
    printf '  [ OK ] backed up %s to %s.backup\n' "$dst" "$dst"
  fi

  ln -s "$src" "$dst"
  printf '  [ OK ] linked %s to %s\n' "$src" "$dst"
done
