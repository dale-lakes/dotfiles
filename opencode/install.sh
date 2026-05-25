#!/usr/bin/env bash

set -e

OPENCODE_DIR="$(cd "$(dirname "$0")" && pwd -P)"
TARGET_DIR="$HOME/.config/opencode/plugins"

mkdir -p "$TARGET_DIR"

for src in "$OPENCODE_DIR"/plugins/*; do
  [ -f "$src" ] || continue

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
