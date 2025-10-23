---
mode: 'agent'
description: Security review checklist using OWASP Top 10 and automated tools
---

# Security Review Prompt for Agent Mode

Review the selected code for security vulnerabilities and potential risks. Use the OWASP Top 10 as a baseline for your analysis, and leverage automated security tools available in agent mode.

## Agent Workflow for Security Review

### Phase 1: Automated Security Scanning
Use agent-specific security tools to identify vulnerabilities:

#### 1. CodeQL Security Scanning
**MUST use for all code changes:**
```
Call codeql_checker tool after code changes to discover vulnerabilities
Review all alerts discovered
Fix alerts that require only localized changes
Document any remaining vulnerabilities
```

#### 2. Dependency Vulnerability Scanning
**MUST use before adding new dependencies:**
```
Call gh-advisory-database tool for ecosystems:
- npm (Node.js)
- pip (Python)
- maven (Java)
- go
- rubygems
- rust
- swift
- composer (PHP)
- nuget (.NET)

DO NOT call for unsupported ecosystems
```

#### 3. Terraform Security Scanning
```bash
# Run tfsec for Terraform security issues
tfsec . --format json

# Run checkov for additional checks
checkov -d . --framework terraform
```

### Phase 2: Manual Security Review
After automated scans, perform manual review using OWASP checklist

## Review Checklist

### 1. Broken Access Control
- [ ] Check for proper authorization on all endpoints/functions
- [ ] Verify access controls cannot be bypassed
- [ ] Ensure users cannot act outside their permissions

### 2. Cryptographic Failures
- [ ] Sensitive data encrypted in transit (HTTPS/TLS)
- [ ] Sensitive data encrypted at rest
- [ ] No hardcoded secrets, keys, or passwords
- [ ] Use of strong, modern cryptographic algorithms

### 3. Injection
- [ ] All user inputs are validated and sanitized
- [ ] Parameterized queries used for database access
- [ ] No OS command injection vulnerabilities
- [ ] LDAP, XML, and other injection vectors protected

### 4. Insecure Design
- [ ] Security requirements defined and implemented
- [ ] Threat modeling performed
- [ ] Defense in depth strategy applied
- [ ] Secure by default configuration

### 5. Security Misconfiguration
- [ ] No default credentials in use
- [ ] Error messages don't leak sensitive information
- [ ] Security headers properly configured
- [ ] Unnecessary features/services disabled

### 6. Vulnerable and Outdated Components
- [ ] All dependencies up to date
- [ ] No known vulnerabilities in dependencies
- [ ] Dependency versions pinned appropriately

### 7. Identification and Authentication Failures
- [ ] Strong password requirements enforced
- [ ] Multi-factor authentication supported
- [ ] Session management properly implemented
- [ ] Credential stuffing protections in place

### 8. Software and Data Integrity Failures
- [ ] Code integrity verified (signatures, checksums)
- [ ] CI/CD pipeline secured
- [ ] Serialization/deserialization vulnerabilities addressed
- [ ] Auto-update mechanisms secured

### 9. Security Logging and Monitoring Failures
- [ ] Security events logged appropriately
- [ ] Logs don't contain sensitive data
- [ ] Monitoring and alerting configured
- [ ] Audit trail maintained

### 10. Server-Side Request Forgery (SSRF)
- [ ] URLs validated before making requests
- [ ] Allowlist for remote resources
- [ ] Response validation implemented

## Language-Specific Considerations

### Python
Reference: [Python Style Guide](../../docs/python-style.md)
- Check for use of `eval()`, `exec()`, or `pickle` with untrusted input
- Verify proper use of secrets management
- Review Django/Flask security settings

### Java
Reference: [Java Style Guide](../../docs/java-style.md)
- Review serialization/deserialization code
- Check Spring Security configurations
- Verify proper exception handling doesn't leak info

### Terraform
Reference: [Terraform Conventions](../../docs/terraform-conventions.md)
- Ensure no hardcoded credentials in `.tf` files
- Verify sensitive outputs marked as sensitive
- Check for overly permissive security groups/firewall rules

## Output Format

Provide findings in this format:

**Severity**: Critical | High | Medium | Low
**Category**: [OWASP Category]
**Location**: [File:Line or Function Name]
**Issue**: [Description of the vulnerability]
**Recommendation**: [How to fix it]
**References**: [Links to relevant documentation]

## Agent-Specific Security Commands

### Python Security Review
```bash
# Check for known vulnerabilities in dependencies
pip-audit

# Scan with bandit for Python security issues
bandit -r src/ -f json

# Check dependency versions
pip list --outdated
```

### Java Security Review
```bash
# Run OWASP dependency check
./gradlew dependencyCheckAnalyze

# SpotBugs with security rules
./gradlew spotbugsMain

# Check for outdated dependencies
./gradlew dependencyUpdates
```

### Terraform Security Review
```bash
# Security scanning with tfsec
tfsec . --minimum-severity MEDIUM

# Checkov security scanning
checkov -d . --framework terraform --quiet

# Validate configuration
terraform validate
```

## Security Review Progress Reporting

### Initial Assessment
```markdown
## Security Review: [Component/Module Name]

### Automated Scans
- [x] CodeQL scan initiated
- [ ] CodeQL alerts reviewed
- [ ] Dependency vulnerabilities checked
- [ ] Language-specific security tools run
- [ ] Manual OWASP review completed

### Findings Summary
- Critical issues: X
- High severity: X
- Medium severity: X
- Low severity: X

### Next Steps
Reviewing automated scan results
```

### Final Report
```markdown
## Security Review: [Component/Module Name]

### Scan Results
- [x] CodeQL scan completed
- [x] CodeQL alerts reviewed and addressed
- [x] Dependency vulnerabilities checked
- [x] Language-specific security tools run
- [x] Manual OWASP review completed

### Security Summary
**Critical Issues**: X found, X fixed, X remaining
**High Severity**: X found, X fixed, X remaining
**Medium Severity**: X found, X fixed, X remaining
**Low Severity**: X found, X fixed, X remaining

### Issues Fixed
1. [Issue description] - Fixed by [solution]
2. [Issue description] - Fixed by [solution]

### Remaining Issues
1. [Issue description] - [Reason not fixed / requires broader changes]

### Recommendations
- [Recommendation 1]
- [Recommendation 2]
```

## Agent Tips for Security Reviews

1. **Always run CodeQL**: Use codeql_checker tool after making code changes
2. **Check dependencies**: Use gh-advisory-database before adding new packages
3. **Scan incrementally**: Run security scans after each change batch
4. **Fix what you can**: Address localized security issues immediately
5. **Document limitations**: If you can't fix an issue, explain why
6. **Validate fixes**: Re-run security tools after fixing issues
7. **Report progress**: Update status after each security scan/fix cycle

## Security Fix Priority

When fixing security issues discovered by automated tools:

**Priority 1 (Fix Immediately)**:
- Hardcoded credentials
- SQL injection vulnerabilities
- Command injection vulnerabilities
- Exposed secrets in code
- Known high/critical CVEs in dependencies

**Priority 2 (Fix If Localized)**:
- Cross-site scripting (XSS) issues
- Path traversal vulnerabilities
- Insecure deserialization
- Weak cryptography
- Missing input validation

**Priority 3 (Document If Can't Fix)**:
- Issues requiring architectural changes
- Issues in third-party code
- False positives (explain why)
- Issues requiring product decisions
