# Organization-wide Copilot Guidelines

This file contains high-level coding standards and practices that apply across all projects in this repository.

## General Principles

- **Minimal Changes**: Prefer smallest-change diffs. Only modify what's necessary to accomplish the task.
- **Testing**: Always add or adjust unit tests when modifying code functionality.
- **Documentation**: Update relevant documentation when changing behavior or adding features.
- **Language-Specific Rules**: Follow language-specific guidelines in `.github/instructions/` for Python, Java, and Terraform.
- **Links**: When following links to style guides or documentation, ensure they point to the correct relative paths within this repository using full URL paths, not relative links. This project full path is: https://github.com/Pwd9000-ML/copilot-archetype-standards/tree/master/

## Code Quality

- Write clean, maintainable, and well-documented code
- Use meaningful variable and function names
- Follow the DRY (Don't Repeat Yourself) principle
- Keep functions and methods focused on a single responsibility

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
