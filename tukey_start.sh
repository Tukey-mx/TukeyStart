#!/usr/bin/env bash
set -euo pipefail

# Configuración de saludo, dependiendo la hora

USER_NAME="${DISPLAY_NAME:-${USER:-$(whoami 2>/dev/null || echo turkey)}}"
HOUR=$(date +%H 2>/dev/null || echo 12)
if   [ "$HOUR" -lt 12 ]; then   GREET="Good morning"
elif [ "$HOUR" -lt 18 ]; then   GREET="Good afternoon"
else                            GREET="Good evening"
fi

# colores, si no soporta, entonces plain text

supports_color=false
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  if [[ $(tput colors) -ge 8 ]]; then supports_color=true; fi
fi

if $supports_color; then
  BOLD=$(tput bold); RESET=$(tput sgr0)
  RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4); MAGENTA=$(tput setaf 5); CYAN=$(tput setaf 6)
else
  BOLD=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""
fi

CHECK="[OK]"; CROSS="[ERR]"; WARN="[WARN]"; INFO="[INFO]"; STEP="-->"

info() { printf "%s%s%s %s\n" "$CYAN" "$INFO" "$RESET" "$1"; }
run()  { printf "%s%s%s %s\n" "$BLUE" "$STEP" "$RESET" "$1"; }
ok()   { printf "%s%s%s %s\n" "$GREEN" "$CHECK" "$RESET" "$1"; }
warn() { printf "%s%s%s %s\n" "$YELLOW" "$WARN" "$RESET" "$1"; }
err()  { printf "%s%s%s %s\n" "$RED" "$CROSS" "$RESET" "$1"; }
ask()  { printf "%s?%s %s " "$MAGENTA" "$RESET" "$1"; }

trap 'err "An error occurred at line $LINENO. Aborting."; exit 1' ERR

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

abort() { err "$*"; exit 1; }

clear
banner
echo "============================================================"
echo " T U K E Y   E N V I R O N M E N T   S E T U P"
echo "============================================================"
echo
echo "${GREET}, ${USER_NAME}!  ($(date '+%A, %B %d, %Y'))"
echo
echo "Welcome to TukeyStart — the unified environment bootstrapper created by"
echo "the ESCOM Data Science Club. This utility prepares a full Python"
echo "workspace for analytics, machine learning, and educational projects."
echo
echo "It automatically configures dependencies, installs essential tools,"
echo "and generates a ready-to-use project layout"
echo
echo "Tasks performed:"
echo "  1. Detects your operating system (macOS / Linux / WSL2)"
echo "  2. Installs Homebrew (or updates it if already present)"
echo "  3. Sets up pyenv and fzf for version and package selection"
echo "  4. Lets you interactively choose a Python version"
echo "  5. Creates a local virtual environment (.venv)"
echo "  6. Installs data-science-ready Python libraries"
echo "  7. Builds a clean project structure with sample datasets"
echo
echo "Once completed, you’ll have an isolated Python workspace ready for"
echo "data analysis, experiments, and reproducible workflows."
echo
echo "============================================================"


# =============================================================================
# trata de encontrar brew en el path para ejecutar los comandos después
# =============================================================================
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# archivo que sirve como flag para saber si el one-time setup ya se hizo o no
MARKER="$HOME/.tukey_ready"

# =============================================================================
# System detection
# =============================================================================
echo
echo "============================================================"
echo " [1] System detection"
echo "============================================================"

case "$(uname -s)" in
  Darwin|Linux) ok "Detected supported OS." ;;
  *) abort "Only macOS or Linux are supported." ;;
esac

is_wsl=false

# Si es wsl, lo detecta aquí, además comprueba que sea wsl 2
# solo se busca palabra microsoft en los files del sistema
if grep -qi microsoft /proc/version 2>/dev/null; then
  is_wsl=true
  if grep -q "Microsoft" /proc/sys/kernel/osrelease && ! grep -q "microsoft-standard-WSL2" /proc/sys/kernel/osrelease; then
    warn "WSL 1 detected. Please upgrade to WSL 2 using: wsl --set-version <distro> 2"
    exit 1
  fi
fi

# =============================================================================
# One-time base setup
# =============================================================================
# esta parte instala lo necesario a nivel del sistema según el SO.
# pyenv compila intérpretes de Python desde código fuente, así que requiere
# toolchain (gcc/make) y headers/bibliotecas de C para enlazar correctamente.
# Por eso instalamos dependencias globales (openssl, zlib, readline, sqlite,
# xz, bzip2, tk/tcl, ffi, lzma, etc.) antes de usar pyenv.

echo
echo "============================================================"
echo " [2] One-time base setup"
echo "============================================================"

# Detecta si existe el archivo de flag que nos dice que ya se hizo alguna vez el setup
if [ ! -f "$MARKER" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    run "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1 || abort "Homebrew installation failed."
    ok "Homebrew installed."
  else
    ok "Homebrew already installed."
  fi

  run "Installing compiler toolchain..."
  if $is_wsl; then
    sudo apt update -y >/dev/null 2>&1
    sudo apt install -y build-essential git curl file pkg-config \
      libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
      xz-utils tk-dev tcl-dev libffi-dev liblzma-dev >/dev/null 2>&1
  elif [ "$(uname -s)" = "Linux" ]; then
    brew install gcc make pkg-config openssl readline zlib xz bzip2 sqlite >/dev/null 2>&1 || true
  elif [ "$(uname -s)" = "Darwin" ]; then
    xcode-select -p >/dev/null 2>&1 || xcode-select --install
  fi
  ok "Toolchain installed."

  run "Installing pyenv and fzf..."
  brew install pyenv fzf >/dev/null 2>&1 || true
  ok "Base environment ready."
  touch "$MARKER"
else
  info "Base setup previously completed. Skipping."
fi

# =============================================================================
# Project directory
# =============================================================================
echo
echo "============================================================"
echo " [3] Project directory"
echo "============================================================"

ask "Current path: $(pwd). Change? (y/N)"
read -r CHANGE_DIR
if [[ "${CHANGE_DIR:-N}" =~ ^[Yy]$ ]]; then
  ask "Enter new path:"
  read -r NEW_PATH
  cd "$NEW_PATH" || abort "Invalid path."
fi
PROJECT_DIR="$(pwd)"
ok "Project path: $PROJECT_DIR"

eval "$(pyenv init -)"

# =============================================================================
# Python setup (interactive)
# =============================================================================
echo
echo "============================================================"
echo " [4] Python setup"
echo "============================================================"

info "Installed Python versions (pyenv):"
pyenv versions --bare 2>/dev/null || info "(none yet)"
echo

LATEST_3="$(pyenv install -l | sed 's/^[[:space:]]*//' | grep -E '^3\.[0-9]+\.[0-9]+$' | tail -1 || true)"
TARGET_PY=""

if command -v fzf >/dev/null 2>&1 && [[ -t 0 ]]; then
  tmpfile="$(mktemp)"
  {
    pyenv versions --bare 2>/dev/null
    echo "[Install new with pyenv (enter 3.x.y)]"
  } | sed '/^$/d' > "$tmpfile"

  sel="$(fzf --ansi --height=60% --reverse \
        --prompt='Select Python version > ' \
        --bind 'space:accept' \
        < "$tmpfile" || true)"
  rm -f "$tmpfile"

  if [[ -z "${sel}" ]]; then
    TARGET_PY="$LATEST_3"
  elif [[ "$sel" == "[Install new with pyenv (enter 3.x.y)]" ]]; then
    ask "Enter exact version (e.g., 3.12.6):"
    read -r CUSTOM_PY
    [[ "$CUSTOM_PY" =~ ^3\.[0-9]+\.[0-9]+$ ]] && TARGET_PY="$CUSTOM_PY" || abort "Invalid version format."
  else
    TARGET_PY="$sel"
  fi
else
  TARGET_PY="$LATEST_3"
fi

TARGET_PY="$(echo "$TARGET_PY" | tr -d '\r' | xargs)"
[[ -z "$TARGET_PY" || "$TARGET_PY" == "system" ]] && TARGET_PY="$LATEST_3"

run "Installing Python $TARGET_PY... this might take several minutes"

pyenv install -s "$TARGET_PY" >/dev/null 2>&1 || abort "Python installation failed."

# Pyenv local set, se cambia por la global en esta parte
pyenv local "$TARGET_PY"

PY_BIN="$(pyenv which python)"
ok "Python ready: $("$PY_BIN" -V 2>/dev/null)"


# =============================================================================
# Virtual environment
# =============================================================================
# pequeño bug, el comando de source no funciona si ya existe un .venv en el directorio
echo
echo "============================================================"
echo " [5] Virtual environment"
echo "============================================================"

if [ -d ".venv" ]; then
  info "Virtual environment already exists."
else
  run "Creating virtual environment..."
  "$PY_BIN" -m venv .venv >/dev/null 2>&1 || abort "venv creation failed."
  ok "Virtual environment created."
fi
source .venv/bin/activate
ok "Virtual environment activated."


# =============================================================================
# Package installation
# =============================================================================
echo
echo "============================================================"
echo " [6] Package installation"
echo "============================================================"

# Solo se checa numpy, casi todos desprenden de ahí
if python -m pip show numpy >/dev/null 2>&1; then
  info "Base packages already installed."
else
  DEFAULT_PKGS=(numpy pandas matplotlib seaborn scikit-learn jupyterlab ipykernel)
  PKGS=("${DEFAULT_PKGS[@]}")

  if command -v fzf >/dev/null 2>&1 && [[ -t 0 ]]; then
    echo
    info "Select base packages (TAB to toggle, ENTER to confirm):"
    SELECTED=$(printf '%s\n' "${DEFAULT_PKGS[@]}" | \
      fzf --multi --height=60% --reverse \
      --prompt="Packages > " --bind 'tab:toggle+down' --exit-0)
    if [ -n "$SELECTED" ]; then
      IFS=$'\n' PKGS=($(echo "$SELECTED"))
    fi
  fi

  ask "Add other packages (space-separated, ENTER to skip):"
  read -r CUSTOM_PKGS || true

  if [[ -n "${CUSTOM_PKGS// }" ]]; then
    # convierte a array por palabras
    read -r -a EXTRAS <<< "$CUSTOM_PKGS"
    PKGS+=("${EXTRAS[@]}")
  fi

  echo
  info "Installing selected packages..."
  echo "→ ${PKGS[*]}"

  # Actualizando pip
  python -m pip install -q -U pip >/dev/null 2>&1 || true

  if ! python -m pip install -q "${PKGS[@]}" >/dev/null 2>&1; then
    err "Package installation failed"
    echo
    python -m pip install "${PKGS[@]}" || abort "Package installation failed."
  else
    ok "Packages installed."
  fi
fi

# =============================================================================
# Project structure
# =============================================================================
echo
echo "============================================================"
echo " [7] Project structure"
echo "============================================================"

run "Creating folders and starter notebook..."
mkdir -p notebooks src data
touch data/.gitkeep

cat > notebooks/starter.ipynb <<'NB'
{
 "cells": [
  {"cell_type": "markdown", "metadata": {}, "source": ["# Tukey Starter Notebook"]},
  {"cell_type": "code", "metadata": {}, "source": [
    "import pandas as pd\n",
    "import numpy as np\n",
    "data_path = './data/example.csv'\n",
    "try:\n",
    "    df = pd.read_csv(data_path)\n",
    "    display(df.head())\n",
    "except FileNotFoundError:\n",
    "    print('CSV not found at', data_path)\n"
  ]}
 ],
 "metadata": {"language_info": {"name": "python"}},
 "nbformat": 4, "nbformat_minor": 5
}
NB
ok "Project structure created."

# =============================================================================
# Sample datasets
# =============================================================================
echo
echo "============================================================"
echo " [8] Sample datasets"
echo "============================================================"

ask "Download sample datasets (Iris, Titanic, Wine)? (y/N)"
read -r DOWNLOAD
if [[ "${DOWNLOAD:-N}" =~ ^[Yy]$ ]]; then
  mkdir -p data
  run "Downloading datasets..."
  curl -fsSL -o data/iris.csv https://raw.githubusercontent.com/mwaskom/seaborn-data/master/iris.csv >/dev/null 2>&1 && ok "Iris dataset ready."
  curl -fsSL -o data/titanic.csv https://raw.githubusercontent.com/mwaskom/seaborn-data/master/titanic.csv >/dev/null 2>&1 && ok "Titanic dataset ready."
  curl -fsSL -o data/winequality-red.csv https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-red.csv >/dev/null 2>&1 && ok "Wine Quality dataset ready."
else
  info "Dataset download skipped."
fi

# =============================================================================
# Final summary
# =============================================================================
echo
echo "============================================================"
echo " Setup completed successfully."
echo "============================================================"
echo
echo "Project directory:"
echo "   ${PROJECT_DIR}"
echo
echo "To activate your environment:"
echo "   source ${PROJECT_DIR}/.venv/bin/activate"
echo
echo "To launch Jupyter or VS Code:"
echo "   jupyter lab"
echo "   code ."
echo
echo "Bye!"
echo "============================================================"
