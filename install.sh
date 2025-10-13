#!/usr/bin/env bash
set -euo pipefail

INSTALL_PATH="/usr/local/bin/tukey_start"
REPO_URL="https://raw.githubusercontent.com/Tukey-mx/TukeyStart/main/tukey_start.sh"

echo "🦃 Installing TukeyStart..."

tmp="$(mktemp)"
# descarga con verificación simple
if ! curl -fsSL "$REPO_URL" -o "$tmp"; then
  echo "Download failed. Check URL or repo visibility." >&2
  exit 1
fi

sudo mkdir -p "$(dirname "$INSTALL_PATH")"
sudo mv "$tmp" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# sanity check
if ! command -v tukey_start >/dev/null 2>&1; then
  echo "WARNING:  'tukey_start' not on PATH. Add /usr/local/bin to PATH." >&2
  echo "   PATH: $PATH"
  exit 1
fi

echo "Installed successfully! Run 'tukey_start' to begin."
