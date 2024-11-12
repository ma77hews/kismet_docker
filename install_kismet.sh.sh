#install_kismet.sh
#!/bin/bash

# Función para verificar e instalar paquetes si es necesario
install_if_missing() {
    for pkg in "$@"; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            echo "El paquete $pkg no está instalado. Instalándolo..."
            apt update && apt install -y "$pkg"
            if [ $? -ne 0 ]; then
                echo "Error al instalar el paquete $pkg."
                exit 1
            fi
        else
            echo "El paquete $pkg ya está instalado."
        fi
    done
}

# Función para instalar aircrack-ng desde el código fuente si no está en los repositorios
install_aircrack_ng() {
    if ! command -v aircrack-ng > /dev/null; then
        echo "Intentando instalar aircrack-ng desde el repositorio..."
        apt update && apt install -y aircrack-ng

        if [ $? -ne 0 ]; then
            echo "Error al instalar aircrack-ng desde los repositorios. Intentando instalar desde el código fuente..."

            # Clonar el repositorio de aircrack-ng y compilar
            git clone https://github.com/aircrack-ng/aircrack-ng.git
            cd aircrack-ng
            make
            make install
            cd ..

            if [ $? -eq 0 ]; then
                echo "aircrack-ng se instaló correctamente desde el código fuente."
            else
                echo "Error al instalar aircrack-ng desde el código fuente."
                exit 1
            fi
        else
            echo "aircrack-ng instalado correctamente desde los repositorios."
        fi
    else
        echo "aircrack-ng ya está instalado."
    fi
}

# Verificar e instalar iw, aircrack-ng, y otras dependencias
install_if_missing iw git build-essential libmicrohttpd-dev libnl-3-dev \
    libnl-genl-3-dev libcap-dev pkg-config libprotobuf-dev protobuf-compiler \
    libprotobuf-c-dev protobuf-c-compiler libsodium-dev libpcap-dev libnm-dev \
    libdw-dev lm-sensors libsensors-config

# Instalación de aircrack-ng si no está presente
install_aircrack_ng

# Instalación de Kismet desde los repositorios oficiales
if ! command -v kismet > /dev/null; then
    echo "Kismet no está instalado. Instalándolo desde el repositorio oficial..."

    # Configurar el repositorio de Kismet
    wget -O - https://www.kismetwireless.net/repos/kismet-release.gpg.key --quiet | gpg --dearmor | tee /usr/share/keyrings/kismet-archive-keyring.gpg >/dev/null
    echo 'deb [signed-by=/usr/share/keyrings/kismet-archive-keyring.gpg] https://www.kismetwireless.net/repos/apt/git/noble noble main' | tee /etc/apt/sources.list.d/kismet.list >/dev/null

    # Actualizar repositorios e instalar Kismet
    apt update
    apt install -y kismet

    if [ $? -ne 0 ]; then
        echo "Error al instalar Kismet."
        exit 1
    else
        echo "Kismet instalado correctamente."
    fi
else
    echo "Kismet ya está instalado."
fi

# Detectar adaptadores WiFi extraíbles
echo "Buscando adaptadores WiFi extraíbles..."
wifi_devices=$(iw dev | grep Interface | awk '{print $2}')

if [ -z "$wifi_devices" ]; then
    echo "No se encontraron adaptadores WiFi. Intentando nuevamente..."
    # Aquí podrías intentar algo más, como esperar un tiempo o intentar otro método de detección
    sleep 5  # Esperar 5 segundos antes de intentar nuevamente
    wifi_devices=$(iw dev | grep Interface | awk '{print $2}')

    if [ -z "$wifi_devices" ]; then
        echo "No se encontraron adaptadores WiFi después del segundo intento."
        exit 1
    fi
fi

# Listar dispositivos y preguntar cuál usar
echo "Adaptadores WiFi detectados:"
select wifi_iface in $wifi_devices; do
    if [ -n "$wifi_iface" ]; then
        echo "Seleccionado: $wifi_iface"
        break
    else
        echo "Selección no válida."
    fi
done

# Verificar si el adaptador soporta modo monitor
echo "Verificando si el adaptador $wifi_iface soporta modo monitor..."
if iw list | grep -A 10 "$wifi_iface" | grep -q "monitor"; then
    echo "El adaptador $wifi_iface soporta modo monitor."
else
    echo "El adaptador $wifi_iface no soporta modo monitor."
    exit 1
fi

# Colocar el adaptador en modo monitor
echo "Colocando $wifi_iface en modo monitor..."
ifconfig "$wifi_iface" down
airmon-ng check kill
airmon-ng start "$wifi_iface"

# Verificar si el adaptador está en modo monitor
monitor_iface="${wifi_iface}mon"
if iw dev | grep -q "$monitor_iface"; then
    echo "El adaptador está ahora en modo monitor como $monitor_iface."
else
    echo "No se pudo activar el modo monitor en $wifi_iface."
    exit 1
fi

# Iniciar Kismet
echo "Iniciando Kismet..."
kismet -c "$monitor_iface"

# Restaurar el adaptador a modo gestionado después de salir de Kismet
echo "Restaurando el adaptador a modo gestionado..."
airmon-ng stop "$monitor_iface"
ifconfig "$wifi_iface" up

echo "Proceso completo."
