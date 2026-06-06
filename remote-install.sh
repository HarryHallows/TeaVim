#!/usr/bin/env bash
# TeaVim remote installer — designed to be piped from curl:
#   curl -fsSL https://raw.githubusercontent.com/HarryHallows/TeaVim/main/remote-install.sh | bash
#
# It clones the repo to ~/.local/share/teavim, then delegates to install.sh.

set -euo pipefail

REPO_URL="https://github.com/HarryHallows/TeaVim.git"
INSTALL_DIR="${TEAVIM_DIR:-$HOME/.local/share/teavim}"

echo ""
echo "  ☕  TeaVim — Remote Installer"
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
check_dep curl

NVIM_VERSION=$(nvim --version | head -n1 | grep -oP '\d+\.\d+\.\d+' | head -n1)
REQUIRED="0.10.0"
if ! printf '%s\n%s\n' "$REQUIRED" "$NVIM_VERSION" | sort -V -C; then
  echo ""
  echo "  ✗  Neovim $REQUIRED+ is required (found $NVIM_VERSION)."
  exit 1
fi
echo "  ✓  Neovim $NVIM_VERSION"

# ── Clone or update repo ──────────────────────────────────────────────────────
echo ""
if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "  Updating existing TeaVim repo at $INSTALL_DIR…"
  git -C "$INSTALL_DIR" pull --ff-only
else
  echo "  Cloning TeaVim into $INSTALL_DIR…"
  git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
fi

# ── Delegate to the local install script ─────────────────────────────────────
# Re-attach stdin to /dev/tty so install.sh can prompt interactively even
# when this script is piped from curl (which replaces stdin with the pipe).
echo ""
if [[ -t 0 ]]; then
  bash "$INSTALL_DIR/install.sh" "$@"
else
  bash "$INSTALL_DIR/install.sh" "$@" </dev/tty
fi
