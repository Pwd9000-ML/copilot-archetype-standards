---
applyTo: "**/*.py"
description: Python coding standards and best practices
---

# Python Development Standards

## Language Version
- Use Python >=3.12
- Use type hints everywhere (PEP 484)
- Leverage modern Python features (match statements, structural pattern matching, etc.)

## Code Formatting & Linting

- **Linter**: Use `ruff` for fast, comprehensive linting
- **Formatter**: Use `black` with 120 character line length
- **Import Sorting**: Use `isort` or ruff's import sorting
- **Type Checking**: Use `mypy` in strict mode

### Configuration Example
```toml
# pyproject.toml
[tool.black]
line-length = 120
target-version = ['py312']

[tool.ruff]
line-length = 120
target-version = "py312"

[tool.mypy]
python_version = "3.12"
strict = true
```

## Testing

- **Framework**: Use `pytest` for all tests
- **Location**: Place tests under `tests/` directory
- **Naming**: Test files must start with `test_*.py`
- **Coverage**: Aim for >80% code coverage
- **Fixtures**: Use pytest fixtures for setup/teardown

### Test Structure
```python
# tests/test_example.py
import pytest
from mymodule import my_function

def test_my_function_success():
    result = my_function(42)
    assert result == expected_value

def test_my_function_error():
    with pytest.raises(ValueError):
        my_function(-1)
```

## Code Style

- Use descriptive variable names (avoid single letters except in comprehensions/lambdas)
- Prefer dataclasses or Pydantic models for data structures
- Use context managers (`with` statements) for resource management
- Follow PEP 8 naming conventions:
  - `snake_case` for functions, variables, and methods
  - `PascalCase` for classes
  - `UPPER_SNAKE_CASE` for constants

## Documentation

- Use docstrings for all public modules, functions, classes, and methods
- Follow Google or NumPy docstring style (be consistent)
- Include type hints in function signatures (don't duplicate in docstrings)

### Example
```python
def calculate_total(prices: list[float], tax_rate: float = 0.1) -> float:
    """Calculate the total price including tax.
    
    Args:
        prices: List of item prices
        tax_rate: Tax rate as decimal (default: 0.1 for 10%)
    
    Returns:
        Total price including tax
    
    Raises:
        ValueError: If any price is negative
    """
    if any(p < 0 for p in prices):
        raise ValueError("Prices cannot be negative")
    subtotal = sum(prices)
    return subtotal * (1 + tax_rate)
```

## Error Handling

- Use specific exception types
- Provide helpful error messages
- Don't catch exceptions silently
- Use `logging` module instead of `print()` for debugging

## Dependencies

- Use `pyproject.toml` for dependency management
- Pin major versions, allow minor/patch updates
- Keep dependencies minimal and well-maintained
- Use virtual environments (venv, poetry, pipenv)

## Additional Resources

See [Python Style Guide](../docs/python-style.md) for extended guidelines.
