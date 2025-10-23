# GitHub Copilot Agent Mode Guide

This guide provides comprehensive information on using GitHub Copilot's Coding Agent with the archetype standards in this repository.

## What is Agent Mode?

Agent Mode (also known as Coding Agent) is GitHub Copilot's autonomous code execution capability that can:
- Read and understand codebases
- Make code changes directly
- Run tests and validation
- Execute commands and scripts
- Commit changes with proper tracking
- Perform security scans
- Report progress systematically

Unlike Chat Mode (interactive assistance), Agent Mode operates autonomously to complete tasks with minimal user intervention.

## Key Differences: Agent Mode vs Chat Mode

### Chat Mode (Interactive)
- **Model**: Conversation-based assistance
- **User Role**: Driver - user makes decisions and applies changes
- **Copilot Role**: Advisor - provides suggestions and guidance
- **Changes**: User manually applies suggested changes
- **Testing**: User runs tests manually
- **Best For**: Learning, exploration, planning, guidance
- **Example**: "How should I implement authentication?"

### Agent Mode (Autonomous)
- **Model**: Task-based execution
- **User Role**: Delegator - defines task and reviews results
- **Copilot Role**: Executor - implements and validates changes
- **Changes**: Agent makes changes directly using tools
- **Testing**: Agent runs tests automatically
- **Best For**: Implementation, debugging, refactoring, fixing
- **Example**: "Implement JWT authentication with tests"

## Agent Mode Tools

The agent has access to these tools:

### Code Manipulation Tools
- **view** - Read files and directories
- **str_replace** - Make surgical changes to files
- **create** - Create new files
- **bash** - Execute commands and scripts

### Repository Tools
- **report_progress** - Commit changes and update PR
- **git commands** (via bash) - Inspect repository state

### Security Tools
- **codeql_checker** - Scan for security vulnerabilities (MANDATORY for code changes)
- **gh-advisory-database** - Check dependencies for CVEs (MANDATORY before adding deps)

### Search Tools (available in chat modes)
- **search** - Search across GitHub
- **usages** - Find code usages
- **githubRepo** - Access repository information

## Using Agent Mode with Archetype Standards

### 1. Feature Implementation

**Scenario**: Implement a new feature with proper testing

**Agent Prompt**: Reference `implement-feature.prompt.md`

**Workflow**:
```markdown
1. Agent reads issue/PR description
2. Explores codebase (parallel file reading)
3. Creates initial plan and reports progress
4. Implements changes incrementally
5. Adds/updates tests for changes
6. Runs linters and tests
7. Fixes any issues found
8. Runs security scans (CodeQL)
9. Reports progress after validation
10. Commits changes with clear message
```

**Example Task**:
> "Implement a user profile API endpoint with proper validation, authentication, and tests. Follow Python archetype standards."

**Expected Outcome**:
- New API endpoint implemented
- Input validation added
- Authentication checks in place
- Unit and integration tests added
- All tests passing
- Linting clean
- Security scans passed
- Documentation updated
- Progress reported with commits

### 2. Debugging and Fixing

**Scenario**: Debug and fix a failing test or bug

**Agent Prompt**: Reference `debug-issue.prompt.md`

**Workflow**:
```markdown
1. Agent reproduces the issue
2. Analyzes error messages and stack traces
3. Forms hypotheses about root cause
4. Tests hypotheses systematically
5. Identifies the actual cause
6. Makes minimal fix
7. Validates fix with tests
8. Checks for regressions
9. Reports findings and solution
```

**Example Task**:
> "The test test_user_login is failing with a 401 error. Debug and fix the issue."

**Expected Outcome**:
- Issue reproduced and analyzed
- Root cause identified (e.g., incorrect token validation)
- Minimal fix applied
- Test now passing
- No regressions introduced
- Fix explanation documented

### 3. Code Refactoring

**Scenario**: Refactor code to improve quality while maintaining behavior

**Agent Prompt**: Reference `refactor-code.prompt.md`

**Workflow**:
```markdown
1. Agent analyzes code to refactor
2. Ensures comprehensive tests exist
3. Runs tests to establish baseline
4. Makes incremental refactoring changes
5. Tests after each change
6. Validates behavior unchanged
7. Updates documentation
8. Reports progress with each validated step
```

**Example Task**:
> "Refactor the UserService class to reduce complexity and improve readability. Maintain all existing functionality."

**Expected Outcome**:
- Code structure improved
- Complexity reduced
- All tests still passing
- Behavior unchanged
- Documentation updated
- Code coverage maintained or improved

### 4. Security Review with Fixes

**Scenario**: Perform security review and fix issues

**Agent Prompt**: Reference `review-security.prompt.md`

**Workflow**:
```markdown
1. Agent runs automated security scans
   - CodeQL (codeql_checker)
   - Dependency scanner (gh-advisory-database)
   - Language-specific tools (bandit, tfsec, etc.)
2. Analyzes findings
3. Performs manual OWASP review
4. Fixes critical/high severity issues
5. Documents issues requiring broader changes
6. Re-runs scanners to verify fixes
7. Reports comprehensive security summary
```

**Example Task**:
> "Perform a security review of the authentication module and fix any critical issues."

**Expected Outcome**:
- CodeQL scan completed
- Dependency vulnerabilities checked
- Critical issues fixed (SQL injection, hardcoded secrets, etc.)
- Medium/low issues documented
- Security tests added
- Comprehensive security report

### 5. Test Generation

**Scenario**: Generate comprehensive tests for existing code

**Agent Prompt**: Reference `generate-tests.prompt.md`

**Workflow**:
```markdown
1. Agent analyzes code to test
2. Identifies test scenarios (happy path, edge cases, errors)
3. Generates tests following language patterns
4. Runs tests to ensure they pass
5. Checks test coverage
6. Adds missing test cases
7. Reports test summary
```

**Example Task**:
> "Generate comprehensive unit tests for the PaymentProcessor class with >80% coverage."

**Expected Outcome**:
- Test file created
- Happy path tests added
- Edge case tests added
- Error handling tests added
- All tests passing
- Coverage >80%
- Test summary documented

### 6. Migration Execution

**Scenario**: Execute a planned migration incrementally

**Agent Prompt**: Reference `plan-migration.prompt.md`

**Workflow**:
```markdown
1. Agent analyzes current and target states
2. Creates detailed migration plan
3. Executes migration in phases
4. Validates after each phase
5. Keeps old code until migration complete
6. Tests continuously
7. Reports progress with metrics
8. Removes old code after full validation
```

**Example Task**:
> "Migrate from requests library to httpx in the API client. Maintain backward compatibility during migration."

**Expected Outcome**:
- Migration plan documented
- Parallel implementation created
- Gradual cutover executed
- All tests passing
- No functionality lost
- Old code removed
- Documentation updated

## Best Practices for Agent Mode

### Do's ✅

1. **Provide Clear Context**
   - Link to relevant documentation
   - Specify requirements clearly
   - Mention constraints or preferences
   - Reference archetype standards

2. **Trust but Verify**
   - Review agent's plan before execution
   - Check progress reports regularly
   - Validate final results
   - Review commits made

3. **Use Appropriate Prompts**
   - Reference specific prompt files for tasks
   - Follow language-specific guidelines
   - Use security tools for code changes
   - Report progress frequently

4. **Leverage Automation**
   - Let agent run tests and linters
   - Use parallel operations
   - Trust automated security scans
   - Validate incrementally

5. **Document Everything**
   - Review progress reports
   - Check commit messages
   - Verify documentation updates
   - Maintain security summaries

### Don'ts ❌

1. **Don't Skip Validation**
   - Never skip testing
   - Don't ignore linter warnings
   - Always run security scans
   - Validate before finalizing

2. **Don't Over-Specify**
   - Avoid micromanaging the agent
   - Don't specify implementation details unnecessarily
   - Trust the agent's expertise
   - Focus on requirements, not how

3. **Don't Ignore Security**
   - Never skip CodeQL scans
   - Always check dependencies
   - Don't ignore security warnings
   - Fix critical issues immediately

4. **Don't Mix Tasks**
   - Don't combine unrelated changes
   - Keep refactoring separate from features
   - Don't fix unrelated issues
   - Stay focused on the task

5. **Don't Rush**
   - Don't skip planning phase
   - Allow time for validation
   - Don't ignore test failures
   - Review changes thoroughly

## Language-Specific Agent Mode Usage

### Python Projects

**Setup Validation**:
```bash
# Agent checks these automatically
python --version  # Should be >=3.12
pip list          # Check dependencies
pytest --version  # Verify test framework
```

**Agent Commands**:
```bash
# Testing
pytest tests/ -v --cov=src

# Linting
ruff check src/
black --check src/
mypy src/

# Security
bandit -r src/
pip-audit
```

**Best Practices**:
- Use type hints everywhere
- Follow PEP 8 style
- Test with pytest
- Use dataclasses for data structures
- Validate with ruff, black, mypy

### Java Projects

**Setup Validation**:
```bash
# Agent checks these automatically
java -version      # Should be >=17
./gradlew --version
./gradlew tasks    # Check available tasks
```

**Agent Commands**:
```bash
# Testing
./gradlew test
./gradlew jacocoTestReport

# Linting & Formatting
./gradlew spotlessCheck
./gradlew spotlessApply

# Security
./gradlew dependencyCheckAnalyze
./gradlew spotbugsMain
```

**Best Practices**:
- Use Java 17+ features (records, sealed classes)
- Follow Google Java Style
- Test with JUnit 5
- Use AssertJ for assertions
- Build with Gradle (preferred)

### Terraform Projects

**Setup Validation**:
```bash
# Agent checks these automatically
terraform version  # Should be >=1.6.0
terraform providers
tflint --version
```

**Agent Commands**:
```bash
# Validation
terraform validate
terraform fmt -check -recursive

# Linting
tflint

# Security
tfsec .
checkov -d .

# Planning
terraform plan -out=tfplan
```

**Best Practices**:
- Pin provider versions
- Use modules for reusability
- Validate and format code
- Scan for security issues
- Use remote state with locking

## Security with Agent Mode

### Mandatory Security Checks

#### 1. CodeQL Scanner (codeql_checker)
**When**: After ANY code changes
**How**: Agent automatically calls `codeql_checker` tool
**Purpose**: Discover security vulnerabilities in code

**Workflow**:
```markdown
1. Agent makes code changes
2. Agent calls codeql_checker
3. Reviews all alerts discovered
4. Fixes critical/high issues immediately
5. Documents remaining issues
6. Re-runs to verify fixes
```

#### 2. Dependency Scanner (gh-advisory-database)
**When**: Before adding ANY new dependency
**How**: Agent calls `gh-advisory-database` with package info
**Purpose**: Check for known CVEs in dependencies

**Supported Ecosystems**:
- npm (Node.js)
- pip (Python)
- maven (Java)
- go
- rubygems (Ruby)
- rust
- swift
- composer (PHP)
- nuget (.NET)

**Workflow**:
```markdown
1. Agent identifies dependency to add
2. Calls gh-advisory-database with name/version/ecosystem
3. Reviews any CVEs found
4. Chooses secure version or alternative
5. Documents decision
```

#### 3. Language-Specific Scanners
**When**: During security reviews
**How**: Agent runs via bash commands
**Purpose**: Find language-specific security issues

**Tools by Language**:
- **Python**: bandit, pip-audit, safety
- **Java**: spotbugs, OWASP dependency-check
- **Terraform**: tfsec, checkov

### Security Fix Priority

Agent follows this priority for security fixes:

**Priority 1: Fix Immediately** 🔴
- Hardcoded credentials
- SQL injection
- Command injection
- Known critical CVEs
- Exposed secrets

**Priority 2: Fix If Localized** 🟡
- XSS vulnerabilities
- Path traversal
- Weak cryptography
- Missing validation
- Known high CVEs

**Priority 3: Document If Can't Fix** 🟢
- Architectural issues
- Third-party code issues
- False positives
- Issues requiring product decisions

### Security Reporting

Agent provides comprehensive security reports:

```markdown
## Security Summary

**Scans Completed**:
- CodeQL: ✅ X issues found
- Dependencies: ✅ X vulnerabilities found
- Bandit/tfsec: ✅ X issues found

**Issues Fixed**: X
- SQL injection in user_query (Critical)
- Hardcoded AWS key removed (Critical)
- Missing auth check added (High)

**Issues Documented**: X
- Legacy auth system (requires architectural change)
- Third-party lib vulnerability (awaiting update)

**Recommendations**:
- Implement automated security scanning in CI/CD
- Regular dependency audits
- Security training for team
```

## Progress Reporting with Agent Mode

### Why Report Progress?

- **Transparency**: Keep stakeholders informed
- **Traceability**: Create clear commit history
- **Validation**: Checkpoint after validated changes
- **Recovery**: Easy to rollback if needed
- **Documentation**: Automatic changelog

### When to Report Progress

- ✅ After creating initial plan
- ✅ After each validated code change
- ✅ After fixing batch of related issues
- ✅ After completing phase of work
- ✅ Before switching focus areas
- ✅ After security scans and fixes
- ✅ Upon task completion

### Progress Report Template

```markdown
## [Task Name]

### Completed
- [x] Task 1: Description
- [x] Task 2: Description

### In Progress
- [ ] Task 3: Description (X% complete)

### Blocked
- [ ] Task 4: Description (Blocked by: reason)

### Metrics
- Files changed: X
- Tests added: X
- Tests passing: X/X
- Coverage: XX%
- Security scans: ✅ Passed

### Next Steps
Brief description of what comes next
```

## Troubleshooting Agent Mode

### Common Issues

#### Agent Not Making Changes
**Symptoms**: Agent provides suggestions but doesn't apply them
**Cause**: Not in agent mode or insufficient permissions
**Solution**: Ensure using Coding Agent, not just Chat

#### Tests Failing After Changes
**Symptoms**: Agent makes changes but tests fail
**Cause**: Logic error or incomplete implementation
**Solution**: Agent should debug using `debug-issue.prompt.md`

#### Security Scans Not Running
**Symptoms**: No security scan results in reports
**Cause**: Tools not called or not available
**Solution**: Ensure codeql_checker and language tools are used

#### Changes Not Committed
**Symptoms**: Changes made but not appearing in PR
**Cause**: report_progress not called
**Solution**: Agent must call report_progress to commit

### Getting Help

If agent encounters issues:
1. Review error messages carefully
2. Check if it's a known limitation
3. Provide additional context
4. Break down task into smaller steps
5. Review and adjust approach

## Advanced Agent Mode Techniques

### Parallel Operations

Agent can perform multiple independent operations simultaneously:

**Example: Reading Multiple Files**
```
view src/file1.py
view src/file2.py
view src/file3.py
(All in same tool call)
```

**Example: Editing Multiple Files**
```
str_replace in file1.py (change A)
str_replace in file2.py (change B)
str_replace in file3.py (change C)
(All in same response)
```

### Incremental Validation

Agent validates changes incrementally:

```markdown
1. Make change A → Run tests → ✅ Pass
2. Make change B → Run tests → ✅ Pass
3. Make change C → Run tests → ✅ Pass
4. Run full suite → ✅ Pass
5. Report progress
```

### Command Chains

Agent uses command chains for efficiency:

```bash
# Instead of separate commands:
git status
git diff

# Use chain:
git --no-pager status && git --no-pager diff
```

### Bash Sessions

For long-running operations:

```bash
# Synchronous with timeout
mode: "sync", timeout: 300
command: "npm run build && npm test"

# Async for interactive tools
mode: "async", sessionId: "build"
command: "tsc --watch"
```

## Real-World Examples

### Example 1: API Endpoint Implementation

**Task**: "Add a GET /api/users/:id endpoint with authentication"

**Agent Actions**:
1. ✅ Reads existing API code and patterns
2. ✅ Creates endpoint implementation
3. ✅ Adds authentication middleware
4. ✅ Adds input validation
5. ✅ Generates unit tests
6. ✅ Generates integration tests
7. ✅ Updates API documentation
8. ✅ Runs all tests
9. ✅ Runs security scan
10. ✅ Reports progress

**Result**: Complete, tested, secure endpoint

### Example 2: Security Vulnerability Fix

**Task**: "Fix SQL injection in user search"

**Agent Actions**:
1. ✅ Runs CodeQL scan
2. ✅ Identifies SQL injection vulnerability
3. ✅ Changes to parameterized query
4. ✅ Adds input validation
5. ✅ Adds security test
6. ✅ Verifies all tests pass
7. ✅ Re-runs CodeQL
8. ✅ Confirms vulnerability fixed
9. ✅ Reports security summary

**Result**: Vulnerability fixed and verified

### Example 3: Test Coverage Improvement

**Task**: "Increase test coverage to >80%"

**Agent Actions**:
1. ✅ Checks current coverage: 65%
2. ✅ Identifies untested code
3. ✅ Generates tests for untested functions
4. ✅ Adds edge case tests
5. ✅ Adds error handling tests
6. ✅ Runs test suite
7. ✅ Verifies coverage: 85%
8. ✅ Reports test summary

**Result**: Coverage goal achieved

## Resources

### Prompt Files Reference
- [implement-feature.prompt.md](../.github/prompts/implement-feature.prompt.md)
- [debug-issue.prompt.md](../.github/prompts/debug-issue.prompt.md)
- [refactor-code.prompt.md](../.github/prompts/refactor-code.prompt.md)
- [generate-tests.prompt.md](../.github/prompts/generate-tests.prompt.md)
- [review-security.prompt.md](../.github/prompts/review-security.prompt.md)
- [plan-migration.prompt.md](../.github/prompts/plan-migration.prompt.md)

### Chat Modes Reference
- [planner.chatmode.md](../.github/chatmodes/planner.chatmode.md)
- [reviewer.chatmode.md](../.github/chatmodes/reviewer.chatmode.md)

### Language Standards
- [Python Instructions](../.github/instructions/python.instructions.md)
- [Java Instructions](../.github/instructions/java.instructions.md)
- [Terraform Instructions](../.github/instructions/terraform.instructions.md)

### Extended Guides
- [Python Style Guide](./python-style.md)
- [Java Style Guide](./java-style.md)
- [Terraform Conventions](./terraform-conventions.md)

## Conclusion

Agent Mode represents a significant evolution in AI-assisted development. By following the guidelines in this document and using the enhanced prompt files, you can leverage the agent's autonomous capabilities while maintaining high code quality, security, and maintainability standards.

Remember:
- 🎯 Be clear about requirements
- 🔒 Security is mandatory, not optional
- ✅ Validation at every step
- 📊 Report progress frequently
- 🔄 Iterate and improve

Happy coding with GitHub Copilot Agent Mode! 🚀
