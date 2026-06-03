#!/bin/sh
set -e

echo "Rodando migrations..."
npm run migration:run

echo "Iniciando aplicação..."
exec "$@"