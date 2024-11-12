# kismet_docker
scripts automatizados para la instalacion de kismet en un ubuntu dockerizado


0) git clone https://github.com/ma77hews/kismet_docker <- esto clona este repo de git en la carpeta donde estes
1) cd kismet_docker <- me muevo dentro de la carpeta
2) mv *.sh ../ <- muevo los archivos a la carpeta anterior
3) cd ../ <- me muevo yo a la carpeta anterior
4) chmod +x *.sh <- le doy permiso de ejecucion a los archivos
5) sudo ./setup_docker_ubuntu_kismet.sh <- ejecuto el instalador del docker como administrador (importante ejecutar como admin)
*el script va a ejecutar e instalar varias cosas de docker, cuando termine ya te va a meter a un bash dentro del docker y el archivo de instalacion de kismet ya va a estar copiado*
6) /home/ubuntu/install_kismet.sh <-  ejecuto el script de instalacion de kismet con todas sus dependencias
7) 2 <-elijo la region en este caso america (donde se hace la eko)
8) 6 <- elijo la zona horaria en este caso buenos aires (donde se hace la eko)
9) yes <- agrego al grupo de administradores el usuario para ejecutar kismet sin sudo
10) elegir la interfaz wifi a utilizar para levantarla en modo monitor
*puede o no levantar el modo monitor si no levanta el modo monitor seguir con el 11*
11) kismet -c "nombre placa que aparece en 10)" --override wardrive 
