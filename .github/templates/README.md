# GitHub Copilot File Templates

This directory contains templates for creating new GitHub Copilot customization files. Use these templates to ensure consistency and completeness when contributing new content.

## Available Templates

### `instruction.template.md`
Template for creating new language or framework instruction files.

**Use when:** Adding standards for a new programming language or framework

**Output location:** `.github/instructions/{language}.instructions.md`

**Steps:**
1. Copy the template
2. Replace all `{placeholders}` with actual values
3. Fill in all sections with relevant content
4. Add code examples for each pattern
5. Include both good and bad examples (✅ and ❌)
6. Link to official documentation

### `prompt.template.md`
Template for creating new prompt files with agent capabilities.

**Use when:** Adding a reusable prompt for common development tasks

**Output location:** `.github/prompts/{scope}.{purpose}.prompt.md`

**Steps:**
1. Copy the template
2. Define clear purpose in front matter
3. Describe how the agent uses tools (search, usages, githubRepo)
4. Provide concrete examples with code
5. Document expected inputs and outputs
6. Include usage examples

### `chatmode.template.md`
Template for creating new custom chat modes.

**Use when:** Adding a specialized development workflow

**Output location:** `.github/chatmodes/{language}.{mode}.chatmode.md`

**Steps:**
1. Copy the template
2. Define clear role and deliverables
3. Specify operating constraints
4. List language/scope-specific considerations
5. Document tool usage patterns
6. Keep concise and focused

## Quick Start

### Creating a New Instruction File

```bash
# 1. Copy template
cp .github/templates/instruction.template.md .github/instructions/rust.instructions.md

# 2. Edit the file
# - Replace {Language} with "Rust"
# - Replace {Version} with "1.75"
# - Replace {extension} with "rs"
# - Fill in all sections

# 3. Add to version control
git add .github/instructions/rust.instructions.md
git commit -m "feat: add Rust instruction file"
```

### Creating a New Prompt File

```bash
# 1. Copy template
cp .github/templates/prompt.template.md .github/prompts/python.refactor.prompt.md

# 2. Edit the file
# - Define clear purpose: "Refactor Python code for better maintainability"
# - Add specific refactoring patterns
# - Include before/after examples
# - Document when to use

# 3. Add to version control
git add .github/prompts/python.refactor.prompt.md
git commit -m "feat: add Python refactoring prompt"
```

### Creating a New Chat Mode

```bash
# 1. Copy template
cp .github/templates/chatmode.template.md .github/chatmodes/python.refactorer.chatmode.md

# 2. Edit the file
# - Define mode purpose and approach
# - List deliverables
# - Add Python-specific refactoring considerations
# - Keep concise and actionable

# 3. Add to version control
git add .github/chatmodes/python.refactorer.chatmode.md
git commit -m "feat: add Python refactorer chat mode"
```

## Template Sections Explained

### Front Matter
All files must start with YAML front matter enclosed in `---`:

```yaml
---
# Required fields vary by file type
# See individual templates for specifics
---
```

### Common Patterns

#### Code Examples
Always include both good and bad examples:

```language
# ❌ Avoid - Bad practice
// problematic code

# ✅ Prefer - Good practice
// improved code
```

#### Tool Usage
When describing tool usage, be specific:

**Using `search` to:**
- Find existing authentication implementations
- Locate configuration files
- Discover similar code patterns

#### References
Link to resources using full GitHub URLs:

```markdown
Reference: [Python Instructions](https://github.com/Pwd9000-ML/copilot-archetype-standards/tree/master/.github/instructions/python.instructions.md)
```

## Validation Checklist

Before submitting your new file:

- [ ] All `{placeholders}` replaced with actual content
- [ ] YAML front matter is valid
- [ ] All required sections are present
- [ ] Code examples are syntactically correct
- [ ] Links use full GitHub URLs with `tree/master`
- [ ] File naming follows conventions
- [ ] Content is consistent with existing similar files
- [ ] Tested in VS Code with GitHub Copilot

## Getting Help

- See [CONTRIBUTING.md](https://github.com/Pwd9000-ML/copilot-archetype-standards/tree/master/CONTRIBUTING.md) for detailed guidelines
- Review existing files for examples
- Ask questions in GitHub Discussions
- Open an issue for clarifications

