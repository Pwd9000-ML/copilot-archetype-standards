# Organization-wide Copilot Guidelines

This file contains high-level coding standards and practices that apply across all projects in this repository.

## General Principles

- **Minimal Changes**: Prefer smallest-change diffs. Only modify what's necessary to accomplish the task.
- **Testing**: Always add or adjust unit tests when modifying code functionality.
- **Documentation**: Update relevant documentation when changing behaviour or adding features to ensure clarity in the codebase README.md
- **Language-Specific Rules**: Follow language-specific guidelines in `.github/instructions/` for development archetypes.

## Code Quality

- Write clean, maintainable, and well-documented code and comments
- Adhere to established coding standards and style guides for the specific language/framework
- Use meaningful variable and function names
- Follow the DRY (Don't Repeat Yourself) principle
- Keep functions and methods focused on a single responsibility
- When making changes, consider the token limits of AI tools and use the 75 words per 100 tokens guideline, especially for large files.
- Avoid deep nesting of code blocks for better readability
- Use consistent indentation and formatting
- Limit line length to 80-120 characters for better readability

## Security

- Never commit secrets, credentials, or sensitive data
- Follow security best practices for the specific language/framework
- Validate and sanitize all inputs
- Use parameterized queries for database operations

## Version Control

- Write clear, descriptive commit messages
- Keep commits atomic and focused
- Reference issue numbers in commits when applicable

## Collaboration

- Be respectful in code reviews
- Provide constructive feedback
- Ask questions when requirements are unclear

## Language-Specific Guidelines

For detailed language-specific instructions, refer to:
- [Python Instructions](.github/instructions/python.instructions.md)
- [Java Instructions](.github/instructions/java.instructions.md)
- [Terraform Instructions](.github/instructions/terraform.instructions.md)
