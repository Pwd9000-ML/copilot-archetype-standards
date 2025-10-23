# GitHub Copilot Archetype Standards

A centralized repository containing development standards, coding guidelines, and GitHub Copilot configuration files for Python, Java, and Terraform projects.

## 📋 Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [How to Use](#how-to-use)
- [Archetype Standards](#archetype-standards)
- [GitHub Copilot Integration](#github-copilot-integration)
- [Testing the Configuration](#testing-the-configuration)
- [Contributing](#contributing)

## 🎯 Overview

This repository serves as a central source of truth for:

- **Organization-wide coding standards** across multiple languages
- **GitHub Copilot instruction files** that guide AI-assisted development
- **Reusable prompt templates** for common development tasks
- **Custom chat modes** for specialized development workflows
- **Language-specific style guides** for Python, Java, and Terraform

### Why This Repository?

GitHub Copilot custom instruction files, prompt files, and chat modes cannot be centrally managed, even in GitHub Enterprise Cloud (GHEC). This repository provides a workaround by:

1. Storing all standards and instructions in a central location
2. Allowing other repositories to reference these standards via Markdown links
3. Providing a consistent development experience across projects
4. Enabling easy updates that propagate to all referencing repositories

## 📁 Repository Structure

```
.
├── README.md
├── .github/
│   ├── copilot-instructions.md              # Repository-wide high-level rules
│   ├── instructions/                        # Path-scoped instruction files
│   │   ├── python.instructions.md
│   │   ├── java.instructions.md
│   │   └── terraform.instructions.md
│   ├── prompts/                             # Reusable prompt files
│   │   ├── review-security.prompt.md
│   │   ├── generate-tests.prompt.md
│   │   └── plan-migration.prompt.md
│   └── chatmodes/                           # Custom chat modes
│       ├── reviewer.chatmode.md
│       └── planner.chatmode.md
└── docs/
    ├── python-style.md                      # Extended Python guidelines
    ├── java-style.md                        # Extended Java guidelines
    └── terraform-conventions.md             # Extended Terraform guidelines
```

### File Types and Purposes

#### `.github/copilot-instructions.md`
- **Purpose**: Repository-wide high-level coding rules
- **Scope**: Automatically applied to entire repository
- **Support**: VS Code, GitHub Copilot

#### `.github/instructions/*.instructions.md`
- **Purpose**: Language or path-specific instructions
- **Scope**: Applied to files matching `applyTo` glob patterns
- **Support**: VS Code, Coding Agent
- **Format**: Front matter with `applyTo` and `description` fields

#### `.github/prompts/*.prompt.md`
- **Purpose**: Reusable prompt templates for common tasks
- **Scope**: Workspace or user-scoped
- **Support**: GitHub Copilot Chat
- **Format**: Front matter with `mode` and `description` fields
- **Usage**: Can reference other workspace files via relative paths

#### `.github/chatmodes/*.chatmode.md`
- **Purpose**: Custom chat modes for specialized workflows
- **Scope**: Workspace-scoped
- **Support**: GitHub Copilot Chat
- **Format**: Front matter with `description` and `tools` fields
- **Usage**: Can reference instruction files via Markdown links

#### `docs/*.md`
- **Purpose**: Extended style guides and conventions
- **Scope**: Referenced by instruction and prompt files
- **Support**: Any Markdown viewer
- **Usage**: Detailed guidelines that complement instruction files

## 🚀 How to Use

### Option 1: Direct Integration (Recommended)

Copy the `.github` directory structure into your project repository:

```bash
# Clone this repository
git clone https://github.com/Pwd9000-ML/copilot-archetype-standards.git

# Copy .github directory to your project
cp -r copilot-archetype-standards/.github /path/to/your/project/

# Copy docs if needed
cp -r copilot-archetype-standards/docs /path/to/your/project/
```

### Option 2: Reference via Markdown Links (Experimental)

Create lightweight instruction files in your project that reference this central repository:

**Example: `.github/copilot-instructions.md` in your project**
```markdown
# Project Copilot Instructions

This project follows the organization-wide standards defined in the central repository:

- [Organization Copilot Guidelines](https://github.com/Pwd9000-ML/copilot-archetype-standards/blob/main/.github/copilot-instructions.md)

## Language-Specific Instructions

- [Python Standards](https://github.com/Pwd9000-ML/copilot-archetype-standards/blob/main/.github/instructions/python.instructions.md)
- [Java Standards](https://github.com/Pwd9000-ML/copilot-archetype-standards/blob/main/.github/instructions/java.instructions.md)
- [Terraform Standards](https://github.com/Pwd9000-ML/copilot-archetype-standards/blob/main/.github/instructions/terraform.instructions.md)

## Project-Specific Guidelines

[Add any project-specific guidelines here]
```

**Note**: The effectiveness of Option 2 depends on GitHub Copilot's ability to follow external links. Test thoroughly in your environment.

### Option 3: Git Submodule

Add this repository as a submodule to reference it directly:

```bash
cd /path/to/your/project
git submodule add https://github.com/Pwd9000-ML/copilot-archetype-standards.git standards
git commit -m "Add copilot standards as submodule"
```

Then create symlinks or reference the files:
```bash
ln -s standards/.github/copilot-instructions.md .github/copilot-instructions.md
```

## 📚 Archetype Standards

### Python Archetype

**Key Standards:**
- Python >=3.12 with type hints everywhere
- Linting with `ruff`, formatting with `black` (120 columns)
- Testing with `pytest` under `tests/` directory
- See: [Python Instructions](.github/instructions/python.instructions.md) | [Python Style Guide](docs/python-style.md)

**Example Project Structure:**
```
python-project/
├── src/
│   └── myapp/
│       ├── __init__.py
│       └── main.py
├── tests/
│   └── test_main.py
├── pyproject.toml
├── .github/
│   └── copilot-instructions.md
└── README.md
```

### Java Archetype

**Key Standards:**
- Java 17 LTS or later (Java 21 LTS recommended)
- Google Java Style Guide with `google-java-format`
- Testing with JUnit 5 and AssertJ
- Build with Gradle or Maven
- See: [Java Instructions](.github/instructions/java.instructions.md) | [Java Style Guide](docs/java-style.md)

**Example Project Structure:**
```
java-project/
├── src/
│   ├── main/java/
│   │   └── com/example/myapp/
│   └── test/java/
│       └── com/example/myapp/
├── build.gradle
├── .github/
│   └── copilot-instructions.md
└── README.md
```

### Terraform Archetype

**Key Standards:**
- Terraform >= 1.6.0 with pinned provider versions
- Format with `terraform fmt`, lint with `tflint`
- Security scanning with `tfsec` or `checkov`
- Remote state with encryption enabled
- See: [Terraform Instructions](.github/instructions/terraform.instructions.md) | [Terraform Conventions](docs/terraform-conventions.md)

**Example Project Structure:**
```
terraform-project/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── modules/
├── .github/
│   └── copilot-instructions.md
└── README.md
```

## 🤖 GitHub Copilot Integration

### VS Code Integration

1. **Install GitHub Copilot Extension**: Ensure GitHub Copilot is installed and activated in VS Code

2. **Instruction Files**: Place instruction files in `.github/instructions/` with proper front matter:
   ```markdown
   ---
   applyTo: "**/*.py"
   description: Python rules
   ---
   ```

3. **Prompt Files**: Save prompt files in `.github/prompts/` and access via Copilot Chat

4. **Chat Modes**: Define custom chat modes in `.github/chatmodes/` for specialized workflows

### How Copilot Uses These Files

- **copilot-instructions.md**: Automatically loaded for all Copilot interactions in the repository
- **instructions/*.instructions.md**: Applied to files matching the `applyTo` glob pattern
- **prompts/*.prompt.md**: Available as reusable prompts in Copilot Chat
- **chatmodes/*.chatmode.md**: Activate specialized modes for focused development tasks

### Example Copilot Workflows

**Security Review:**
1. Select code to review
2. Open Copilot Chat
3. Reference: `/prompt review-security`
4. Copilot performs security analysis using OWASP Top 10

**Generate Tests:**
1. Select function/class to test
2. Open Copilot Chat
3. Reference: `/prompt generate-tests`
4. Copilot generates comprehensive test suite

**Migration Planning:**
1. Open Copilot Chat
2. Reference: `/prompt plan-migration`
3. Describe migration scenario
4. Copilot provides detailed migration plan

## 🧪 Testing the Configuration

### Test Plan for Referenced Instructions

To verify whether GitHub Copilot follows instructions from external repositories:

#### Setup Test Repositories

1. **Create archetype-specific empty repositories:**
   - `python-test-archetype`
   - `java-test-archetype`
   - `terraform-test-archetype`

2. **Add minimal instruction files** that reference this central repository

3. **Test Copilot behavior** in each repository

#### Test Cases

**Test 1: Instruction Following**
- Create a Python file in `python-test-archetype`
- Ask Copilot to create a function
- Verify: Does it use type hints? Black formatting? pytest conventions?

**Test 2: Prompt Application**
- Select code in any test repository
- Use security review prompt
- Verify: Does Copilot follow OWASP Top 10 checklist?

**Test 3: Cross-Reference**
- Ask Copilot about style guidelines
- Verify: Does it reference the central repository docs?

**Test 4: Updates Propagation**
- Update central repository instructions
- Test in archetype repositories
- Verify: Do changes take effect immediately or need cache clear?

#### Testing Procedure

```bash
# 1. Create test repository
mkdir python-test-archetype && cd python-test-archetype
git init

# 2. Add minimal reference file
mkdir -p .github
cat > .github/copilot-instructions.md << 'EOF'
# Python Project Standards

Follow organization standards: 
https://github.com/Pwd9000-ML/copilot-archetype-standards/blob/main/.github/instructions/python.instructions.md

See: https://github.com/Pwd9000-ML/copilot-archetype-standards/blob/main/docs/python-style.md
EOF

# 3. Create test file
cat > test.py << 'EOF'
# Ask Copilot to create a function that calculates factorial
EOF

# 4. Open in VS Code and test with Copilot
code .
```

### Expected Results

| Test | Expected Behavior | Pass/Fail |
|------|------------------|-----------|
| Type hints usage | Copilot suggests type hints | ✅ / ❌ |
| Code formatting | 120 char line length | ✅ / ❌ |
| Test generation | pytest format with fixtures | ✅ / ❌ |
| Security review | OWASP checklist applied | ✅ / ❌ |

### Testing in Your Environment

1. **Clone this repository** to your organization
2. **Create test repositories** for each archetype
3. **Follow the testing procedure** above
4. **Document results** in your environment
5. **Choose integration method** based on test results

## 🤝 Contributing

### Making Updates

1. **Fork this repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/update-python-standards
   ```
3. **Make your changes**
4. **Test in a sample project**
5. **Submit a pull request**

### Updating Standards

When updating standards, consider:

- **Backward compatibility**: Will existing projects break?
- **Documentation**: Update both instruction files and style guides
- **Examples**: Provide code examples for new patterns
- **Communication**: Notify teams using these standards

### Adding New Archetypes

To add a new language archetype:

1. Create instruction file: `.github/instructions/[language].instructions.md`
2. Create style guide: `docs/[language]-style.md`
3. Update this README with archetype information
4. Add examples and test cases

## 📖 Additional Resources

### GitHub Copilot Documentation
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [Copilot Chat Documentation](https://docs.github.com/en/copilot/github-copilot-chat)
- [Custom Instructions](https://code.visualstudio.com/docs/copilot/copilot-customization)

### Style Guides
- [PEP 8 - Python Style Guide](https://pep8.org/)
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Security Resources
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

## 📄 License

This project is licensed under the terms of the LICENSE file in the root directory.

## 🙋 Support

For questions or issues:
- Open an issue in this repository
- Contact the development standards team
- Review existing discussions and documentation

---

**Last Updated**: 2025-10-23  
**Maintained By**: Development Standards Team
