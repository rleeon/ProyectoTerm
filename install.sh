#!/bin/bash
#   ______   __  __  __ ____      ___           _     _           
#  | __ ) \ / / |  \/  |  _ \    |_ _|_ __  ___(_) __| | ___ _ __ 
#  |  _ \\ V /  | |\/| | |_) |    | || '_ \/ __| |/ _` |/ _ \ '__|
#  | |_) || |   | |  | |  _ < _   | || | | \__ \ | (_| |  __/ |   
#  |____/ |_|   |_|  |_|_| \_(_) |___|_| |_|___/_|\__,_|\___|_|   
#
##################################################################
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
echo "" # Los comentarios son en español debido a mi idioma nativo :P

# ------------------ inicio dependencia / instalador ------------------
REQUIRED_CMDS=(xdotool neofetch) # Lista de comandos requeridoss

# Aqui detecta el gestor de paquetes disponible
detect_pkg_mgr() { 
  if command -v apt >/dev/null 2>&1; then echo "apt" # Detecta apt
  elif command -v dnf >/dev/null 2>&1; then echo "dnf" # Detecta dnf
  elif command -v pacman >/dev/null 2>&1; then echo "pacman" # Detecta pacman
  elif command -v zypper >/dev/null 2>&1; then echo "zypper" # Detecta zypper
  elif command -v apk >/dev/null 2>&1; then echo "apk" # Detecta apk
  else
    echo ""
  fi
}

# instalar paquetes depende de el gestor de paquetes
install_with_mgr() {
  mgr="$1"; shift # El primer argumento es el gestor de paquetes
  pkgs=("$@")
  case "$mgr" in # Segun el gestor de paquetes, instala los paquetes
    apt) sudo apt update && sudo apt install -y "${pkgs[@]}" ;;
    dnf) sudo dnf install -y "${pkgs[@]}" ;;
    pacman) sudo pacman -Sy --noconfirm "${pkgs[@]}" ;;
    zypper) sudo zypper install -y "${pkgs[@]}" ;;
    apk) sudo apk add "${pkgs[@]}" ;;
    *) return 1 ;;
  esac
}

# descarga neofetch directamente desde github
download_neofetch_from_github() {
  echo "Downloading neofetch script from GitHub..."
  if command -v curl >/dev/null 2>&1; then # Usa curl para descargar
    sudo curl -fsSL "https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch" -o /usr/local/bin/neofetch
  elif command -v wget >/dev/null 2>&1; then # Usa wget para descargar
    sudo wget -qO /usr/local/bin/neofetch "https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch"
  else # No hay curl ni wget
    echo "No curl or wget available to download neofetch."
    return 1
  fi
  sudo chmod +x /usr/local/bin/neofetch # Le da permisos de ejecucion
  echo "neofetch installed to /usr/local/bin/neofetch" # Confirma la instalacion
  return 0
}

# Verifica e instala dependencias
check_and_install_deps() { 
  missing=() # Array para dependencias faltantes
  for cmd in "${REQUIRED_CMDS[@]}"; do # Revisa cada comando requerido
    if ! command -v "$cmd" >/dev/null 2>&1; then # Si el comando no se encuentra
      missing+=("$cmd") # Lo agrega a la lista de faltantes
    fi
  done

  if [ "${#missing[@]}" -eq 0 ]; then # Si no hay dependencias faltantes
    echo "Dependencies found: ${REQUIRED_CMDS[*]}" # Confirma que todas las dependencias estan presentes
    return 0
  fi

  echo "Missing dependencies: ${missing[*]}" # Informa las dependencias faltantes
  mgr=$(detect_pkg_mgr) # Detecta el gestor de paquetes disponible

  # Intenta automaticamente arreglar: neofetch via descarga, xdotool via gestor de paquetes
  for pkg in "${missing[@]}"; do
    case "$pkg" in
      neofetch) # intenta descargar neofetch desde github
        if ! download_neofetch_from_github; then # Si la descarga falla, informa al usuario
          echo "Failed to install neofetch automatically. Install manually or via package manager."
          return 1
        fi
        ;;
      xdotool) # intenta instalar xdotool via gestor de paquetes
        if [ -n "$mgr" ]; then # Si hay un gestor de paquetes detectado
          echo "Installing xdotool with $mgr..."
          if ! install_with_mgr "$mgr" xdotool; then
            echo "Failed to install xdotool with $mgr. Install manually."
            return 1
          fi
        else # No hay gestor de paquetes detectado
          echo "xdotool missing and no package manager detected. Install manually."
          return 1
        fi
        ;;
      *)
        echo "Unhandled missing dependency: $pkg" # Esto no deberia pasar nunca porque solo hay dos dependencias
        return 1
        ;;
    esac
  done


  echo "Re-checking dependencies..." # Esto es para verificar que todo se instalo bien
  for cmd in "${REQUIRED_CMDS[@]}"; do # Revisa cada comando requerido nuevamente
    if ! command -v "$cmd" >/dev/null 2>&1; then # Si algun comando sigue faltando
      echo "Still missing: $cmd"
      return 1
    fi
  done

  echo "All dependencies satisfied."
  return 0
}
# ------------------ fin dependencia / instalador ------------------
#
# :)
#
# ---------------------- inicio instalador/desinstalador ------------------
check_and_install_deps || exit 1 # Ejecuta la funcion y si falla pues sale con error
INSTALL_PATH="/usr/local/bin/neofetchjoke" # Ruta de instalacion

echo "What do you want to do? (i = install/reinstall, u = uninstall, q = quit)" # Pregunta al usuario que hacer
read -r RESPUESTA # Lee la respuesta del usuario

if [[ $RESPUESTA =~ ^[Uu]$ ]]; then # Opcion para desinstalar " uninstall "
    echo "Uninstalling neofetchjoke..."
    if sudo rm -f "$INSTALL_PATH"; then # Intenta eliminar el archivo de instalacion
        echo "Removed $INSTALL_PATH" # Confirma que se elimino
        exit 0
    else
        echo "Failed to remove $INSTALL_PATH (or it did not exist)." # Error al eliminar
        exit 1 # Sale a la terminal con error
    fi
fi

if [[ $RESPUESTA =~ ^[Qq]$ ]]; then # Opcion para salir " quit "
    echo "Aborted by user."
    exit 0 # Sale a la terminal sin error
fi

if [[ $RESPUESTA =~ ^[Ii]$ ]]; then # Opcion para instalar " install "
    echo "Installing neofetchjoke..."
    if [ -f "$INSTALL_PATH" ]; then # Si una instalacion previa existe, pregunta para sobrescribir
      read -r -p "An existing installation was found at $INSTALL_PATH. Overwrite? (y/N): " OVER # Pregunta para sobrescribir
      if ! [[ $OVER =~ ^[Yy]$ ]]; then # Si el usuario no quiere sobrescribir, cancela la instalacion
        echo "Install cancelled."
        exit 0 # Sale a la terminal sin error
      fi
    fi

    # Prefiere el script local del proyectom, si es que esta disponible
    if [ -f "./neofetchjoke" ]; then # Si el archivo local existe, lo instala
        echo "Installing local ./neofetchjoke..."
        sudo install -m 755 "./neofetchjoke" "$INSTALL_PATH" && echo "Installed to $INSTALL_PATH" # Confirma la instalacion
        exit $? # Sale con el codigo de exito o error de la instalacion
    elif [ -f "./neofetch.sh" ]; then # Si el archivo local alternativo existe, lo instala
        echo "Installing local ./neofetch.sh..." 
        sudo install -m 755 "./neofetch.sh" "$INSTALL_PATH" && echo "Installed to $INSTALL_PATH" # Confirma la instalacion
        exit $? # Lo mismo que arriba "Sale con el codigo de exito o error de la instalacion"
    fi

    echo "No local 'neofetchjoke' or 'neofetch.sh' found."
    read -r -p "Enter a raw URL to download the script (leave empty to install official neofetch script): " RAWURL

    # Por defecto descarga el script oficial de neofetch si el usuario deja en blanco
    if [ -z "$RAWURL" ]; then
        RAWURL="https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch" # Repo de neofetch
        echo "No URL provided — will download official neofetch from: $RAWURL" # Informa que descargara neofetch pero de manera oficial
    fi

    TMPFILE="$(mktemp /tmp/neofetchjoke.XXXXXX.sh)" # Crea un archivo temporal que sera eliminado luego, solo es para la descarga.
    if command -v curl >/dev/null 2>&1; then # Usa curl para descargar
        if ! curl -fsSL "$RAWURL" -o "$TMPFILE"; then # Si la descarga falla, informa y elimina el archivo temporal
            echo "Failed to download from $RAWURL"
            rm -f "$TMPFILE" # Aqui lo borra
            exit 1 # Sale con error
        fi
    elif command -v wget >/dev/null 2>&1; then # Usa wget para descargar
        if ! wget -qO "$TMPFILE" "$RAWURL"; then # Si la descarga falla, informa y elimina el archivo temporal
            echo "Failed to download from $RAWURL"
            rm -f "$TMPFILE" # Aqui lo borra
            exit 1 # Sale con error
        fi
    else
        echo "Neither curl nor wget available to download file. Install aborted."
        rm -f "$TMPFILE" 2>/dev/null || true # Intenta borrar el archivo temporal si existe
        exit 1 # Sale con error
    fi

    # Esto instala el archivo descargado
    echo "Installing downloaded script to $INSTALL_PATH..."
    sudo install -m 755 "$TMPFILE" "$INSTALL_PATH" && echo "Installed to $INSTALL_PATH" # Confirma la instalacion
    rm -f "$TMPFILE" # Elimina el archivo temporal
    exit $? # Sale con el codigo de exito o error de la instalacion
fi

echo "Invalid option."
exit 1 # Sale con error si la opcion no es valida
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
exit 0 # Sale sin error
# ---------------------- Fin ------------------------------------------