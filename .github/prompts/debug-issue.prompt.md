---
mode: 'agent'
description: Debug and troubleshoot issues systematically using agent mode
---

# Debug Issue Prompt for Agent Mode

Use this prompt when working with GitHub Copilot's Coding Agent to debug issues, troubleshoot failures, or investigate problems in the codebase.

## Systematic Debugging Approach

### Phase 1: Problem Identification
**Goal**: Clearly understand what's broken and how it manifests

#### Steps
1. **Read the error message**: Capture the exact error text, stack trace, and context
2. **Reproduce the issue**: Run the failing test, build, or command
3. **Identify the scope**: Is it one test? Multiple tests? Build failure? Runtime error?
4. **Check recent changes**: Review git log to see what changed recently
5. **Gather evidence**: Collect logs, error outputs, and relevant system state

#### Agent Commands
```bash
# Get recent changes
git --no-pager log --oneline -20

# Check current status
git --no-pager status

# View specific commit that may have introduced the issue
git --no-pager show <commit-hash>

# Run failing test with verbose output
pytest tests/test_file.py -v --tb=long
# or for Java
./gradlew test --tests ClassNameTest --info
```

### Phase 2: Root Cause Analysis
**Goal**: Understand WHY the issue is occurring

#### Debugging Strategies

**Strategy 1: Follow the Stack Trace**
- Start from the innermost call in the stack trace
- Work your way up to understand the call chain
- Identify which function/method is causing the actual failure

**Strategy 2: Binary Search**
- Identify when the code last worked (git bisect if needed)
- Compare working vs. broken versions
- Isolate the change that introduced the issue

**Strategy 3: Data Flow Analysis**
- Trace the path of data through the system
- Identify where data gets corrupted or unexpected
- Check input validation and transformation steps

**Strategy 4: Dependency Analysis**
- Check if dependencies changed recently
- Verify dependency versions are compatible
- Look for breaking changes in dependency release notes

#### Investigation Commands
```bash
# Compare two versions of a file
git --no-pager diff <commit1> <commit2> -- path/to/file

# Search for specific patterns in code
grep -r "pattern" src/

# Find usages of a function
grep -r "function_name" .

# Check dependency versions (Python)
pip list | grep package-name
# or (Java)
./gradlew dependencies | grep package-name
```

### Phase 3: Hypothesis Formation
**Goal**: Form testable hypotheses about what's wrong

#### Hypothesis Template
```
Hypothesis: [What you think is wrong]
Evidence: [What leads you to this conclusion]
Test: [How you will verify this hypothesis]
Expected: [What should happen if hypothesis is correct]
```

#### Example Hypotheses
1. **Null Pointer/None Value**
   - Hypothesis: A required value is None/null when it shouldn't be
   - Test: Add logging or assertion to check the value
   - Expected: Value is None at a specific point in execution

2. **Type Mismatch**
   - Hypothesis: Wrong type being passed to a function
   - Test: Check type at call site
   - Expected: Type doesn't match function signature

3. **Race Condition**
   - Hypothesis: Timing issue causing intermittent failures
   - Test: Run test multiple times, check for non-deterministic behavior
   - Expected: Test passes sometimes, fails other times

4. **Environment Issue**
   - Hypothesis: Test depends on specific environment state
   - Test: Check environment variables, file system state
   - Expected: Issue disappears in different environment

### Phase 4: Fix Implementation
**Goal**: Make minimal changes to resolve the issue

#### Fix Guidelines

**1. Verify First**
Before making changes:
- Confirm you understand the root cause
- Ensure the issue is not in external code
- Check if it's a known issue with existing fix

**2. Make Minimal Changes**
- Fix only what's broken
- Don't refactor working code
- Don't fix unrelated issues
- Keep changes focused and reviewable

**3. Test Your Fix**
- Verify the failing test now passes
- Run related tests to ensure no regressions
- Test edge cases that might still be broken
- Run full test suite if changes are significant

#### Language-Specific Debugging

##### Python Debugging
Reference: [Python Instructions](../instructions/python.instructions.md)

**Common issues:**
- Import errors: Check PYTHONPATH and module structure
- Type errors: Run mypy to catch type issues
- Indentation errors: Use consistent spaces (4 spaces per PEP 8)
- Missing dependencies: Check requirements.txt or pyproject.toml

**Debugging commands:**
```bash
# Run with verbose pytest output
pytest tests/test_file.py -vv -s

# Run with debugging on failure
pytest tests/test_file.py --pdb

# Check type hints
mypy src/ --show-error-codes

# Check import issues
python -c "import module_name; print(module_name.__file__)"
```

**Using pdb (Python debugger):**
```python
import pdb; pdb.set_trace()  # Add this line where you want to break

# Or use breakpoint() in Python 3.7+
breakpoint()
```

##### Java Debugging
Reference: [Java Instructions](../instructions/java.instructions.md)

**Common issues:**
- ClassNotFoundException: Check classpath and dependencies
- NullPointerException: Add null checks or use Optional
- ConcurrentModificationException: Check for unsafe concurrent access
- Version conflicts: Use dependencyInsight to check versions

**Debugging commands:**
```bash
# Run single test with full output
./gradlew test --tests ClassName.methodName --info

# Check dependency tree
./gradlew dependencies --configuration runtimeClasspath

# Check for dependency conflicts
./gradlew dependencyInsight --dependency package-name

# Run with JVM debug options
./gradlew test -Dorg.gradle.debug=true
```

**Adding debug logging:**
```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

private static final Logger logger = LoggerFactory.getLogger(ClassName.class);

logger.debug("Variable value: {}", variable);
```

##### Terraform Debugging
Reference: [Terraform Instructions](../instructions/terraform.instructions.md)

**Common issues:**
- State inconsistencies: State doesn't match actual resources
- Resource conflicts: Resource already exists
- Provider issues: Wrong provider version or configuration
- Dependency cycles: Circular dependencies in resources

**Debugging commands:**
```bash
# Validate configuration
terraform validate

# Plan with verbose output
terraform plan -out=tfplan

# Show state
terraform state list
terraform state show resource.name

# Check provider versions
terraform version

# Enable debug logging
export TF_LOG=DEBUG
terraform plan

# Disable debug logging
unset TF_LOG
```

### Phase 5: Verification
**Goal**: Confirm the fix works and doesn't break anything else

#### Verification Checklist
- [ ] Failing test/build now passes
- [ ] No new test failures introduced
- [ ] Linting passes
- [ ] Build succeeds
- [ ] Manual testing completed (if applicable)
- [ ] Edge cases tested
- [ ] Documentation updated (if needed)

#### Verification Commands
```bash
# Run full test suite
pytest tests/  # Python
./gradlew test  # Java
terraform validate && tflint  # Terraform

# Run linters
ruff check .  # Python
./gradlew spotlessCheck  # Java
terraform fmt -check -recursive  # Terraform

# Build the project
python -m build  # Python
./gradlew build  # Java
terraform plan  # Terraform
```

## Common Issue Patterns

### Pattern 1: Test Failures After Dependency Update

**Symptoms**: Tests fail after updating dependencies

**Investigation:**
1. Check what dependency changed: `git diff package.json` or equivalent
2. Review release notes for breaking changes
3. Look for deprecation warnings in test output

**Solution:**
- Update code to use new API
- Pin to older version if update not critical
- Add compatibility layer if supporting multiple versions

### Pattern 2: Intermittent Test Failures

**Symptoms**: Test passes sometimes, fails other times

**Investigation:**
1. Run test multiple times: `pytest tests/test.py --count=10`
2. Check for time-dependent logic
3. Look for shared state between tests
4. Check for race conditions in async code

**Solution:**
- Add proper test isolation
- Use fixed time in tests (mock time)
- Add proper locking/synchronization
- Make tests independent

### Pattern 3: Build Failures in CI Only

**Symptoms**: Build passes locally but fails in CI

**Investigation:**
1. Check CI environment differences (OS, versions)
2. Review CI logs for environment-specific errors
3. Check for missing environment variables
4. Look for file system differences (case sensitivity)

**Solution:**
- Match local environment to CI
- Add missing environment configuration
- Fix platform-specific code
- Update CI configuration

### Pattern 4: Import/Module Not Found

**Symptoms**: Module or class cannot be imported

**Investigation:**
1. Check file/module exists: `ls -la path/to/module`
2. Verify directory structure
3. Check for __init__.py files (Python)
4. Verify CLASSPATH (Java)

**Solution:**
- Add missing __init__.py files
- Fix import paths
- Update build configuration
- Check package structure

### Pattern 5: Type Errors

**Symptoms**: Type checker complains about type mismatches

**Investigation:**
1. Run type checker: `mypy` (Python) or check IDE
2. Trace the types through the call chain
3. Check function signatures

**Solution:**
- Add proper type hints
- Fix type mismatches
- Use type casting where appropriate
- Update type annotations

## Debugging Tools and Techniques

### Python Debugging Tools
- **pdb**: Built-in debugger
- **pytest**: Test framework with excellent error reporting
- **logging**: Add strategic logging statements
- **print debugging**: Sometimes the simplest approach works

### Java Debugging Tools
- **IntelliJ IDEA Debugger**: Full-featured IDE debugger
- **jdb**: Command-line debugger
- **Logging frameworks**: SLF4J, Log4j, Logback
- **JUnit**: Test framework with detailed assertions

### Terraform Debugging Tools
- **terraform console**: Interactive console for testing expressions
- **terraform graph**: Visualize resource dependencies
- **TF_LOG**: Environment variable for debug logging
- **terraform state**: Inspect and manipulate state

## Agent-Specific Debugging Tips

### Efficient Tool Usage

**Read error logs strategically:**
```bash
# For large logs, use tail to see recent errors
tail -n 100 logfile.txt

# Use grep to filter relevant errors
grep -i "error\|exception\|failed" logfile.txt

# Combine commands for efficiency
tail -n 100 logfile.txt | grep -i "error"
```

**Use bash sessions for interactive debugging:**
```bash
# Start an interactive session
mode: "async", sessionId: "debug"

# Then send commands
pytest tests/test.py -v
# analyze output
pytest tests/test.py --pdb
# etc.
```

**Parallel investigation:**
When you need to check multiple files or run multiple commands, do them in parallel:
```
- view src/file1.py
- view src/file2.py
- view tests/test_file.py
All in the same tool call
```

### Progress Reporting During Debugging

**Initial Investigation Report:**
```markdown
## Debugging: [Issue Description]

### Issue Identified
- [x] Reproduced the failure
- [x] Captured error message
- [x] Reviewed recent changes
- [ ] Root cause identified
- [ ] Fix implemented
- [ ] Fix verified

### Current Status
Error: [Error message]
Location: [File:Line]
Context: [What was happening when error occurred]

### Investigation Plan
1. Check [specific area]
2. Review [specific code]
3. Test hypothesis: [hypothesis]
```

**Post-Fix Report:**
```markdown
## Debugging: [Issue Description]

### Issue Resolution
- [x] Reproduced the failure
- [x] Captured error message
- [x] Reviewed recent changes
- [x] Root cause identified
- [x] Fix implemented
- [x] Fix verified

### Root Cause
[Description of what was wrong]

### Fix Applied
[Description of what was changed]

### Verification
- All tests passing
- No new issues introduced
- Build successful
```

## Anti-Patterns to Avoid

❌ **Random Changes**: Don't make changes without understanding the problem
❌ **Over-fixing**: Don't fix more than what's broken
❌ **Skipping Tests**: Don't skip running tests after a fix
❌ **Ignoring Warnings**: Don't ignore deprecation warnings or linter warnings
❌ **Cargo Cult Debugging**: Don't copy solutions without understanding them
❌ **Analysis Paralysis**: Don't over-analyze; sometimes you need to test hypotheses

✅ **Systematic Approach**: Follow a structured debugging process
✅ **Minimal Changes**: Make the smallest fix that solves the problem
✅ **Verify Everything**: Test your hypotheses and verify fixes
✅ **Document Findings**: Keep notes on what you learn
✅ **Learn Patterns**: Recognize common issues and their solutions
✅ **Ask for Help**: If stuck, report what you've tried and ask for guidance

## Debugging Checklist

```markdown
### Initial Assessment
- [ ] Error message captured
- [ ] Issue reproduced locally
- [ ] Recent changes reviewed
- [ ] Baseline tests run

### Investigation
- [ ] Root cause hypothesis formed
- [ ] Evidence gathered
- [ ] Hypothesis tested
- [ ] Root cause confirmed

### Fix
- [ ] Minimal fix implemented
- [ ] Fix tested locally
- [ ] No new failures introduced
- [ ] Edge cases considered

### Verification
- [ ] All tests passing
- [ ] Linting clean
- [ ] Build successful
- [ ] Manual testing done (if applicable)
- [ ] Progress reported
```

## Remember

Debugging is a systematic process of elimination. Take time to understand the problem before attempting a fix. Use the scientific method: form hypotheses, test them, and iterate. Always verify your fixes thoroughly before reporting progress.
