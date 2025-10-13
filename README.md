# TukeyStart
> Automates your Python data environment setup - from dependencies to notebooks - in one command

![Tukey Start Screen](images/start_screen.png)

**TukeyStart** is a simple command-line tool that helps you spin up a complete **Data Science environment** on macOS, Linux, or WSL — instantly.

It’s made for people who want to **start coding without worrying about setup**.

---

## Table of Contents

0. [Why TukeyStart](#why-tukeystart)
1. [Overview](#overview)  
2. [Features](#features)  
3. [Installation](#installation)  
4. [WSL Setup (Windows Users)](#wsl-setup-windows-users)  
5. [Usage](#usage)  
6. [How It Works](#how-it-works)  
7. [Requirements](#requirements)  
8. [Update](#update)
9. [Contributions](#contributing)
10. [FAQ](#faq)
11. [Credits](#credits)  
12. [License](#license)


---
## Why TukeyStart?

TukeyStart was born as a practical solution after noticing that many members of the ESCOM Data Science Club struggled with setting up their Python environments.
During workshops and collaborative projects, configuration issues often took more time than the actual data analysis.

The goal of TukeyStart is to remove that friction — to provide a clean, reproducible setup that works across macOS, Linux, and WSL, so users can focus on learning, experimenting, and building.


---

## Overview

TukeyStart is a lightweight automation script that simplifies the creation of Python environments for data analysis and machine learning.
It handles everything from installing dependencies and managing Python versions to creating a virtual environment and preloading essential libraries.

The goal is to let you begin coding immediately with a consistent, reproducible setup across systems.

---

## Features

- Works on macOS, Linux, and WSL 2
- Interactive Python version selector via pyenv and fzf
- Creates a .venv virtual environment
- Optional package selection during setup
- Automatically sets up a clean project folder structure
- Generates a starter Jupyter notebook ready to run
- Installs all required build tools and dependencies automatically

---

## Installation

If you're using WSL, check first [WSL installation](#wsl-setup-windows-users)

Run the installer directly:

```bash
curl -fsSL https://raw.githubusercontent.com/Tukey-mx/TukeyStart/main/install.sh | bash
```

Once installed, you can run it from anywhere:

```bash
tukey_start
```

To uninstall:

```bash
sudo rm -f /usr/local/bin/tukey_start /opt/homebrew/bin/tukey_start "$HOME/.tukey_ready"
```

---

## WSL Setup (Windows Users)

If you are using Windows, TukeyStart runs best inside Windows Subsystem for Linux (WSL 2).
Below is a brief setup guide.

### 1. Enable WSL (Windows Subsystem for Linux)

Open **PowerShell** as Administrator and run:

```powershell
wsl --install
```

This installs WSL 2 and Ubuntu by default.

If you already have WSL 1, upgrade it with:

```powershell
wsl --set-version <distro-name> 2
```

Check your version:

```powershell
wsl --list --verbose
```
---

### 2. Install or update Ubuntu

If Ubuntu is missing, install it from the **Microsoft Store**.
Launch it and create a username and password.

Alternatively, install directly via PowerShell

```powershell
wsl --install -d Ubuntu-22.04
```

---

### 3. Update your Ubuntu system

Inside your WSL terminal

```bash
sudo apt update && sudo apt upgrade -y
```

This ensures you have up-to-date compilers and libraries before running TukeyStart

---

### 4. Restart WSL

```powershell
wsl --shutdown
```

Then reopen Ubuntu.

---

### 5. Install TukeyStart

Once your environment is ready:

```bash
curl -fsSL https://raw.githubusercontent.com/Tukey-mx/TukeyStart/main/install.sh | bash
tukey_start
```

---

## Usage

From any directory, run:

```bash
tukey_start
```

Follow the on-screen instructions to set up your environment.

---

## How It Works

1. Detects the operating system (macOS, Linux, or WSL 2).
2. Ensures Homebrew, pyenv, and fzf are available.
3. Lists all installed Python versions via pyenv.
4. Lets you select or install a new version interactively.
5. Creates a local `.venv` virtual environment.
6. Lets you select among the following base packages to install.

   ```
   numpy
   pandas
   matplotlib
   seaborn
   scikit-learn
   jupyterlab
   ipykernel
   ```

7. Builds a minimal project layout:
   ```
   notebooks/
   ├── starter.ipynb
   src/
   data/
   └── .gitkeep
   ```

8. Downloads example datasets.

---

## Requirements

- macOS 11+, Linux, or WSL 2  
- Internet connection  

TukeyStart automatically installs
- `Homebrew`  
- `pyenv`  
- `fzf`  
- Core system dependencies (openssl, readline, zlib, sqlite, xz, bzip2, etc.)

---

## Update

Re-run the installer anytime to get the latest version:

```bash
curl -fsSL https://raw.githubusercontent.com/Tukey-mx/TukeyStart/main/install.sh | bash
```

---
## Contributing

Contributions are welcome.  
If you find a bug or have an idea for improvement, please open an issue or submit a pull request.  
Before making major changes, consider discussing them first in an issue to align on approach.

---

## FAQ

*Q: Do I need to install Python before running TukeyStart?*  
A: No. TukeyStart installs and manages Python versions automatically using pyenv.

*Q: Does it work on Windows?*  
A: Yes, through WSL 2. TukeyStart is Linux-based but works seamlessly inside Ubuntu on Windows.

*Q: Will it overwrite my existing Python setup?*  
A: No. It installs everything locally inside the selected directory and uses isolated environments.

*Q: Can I customize which packages are installed?*  
A: Yes. TukeyStart lets you select packages interactively using fzf, and you can also add more manually after setup with pip install

---

## Credits

Developed by the **ESCOM Data Science Club**  

[![Contributors](https://img.shields.io/github/contributors/Tukey-mx/TukeyStart?color=0A66C2&label=Contributors&logo=github)](https://github.com/Tukey-mx/TukeyStart/graphs/contributors)

---

## License

MIT License © 2025

---

## Performance Notes

A full setup usually takes between 3–8 minutes, depending on your internet connection and system performance.  
Subsequent runs are much faster since installed tools and Python versions are cached.