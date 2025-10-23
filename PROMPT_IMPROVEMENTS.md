# Prompt File Improvements - Agent Mode

This document summarizes the improvements made to the GitHub Copilot prompt files to leverage agent mode capabilities.

## Overview

All prompt files have been upgraded from passive `mode: 'ask'` to active `mode: 'agent'` with tool capabilities. Additionally, the test generation prompt has been split into three archetype-specific versions for Python, Java, and Terraform.

## What Changed

### Before (Ask Mode)
- **Mode**: `ask`
- **Behavior**: Passive templates that provide guidance and checklists
- **Interaction**: User follows template manually
- **Output**: Generic advice and best practices

### After (Agent Mode)
- **Mode**: `agent`
- **Tools**: `['search', 'usages', 'githubRepo']`
- **Behavior**: Active analysis of your codebase
- **Interaction**: Agent searches, analyzes, and provides specific findings
- **Output**: Data-driven recommendations with file locations and metrics

## Improved Prompt Files

### 1. plan-migration.prompt.md

**Old Approach:**
- Provided migration planning template
- Generic phases and checklists
- User fills in details manually

**New Approach:**
- **Active Repository Analysis**: Scans codebase to identify files to migrate
- **Dependency Mapping**: Uses `usages` to trace all dependencies
- **Data-Driven Timeline**: Estimates based on repository size and complexity
- **Specific File Lists**: Generates exact file paths and migration order
- **Historical Context**: Uses `githubRepo` to analyze commit history

**Example Output Difference:**
```
OLD: "Phase 1: Preparation (2 weeks)"
NEW: "Phase 1: Preparation (2 weeks based on 150 files analyzed)
      ├─ 45 files need refactoring
      └─ 12 dependencies to update"
```

### 2. review-security.prompt.md

**Old Approach:**
- Provided OWASP Top 10 checklist
- Generic security considerations
- Manual code review by user

**New Approach:**
- **Active Vulnerability Scanning**: Searches for security anti-patterns
- **Data Flow Analysis**: Traces user input to sensitive operations using `usages`
- **Dependency Checking**: Scans package files for known CVEs
- **Language-Specific Checks**: Detects language and applies relevant security rules
- **Specific Findings**: Reports exact file locations and line numbers

**Example Output Difference:**
```
OLD: "Check for SQL injection vulnerabilities"
NEW: "🔴 CRITICAL: SQL injection vulnerability
     File: src/auth/login.py:45
     Issue: User input 'username' directly interpolated into SQL
     Evidence: query = f\"SELECT * FROM users WHERE username = '{username}'\"
     Fix: Use parameterized queries"
```

### 3. Test Generation Prompts (Archetype-Specific)

**Old Approach:**
- Single prompt file with all languages combined
- Provided test templates and examples
- Generic test patterns
- User adapts templates manually

**New Approach:**
Split into three archetype-specific prompt files:
- **generate-tests-python.prompt.md**: Python/pytest focused
- **generate-tests-java.prompt.md**: Java/JUnit 5 focused
- **generate-tests-terraform.prompt.md**: Terraform/Terratest focused

Each prompt provides:
- **Code Path Analysis**: Identifies all execution paths to test
- **Pattern Detection**: Searches for existing test conventions in your repo
- **Dependency Discovery**: Uses `usages` to find all mocks needed
- **Coverage Analysis**: Calculates current and projected coverage
- **Style Matching**: Generates tests matching your project's patterns
- **Language-Specific Best Practices**: Tailored to each technology

**Example Output Difference:**
```
OLD: "def test_function_with_valid_input():"

NEW (Python): "def test_calculate_total_with_valid_items_returns_correct_sum():
     # Based on analysis: 50 usages found, 3 code paths identified
     # Current coverage: 45%, will bring to 92%
     # Mocks needed: database.connection (line 23), email_service (line 45)"

NEW (Java): "@Test
     @DisplayName(\"Should calculate total with valid items\")
     void testCalculateTotal_ValidItems_ReturnsCorrectSum() {
         // Analysis: 3 public methods, 2 dependencies to mock
         // Coverage improvement: 52% -> 94%"

NEW (Terraform): "func TestAzureInfrastructure(t *testing.T) {
     // Analysis: 7 resources, 5 required variables, 3 outputs
     // Tests: validation script + Terratest integration"
```

## How to Use Agent Mode Prompts

### Migration Planning
```
User: "Plan migration from Python 3.8 to 3.12 for /src/core directory"

Agent:
1. Searches repository for Python 3.8 specific code
2. Identifies deprecated features using `search`
3. Traces usage of deprecated features with `usages`
4. Analyzes repository structure with `githubRepo`
5. Generates specific migration plan with file lists and timeline
```

### Security Review
```
User: "Review authentication module for security vulnerabilities"

Agent:
1. Searches /src/auth for security patterns
2. Traces user input flows using `usages`
3. Checks dependencies for CVEs
4. Identifies specific vulnerabilities with locations
5. Provides prioritized findings with fixes
```

### Test Generation (Archetype-Specific)

**Python:**
```
User: "Generate tests for UserService with >90% coverage"
Prompt: /prompt generate-tests-python

Agent:
1. Analyzes UserService code structure
2. Finds existing pytest patterns in project
3. Identifies all dependencies to mock (using pytest-mock)
4. Traces all code paths
5. Generates pytest test suite with fixtures matching your style
```

**Java:**
```
User: "Generate JUnit tests for OrderService with Mockito"
Prompt: /prompt generate-tests-java

Agent:
1. Analyzes OrderService class and methods
2. Finds existing JUnit 5 patterns in project
3. Identifies dependencies for @Mock and @InjectMocks
4. Traces exception paths and validation logic
5. Generates JUnit 5 tests with AssertJ assertions and nested test classes
```

**Terraform:**
```
User: "Generate tests for networking module with validation and Terratest"
Prompt: /prompt generate-tests-terraform

Agent:
1. Analyzes Terraform resources and variables
2. Finds existing Terratest patterns if any
3. Identifies required variables and outputs
4. Creates validation bash script for tfsec/tflint
5. Generates Terratest Go integration tests with cleanup
```

## Benefits of Agent Mode

### 1. **Time Savings**
- No manual code scanning required
- Automated dependency analysis
- Instant repository insights

### 2. **Accuracy**
- Data-driven recommendations
- Specific file locations and line numbers
- Based on actual codebase, not assumptions

### 3. **Context-Aware**
- Understands your project structure
- Matches existing code patterns
- Considers your tech stack

### 4. **Actionable**
- Specific files to modify
- Exact lines to change
- Prioritized recommendations

### 5. **Comprehensive**
- Analyzes entire codebase
- Traces dependencies across files
- Identifies hidden relationships

## Technical Details

### Tools Available in Agent Mode

1. **search**: Search codebase for patterns, files, and content
   - Use for: Finding security patterns, identifying deprecated code, locating dependencies

2. **usages**: Trace how code is used throughout the repository
   - Use for: Dependency analysis, impact assessment, data flow tracing

3. **githubRepo**: Access repository structure and history
   - Use for: Understanding project organization, analyzing commit patterns, identifying contributors

### Frontmatter Format

```yaml
---
mode: 'agent'
description: Brief description of what the agent does
tools: ['search', 'usages', 'githubRepo']
---
```

## Best Practices for Using Agent Prompts

### Be Specific
❌ "Review my code for security"
✅ "Review the authentication module in /src/auth for security vulnerabilities, focusing on session management"

### Provide Context
❌ "Generate tests"
✅ "Generate comprehensive tests for UserService with >90% coverage, focusing on create and update methods"

### Set Constraints
❌ "Plan a migration"
✅ "Plan migration from Python 3.8 to 3.12 for /src/core directory. We have 6 weeks and must maintain backward compatibility"

### Ask for Metrics
✅ "Show me coverage improvement estimates"
✅ "Identify high-priority security issues first"
✅ "Provide a timeline based on repository analysis"

## References

- [GitHub Copilot Prompt Files Documentation](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
- [GitHub Copilot Chat Modes Documentation](https://docs.github.com/en/copilot/using-github-copilot/asking-github-copilot-questions-in-your-ide)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Repository README](./README.md)

## Feedback and Contributions

If you have suggestions for improving these agent mode prompts:
1. Open an issue describing your use case
2. Share examples of prompts that work well in your workflow
3. Contribute improvements via pull request

---

**Last Updated**: 2025-10-23
**Version**: 2.0 (Agent Mode)
