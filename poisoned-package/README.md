# @lab/malicious-util

⚠️ **LAB-ONLY MALICIOUS PACKAGE - DO NOT PUBLISH TO PUBLIC REGISTRIES** ⚠️

## Overview

This package simulates a supply-chain attack for educational purposes. It appears to provide useful utility functions but contains malicious code that executes during installation.

## Attack Vectors

### 1. Preinstall Script
The `preinstall` script in `package.json` executes automatically during `npm install`:
- Runs before the package is installed
- Has access to the full system environment
- Can execute arbitrary code with the user's permissions

### 2. Module Initialization
The main `index.js` file executes code when the module is loaded:
- Runs when the application `require()`s or `import`s the package
- Can maintain persistence throughout application runtime
- Can intercept or modify application behavior

## Payload (Benign)

This package contains **benign payloads only**:

1. **LAB_COMPROMISED.txt**: Created in the project root with compromise details
2. **evidence/compromise-log.json**: Detailed log of the compromise event
3. **.lab_malicious_util_loaded**: Runtime marker file

All payloads:
- Do NOT make network requests
- Do NOT modify existing files (except creating new marker files)
- Do NOT exfiltrate real data
- Do NOT cause system harm

## Real-World Attack Scenarios

In a real supply-chain attack, malicious packages might:

### During Installation (preinstall/postinstall scripts):
- Steal environment variables (API keys, tokens, secrets)
- Download and execute secondary payloads
- Modify package.json or other project files
- Install backdoors in system directories
- Exfiltrate source code to external servers

### During Runtime:
- Hook into application logic (password capture, data theft)
- Establish C2 (Command & Control) connections
- Inject malicious code into build artifacts
- Perform cryptojacking
- Act as a ransomware dropper

## Detection Methods

### SBOM Analysis
```bash
syft . -o cyclonedx-json > sbom.json
# Look for unexpected @lab/* packages
```

### Dependency Scanning
```bash
grype dir:. --fail-on medium
# Scan for known vulnerabilities and suspicious patterns
```

### Manual Inspection
```bash
# Check for suspicious scripts
cat package.json | jq '.scripts'

# List all installed packages
npm ls --all

# Check package contents
npm pack --dry-run @lab/malicious-util
```

### CI/CD Gates
- Block packages from untrusted registries
- Require SBOM attestation
- Fail on unknown dependencies
- Verify package signatures

## Installation (Lab Only)

**DO NOT** install this package in production or from public registries.

### Publish to Private Registry

```bash
# From this directory
npm publish --registry http://localhost:4873
```

### Install in Target Application

```bash
# Add to package.json dependencies
{
  "dependencies": {
    "@lab/malicious-util": "^0.0.1"
  }
}

# Configure npm to use private registry for @lab packages
npm config set @lab:registry http://localhost:4873

# Install
npm install
```

## Defensive Measures

1. **Use Lock Files**: Commit `package-lock.json` to detect unauthorized changes
2. **Audit Dependencies**: Run `npm audit` regularly
3. **Review Scripts**: Check `preinstall`, `postinstall`, `preuninstall` scripts
4. **Use Private Registries**: Control the supply chain with Artifactory/Verdaccio
5. **SBOM Generation**: Track all components and their origins
6. **Vulnerability Scanning**: Integrate Grype, Snyk, or Dependabot
7. **CI Security Gates**: Block untrusted or vulnerable packages
8. **Principle of Least Privilege**: Run npm install with minimal permissions
9. **Sandboxing**: Use containers or VMs for build processes
10. **Code Signing**: Verify package signatures and provenance

## References

- [npm Security Best Practices](https://docs.npmjs.com/misc/security)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
- [Snyk Supply Chain Security](https://snyk.io/learn/supply-chain-security/)
- [SLSA Framework](https://slsa.dev/)

## License

MIT - For educational purposes only.

---

**Remember**: Never publish this package to public registries!
