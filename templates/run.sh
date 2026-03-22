#!/bin/bash
set -e

cd "$(dirname "$0")"

docker compose -f docker-compose.claude.yml run --rm claude "/implement"
docker compose -f docker-compose.claude.yml run --rm claude "/review"