---
mode: 'ask'
description: Security review checklist using OWASP Top 10
---

# Security Review Prompt

Review the selected code for security vulnerabilities and potential risks. Use the OWASP Top 10 as a baseline for your analysis.

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
