#!/usr/bin/env bash
# install-delta.sh
# Helper to install and configure git-delta (delta) automatically.
# Intended for use from dotfiles. Non-interactive friendly: pass -y to auto-apply changes.

set -euo pipefail

PROGNAME=$(basename "$0")
AUTO_CONFIRM=0
NO_CONFIG=0
SCOPE=global

usage() {
  cat <<EOF
Usage: $PROGNAME [options]

Options:
  -y, --yes         Auto-confirm and apply changes (non-interactive)
  --no-config       Install delta but do not change git config
  --local           Configure git locally (in current repo) instead of globally
  -h, --help        Show this help

Example (from dotfiles):
  $PROGNAME -y
EOF
}

# simple arg parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) AUTO_CONFIRM=1; shift ;;
    --no-config) NO_CONFIG=1; shift ;;
    --local) SCOPE=local; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 2 ;;
  esac
done

echoc() { printf "%s\n" "$*"; }

# Check if already installed
if command -v delta >/dev/null 2>&1 || command -v git-delta >/dev/null 2>&1; then
  echoc "delta (git-delta) already installed."
else
  echoc "delta not found — attempting install..."
  uname_s=$(uname -s)
  if [[ "$uname_s" == "Darwin" ]]; then
    if command -v brew >/dev/null 2>&1; then
      echoc "Installing via Homebrew..."
      brew install git-delta
    else
      echoc "Homebrew not found. Trying cargo (rust) install if available..."
      if command -v cargo >/dev/null 2>&1; then
        cargo install git-delta
      else
        echoc "No Homebrew or cargo found. Please install via Homebrew: 'brew install git-delta' or via cargo."
        exit 1
      fi
    fi
  else
    # Linux-ish fallback
    if command -v cargo >/dev/null 2>&1; then
      echoc "Installing via cargo..."
      cargo install git-delta
    elif command -v apt-get >/dev/null 2>&1; then
      echoc "Attempting apt (may not have newest delta)."
      sudo apt-get update && sudo apt-get install -y git-delta
    else
      echoc "Could not find a compatible package manager. Please install 'git-delta' manually."
      exit 1
    fi
  fi
fi

if [[ $NO_CONFIG -eq 1 ]]; then
  echoc "Installation complete. Skipping git configuration as requested (--no-config)."
  exit 0
fi

# Configure git to use delta
apply_config() {
  local scope_flag=""
  if [[ "$SCOPE" == "global" ]]; then
    scope_flag="--global"
  fi

  # backup existing config values if present
  local existing_core_pager
  existing_core_pager=$(git config $scope_flag --get core.pager || true)
  if [[ -n "$existing_core_pager" ]]; then
    # store backup in user's home so dotfiles runs won't lose previous setup
    local backup_file="$HOME/.gitconfig.delta.backup"
    echoc "Backing up previous pager ('$existing_core_pager') to $backup_file"
    printf "# backup created by install-delta.sh on %s\ncore.pager=%s\n" "$(date -u)" "$existing_core_pager" >> "$backup_file"
  fi

  echoc "Configuring git to use delta ($SCOPE)..."
  git config $scope_flag core.pager delta

  # Optional: set recommended delta preferences
  git config $scope_flag delta.syntax-theme "Monokai Extended" || true
  git config $scope_flag delta.line-numbers true || true
  git config $scope_flag delta.side-by-side false || true
  git config $scope_flag delta.navigate true || true

  echoc "Git configuration updated."
  echoc "To revert: inspect $HOME/.gitconfig.delta.backup (if created) and run 'git config --global --unset core.pager' or restore values manually."
}

if [[ $AUTO_CONFIRM -eq 0 ]]; then
  echoc "About to configure git to use delta ($SCOPE)."
  read -r -p "Proceed? [y/N]: " ans || true
  case "$ans" in
    [Yy]*) apply_config ;;
    *) echoc "Aborting config changes."; exit 0 ;;
  esac
else
  apply_config
fi

echoc "Done. You can now run 'git diff' and see delta output."
