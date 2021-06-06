#!/bin/bash

FILENAME=$1

curl -X GET \
  "https://api.esios.ree.es/archives/70/download_json?locale=en" \
	-H "Accept: application/json; application/vnd.esios-api-v2+json" \
	-H "Content-Type: application/json" \
	-H "Host: api.esios.ree.es" \
	-H "Authorization: Token token=\"${ESIOS_TOKEN}\"" \
	-H "Cookie: " > ${FILENAME}