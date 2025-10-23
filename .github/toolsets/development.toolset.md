---
description: Essential development tools for code analysis, testing, and quality assurance
---

# Development Toolset

This toolset provides access to essential development tools for analyzing code, running tests, checking quality, and managing the development workflow. These tools are available across all chat modes and prompts.

## Available Tools

### Code Analysis Tools

#### `search`
Search the codebase for files, symbols, patterns, and code.

**Use cases:**
- Find function definitions and usages
- Locate configuration files
- Search for specific patterns or anti-patterns
- Discover similar implementations
- Identify where dependencies are used

**Example queries:**
```
"Find all functions that handle user authentication"
"Search for TODO comments in Python files"
"Locate all database connection configurations"
"Find classes that implement the Repository pattern"
```

#### `usages`
Trace how functions, classes, and symbols are used throughout the codebase.

**Use cases:**
- Identify all callers of a function
- Understand the impact of changing an API
- Find dead code that's never called
- Trace data flows through the application
- Discover tightly coupled components

**Example usage:**
```
"Show all places where UserService.createUser is called"
"Find usages of the DATABASE_URL environment variable"
"Trace where sensitive data flows in the authentication module"
```

#### `githubRepo`
Access repository metadata, structure, and history.

**Use cases:**
- Get repository owner, name, and default branch
- List files and directory structure
- Access commit history and contributors
- Find related repositories
- Check repository settings and configuration

**Example queries:**
```
"What is the default branch and primary language?"
"List all markdown files in the docs directory"
"Show recent commits to the authentication module"
"Find similar repositories in the organization"
```

## Tool Combinations for Common Tasks

### Security Review
```
1. Use `search` to find authentication implementations
2. Use `usages` to trace sensitive data flows
3. Use `githubRepo` to check dependency versions
4. Combine findings to identify vulnerabilities
```

### Test Generation
```
1. Use `search` to find existing test patterns
2. Use `usages` to identify all code paths to test
3. Use `githubRepo` to determine test coverage
4. Generate comprehensive test suite
```

### Code Review
```
1. Use `search` to find similar code in the repository
2. Use `usages` to assess impact of changes
3. Use `githubRepo` to check consistency with conventions
4. Provide actionable feedback
```

### Refactoring
```
1. Use `usages` to find all places affected by change
2. Use `search` to find duplication opportunities
3. Use `githubRepo` to maintain consistency
4. Plan safe refactoring steps
```

### Migration Planning
```
1. Use `search` to identify deprecated patterns
2. Use `usages` to count affected code locations
3. Use `githubRepo` to analyze project structure
4. Create phased migration plan
```

## Best Practices

### Effective Searching
- Be specific with search terms
- Use file type filters when appropriate
- Combine multiple searches for comprehensive results
- Search for patterns, not just exact matches

### Tracing Usages
- Start from public APIs and work inward
- Identify critical paths first
- Look for unexpected usages
- Consider indirect dependencies

### Repository Analysis
- Check for conventions before making changes
- Look at similar files for patterns
- Review recent changes for context
- Consider project structure and organization

## Tool Limitations

### What Tools Can Do
✅ Read and analyze code
✅ Search for patterns and symbols
✅ Trace relationships and dependencies
✅ Access repository metadata
✅ Provide insights and recommendations

### What Tools Cannot Do
❌ Execute code or run commands
❌ Make changes to files
❌ Access external systems
❌ Perform network operations
❌ Read files outside the repository

## Integration with Chat Modes

### Planner Mode
Uses tools in **read-only** mode to:
- Analyze codebase structure
- Identify dependencies
- Assess complexity and risk
- Create implementation plans

### Security Reviewer Mode
Uses tools to:
- Find security-sensitive code
- Trace data flows
- Identify vulnerabilities
- Provide remediation guidance

### Test Generation Mode
Uses tools to:
- Find existing test patterns
- Identify code paths
- Determine coverage gaps
- Generate appropriate tests

## Examples by Language

### Python
```
# Find all async functions
search: "async def" in Python files

# Trace database queries
usages: db.execute, session.query

# Check test framework
githubRepo: find pytest.ini, tox.ini
```

### Java
```
# Find Spring controllers
search: @RestController, @RequestMapping

# Trace service dependencies
usages: @Autowired, @Inject

# Check build configuration
githubRepo: find pom.xml, build.gradle
```

### Terraform
```
# Find resource definitions
search: resource "aws_*", azurerm_*

# Trace module usage
usages: module.*

# Check provider versions
githubRepo: find versions.tf, .terraform.lock.hcl
```

## Advanced Patterns

### Cross-Reference Analysis
```
1. Search for interface definitions
2. Use usages to find all implementations
3. Compare implementations for consistency
4. Identify missing implementations
```

### Dependency Impact Analysis
```
1. Search for library imports
2. Trace usages throughout codebase
3. Assess update impact
4. Plan migration strategy
```

### Dead Code Detection
```
1. Search for function definitions
2. Check usages for each function
3. Identify functions with zero usages
4. Verify before removal (may be called dynamically)
```

### API Contract Analysis
```
1. Search for public API definitions
2. Trace all usages of the API
3. Identify breaking change risks
4. Plan backward-compatible changes
```

## Getting Help

For assistance with tools:
- Ask for specific search strategies
- Request usage analysis guidance
- Get repository navigation help
- Learn advanced tool combinations

**Example questions:**
```
"How do I search for security vulnerabilities?"
"What's the best way to trace authentication flows?"
"How can I find all files that need updating?"
"Show me how to analyze test coverage using tools"
```

## Tool Availability

These tools are available in:
- All prompt files with `mode: 'agent'`
- All chat modes with `tools` specified in front matter
- Workspace-scoped custom instructions
- GitHub Copilot Chat sessions

To use these tools effectively, reference them in your prompts and chat modes by adding:
```yaml
---
tools: ['search', 'usages', 'githubRepo']
---
```
