#!/bin/bash

# env

CONTAINER_NAME="jupyterhub"

#comando a ejecutar
COMMAND="cd /usr/local/share/jupyterhub/ && rm -rf static && rm -rf templates"

#entrar en el contenedor
docker exec -it $CONTAINER_NAME bash -c "$COMMAND"

#copiar static
docker cp resources/static jupyterhub:/usr/local/share/jupyterhub/ && docker cp resources/templates jupyterhub:/usr/local/share/jupyterhub/

#reiniciar
docker compose restart

