#!/usr/bin/env bash
# TeaVim installer
# Usage:
#   ./install.sh           — fresh install (backs up existing config)
#   ./install.sh --force   — overwrite without backup prompt
#
# Also called internally by remote-install.sh after cloning the repo.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
BACKUP_DIR="$HOME/.config/nvim.bak.$(date +%Y%m%d_%H%M%S)"

FORCE=false
for arg in "$@"; do
  [[ "$arg" == "--force" ]] && FORCE=true
done

echo ""
echo "  ☕  TeaVim Installer"
echo "  ──────────────────────────────────────"
echo ""

# ── Dependency check ──────────────────────────────────────────────────────────
check_dep() {
  if ! command -v "$1" &>/dev/null; then
    echo "  ✗  '$1' not found. Please install it and re-run."
    exit 1
  fi
  echo "  ✓  $1"
}

echo "  Checking dependencies…"
check_dep nvim
check_dep git
check_dep node   # for many LSP servers
check_dep npm
check_dep python3

NVIM_VERSION=$(nvim --version | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
REQUIRED="0.10.0"
if ! printf '%s\n%s\n' "$REQUIRED" "$NVIM_VERSION" | sort -V -C; then
  echo ""
  echo "  ✗  Neovim $REQUIRED+ is required (found $NVIM_VERSION)."
  exit 1
fi
echo "  ✓  Neovim $NVIM_VERSION"

# ── Backup existing config ────────────────────────────────────────────────────
echo ""
if [[ -d "$CONFIG_DIR" ]]; then
  if [[ "$FORCE" == false ]]; then
    read -r -p "  Existing Neovim config found. Back it up? [Y/n] " answer
    answer="${answer:-Y}"
    if [[ "$answer" =~ ^[Yy] ]]; then
      mv "$CONFIG_DIR" "$BACKUP_DIR"
      echo "  Backed up to: $BACKUP_DIR"
    else
      echo "  Overwriting existing config…"
      rm -rf "$CONFIG_DIR"
    fi
  else
    mv "$CONFIG_DIR" "$BACKUP_DIR"
    echo "  Backed up to: $BACKUP_DIR"
  fi
fi

# ── Symlink or copy ───────────────────────────────────────────────────────────
echo ""
# If the repo lives in the dedicated remote-install location, always symlink
# so that future `git pull` in that directory updates the config automatically.
REMOTE_INSTALL_DIR="${TEAVIM_DIR:-$HOME/.local/share/teavim}"
if [[ "$REPO_DIR" == "$REMOTE_INSTALL_DIR" ]]; then
  ln -s "$REPO_DIR" "$CONFIG_DIR"
  echo "  Symlinked: $CONFIG_DIR → $REPO_DIR"
  echo "  (Updates via:  git -C $REPO_DIR pull)"
else
  read -r -p "  Symlink config (recommended) or copy? [S/c] " link_answer
  link_answer="${link_answer:-S}"

  if [[ "$link_answer" =~ ^[Cc] ]]; then
    cp -r "$REPO_DIR" "$CONFIG_DIR"
    echo "  Copied to $CONFIG_DIR"
  else
    ln -s "$REPO_DIR" "$CONFIG_DIR"
    echo "  Symlinked: $CONFIG_DIR → $REPO_DIR"
  fi
fi

# ── Profile selection ─────────────────────────────────────────────────────────
echo ""
echo "  Choose your editing profile:"
echo "    1) vscode       — Vim modes + VSCode shortcuts layered on top (default)"
echo "    2) vscode_pure  — Modal-less, feels like a normal text editor"
echo "    3) vim          — Pure Vim motions, no VSCode shortcuts"
echo ""
read -r -p "  Profile [1]: " profile_choice
profile_choice="${profile_choice:-1}"

case "$profile_choice" in
  2) PROFILE="vscode_pure" ;;
  3) PROFILE="vim" ;;
  *)  PROFILE="vscode" ;;
esac

# Patch user/config.lua with the selected profile
USER_CONFIG="$CONFIG_DIR/lua/user/config.lua"
sed -i "s/-- profile = \"vscode\",/profile = \"$PROFILE\",/" "$USER_CONFIG"
echo "  Profile set to: $PROFILE"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "  ──────────────────────────────────────"
echo "  ✓  TeaVim installed!"
echo ""
echo "  Open Neovim — lazy.nvim will install all plugins on first launch."
echo "  The onboarding walkthrough will start automatically."
echo ""
echo "  To change your profile or features later:"
echo "    edit  ~/.config/nvim/user/config.lua"
echo ""
echo "  To re-run this walkthrough inside Neovim:"
echo "    press  <Space>?"
echo ""
