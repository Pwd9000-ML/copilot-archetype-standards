---
mode: 'agent'
description: Implement a feature or fix with minimal changes using agent mode
---

# Implement Feature Prompt for Agent Mode

Use this prompt when working with GitHub Copilot's Coding Agent to implement features, fix bugs, or make changes to the codebase.

## Agent Workflow Guidelines

### 1. Understanding Phase
- **Read thoroughly**: Review all related files, issues, and documentation
- **Explore efficiently**: Use parallel tool calls to read multiple files simultaneously
- **Build context**: Run existing tests, lints, and builds to understand the current state
- **Never skip**: Always run tests/builds BEFORE making changes to establish baseline

### 2. Planning Phase
- **Report early**: Use `report_progress` immediately with your implementation plan
- **Be specific**: Create a detailed checklist of tasks to complete
- **Think minimal**: Plan the smallest possible changes to achieve the goal
- **Consider testing**: Plan what tests to add/modify alongside code changes

### 3. Implementation Phase
- **Make surgical changes**: Modify only what's necessary
- **Use str_replace carefully**: Ensure old_str matches EXACTLY including whitespace
- **Parallel edits**: When editing multiple independent files, make changes in parallel
- **Test incrementally**: Run tests after each significant change
- **Follow standards**: Apply language-specific guidelines from instruction files

### 4. Validation Phase
- **Lint your changes**: Run linters specific to the language/framework
- **Build the code**: Ensure the project builds successfully
- **Run tests**: Execute relevant test suites
- **Manual verification**: For UI/CLI changes, run and verify the output
- **Security check**: Run security scanners if making security-related changes

### 5. Completion Phase
- **Report frequently**: Use `report_progress` after each validated change
- **Review commits**: Check what was committed using git status/diff
- **Update documentation**: Modify docs if behavior changed
- **Clean artifacts**: Use .gitignore to exclude build artifacts and dependencies

## Language-Specific Implementation Guidelines

### Python Projects
Reference: [Python Instructions](../instructions/python.instructions.md)

**Agent-specific tips:**
- Run `ruff check .` for linting
- Run `black --check .` for formatting validation
- Run `mypy .` for type checking
- Run `pytest` with appropriate test paths
- Use `python -m` for running modules

**Example workflow:**
```bash
# 1. Check current state
python -m pytest tests/ -v

# 2. Make changes using str_replace tool

# 3. Validate changes
python -m black --check src/
python -m ruff check src/
python -m mypy src/
python -m pytest tests/ -v

# 4. Report progress
```

### Java Projects
Reference: [Java Instructions](../instructions/java.instructions.md)

**Agent-specific tips:**
- Run `./gradlew build` or `mvn verify` for builds
- Run `./gradlew test` or `mvn test` for tests
- Use `./gradlew spotlessCheck` for formatting
- Run `./gradlew check` for all quality checks

**Example workflow:**
```bash
# 1. Check current state
./gradlew clean build test

# 2. Make changes using str_replace tool

# 3. Validate changes
./gradlew spotlessCheck
./gradlew build test

# 4. Report progress
```

### Terraform Projects
Reference: [Terraform Instructions](../instructions/terraform.instructions.md)

**Agent-specific tips:**
- Run `terraform fmt -check -recursive` for formatting
- Run `terraform validate` for syntax validation
- Run `tflint` for linting
- Run `tfsec .` for security scanning

**Example workflow:**
```bash
# 1. Check current state
terraform fmt -check -recursive
terraform validate
tflint

# 2. Make changes using str_replace tool

# 3. Validate changes
terraform fmt -recursive
terraform validate
tflint
tfsec .

# 4. Report progress
```

## Common Agent Patterns

### Pattern 1: Parallel File Reading
When you need to understand multiple files:
```
Use view tool with multiple files in parallel:
- view file1.py
- view file2.py
- view file3.py
All in the same tool call block
```

### Pattern 2: Efficient Context Building
```
Use command chains:
bash: "git --no-pager status && git --no-pager diff"
Instead of separate calls
```

### Pattern 3: Incremental Testing
```
After each change:
1. Make the change
2. Run affected tests
3. Report progress if tests pass
4. Continue to next change
```

### Pattern 4: Using bash Sessions
For long-running operations:
```
Use mode="sync" with appropriate timeout:
- timeout=300 for builds (5 minutes)
- timeout=600 for extensive test suites (10 minutes)
```

## Error Recovery Guidelines

### When Tests Fail
1. **Analyze the failure**: Read the error message carefully
2. **Isolate the issue**: Run specific failing tests
3. **Understand the cause**: Is it your change or pre-existing?
4. **Fix only if related**: Don't fix unrelated test failures
5. **Re-run tests**: Verify your fix

### When Linting Fails
1. **Run the linter**: Get specific error messages
2. **Auto-fix if possible**: Use `--fix` flags when available
3. **Manual fixes**: Use str_replace for remaining issues
4. **Verify**: Re-run linter to confirm

### When Builds Fail
1. **Check dependencies**: Are all dependencies installed?
2. **Read build logs**: Identify the specific failure point
3. **Fix incrementally**: Address one error at a time
4. **Rebuild**: Verify each fix

## Security Considerations

### Always Check For
- Hardcoded secrets or credentials
- Vulnerable dependencies (use gh-advisory-database tool)
- Input validation on user-provided data
- Proper error handling that doesn't leak information
- SQL injection vulnerabilities
- XSS vulnerabilities in web applications

### Use Security Tools
- Run `codeql_checker` after code changes
- Review and fix security alerts
- Document any remaining vulnerabilities

## Progress Reporting Best Practices

### When to Report Progress
✅ After completing initial plan
✅ After each significant code change that passes tests
✅ After fixing a set of related issues
✅ Before switching to a different area of work
✅ When taking a break from implementation

### What to Include
- Clear commit message describing the change
- Updated checklist showing progress
- Note any blockers or issues encountered
- Next steps to be taken

### Example Progress Reports

**Initial Plan:**
```markdown
## Feature: Add user authentication

### Plan
- [x] Analyzed existing code structure
- [x] Reviewed authentication requirements
- [ ] Implement authentication middleware
- [ ] Add authentication tests
- [ ] Update API documentation
- [ ] Run security scan

### Next Steps
Implementing authentication middleware with JWT tokens
```

**After Implementation:**
```markdown
## Feature: Add user authentication

### Progress
- [x] Analyzed existing code structure
- [x] Reviewed authentication requirements
- [x] Implement authentication middleware
- [x] Add authentication tests
- [ ] Update API documentation
- [ ] Run security scan

### Completed
- Added JWT authentication middleware
- Implemented token validation
- Added 15 new test cases covering auth flows
- All tests passing

### Next Steps
Update API documentation to reflect authentication requirements
```

## Efficiency Tips

### Maximize Parallelism
- Read multiple files simultaneously when they're independent
- Run multiple checks in command chains
- Edit multiple files in the same response when changes are independent

### Minimize File Operations
- Use view with view_range for large files
- Only read what you need
- Cache information mentally to avoid re-reading

### Optimize Test Runs
- Run specific test files/classes instead of entire suite when possible
- Use test markers or filters to run relevant tests
- Re-run full suite before final report_progress

### Use Workspace Features
- Leverage instruction files that are automatically applied
- Reference existing prompts and guidelines
- Follow established patterns in the codebase

## Common Pitfalls to Avoid

❌ **Don't**: Make changes without understanding the codebase
✅ **Do**: Explore and build context first

❌ **Don't**: Modify working code unnecessarily
✅ **Do**: Make minimal, surgical changes

❌ **Don't**: Skip running tests before making changes
✅ **Do**: Establish baseline by running tests first

❌ **Don't**: Commit without validating changes
✅ **Do**: Lint, build, and test before reporting progress

❌ **Don't**: Fix unrelated issues or tests
✅ **Do**: Stay focused on the specific task

❌ **Don't**: Add new dependencies without checking security
✅ **Do**: Run gh-advisory-database for new dependencies

❌ **Don't**: Create temporary files in the repository
✅ **Do**: Use /tmp for temporary files and scripts

❌ **Don't**: Force push or rebase (you can't anyway)
✅ **Do**: Make clean, forward-only commits

## Checklist Template

Use this checklist format in your progress reports:

```markdown
## [Task Name]

### Preparation
- [ ] Understood requirements and constraints
- [ ] Explored relevant code areas
- [ ] Ran existing tests/builds (baseline)
- [ ] Planned minimal changes
- [ ] Reported initial plan

### Implementation
- [ ] Made code changes
- [ ] Added/updated tests
- [ ] Linted code
- [ ] Built successfully
- [ ] All tests passing
- [ ] Updated documentation

### Security & Quality
- [ ] Ran security checks (if applicable)
- [ ] No hardcoded secrets
- [ ] No vulnerable dependencies
- [ ] Proper error handling
- [ ] Input validation added

### Finalization
- [ ] Manual verification completed
- [ ] Git status reviewed
- [ ] .gitignore updated (if needed)
- [ ] Final progress report submitted
```

## Remember

The goal is to make **minimal, precise changes** that accomplish the task while maintaining code quality and security. Always validate your changes through testing and linting, and report progress frequently to keep stakeholders informed.
