#!/bin/bash

# Vulnerability scanning using Grype and npm audit
# Scans dependencies for known CVEs and security issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCANS_DIR="$PROJECT_ROOT/scans"
APP_DIR="$PROJECT_ROOT/app"
SBOM_DIR="$PROJECT_ROOT/sbom"

echo "═══════════════════════════════════════════════════════"
echo "  Vulnerability Scanning - Dependency Analysis"
echo "═══════════════════════════════════════════════════════"
echo ""

# Check if Grype is installed
if ! command -v grype &> /dev/null; then
    echo "❌ Grype is not installed"
    echo ""
    echo "Install Grype:"
    echo "  curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin"
    echo ""
    exit 1
fi

echo "✅ Grype version: $(grype version | head -n 1)"
echo ""

# Create scans directory
mkdir -p "$SCANS_DIR"

echo "═══════════════════════════════════════════════════════"
echo "  1. Grype Vulnerability Scan"
echo "═══════════════════════════════════════════════════════"
echo ""

# Scan with Grype (JSON output)
echo "🛡️  Running Grype scan (JSON)..."
grype dir:"$APP_DIR" -o json > "$SCANS_DIR/grype-results.json" 2>&1 || true
echo "   ✅ Created: scans/grype-results.json"

# Scan with Grype (table output)
echo "🛡️  Running Grype scan (table)..."
grype dir:"$APP_DIR" -o table > "$SCANS_DIR/grype-results.txt" 2>&1 || true
echo "   ✅ Created: scans/grype-results.txt"

# Scan SBOM if it exists
if [ -f "$SBOM_DIR/sbom-cyclonedx.json" ]; then
    echo "🛡️  Scanning SBOM with Grype..."
    grype sbom:"$SBOM_DIR/sbom-cyclonedx.json" -o table > "$SCANS_DIR/grype-sbom-scan.txt" 2>&1 || true
    echo "   ✅ Created: scans/grype-sbom-scan.txt"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  2. npm audit"
echo "═══════════════════════════════════════════════════════"
echo ""

cd "$APP_DIR"

# Run npm audit (JSON)
echo "🔍 Running npm audit (JSON)..."
npm audit --json > "$SCANS_DIR/npm-audit.json" 2>&1 || true
echo "   ✅ Created: scans/npm-audit.json"

# Run npm audit (human-readable)
echo "🔍 Running npm audit (text)..."
npm audit > "$SCANS_DIR/npm-audit.txt" 2>&1 || true
echo "   ✅ Created: scans/npm-audit.txt"

cd "$PROJECT_ROOT"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  3. Analysis & Summary"
echo "═══════════════════════════════════════════════════════"
echo ""

# Parse Grype results
if [ -f "$SCANS_DIR/grype-results.json" ]; then
    CRITICAL=$(cat "$SCANS_DIR/grype-results.json" | grep -o '"severity":"Critical"' | wc -l || echo "0")
    HIGH=$(cat "$SCANS_DIR/grype-results.json" | grep -o '"severity":"High"' | wc -l || echo "0")
    MEDIUM=$(cat "$SCANS_DIR/grype-results.json" | grep -o '"severity":"Medium"' | wc -l || echo "0")
    LOW=$(cat "$SCANS_DIR/grype-results.json" | grep -o '"severity":"Low"' | wc -l || echo "0")
    
    echo "📊 Grype Vulnerability Count:"
    echo "   🔴 Critical: $CRITICAL"
    echo "   🟠 High:     $HIGH"
    echo "   🟡 Medium:   $MEDIUM"
    echo "   🟢 Low:      $LOW"
    echo ""
    
    # Check thresholds
    if [ "$CRITICAL" -gt 0 ]; then
        echo "❌ FAIL: Critical vulnerabilities detected!"
        echo "   ACTION REQUIRED: Review and remediate immediately"
    elif [ "$HIGH" -gt 0 ]; then
        echo "⚠️  WARNING: High severity vulnerabilities detected"
        echo "   ACTION REQUIRED: Review and plan remediation"
    else
        echo "✅ PASS: No critical or high severity vulnerabilities"
    fi
fi

echo ""

# Parse npm audit results
if [ -f "$SCANS_DIR/npm-audit.json" ]; then
    echo "📊 npm audit Summary:"
    cat "$SCANS_DIR/npm-audit.json" | grep -E '"(critical|high|moderate|low|info)"' | head -n 10 || echo "   ℹ️  Check npm-audit.txt for details"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Scan Complete"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Results saved in: $SCANS_DIR"
echo ""
echo "Review findings:"
echo "  cat scans/grype-results.txt"
echo "  cat scans/npm-audit.txt"
echo ""
echo "Next steps:"
echo "  1. Review vulnerability reports"
echo "  2. Update vulnerable dependencies"
echo "  3. Apply security patches"
echo "  4. Re-run scan to verify fixes"
echo ""
