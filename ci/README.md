# CI/CD Security Pipeline

This directory contains CI/CD configurations for supply-chain attack detection and prevention.

## GitHub Actions Workflow

The `.github/workflows/security-scan.yml` workflow includes:

### 1. Dependency Analysis
- Generates SBOM using Syft (CycloneDX and SPDX formats)
- Detects suspicious `@lab/*` packages
- Captures installation logs

### 2. Vulnerability Scanning
- Scans with Grype for known vulnerabilities
- Runs `npm audit` for npm-specific issues
- Fails on critical/high severity vulnerabilities

### 3. Policy Enforcement
- Checks for suspicious lifecycle scripts
- Verifies `package-lock.json` integrity
- Detects non-standard registries

### 4. Evidence Collection
- Collects compromise artifacts on failure
- Archives logs and evidence files
- Retains artifacts for forensic analysis

## Running Locally with `act`

You can run GitHub Actions locally using [act](https://github.com/nektos/act):

```bash
# Install act
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Run the workflow
act -W .github/workflows/security-scan.yml
```

## Alternative CI Systems

### GitLab CI

Create `.gitlab-ci.yml`:

```yaml
stages:
  - analyze
  - scan
  - enforce

sbom_generation:
  stage: analyze
  script:
    - syft dir:./app -o cyclonedx-json > sbom/sbom.json
    - grep -q "@lab/" sbom/sbom.json && exit 1 || true
  artifacts:
    paths:
      - sbom/

vulnerability_scan:
  stage: scan
  script:
    - grype dir:./app --fail-on critical
  artifacts:
    paths:
      - scans/
```

### Jenkins Pipeline

Create `Jenkinsfile`:

```groovy
pipeline {
    agent any
    
    stages {
        stage('SBOM Generation') {
            steps {
                sh 'syft dir:./app -o cyclonedx-json > sbom/sbom.json'
            }
        }
        
        stage('Vulnerability Scan') {
            steps {
                sh 'grype dir:./app --fail-on critical'
            }
        }
        
        stage('Policy Enforcement') {
            steps {
                sh '''
                    if grep -q "@lab/" sbom/sbom.json; then
                        echo "Suspicious package detected"
                        exit 1
                    fi
                '''
            }
        }
    }
}
```

## Security Gates

The CI pipeline implements these security gates:

1. **SBOM Analysis**: Fail if unknown packages are detected
2. **Vulnerability Threshold**: Fail on critical/high CVEs
3. **Script Detection**: Warn on lifecycle scripts
4. **Registry Check**: Fail if non-standard registries are used
5. **Lock File Verification**: Fail if `package-lock.json` is missing

## Evidence Collection

On detection of a compromise:
- `LAB_COMPROMISED.txt` is captured
- npm install logs are archived
- SBOM is preserved for forensic analysis
- All evidence is uploaded as CI artifacts

## Integration with SIEM

Logs can be forwarded to a SIEM for centralized monitoring:

```bash
# Example: Forward to ELK stack
- name: Forward logs to ELK
  run: |
    curl -X POST "https://elasticsearch:9200/ci-logs/_doc" \
      -H "Content-Type: application/json" \
      -d @evidence/compromise-log.json
```

## Best Practices

1. **Run on Every Commit**: Catch compromises early
2. **Block Merge**: Require passing security checks before merge
3. **Alert on Failure**: Notify security team immediately
4. **Retain Evidence**: Keep artifacts for incident response
5. **Review Regularly**: Update policies based on new threats

## References

- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [OWASP CI/CD Security](https://owasp.org/www-project-top-10-ci-cd-security-risks/)
- [Anchore Syft](https://github.com/anchore/syft)
- [Anchore Grype](https://github.com/anchore/grype)
