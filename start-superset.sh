#!/bin/sh

set -o allexport
source superset.env
set +o allexport

docker exec -it superset-oauth superset db upgrade
docker exec -it superset-oauth superset fab create-admin --username ${SUPERSET_ADMIN_USERNAME} --password ${SUPERSET_ADMIN_PASSWORD} --firstname Superset --lastname Admin --email ${SUPERSET_ADMIN_EMAIL}
docker exec -it superset-oauth superset init
