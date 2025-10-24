#!/bin/bash
#   ______   __  __  __ ____      ___           _     _           
#  | __ ) \ / / |  \/  |  _ \    |_ _|_ __  ___(_) __| | ___ _ __ 
#  |  _ \\ V /  | |\/| | |_) |    | || '_ \/ __| |/ _` |/ _ \ '__|
#  | |_) || |   | |  | |  _ < _   | || | | \__ \ | (_| |  __/ |   
#  |____/ |_|   |_|  |_|_| \_(_) |___|_| |_|___/_|\__,_|\___|_|   
#
##################################################################
chmod +x "$0" # Le da permisos de ejecucion al script mismo
clear
echo "┌──────────────────────────────────────────────────────────────────┐"
echo "│                                                                  │"
echo "│   ______   __  __  __ ____      ___           _     _            │"
echo "│  | __ ) \ / / |  \/  |  _ \    |_ _|_ __  ___(_) __| | ___ _ __  │"
echo "│  |  _ \  V /  | |\/| | |_) |    | ||  _ \/ __| |/ _  |/ _ \  __| │"
echo "│  | |_) || |   | |  | |  _ < _   | || | | \__ \ | (_| |  __/ |    │"
echo "│  |____/ |_|   |_|  |_|_| \_(_) |___|_| |_|___/_|\__,_|\___|_|    │"
echo "│                                                                  │"
echo "│   Project: neofetchjoke                                          │"
echo "│   Description: Launches animated neofetch terminals              │"
echo "│                with floating ASCII logos of distros              │"
echo "│                                                                  │"
echo "└──────────────────────────────────────────────────────────────────┘"
echo "" # Los comentarios son en español debido a mi idioma nativo.

# ------------------ inicio dependencia / instalador ------------------
REQUIRED_CMDS=(xdotool neofetch xterm)

# Detecta el gestor de paquetes, por ejemplo apt de debian/ubuntu o apk de alpine.
detect_pkg_mgr() {
  if command -v apt >/dev/null 2>&1; then echo "apt"; return; fi
  if command -v dnf >/dev/null 2>&1; then echo "dnf"; return; fi
  if command -v pacman >/dev/null 2>&1; then echo "pacman"; return; fi
  if command -v zypper >/dev/null 2>&1; then echo "zypper"; return; fi
  if command -v apk >/dev/null 2>&1; then echo "apk"; return; fi
  echo ""
}

# Instala los paquetes usando el gestor de paquetes que encontro anteriormente.
install_with_mgr() {
  mgr="$1"; shift
  case "$mgr" in
    apt) sudo apt update && sudo apt install -y "$@" ;;
    dnf) sudo dnf install -y "$@" ;;
    pacman) sudo pacman -Sy --noconfirm "$@" ;;
    zypper) sudo zypper install -y "$@" ;;
    apk) sudo apk add "$@" ;;
    *) return 1 ;;
  esac
}

# Verifica que estan todas las dependencias, si no estan, pregunta para instalarlas.
check_and_install_deps() {
  missing=()
  for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [ "${#missing[@]}" -eq 0 ]; then
    echo "Dependencies found: ${REQUIRED_CMDS[*]}"
    return 0
  fi

  echo "Missing dependencies: ${missing[*]}"
  mgr=$(detect_pkg_mgr)
  if [ -z "$mgr" ]; then
    echo "No supported package manager detected. Please install: ${missing[*]} manually."
    return 1
  fi

  read -r -p "¿Should I try to install them using '$mgr'? (y/n) " answer
  if [[ $answer =~ ^[Yy]$ ]]; then
    if install_with_mgr "$mgr" "${missing[@]}"; then
      echo "Dependencies installeds."
      return 0
    else
      echo "Failed to install dependencies with $mgr. Please install manually: ${missing[*]}"
      return 1
    fi
  fi

  return 1
}
# ------------------ fin dependencia / instalador ------------------
#
# :)
#
# ---------------------- inicio instalador/desinstalador ------------------
check_and_install_deps || exit 1 # Ejecuta la funcion y si falla pues sale con error
echo "You want install neofetchjoke in your system? (y/n/u)" 
echo "y = yes, n = no, u = uninstall"
read -r RESPUESTA
if [ ! -f neofetch.sh ]; then
    echo "File 'neofetch.sh' not found. Installation aborted."
    exit 1
fi
if [[ $RESPUESTA =~ ^[Uu]$ ]]; then
    echo "Uninstalling neofetchjoke..."
    sudo rm -f /usr/local/bin/neofetchjoke
    exit 0
fi
if [[ $RESPUESTA =~ ^[Yy]$ ]]; then # Si la respuesta es yes (y o Y)
    echo "Installing neofetchjoke..."
    chmod +x neofetch.sh # Dar permisos de ejecucion
    sudo mv neofetch.sh /usr/local/bin/neofetchjoke # Mover el script a /usr/local/bin con el nombre neofetchjoke, para que pueda ser ejecutado desde la terminal o cualquier
    echo "Install complete, You can exec 'neofetchjoke' in the terminal."
else
    echo "Install cancel."
fi
# ---------------------- fin instalador/desinstalador ------------------
#
# :)
#
# ---------------------- Inicio/Final ----------------------------------
echo ""
echo "┌──────────────────────────────────────┐"
echo "│  Thanx for choosing neofetchjoke :)  │"
echo "│  Run 'neofetchjoke' to start it!     │"
echo "│  Uninstall with this script again.   │"
echo "│  By Mr. Insider                      │"
echo "└──────────────────────────────────────┘"
echo ""
exit 0
