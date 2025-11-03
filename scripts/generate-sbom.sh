#!/bin/bash

# Generate Software Bill of Materials (SBOM) using Syft
# Supports multiple output formats: CycloneDX, SPDX, Table

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SBOM_DIR="$PROJECT_ROOT/sbom"
APP_DIR="$PROJECT_ROOT/app"

echo "═══════════════════════════════════════════════════════"
echo "  SBOM Generation - Supply Chain Analysis"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check if Syft is installed
if ! command -v syft &> /dev/null; then
    echo "❌ Syft is not installed"
    echo ""
    echo "Install Syft:"
    echo "  curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin"
    echo ""
    exit 1
fi

echo "✅ Syft version: $(syft version | head -n 1)"
echo ""

# Create SBOM directory
mkdir -p "$SBOM_DIR"

# Generate CycloneDX JSON SBOM
echo "📦 Generating CycloneDX JSON SBOM..."
syft dir:"$APP_DIR" -o cyclonedx-json > "$SBOM_DIR/sbom-cyclonedx.json"
echo "   ✅ Created: sbom/sbom-cyclonedx.json"

# Generate SPDX JSON SBOM
echo "📦 Generating SPDX JSON SBOM..."
syft dir:"$APP_DIR" -o spdx-json > "$SBOM_DIR/sbom-spdx.json"
echo "   ✅ Created: sbom/sbom-spdx.json"

# Generate human-readable table
echo "📦 Generating human-readable table..."
syft dir:"$APP_DIR" -o table > "$SBOM_DIR/sbom-table.txt"
echo "   ✅ Created: sbom/sbom-table.txt"

# Generate Syft JSON (detailed)
echo "📦 Generating Syft detailed JSON..."
syft dir:"$APP_DIR" -o syft-json > "$SBOM_DIR/sbom-syft.json"
echo "   ✅ Created: sbom/sbom-syft.json"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  SBOM Analysis"
echo "═══════════════════════════════════════════════════════"
echo ""

# Count packages
PACKAGE_COUNT=$(cat "$SBOM_DIR/sbom-table.txt" | grep -v "^NAME" | grep -c "^" || echo "0")
echo "📊 Total packages detected: $PACKAGE_COUNT"
echo ""

# Check for suspicious packages
echo "🔍 Checking for suspicious packages..."
if grep -q "@lab/" "$SBOM_DIR/sbom-cyclonedx.json"; then
    echo "❌ ALERT: Suspicious @lab/* package detected!"
    echo ""
    echo "Details:"
    grep -B 2 -A 5 "@lab/" "$SBOM_DIR/sbom-cyclonedx.json" | head -n 20
    echo ""
    echo "⚠️  ACTION REQUIRED: Investigate and remove malicious package"
else
    echo "✅ No suspicious @lab/* packages detected"
fi
echo ""

# Check for packages from non-standard registries
echo "🔍 Checking for non-standard package sources..."
if grep -qi "localhost:4873" "$SBOM_DIR/sbom-cyclonedx.json"; then
    echo "❌ ALERT: Packages from private/local registry detected!"
    echo "   This may indicate a supply-chain compromise"
else
    echo "✅ All packages from standard registries"
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo "  Summary"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "SBOM files created in: $SBOM_DIR"
echo ""
echo "Next steps:"
echo "  1. Review the SBOM: cat sbom/sbom-table.txt"
echo "  2. Run vulnerability scan: ./scripts/scan-dependencies.sh"
echo "  3. Integrate SBOM into CI/CD pipeline"
echo ""
