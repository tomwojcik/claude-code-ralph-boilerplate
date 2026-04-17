#!/bin/bash
set -e

cd "$(dirname "$0")"

export HOST_UID=$(id -u)
export HOST_GID=$(id -g)

docker compose -f docker-compose.claude.yml run --rm claude "/implement"
docker compose -f docker-compose.claude.yml run --rm claude "/review"