#!/bin/bash
# Стенд ДЗ №1: приложение osipov-03/probe + база postgres на томе

PREFIX=osipov-03
PUB_PORT=8009
DB_PORT=8011
IMAGE=${PREFIX}/probe
VOLUME=${PREFIX}-data

# 1. Удалить прежние контейнеры (том не трогаем!)
docker rm -f ${PREFIX}-web ${PREFIX}-db 2>/dev/null

# 2. Собрать образ версии 2.0
docker build --build-arg VERSION=2.0 -t ${IMAGE}:2.0 .

# 3. Создать том (если его нет)
docker volume create ${VOLUME}

# 4. Запустить базу на томе
docker run -d --name ${PREFIX}-db \
  -e POSTGRES_PASSWORD=lab -e POSTGRES_DB=lab \
  -p ${DB_PORT}:5432 \
  -v ${VOLUME}:/var/lib/postgresql/data \
  postgres:16-alpine

# 5. Запустить приложение с --add-host и DATABASE_URL
docker run -d --name ${PREFIX}-web \
  -p ${PUB_PORT}:5003 \
  --add-host host.docker.internal:host-gateway \
  -e DATABASE_URL="postgresql://postgres:lab@host.docker.internal:${DB_PORT}/lab" \
  ${IMAGE}:2.0

# 6. Дождаться готовности базы (до 60 секунд)
echo "Ждём готовности базы..."
SECONDS=0
until curl -sf -m 3 localhost:${PUB_PORT}/notes > /dev/null || [ $SECONDS -ge 60 ]; do
  sleep 2
done

# 7. Показать заметки
curl -s localhost:${PUB_PORT}/notes
