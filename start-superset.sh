#!/bin/sh

set -o allexport
source superset.env
set +o allexport

docker exec -itd docker-superset-superset-1 celery --app=superset.tasks.celery_app:app worker --pool=prefork -O fair -c 4
docker exec -itd docker-superset-superset-1 celery --app=superset.tasks.celery_app:app beat
docker exec -itd docker-superset-superset-1 celery --app=superset.tasks.celery_app:app flower
docker exec -itd docker-superset-superset-1 superset db upgrade
docker exec -itd docker-superset-superset-1 superset fab create-admin --username admin --password ${SUPERSET_ADMIN_PASSWORD} --firstname Superset --lastname Admin --email ${SUPERSET_ADMIN_EMAIL}
docker exec -itd docker-superset-superset-1 superset init
