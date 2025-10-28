# Contributing to GitHub Copilot Archetype Standards

Thank you for your interest in contributing to this repository! This guide will help you add new standards, prompts, agents, and improvements.

## Table of Contents

- [Getting Started](#getting-started)
- [Adding New Content](#adding-new-content)
- [File Naming Conventions](#file-naming-conventions)
- [Front Matter Standards](#front-matter-standards)
- [Testing Your Changes](#testing-your-changes)
- [Submitting Changes](#submitting-changes)

## Getting Started

1. **Fork the repository** to your GitHub account
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/copilot-archetype-standards.git
   cd copilot-archetype-standards
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Adding New Content

### Adding a New Instruction File

Instruction files define language or path-specific coding standards.

**Location**: `.github/instructions/`

**Naming**: `{language}.instructions.md` or `{framework}.instructions.md`

**Template**:
```markdown
---
applyTo: "**/*.{extension}"
description: Brief description of what this instruction file covers
---

# {Language/Framework} Development Standards

## Language Version
- **Required**: {Language} {Version}+
- **Key Features**: List important features to use

## Code Formatting & Linting
- **Linter**: Tool name and configuration
- **Formatter**: Tool name and line length
- **Type Checking**: Tool name and mode

## Configuration
\`\`\`toml
[tool.formatter]
line-length = 120
\`\`\`

## Best Practices
- List key best practices
- Include code examples
 
\`\`\`language
// Good example
\`\`\`

## Resources
- Links to official documentation
```

**Example**: See `.github/instructions/python.instructions.md`

### Adding a New Prompt File

Prompt files are reusable templates for common tasks with agent capabilities.

**Location**: `.github/prompts/`

**Naming**: 
- Language-specific: `{language}.{purpose}.prompt.md`
- Global: `global.{purpose}.prompt.md`

**Template**:
```markdown
---
mode: 'agent'
description: Clear description of what this prompt does (one line)
tools: ['search', 'usages', 'githubRepo']
---

# {Purpose} Agent

As a {purpose} agent, I will {describe capabilities}. I have access to search tools, usage analysis, and repository context to {describe what you provide}.

## How I Can Help

I will analyze your {target} for {concerns}, {actions}, and provide {deliverables}.

## My Process

When you request {action}, I will:

### 1. Analysis Phase

**Using `search` to:**
- Specific use case 1
- Specific use case 2

**Using `usages` to:**
- Specific use case 1
- Specific use case 2

**Using `githubRepo` to:**
- Specific use case 1
- Specific use case 2

### 2. Action Phase

Describe what actions are taken...

## Examples

Provide concrete code examples showing:
- Input scenarios
- Expected outputs
- Common patterns

## How to Work With Me

**To get {service}, provide:**
- Required information 1
- Required information 2

**I will then:**
1. Step 1
2. Step 2
3. Step 3

**Example Usage:**
\`\`\`
"Description of a request"
\`\`\`

**I will respond with:**
- Deliverable 1
- Deliverable 2
```

**Examples**: 
- See `.github/prompts/python.generate-tests.prompt.md`
- See `.github/prompts/global.code-review.prompt.md`

### Adding a New Agent

Agents define specialized workflows for development tasks.

**Location**: `.github/agents/`

**Naming**: `{language}.{mode}.agent.md`

**Template**:
```markdown
---
description: Brief description of the agent's purpose and approach
tools: ['search', 'usages', 'githubRepo']
model: Claude Sonnet 4.5 or GPT-5
---

# {Mode} ({Language})

Operate as a {description} with {language}-specific awareness. Produce {output} to deliver:

- Deliverable 1
- Deliverable 2
- Deliverable 3

Operating constraints:
- Constraint 1
- Constraint 2

{Language} considerations:
- Consideration 1
- Consideration 2
- Consideration 3
```

**Examples**:
- See `.github/agents/python.planner.agent.md`
- See `.github/agents/java.sec-reviewer.agent.md`

 

## File Naming Conventions

### Instruction Files
- Format: `{language}.instructions.md`
- Examples: `python.instructions.md`, `java.instructions.md`
- Location: `.github/instructions/`

### Prompt Files
- Format: `{scope}.{purpose}.prompt.md`
- Scope: `global`, `python`, `java`, `terraform`
- Examples: `python.generate-tests.prompt.md`, `global.code-review.prompt.md`
- Location: `.github/prompts/`

### Agent Files
- Format: `{language}.{mode}.agent.md`
- Mode: `planner`, `sec-reviewer`, `refactorer`
- Examples: `python.planner.agent.md`, `java.sec-reviewer.agent.md`
- Location: `.github/agents/`

 

### Toolset Files
- Format: `{category}.toolset.md`
- Examples: `development.toolset.md`, `security.toolset.md`
- Location: `.github/toolsets/`

## Front Matter Standards

### Instruction Files
```yaml
---
applyTo: "**/*.{ext}"
description: One-line description
---
```

**Fields:**
- `applyTo` (required): Glob pattern for files this applies to
- `description` (required): Brief description of the instruction scope

### Prompt Files
```yaml
---
mode: 'agent'
description: One-line description of what the prompt does
tools: ['search', 'usages', 'githubRepo']
---
```

**Fields:**
- `mode` (required): Always `'agent'` for active prompts
- `description` (required): Clear, concise purpose statement
- `tools` (required): Array of tools the prompt uses

### Agent Files
```yaml
---
description: One-line description of the agent
tools: ['search', 'usages', 'githubRepo']
model: Claude Sonnet 4.5
---
```

**Fields:**
- `description` (required): Purpose and approach of the agent
- `tools` (required): Array of tools the agent uses
- `model` (optional): Recommended AI model (e.g., "Claude Sonnet 4.5", "GPT-5")

### Toolset Files
```yaml
---
description: One-line description of the toolset
---
```

**Fields:**
- `description` (required): Brief description of tools included

## Testing Your Changes

### Automated Validation (Recommended)

Run the validation script to automatically check all requirements:

```bash
.github/scripts/validate-files.sh
```

This script checks:
- ✅ YAML front matter validity and required fields
- ✅ URL consistency (tree/master)
- ✅ File naming conventions
- ✅ Code fence matching
- ✅ Unfilled template placeholders

### Manual Testing

If you prefer manual testing or want to verify specific aspects:

### 1. Validate Front Matter

Ensure all YAML front matter is properly formatted:
```bash
# Check for YAML errors
grep -r "^---$" .github/
```

### 2. Check Markdown Formatting

Verify markdown is well-formed:
```bash
# Use markdownlint or similar tool
markdownlint .
```

### 3. Validate Links

Ensure all internal links use full GitHub URLs:
- ✅ Good: `https://github.com/Pwd9000-ML/copilot-archetype-standards/tree/master/.github/instructions/python.instructions.md`
- ❌ Bad: `../instructions/python.instructions.md`

### 4. Test in VS Code

1. Copy your changes to a test repository
2. Open the repository in VS Code with GitHub Copilot
3. Verify that:
   - Instruction files are applied correctly
   - Prompt files appear in Copilot Chat
   - Agents are accessible
   - Tools work as expected

### 5. Check Consistency

Compare your new file with existing similar files:
- Does it follow the same structure?
- Does it use consistent terminology?
- Does it reference appropriate related files?

## Submitting Changes

### 1. Commit Your Changes

Follow conventional commit format:
```bash
git add .
git commit -m "feat: add Python refactoring prompt file

- Add python.refactor.prompt.md for common refactoring patterns
- Include examples for extract method, extract class
- Add references to Python style guide"
```

**Commit message format:**
- `feat:` - New feature (new file, new section)
- `fix:` - Bug fix or correction
- `docs:` - Documentation updates
- `style:` - Formatting, no code change
- `refactor:` - Restructuring without changing behavior
- `test:` - Adding or updating tests

### 2. Push Your Branch

```bash
git push origin feature/your-feature-name
```

### 3. Create Pull Request

1. Go to the repository on GitHub
2. Click "Pull Requests" > "New Pull Request"
3. Select your branch
4. Fill in the PR template:

```markdown
## Description
Brief description of what this PR adds or changes.

## Type of Change
- [ ] New instruction file
- [ ] New prompt file
- [ ] New agent
- [ ] Style guide update
- [ ] Documentation improvement
- [ ] Bug fix

## Files Added/Modified
- `.github/prompts/python.refactor.prompt.md` - Added
- `README.md` - Updated to reference new prompt

## Testing
- [x] Validated YAML front matter
- [x] Checked markdown formatting
- [x] Verified all links use full URLs
- [x] Tested in VS Code with Copilot
- [x] Compared with existing similar files

## Related Issues
Closes #123
```

### 4. Respond to Review Feedback

- Address all comments from reviewers
- Make requested changes in your branch
- Push updates (they'll appear in the PR automatically)

## Style and Quality Guidelines

### Writing Style
- **Clear and Concise**: Use simple language and short sentences
- **Actionable**: Provide specific examples and code snippets
- **Consistent**: Follow patterns from existing files
- **Complete**: Include all required sections

### Code Examples
- Use realistic, practical examples
- Show only ✅ secure/approved patterns (avoid including insecure examples)
- Include comments explaining why
- Test that examples are syntactically correct

### Documentation
- Link to official documentation when appropriate
- Use full GitHub URLs for internal references
- Keep examples up to date with current versions
- Include references to related files

## Need Help?

- **Questions**: Open a GitHub Discussion
- **Issues**: Create a GitHub Issue
- **General Help**: Contact the author and maintainer @Pwd9000-ML

## Code of Conduct

- Be respectful and constructive
- Focus on improving the content
- Provide clear, specific feedback
- Help others learn and contribute

## License

By contributing, you agree that your contributions will be licensed under the same license as this project (see LICENSE file).

---

Thank you for contributing to GitHub Copilot Archetype Standards! Your contributions help teams maintain consistent, high-quality code across their projects.
