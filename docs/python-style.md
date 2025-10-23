# Python Style Guide

This document provides extended Python coding guidelines and best practices for projects following the organization's standards.

## Table of Contents
1. [Code Layout](#code-layout)
2. [Naming Conventions](#naming-conventions)
3. [Type Hints](#type-hints)
4. [Documentation](#documentation)
5. [Error Handling](#error-handling)
6. [Testing](#testing)
7. [Security](#security)
8. [Performance](#performance)
9. [Common Patterns](#common-patterns)

## Code Layout

### Imports
Organize imports in this order:
1. Standard library imports
2. Related third-party imports
3. Local application/library imports

Use blank lines to separate groups.

```python
# Standard library
import os
import sys
from pathlib import Path
from typing import Any, Optional

# Third-party
import requests
from pydantic import BaseModel

# Local
from myapp.models import User
from myapp.utils import validate_email
```

### Line Length
- Maximum line length: 120 characters (configured in black)
- Break long lines at logical points
- Use parentheses for implicit line continuation

```python
# Good
result = some_function(
    argument1,
    argument2,
    argument3,
    keyword_arg=value,
)

# Also good for single expression
result = (
    long_variable_name
    + another_variable
    + third_variable
)
```

### Blank Lines
- Two blank lines between top-level functions and classes
- One blank line between methods in a class
- Use blank lines sparingly within functions

## Naming Conventions

### General Rules
- `snake_case` for functions, variables, and module names
- `PascalCase` for class names
- `UPPER_SNAKE_CASE` for constants
- `_leading_underscore` for internal/private members
- `__double_leading_underscore` for name mangling

```python
# Constants
MAX_CONNECTIONS = 100
DEFAULT_TIMEOUT = 30

# Classes
class UserAccount:
    pass

# Functions and variables
def calculate_total(item_prices: list[float]) -> float:
    total_amount = sum(item_prices)
    return total_amount

# Private members
class DatabaseConnection:
    def __init__(self):
        self._connection = None  # Internal use
        self.__secret_key = None  # Name mangling
```

### Descriptive Names
- Use intention-revealing names
- Avoid abbreviations unless widely known
- Be specific rather than generic

```python
# Bad
def proc(d):
    t = d * 0.1
    return d + t

# Good
def calculate_price_with_tax(price: float) -> float:
    tax_amount = price * 0.1
    return price + tax_amount
```

## Type Hints

### Always Use Type Hints
Type hints improve code clarity and enable better IDE support.

```python
from typing import Optional, Union, Any
from collections.abc import Sequence, Mapping

# Simple types
def greet(name: str) -> str:
    return f"Hello, {name}"

# Optional types
def find_user(user_id: int) -> Optional[User]:
    return database.get(user_id)

# Union types (Python 3.10+)
def process_id(id: int | str) -> str:
    return str(id)

# Collections
def sum_numbers(numbers: Sequence[int]) -> int:
    return sum(numbers)

# Generics
from typing import TypeVar
T = TypeVar('T')

def first(items: Sequence[T]) -> Optional[T]:
    return items[0] if items else None
```

### Type Aliases
Create type aliases for complex types:

```python
from typing import TypeAlias

UserId: TypeAlias = int
UserData: TypeAlias = dict[str, Any]
ValidationResult: TypeAlias = tuple[bool, list[str]]

def validate_user(user: UserData) -> ValidationResult:
    errors = []
    # Validation logic
    is_valid = len(errors) == 0
    return is_valid, errors
```

## Documentation

### Docstrings
Use Google style docstrings:

```python
def calculate_discount(price: float, discount_percent: float, max_discount: float = 100.0) -> float:
    """Calculate the discounted price.
    
    This function applies a percentage discount to a price, ensuring the discount
    does not exceed the maximum allowed discount amount.
    
    Args:
        price: The original price of the item
        discount_percent: Discount percentage (0-100)
        max_discount: Maximum discount amount allowed (default: 100.0)
    
    Returns:
        The final price after applying the discount
    
    Raises:
        ValueError: If price is negative or discount_percent is not in range 0-100
    
    Example:
        >>> calculate_discount(100.0, 10.0)
        90.0
        >>> calculate_discount(1000.0, 20.0, max_discount=100.0)
        900.0
    """
    if price < 0:
        raise ValueError("Price cannot be negative")
    if not 0 <= discount_percent <= 100:
        raise ValueError("Discount percent must be between 0 and 100")
    
    discount = min(price * (discount_percent / 100), max_discount)
    return price - discount
```

## Error Handling

### Use Specific Exceptions
```python
# Bad
try:
    result = risky_operation()
except:
    pass

# Good
try:
    result = risky_operation()
except ValueError as e:
    logger.error(f"Invalid value: {e}")
    raise
except ConnectionError as e:
    logger.error(f"Connection failed: {e}")
    return default_value
```

### Custom Exceptions
```python
class ApplicationError(Exception):
    """Base exception for application errors."""
    pass

class ValidationError(ApplicationError):
    """Raised when validation fails."""
    pass

class DatabaseError(ApplicationError):
    """Raised when database operations fail."""
    pass

def create_user(email: str) -> User:
    if not is_valid_email(email):
        raise ValidationError(f"Invalid email address: {email}")
    # Create user
```

## Testing

### Test Structure
```python
import pytest
from myapp.models import User
from myapp.services import UserService

@pytest.fixture
def user_service():
    """Provide a UserService instance for testing."""
    return UserService()

@pytest.fixture
def sample_user():
    """Provide a sample user for testing."""
    return User(name="John Doe", email="john@example.com")

class TestUserService:
    """Tests for UserService."""
    
    def test_create_user_success(self, user_service):
        """Test successful user creation."""
        user = user_service.create_user("Jane", "jane@example.com")
        assert user.name == "Jane"
        assert user.email == "jane@example.com"
    
    def test_create_user_invalid_email(self, user_service):
        """Test user creation with invalid email raises ValueError."""
        with pytest.raises(ValueError, match="Invalid email"):
            user_service.create_user("Jane", "invalid-email")
    
    @pytest.mark.parametrize("name,email,expected_valid", [
        ("John", "john@example.com", True),
        ("", "test@example.com", False),
        ("Jane", "invalid", False),
    ])
    def test_validate_user_data(self, user_service, name, email, expected_valid):
        """Test user data validation with various inputs."""
        result = user_service.validate_user_data(name, email)
        assert result == expected_valid
```

## Security

### Input Validation
```python
import re
from typing import Optional

def sanitize_filename(filename: str) -> str:
    """Remove potentially dangerous characters from filename."""
    # Remove path traversal attempts
    filename = os.path.basename(filename)
    # Remove special characters
    filename = re.sub(r'[^\w\s.-]', '', filename)
    return filename

def validate_user_input(user_input: str, max_length: int = 255) -> Optional[str]:
    """Validate and sanitize user input."""
    if not user_input or len(user_input) > max_length:
        return None
    # Remove potentially dangerous content
    cleaned = user_input.strip()
    # Additional validation as needed
    return cleaned
```

### Secrets Management
```python
import os
from typing import Optional

def get_secret(secret_name: str) -> str:
    """Retrieve secret from environment or secret manager."""
    # Never hardcode secrets!
    secret = os.environ.get(secret_name)
    if not secret:
        raise ValueError(f"Secret {secret_name} not found in environment")
    return secret

# Usage
DATABASE_PASSWORD = get_secret("DATABASE_PASSWORD")
API_KEY = get_secret("API_KEY")
```

### SQL Injection Prevention
```python
import sqlite3

# Bad - SQL injection vulnerable
def get_user_bad(user_id: str):
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    query = f"SELECT * FROM users WHERE id = {user_id}"  # NEVER DO THIS!
    cursor.execute(query)
    return cursor.fetchone()

# Good - Parameterized query
def get_user(user_id: int):
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    query = "SELECT * FROM users WHERE id = ?"
    cursor.execute(query, (user_id,))
    return cursor.fetchone()
```

## Performance

### List Comprehensions
```python
# Good for simple transformations
squares = [x**2 for x in range(10)]
even_squares = [x**2 for x in range(10) if x % 2 == 0]

# Generator expressions for large datasets
large_sum = sum(x**2 for x in range(1000000))
```

### Use Built-in Functions
```python
# Slow
total = 0
for item in items:
    total += item.price

# Fast
total = sum(item.price for item in items)

# Slow
found = False
for item in items:
    if item.id == search_id:
        found = True
        break

# Fast
found = any(item.id == search_id for item in items)
```

## Common Patterns

### Context Managers
```python
from contextlib import contextmanager
import time

@contextmanager
def timer(name: str):
    """Context manager to time code execution."""
    start = time.time()
    try:
        yield
    finally:
        duration = time.time() - start
        print(f"{name} took {duration:.2f} seconds")

# Usage
with timer("database query"):
    results = database.query()
```

### Dataclasses
```python
from dataclasses import dataclass, field
from typing import Optional

@dataclass
class Product:
    """Product information."""
    name: str
    price: float
    description: str = ""
    tags: list[str] = field(default_factory=list)
    stock: int = 0
    
    def __post_init__(self):
        """Validate after initialization."""
        if self.price < 0:
            raise ValueError("Price cannot be negative")
        if self.stock < 0:
            raise ValueError("Stock cannot be negative")
```

### Dependency Injection
```python
from typing import Protocol

class Database(Protocol):
    """Database interface."""
    def get(self, id: int) -> Optional[dict]:
        ...
    def save(self, data: dict) -> int:
        ...

class UserService:
    """Service for user operations."""
    
    def __init__(self, database: Database):
        self.database = database
    
    def get_user(self, user_id: int) -> Optional[User]:
        data = self.database.get(user_id)
        return User(**data) if data else None
```

## Additional Resources

- [PEP 8](https://pep8.org/) - Official Python Style Guide
- [PEP 484](https://peps.python.org/pep-0484/) - Type Hints
- [Black Documentation](https://black.readthedocs.io/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [pytest Documentation](https://docs.pytest.org/)
