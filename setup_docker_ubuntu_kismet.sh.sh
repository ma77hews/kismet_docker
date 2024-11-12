#setup_docker_ubuntu_kismet.sh 

#!/bin/bash

# Función para verificar e instalar Docker si no está presente
install_docker() {
    if ! command -v docker > /dev/null; then
        echo "Docker no está instalado. Instalándolo..."
        apt update && apt install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        apt update && apt install -y docker-ce
        if [ $? -ne 0 ]; then
            echo "Error al instalar Docker."
            exit 1
        fi
    else
        echo "Docker ya está instalado."
    fi
}

# Instalar Docker si no está presente
install_docker

# Descargar la imagen de Ubuntu 24 de Docker Hub si no está presente
if ! docker image inspect ubuntu:24.04 > /dev/null 2>&1; then
    echo "Descargando la imagen de Ubuntu 24 desde Docker Hub..."
    docker pull ubuntu:24.04
fi

# Asignar permisos de ejecución al script de instalación de Kismet
chmod +x install_kismet.sh

# Crear y ejecutar el contenedor de Docker (sin reinicio automático)
docker run -it --name ubuntu_kismet_setup --privileged --net=host --pid=host -v "$(pwd)/install_kismet.sh":/home/ubuntu/install_kismet.sh ubuntu:24.04 /bin/bash

# Verificar si el contenedor está corriendo
docker ps -f name=ubuntu_kismet_setup

# Obtener el ID del contenedor
container_id=$(docker ps -f name=ubuntu_kismet_setup -q)

if [ -z "$container_id" ]; then
    echo "El contenedor no se está ejecutando. Verifique los logs."
    exit 1
fi

echo "Contenedor ejecutándose correctamente."
