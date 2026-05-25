#!/usr/bin/env bash
#
# bootstrap installs things.

if [ -z "${BASH_VERSION:-}" ]; then
  exec bash "$0" "$@"
fi

set -euo pipefail

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo ''

info() {
  printf '\r  [ \033[00;34m..\033[0m ] %b\n' "$1"
}

user() {
  printf '\r  [ \033[0;33m??\033[0m ] %b\n' "$1"
}

success() {
  printf '\r\033[2K  [ \033[00;32mOK\033[0m ] %b\n' "$1"
}

fail() {
  printf '\r\033[2K  [\033[0;31mFAIL\033[0m] %b\n' "$1"
  echo ''
  exit 1
}

setup_gitconfig() {
  local git_config git_template git_credential
  local git_authorname git_authoremail git_authorhandle gpg_signing_key

  git_config="$DOTFILES_ROOT/git/gitconfig.symlink"
  git_template="$DOTFILES_ROOT/git/gitconfig.symlink.example"

  if [ -f "$git_config" ] || [ ! -f "$git_template" ]; then
    return
  fi

  info 'setup gitconfig'

  git_credential='cache'
  if [ "$(uname -s)" = "Darwin" ]; then
    git_credential='osxkeychain'
  fi

  user ' - What is your github author name?'
  read -r -e git_authorname
  user ' - What is your github author email?'
  read -r -e git_authoremail
  user ' - What is your github username?'
  read -r -e git_authorhandle
  user ' - What is your GPG signing key? (Run `gpg --list-keys`)'
  read -r -e gpg_signing_key

  sed -e "s/AUTHOR_NAME/$git_authorname/g" -e "s/AUTHOR_EMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" -e "s/AUTHOR_HANDLE/$git_authorhandle/g" -e "s/GPG_SIGNING_KEY/$gpg_signing_key/g" "$git_template" >"$git_config"

  success 'gitconfig'
}

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
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -e "$dst" ] || [ -L "$dst" ]; then

    if [ "${overwrite_all:-false}" = "false" ] && [ "${backup_all:-false}" = "false" ] && [ "${skip_all:-false}" = "false" ]; then

      local currentSrc
      currentSrc="$(readlink "$dst" 2>/dev/null || true)"

      if [ "$currentSrc" = "$src" ]; then

        skip=true

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
        o)
          overwrite=true
          ;;
        O)
          overwrite_all=true
          ;;
        b)
          backup=true
          ;;
        B)
          backup_all=true
          ;;
        s)
          skip=true
          ;;
        S)
          skip_all=true
          ;;
        *)
          skip=true
          ;;

        esac

      fi

    fi

    overwrite=${overwrite:-${overwrite_all:-false}}
    backup=${backup:-${backup_all:-false}}
    skip=${skip:-${skip_all:-false}}

    if [ "$overwrite" = "true" ]; then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" = "true" ]; then
      local backup_path
      backup_path="$(next_backup_path "$dst")"
      mv "$dst" "$backup_path"
      success "moved $dst to $backup_path"
    fi

    if [ "$skip" = "true" ]; then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]; then # "false" or empty
    ln -s "$src" "$dst"
    success "linked $src to $dst"
  fi
}

install_dotfiles() {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false
  local src dst

  for src in "$DOTFILES_ROOT"/*/*.symlink; do
    [ -e "$src" ] || continue
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}

run_installers() {
  local installer installer_name

  for installer in "$DOTFILES_ROOT"/*/install.sh; do
    [ -f "$installer" ] || continue
    installer_name="$(basename "$(dirname "$installer")")"
    info "running $installer_name/install.sh"
    bash "$installer"
  done
}

# setup_gitconfig
install_dotfiles
run_installers

echo ''
echo '  All installed!'
