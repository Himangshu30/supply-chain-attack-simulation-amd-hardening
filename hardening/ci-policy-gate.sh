#!/bin/bash

# CI Policy Gate - Supply Chain Security Enforcement
# 
# This script enforces security policies in CI/CD pipelines
# Fails the build if any policy violations are detected

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SBOM_DIR="$PROJECT_ROOT/sbom"
SCANS_DIR="$PROJECT_ROOT/scans"
APP_DIR="$PROJECT_ROOT/app"

EXIT_CODE=0

echo "═══════════════════════════════════════════════════════"
echo "  CI Security Policy Gate"
echo "  Supply Chain Attack Prevention"
echo "═══════════════════════════════════════════════════════"
echo ""

# Policy 1: Check for lock file
echo "🔒 Policy 1: Verify package-lock.json exists"
if [ ! -f "$APP_DIR/package-lock.json" ]; then
    echo "   ❌ FAIL: package-lock.json not found"
    echo "   ACTION: Commit package-lock.json to repository"
    EXIT_CODE=1
else
    echo "   ✅ PASS: Lock file present"
fi
echo ""

# Policy 2: Check for suspicious lifecycle scripts
echo "🔍 Policy 2: Check for suspicious npm lifecycle scripts"
if grep -qE "(preinstall|postinstall|preuninstall)" "$APP_DIR/package.json"; then
    echo "   ⚠️  WARNING: Lifecycle scripts detected"
    echo "   Detected scripts:"
    grep -E "(preinstall|postinstall|preuninstall)" "$APP_DIR/package.json" | head -n 5
    echo "   ACTION: Review scripts for malicious code"
    # This is a warning, not a failure (legitimate packages may use these)
else
    echo "   ✅ PASS: No suspicious lifecycle scripts"
fi
echo ""

# Policy 3: Check for non-standard registries
echo "🌐 Policy 3: Verify package sources"
if [ -f "$APP_DIR/.npmrc" ]; then
    if grep -v "registry.npmjs.org" "$APP_DIR/.npmrc" | grep -q "registry"; then
        echo "   ❌ FAIL: Custom registry detected in .npmrc"
        cat "$APP_DIR/.npmrc"
        echo "   ACTION: Use only trusted registries"
        EXIT_CODE=1
    else
        echo "   ✅ PASS: Standard registry configured"
    fi
else
    echo "   ✅ PASS: No custom .npmrc file"
fi

if [ -f "$APP_DIR/package-lock.json" ]; then
    if grep -qi "localhost:4873" "$APP_DIR/package-lock.json"; then
        echo "   ❌ FAIL: Private/local registry detected in package-lock.json"
        echo "   This indicates a possible supply-chain compromise"
        EXIT_CODE=1
    fi
fi
echo ""

# Policy 4: Check SBOM for suspicious packages
echo "📦 Policy 4: SBOM Analysis - Check for malicious packages"
if [ -f "$SBOM_DIR/sbom-cyclonedx.json" ]; then
    if grep -q "@lab/" "$SBOM_DIR/sbom-cyclonedx.json"; then
        echo "   ❌ FAIL: Suspicious @lab/* package detected in SBOM"
        echo "   Malicious package(s):"
        grep -o "@lab/[a-z-]*" "$SBOM_DIR/sbom-cyclonedx.json" | sort -u
        echo "   ACTION: Remove malicious package and investigate compromise"
        EXIT_CODE=1
    else
        echo "   ✅ PASS: No suspicious packages in SBOM"
    fi
else
    echo "   ⚠️  WARNING: SBOM not found - run ./scripts/generate-sbom.sh"
fi
echo ""

# Policy 5: Vulnerability severity threshold
echo "🛡️  Policy 5: Vulnerability Severity Threshold"
if [ -f "$SCANS_DIR/grype-results.json" ]; then
    CRITICAL=$(cat "$SCANS_DIR/grype-results.json" | grep -o '"severity":"Critical"' | wc -l || echo "0")
    HIGH=$(cat "$SCANS_DIR/grype-results.json" | grep -o '"severity":"High"' | wc -l || echo "0")
    
    echo "   Vulnerability count:"
    echo "     - Critical: $CRITICAL"
    echo "     - High: $HIGH"
    
    if [ "$CRITICAL" -gt 0 ]; then
        echo "   ❌ FAIL: Critical vulnerabilities detected"
        echo "   ACTION: Remediate critical vulnerabilities before deployment"
        EXIT_CODE=1
    elif [ "$HIGH" -gt 0 ]; then
        echo "   ⚠️  WARNING: High severity vulnerabilities detected"
        echo "   ACTION: Plan remediation for high severity issues"
        # Don't fail on high, but warn
    else
        echo "   ✅ PASS: No critical or high vulnerabilities"
    fi
else
    echo "   ⚠️  WARNING: Vulnerability scan results not found"
    echo "   ACTION: Run ./scripts/scan-dependencies.sh"
fi
echo ""

# Policy 6: Check for compromise evidence
echo "🚨 Policy 6: Check for compromise indicators"
COMPROMISE_FOUND=0

if [ -f "$PROJECT_ROOT/LAB_COMPROMISED.txt" ]; then
    echo "   ❌ FAIL: LAB_COMPROMISED.txt found - supply chain compromise detected!"
    COMPROMISE_FOUND=1
fi

if [ -f "$PROJECT_ROOT/evidence/compromise-log.json" ]; then
    echo "   ❌ FAIL: Compromise log found - malicious code executed!"
    COMPROMISE_FOUND=1
fi

if [ -f "$PROJECT_ROOT/.lab_malicious_util_loaded" ]; then
    echo "   ❌ FAIL: Runtime compromise marker found!"
    COMPROMISE_FOUND=1
fi

if [ $COMPROMISE_FOUND -eq 1 ]; then
    echo "   ACTION: Investigate compromise, remove malicious packages, and rebuild"
    EXIT_CODE=1
else
    echo "   ✅ PASS: No compromise indicators detected"
fi
echo ""

# Policy 7: Dependency count check (optional - detect bloat)
echo "📊 Policy 7: Dependency Count Check"
if [ -f "$APP_DIR/package.json" ]; then
    DEP_COUNT=$(cat "$APP_DIR/package.json" | grep -A 100 '"dependencies"' | grep '":' | wc -l)
    echo "   Total dependencies: $DEP_COUNT"
    
    if [ "$DEP_COUNT" -gt 50 ]; then
        echo "   ⚠️  WARNING: High dependency count increases attack surface"
        echo "   ACTION: Review dependencies and remove unused packages"
    else
        echo "   ✅ PASS: Dependency count within acceptable range"
    fi
fi
echo ""

# Final summary
echo "═══════════════════════════════════════════════════════"
echo "  Policy Gate Summary"
echo "═══════════════════════════════════════════════════════"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ ALL POLICIES PASSED"
    echo ""
    echo "The build meets all security requirements."
    echo "Safe to proceed with deployment."
else
    echo "❌ POLICY VIOLATIONS DETECTED"
    echo ""
    echo "The build does NOT meet security requirements."
    echo "Fix the issues above before deploying."
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo ""

exit $EXIT_CODE
