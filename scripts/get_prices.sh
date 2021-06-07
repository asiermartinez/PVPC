#!/bin/bash

FILENAME=$1
DATE=$(TZ="Europe/Madrid" date +%F)

curl -sS -X GET \
  "https://api.esios.ree.es/archives/70/download_json?locale=en&date=${DATE}" \
	-H "Accept: application/json; application/vnd.esios-api-v2+json" \
	-H "Content-Type: application/json" \
	-H "Host: api.esios.ree.es" \
	-H "Authorization: Token token=\"${ESIOS_TOKEN}\"" \
	-H "Cookie: " > ${FILENAME}