# kismet_docker
scripts automatizados para la instalacion de kismet en un ubuntu dockerizado


0) git clone https://github.com/ma77hews/kismet_docker
1) sudo ./setup_docker_ubuntu_kismet.sh
(aca ya nos instala docker con la imagen y nos mete adentro como administrador)
2) /home/ubuntu/install_kismet.sh
(instala todas las dependencias)
3) 2, 6
(region y zona horaria)
4) yes
5) elegis la interfaz 
(puede o no levantar el modo monitor)
6) si no la levanta te copias el nombre de la placa
kismet -c "nombre placa" --override wardrive &
