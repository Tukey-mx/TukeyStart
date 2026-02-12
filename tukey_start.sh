#!/usr/bin/env bash
set -euo pipefail

# Colores y formato
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold); RESET=$(tput sgr0)
  RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4); CYAN=$(tput setaf 6); MAGENTA=$(tput setaf 5)
else
  BOLD=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""; MAGENTA=""
fi

info() { printf "%s[INFO]%s %s\n" "$CYAN" "$RESET" "$1"; }
run()  { printf "%s-->%s %s\n" "$BLUE" "$RESET" "$1"; }
ok()   { printf "%s[OK]%s %s\n" "$GREEN" "$RESET" "$1"; }
err()  { printf "%s[ERR]%s %s\n" "$RED" "$RESET" "$1"; }
ask()  { printf "%s?%s %s " "$MAGENTA" "$RESET" "$1"; }
abort() { err "$*"; exit 1; }

trap 'exit 1' ERR

banner() {
cat <<'EOF'
████████╗██╗   ██╗██╗  ██╗███████╗██╗   ██╗
╚══██╔══╝██║   ██║██║ ██╔╝██╔════╝╚██╗ ██╔╝
   ██║   ██║   ██║█████╔╝ █████╗   ╚████╔╝ 
   ██║   ██║   ██║██╔═██╗ ██╔══╝    ╚██╔╝  
   ██║   ╚██████╔╝██║  ██╗███████╗   ██║   
   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝   ╚═╝   
EOF
}

# Setup de tools base
setup_tools() {
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    
    # UV si no existe
    if ! command -v uv >/dev/null 2>&1; then
        run "Instalando uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
        export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    fi

    # FZF para interactuar
    if ! command -v fzf >/dev/null 2>&1; then
        run "Instalando fzf..."
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update -y >/dev/null 2>&1 && apt-get install -y fzf >/dev/null 2>&1 || true
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y fzf >/dev/null 2>&1 || true
        elif command -v brew >/dev/null 2>&1; then
            brew install fzf >/dev/null 2>&1 || true
        fi
    fi
}

clear
banner
echo "------------------------------------------------------------"
echo " CLUB DE CIENCIA DE DATOS DE ESCOM "
echo "------------------------------------------------------------"

setup_tools
ok "Sistema base listo."

# Ubicacion
echo
info "[2] Ubicacion del proyecto"
ask "Ruta actual: $(pwd). ¿Cambiar? (Escribe la ruta nueva o 'n'):"
read -r DIR_INPUT

if [[ "$DIR_INPUT" =~ ^[nN]o?$ ]]; then
    PROJECT_DIR="$(pwd)"
elif [[ -n "$DIR_INPUT" ]]; then
    mkdir -p "$DIR_INPUT" && cd "$DIR_INPUT" || abort "No se pudo crear la ruta."
    PROJECT_DIR="$(pwd)"
else
    PROJECT_DIR="$(pwd)"
fi
ok "Directorio activo: $PROJECT_DIR"

# Python
echo
info "[3] Selección de Python"
TARGET_PY=""

# Versiones sugeridas + uv list
DEFAULT_VERSIONS=$(printf "3.13\n3.12\n3.11\n3.10\n3.9")
UV_INSTALLED=$(uv python list 2>/dev/null | awk '{print $1}' | grep -E '^[0-9]' || echo "")
ALL_OPTS=$(echo -e "$UV_INSTALLED\n$DEFAULT_VERSIONS" | sort -u -r | grep -v "^$")

if command -v fzf >/dev/null 2>&1 && [[ -t 0 ]]; then
    TARGET_PY=$(echo "$ALL_OPTS" | fzf --height=20% --reverse --header="Selecciona o presiona ESC para otra versión" --prompt="Python > " || true)
fi

# Default 3.12
if [ -z "$TARGET_PY" ]; then
    ask "Escribe la versión deseada (o Enter para 3.12):"
    read -r MANUAL_PY
    TARGET_PY="${MANUAL_PY:-3.12}"
fi

ok "Seleccionado: $TARGET_PY"

if [ ! -f "pyproject.toml" ]; then
    run "Inicializando..."
    uv init --python "$TARGET_PY" --no-workspace >/dev/null 2>&1 || abort "Fallo al inicializar Python $TARGET_PY"
    ok "Proyecto creado."
else
    ok "Proyecto ya existente."
fi

# Dependencias
echo
info "[4] Librerias"
BASE_PKGS="numpy pandas matplotlib seaborn scikit-learn jupyterlab ipykernel"
PKGS=()

if command -v fzf >/dev/null 2>&1 && [[ -t 0 ]]; then
    SELECTED=$(echo "$BASE_PKGS" | tr ' ' '\n' | fzf --multi --height=40% --reverse --header="TAB para seleccionar" --prompt="Librerias > " || true)
    if [ -n "$SELECTED" ]; then
        PKGS=($SELECTED)
    fi
else
    PKGS=($BASE_PKGS)
fi

ask "Paquetes extra (Enter para omitir):"
read -r EXTRAS
if [[ -n "$EXTRAS" ]]; then
    PKGS+=($EXTRAS)
fi

if [ ${#PKGS[@]} -gt 0 ]; then
    run "Instalando: ${PKGS[*]}"
    uv add "${PKGS[@]}" >/dev/null 2>&1 || uv add "${PKGS[@]}"
    ok "Instalacion completa."
fi

# Estructura
echo
info "[5] Finalizando"
mkdir -p notebooks src data
[ ! -f "notebooks/starter.ipynb" ] && cat > notebooks/starter.ipynb <<'NB'
{
 "cells": [{"cell_type": "code", "source": ["import pandas as pd\nprint('Ready')"], "metadata": {}}],
 "metadata": {"language_info": {"name": "python"}}, "nbformat": 4, "nbformat_minor": 5
}
NB

echo "------------------------------------------------------------"
echo " ${GREEN}${BOLD}LISTO${RESET}"
echo "------------------------------------------------------------"
echo " Proyecto configurado en: $PROJECT_DIR"
echo
echo " ${BOLD}Siguientes pasos:${RESET}"
echo "  1. Entra al directorio:"
echo "     ${CYAN}cd $PROJECT_DIR${RESET}"
echo
echo "  2. Activa el entorno virtual:"
echo "     ${CYAN}source .venv/bin/activate${RESET}"
echo
echo "  3. Abre tu editor o Jupyter:"
echo "     ${CYAN}code .${RESET}  (o el editor que prefieras)"
echo "     ${CYAN}uv run jupyter lab${RESET}"
echo "------------------------------------------------------------"


# Holi c:
