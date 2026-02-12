#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/Tukey-mx/TukeyStart/main/tukey_start.sh"
BIN_NAME="tukey"

# Es root o no
# Si el UID es 0, es root -> /usr/local/bin sin sudo
if [ "$(id -u)" -eq 0 ]; then
    DEST_DIR="/usr/local/bin"
    SUDO_CMD=""
# si no root, pero sudo
elif command -v sudo >/dev/null 2>&1; then
    DEST_DIR="/usr/local/bin"
    SUDO_CMD="sudo"
# si no root y no sudo
else
    DEST_DIR="$HOME/.local/bin"
    SUDO_CMD=""
    mkdir -p "$DEST_DIR"
fi

TARGET_PATH="$DEST_DIR/$BIN_NAME"

echo "🦃 Instalando TukeyStart..."

TMP_FILE="$(mktemp)"
if ! curl -fsSL "$REPO_URL" -o "$TMP_FILE"; then
    echo "Error: Falló la descarga." >&2
    rm "$TMP_FILE"
    exit 1
fi

${SUDO_CMD} mv "$TMP_FILE" "$TARGET_PATH"
${SUDO_CMD} chmod +x "$TARGET_PATH"

echo "Instalado en: $TARGET_PATH"

if ! command -v "$BIN_NAME" >/dev/null 2>&1; then
    echo
    echo "'$DEST_DIR' no está en tu PATH."
    echo "   Para usarlo, agrega esto a tu .bashrc/.zshrc:"
    echo "     export PATH=\"$DEST_DIR:\$PATH\""
else
    echo "Ejecuta el comando '$BIN_NAME' para empezar."
fi
