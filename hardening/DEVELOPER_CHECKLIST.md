# Developer Security Checklist

## Supply-Chain Security Best Practices

Use this checklist to protect your projects from supply-chain attacks.

---

## ✅ Dependency Management

### Before Adding Dependencies

- [ ] **Research the package**: Check GitHub stars, download count, and maintainer activity
- [ ] **Review the code**: Look at the source code before installing
- [ ] **Check for typosquatting**: Verify exact package name spelling
- [ ] **Assess necessity**: Do you really need this dependency?
- [ ] **Consider alternatives**: Are there better-maintained alternatives?

### When Installing

- [ ] **Use lock files**: Always commit `package-lock.json` (npm) or `yarn.lock`
- [ ] **Pin versions**: Use exact versions (`1.2.3`) instead of ranges (`^1.2.3`)
- [ ] **Review lifecycle scripts**: Check `preinstall`, `postinstall`, etc.
- [ ] **Use clean installs**: Prefer `npm ci` over `npm install` in CI/CD
- [ ] **Audit on install**: Run `npm audit` after adding packages

### Regular Maintenance

- [ ] **Update regularly**: Keep dependencies up to date
- [ ] **Audit frequently**: Run `npm audit` weekly
- [ ] **Remove unused packages**: Clean up `package.json` regularly
- [ ] **Monitor advisories**: Subscribe to security advisories for critical packages
- [ ] **Test updates**: Test dependency updates in staging before production

---

## ✅ SBOM (Software Bill of Materials)

- [ ] **Generate SBOMs**: Create SBOM for every release
- [ ] **Use standard formats**: CycloneDX or SPDX
- [ ] **Store with artifacts**: Include SBOM in release packages
- [ ] **Review before release**: Check SBOM for unexpected packages
- [ ] **Sign SBOMs**: Cryptographically sign for authenticity

**Commands**:
```bash
# Generate SBOM
syft dir:. -o cyclonedx-json > sbom.json

# Review SBOM
cat sbom.json | jq '.components[] | {name, version}'
```

---

## ✅ Vulnerability Scanning

- [ ] **Scan on every commit**: Integrate scanning into CI/CD
- [ ] **Use multiple tools**: Grype, npm audit, Snyk, etc.
- [ ] **Set severity thresholds**: Fail builds on critical/high CVEs
- [ ] **Track remediation**: Document and track vulnerability fixes
- [ ] **Test fixes**: Verify patches don't break functionality

**Commands**:
```bash
# Scan with Grype
grype dir:. --fail-on critical

# npm audit
npm audit --audit-level=moderate
```

---

## ✅ Package Registry Security

- [ ] **Use official registries**: npm, PyPI, Maven Central
- [ ] **Configure scoped packages**: Use private registries for internal packages
- [ ] **Verify package sources**: Check package origins in lock files
- [ ] **Use package signing**: Verify npm package signatures when available
- [ ] **Implement allow/deny lists**: Block known-bad packages

**npm configuration**:
```bash
# Set registry for scoped packages
npm config set @company:registry https://private-registry.company.com

# Always use HTTPS
npm config set registry https://registry.npmjs.org/
```

---

## ✅ CI/CD Pipeline Security

- [ ] **Implement security gates**: Fail builds on policy violations
- [ ] **Isolate build environments**: Use containers or VMs
- [ ] **Minimize permissions**: Use least privilege for build processes
- [ ] **Secure secrets**: Use secret management (Vault, AWS Secrets Manager)
- [ ] **Audit CI logs**: Monitor for suspicious activity
- [ ] **Verify lock files**: Ensure lock files match package.json

**GitHub Actions example**:
```yaml
- name: Security gate
  run: |
    npm audit --audit-level=high
    syft dir:. -o cyclonedx-json > sbom.json
    grype dir:. --fail-on critical
```

---

## ✅ Code Review

- [ ] **Review package.json changes**: Scrutinize new dependencies in PRs
- [ ] **Check for lifecycle scripts**: Review preinstall, postinstall scripts
- [ ] **Inspect lock file diffs**: Look for unexpected registry changes
- [ ] **Verify version changes**: Ensure version bumps are intentional
- [ ] **Use automated checks**: Dependabot, Renovate, etc.

---

## ✅ Incident Response

### Detection

- [ ] **Monitor for indicators**: LAB_COMPROMISED files, unexpected network calls
- [ ] **Review runtime logs**: Check for suspicious module loads
- [ ] **Analyze SBOM changes**: Compare SBOMs across versions
- [ ] **Check file integrity**: Verify critical files haven't been modified

### Response

- [ ] **Isolate affected systems**: Stop deployments immediately
- [ ] **Collect evidence**: Save logs, SBOMs, and artifacts
- [ ] **Identify malicious package**: Review SBOM and dependencies
- [ ] **Remove compromise**: Delete malicious packages, rebuild clean
- [ ] **Rotate credentials**: Change all API keys and secrets
- [ ] **Notify stakeholders**: Inform security team and users
- [ ] **Document incident**: Write post-mortem and lessons learned

### Recovery

- [ ] **Clean rebuild**: Fresh install from clean sources
- [ ] **Verify integrity**: Compare checksums and SBOMs
- [ ] **Update defenses**: Add new detections based on attack
- [ ] **Test thoroughly**: Full regression testing before deploy
- [ ] **Monitor closely**: Enhanced monitoring for recurrence

---

## ✅ Runtime Protection

- [ ] **Use integrity monitoring**: Detect file modifications at runtime
- [ ] **Monitor module loading**: Hook `require()` to detect malicious imports
- [ ] **Sandbox dependencies**: Isolate untrusted code
- [ ] **Implement CSP**: Content Security Policy for web apps
- [ ] **Use subresource integrity**: For CDN resources

**Example**: Use the runtime monitor from this lab
```bash
node hardening/runtime-monitor.js &
node app/server.js
```

---

## ✅ Developer Environment

- [ ] **Use separate environments**: Dev, staging, prod
- [ ] **Don't run untrusted code**: Review before executing
- [ ] **Keep tools updated**: npm, Node.js, security scanners
- [ ] **Use virtual environments**: Containers or VMs for testing
- [ ] **Back up regularly**: Git commits, system backups

---

## ✅ Team Practices

- [ ] **Security training**: Educate team on supply-chain risks
- [ ] **Establish policies**: Document security requirements
- [ ] **Regular audits**: Periodic security reviews
- [ ] **Share knowledge**: Document and share lessons learned
- [ ] **Celebrate security**: Recognize good security practices

---

## ✅ Tools & Resources

### Essential Tools

- **Syft**: SBOM generation - https://github.com/anchore/syft
- **Grype**: Vulnerability scanning - https://github.com/anchore/grype
- **npm audit**: Built-in npm security auditing
- **Dependabot**: Automated dependency updates (GitHub)
- **Snyk**: Commercial vulnerability scanning - https://snyk.io
- **Socket Security**: Supply-chain threat detection - https://socket.dev

### Learning Resources

- OWASP Top 10 CI/CD Risks: https://owasp.org/www-project-top-10-ci-cd-security-risks/
- SLSA Framework: https://slsa.dev/
- CISA Software Security: https://www.cisa.gov/sbom
- npm Security Best Practices: https://docs.npmjs.com/misc/security

---

## 🎯 Quick Daily Checklist

**Before you commit**:
1. [ ] `npm audit` - No critical vulnerabilities?
2. [ ] Review `package.json` changes
3. [ ] Check lock file diffs
4. [ ] Run tests
5. [ ] Commit with descriptive message

**Weekly**:
1. [ ] Update dependencies: `npm update`
2. [ ] Full security scan: `./scripts/scan-dependencies.sh`
3. [ ] Review SBOM: `./scripts/generate-sbom.sh`
4. [ ] Check security advisories

**Monthly**:
1. [ ] Dependency audit: Remove unused packages
2. [ ] Review CI/CD security
3. [ ] Update security tools
4. [ ] Team security training

---

**Remember**: Security is a continuous process, not a one-time task!
