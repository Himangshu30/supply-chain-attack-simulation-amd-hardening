#!/bin/bash

# Stop Verdaccio Private Registry

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[*] Stopping Lab Private Registry..."
docker-compose down

echo "[✓] Registry stopped"
echo ""
echo "To clean up all data (packages, users, etc.):"
echo "  docker-compose down -v"
echo "  rm -rf storage/*"
