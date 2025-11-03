#!/bin/bash

# Start Verdaccio Private Registry for Lab
# LAB-ONLY: For supply-chain attack simulation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[*] Starting Lab Private Registry (Verdaccio)..."

# Create required directories
mkdir -p storage config plugins

# Check if config exists, if not use the provided one
if [ ! -f config/config.yaml ]; then
    echo "[!] config.yaml not found in config/ directory"
    exit 1
fi

# Start Docker Compose
echo "[*] Starting Verdaccio container..."
docker-compose up -d

# Wait for registry to be ready
echo "[*] Waiting for registry to be ready..."
sleep 5

# Check if registry is accessible
if curl -s http://localhost:4873 > /dev/null 2>&1; then
    echo "[✓] Verdaccio registry is running at http://localhost:4873"
    echo "[✓] Web UI available at http://localhost:4873"
    echo ""
    echo "Next steps:"
    echo "  1. Configure npm to use the private registry:"
    echo "     npm set registry http://localhost:4873"
    echo ""
    echo "  2. Create a user (optional):"
    echo "     npm adduser --registry http://localhost:4873"
    echo ""
    echo "  3. Publish the malicious package:"
    echo "     cd ../poisoned-package && npm publish --registry http://localhost:4873"
else
    echo "[!] Failed to start Verdaccio registry"
    docker-compose logs
    exit 1
fi
