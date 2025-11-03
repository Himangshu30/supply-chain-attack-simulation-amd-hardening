# ⚠️ LAB-ONLY DISCLAIMER ⚠️

## CRITICAL SAFETY NOTICE

This repository contains **simulated malicious code** for educational and security research purposes ONLY.

### DO NOT:

❌ **DO NOT** publish any package from this repository to public registries (npm, PyPI, Maven Central, etc.)

❌ **DO NOT** use this code in production environments

❌ **DO NOT** target systems you don't own or have explicit permission to test

❌ **DO NOT** modify the malicious payload to cause actual harm

❌ **DO NOT** share this project without this disclaimer

### MUST DO:

✅ **RUN ONLY** in isolated lab environments (VMs, containers, air-gapped networks)

✅ **USE ONLY** the provided private registry (Verdaccio) for package hosting

✅ **ENSURE** all malicious packages are clearly labeled with `@lab/` scope

✅ **VERIFY** all payloads are benign (create test files only, no network calls to external systems)

✅ **DOCUMENT** all activities in your lab notebook

✅ **CLEANUP** all artifacts after completing the exercise

## Legal & Ethical Considerations

### Authorization
- You must have explicit authorization to run security tests
- This project is designed for personal learning in controlled environments
- Unauthorized testing of production systems is illegal

### Responsible Disclosure
- If you discover real vulnerabilities while studying this project, follow responsible disclosure practices
- Report findings to the appropriate vendor security teams
- Do not publicly disclose vulnerabilities before patches are available

### Academic Integrity
- If using this project for coursework, ensure it complies with your institution's policies
- Cite this work appropriately in any publications or presentations
- Do not plagiarize the concepts or code

## Technical Safeguards

This project includes multiple safeguards:

1. **Scoped Packages**: All malicious packages use `@lab/` scope
2. **Private Registry**: Verdaccio runs locally on localhost:4873
3. **Benign Payloads**: Code only creates files prefixed with `LAB_COMPROMISED`
4. **No External Network**: Malicious code does not make real network requests
5. **Clear Labeling**: All malicious artifacts are clearly marked

## Environment Setup

### Recommended Lab Environment

- **VM or Container**: Ubuntu/Debian Linux in VirtualBox or Docker
- **Network**: Host-only or isolated network (no internet access required for the attack simulation)
- **Snapshots**: Take VM snapshots before running exercises
- **Monitoring**: Enable logging to observe attack behavior

### Cleanup After Lab

```bash
# Stop and remove containers
docker-compose down -v

# Remove node_modules and lock files
find . -name "node_modules" -type d -exec rm -rf {} +
find . -name "package-lock.json" -delete

# Remove evidence and artifacts
rm -rf evidence/* LAB_COMPROMISED.txt

# Reset Git repository
git clean -fdx
```

## Educational Use

This project is designed to teach:

- How supply-chain attacks work in modern software development
- The importance of Software Bill of Materials (SBOM)
- How to implement security scanning in CI/CD pipelines
- Detection and response procedures for dependency compromises
- Best practices for secure dependency management

## Questions or Concerns?

If you have questions about the ethical or legal implications of this project, consult:

- Your organization's security team
- Legal counsel
- Academic advisor (if student)
- Professional security community mentors

---

**By using this repository, you agree to use it responsibly and ethically in accordance with this disclaimer.**

Last Updated: 2025-11-01
