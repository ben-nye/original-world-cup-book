#!/bin/bash
set -euo pipefail

if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "Stopping and removing container..."
docker-compose down

echo "Removing persistent data folder..."
rm -rf ./pgdata

echo "Done. All clean."