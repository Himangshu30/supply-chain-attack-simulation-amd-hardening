# Supply-Chain Attack Simulation & Hardening Lab

⚠️ **LAB-ONLY PROJECT - DO NOT USE IN PRODUCTION** ⚠️

## Overview

This project demonstrates a realistic software supply-chain compromise simulation for educational and security research purposes. It showcases how a malicious dependency can infiltrate a web application, demonstrates the attack impact, and provides comprehensive hardening and detection measures.

**Purpose**: DevSecOps Red Team exercise to understand and defend against supply-chain attacks.

## ⚠️ Safety & Ethics

- **DO NOT** publish malicious packages to public registries (npm, PyPI, etc.)
- All malicious code is contained in a local private registry (Verdaccio)
- All payloads are benign and create only test files with LAB_ prefix
- This project is for **educational purposes only** in isolated lab environments
- Follow responsible disclosure practices for any real vulnerabilities discovered

## Project Structure

```
supply-chain-lab/
├── app/                    # Target web application (Node.js/Express)
├── registry/               # Private npm registry (Verdaccio) configuration
├── poisoned-package/       # Malicious dependency source (@lab/malicious-util)
├── ci/                     # CI/CD pipeline configurations (GitHub Actions)
├── sbom/                   # Software Bill of Materials outputs
├── scans/                  # Vulnerability scan results
├── hardening/              # Security controls and policy-as-code
├── evidence/               # Attack evidence (logs, screenshots, artifacts)
├── lab/                    # Documentation and topology diagrams
└── Final_Report.pdf        # Executive summary and technical appendix
```

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- Docker and Docker Compose
- Git
- Syft (SBOM generation)
- Grype (vulnerability scanning)

### Setup

1. **Start the private registry**:
   ```bash
   cd registry
   docker-compose up -d
   ```

2. **Publish the malicious package** (lab-only):
   ```bash
   cd poisoned-package
   npm publish --registry http://localhost:4873
   ```

3. **Install and run the target app**:
   ```bash
   cd app
   npm install
   npm start
   ```

4. **Generate SBOM and scan**:
   ```bash
   ./scripts/generate-sbom.sh
   ./scripts/scan-dependencies.sh
   ```

## Attack Scenario

1. **Compromise**: A seemingly legitimate utility package `@lab/malicious-util` is introduced into the dependency tree
2. **Execution**: The malicious code runs during `npm install` or application startup
3. **Impact**: Creates `LAB_COMPROMISED.txt`, simulates data exfiltration (benign test file only)
4. **Detection**: SBOM analysis reveals unknown private packages, CI gates trigger alerts

## Hardening Measures

- ✅ SBOM generation with Syft (CycloneDX format)
- ✅ Automated vulnerability scanning with Grype
- ✅ CI policy gates (fail on unknown packages or medium+ severity vulns)
- ✅ Pre-merge security checks via GitHub Actions
- ✅ Runtime integrity monitoring
- ✅ Dependency pinning and lock file verification

## Learning Outcomes

- Understanding dependency confusion and typosquatting attacks
- Generating and analyzing SBOMs
- Implementing Software Composition Analysis (SCA)
- Building secure CI/CD pipelines with policy enforcement
- Creating incident response procedures for supply-chain compromises

## References

- [OWASP Top 10 CI/CD Security Risks](https://owasp.org/www-project-top-10-ci-cd-security-risks/)
- [SLSA Framework](https://slsa.dev/)
- [CycloneDX SBOM Standard](https://cyclonedx.org/)
- [Verdaccio - Private npm Registry](https://verdaccio.org/)

## License

MIT License - For educational and research purposes only.

## Author
Himangshu Sarkar
