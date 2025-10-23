---
applyTo: "**/*.py"
description: Python 3.12 coding standards and best practices
---

# Python 3.12 Development Standards

## Language Version
- **Required**: Python 3.12+
- **Type Hints**: Mandatory for all public APIs (PEP 484, 604, 695)
- **Pattern Matching**: Use `match` for complex conditionals (PEP 634)
- **Type Parameter Syntax**: New generic syntax (PEP 695)
- **Exception Groups**: For concurrent error handling (PEP 654)

## Code Formatting & Linting

- **Linter**: `ruff` with all stable rules
- **Formatter**: `black` (120 char line length)
- **Type Checking**: `mypy` strict mode or `pyright`
- **Security**: `bandit` for vulnerability scanning

### Configuration (pyproject.toml)
```toml
[tool.black]
line-length = 120
target-version = ['py312']

[tool.ruff]
line-length = 120
target-version = "py312"
select = ["E", "W", "F", "I", "B", "UP", "SIM", "S"]
ignore = ["E501"]

[tool.mypy]
python_version = "3.12"
strict = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
# By default, pytest discovers tests in files matching 'test_*.py' or '*_test.py',
# in classes named 'Test*', and functions named 'test_*'.
testpaths = ["tests"]
addopts = ["--strict-markers", "--cov=src", "--cov-fail-under=80"]
```

## Modern Python 3.12 Features

### Type Parameter Syntax (PEP 695)
```python
# Generic class
class Stack[T]:
    def __init__(self) -> None:
        self._items: list[T] = []
    
    def push(self, item: T) -> None:
        self._items.append(item)
    
    def pop(self) -> T | None:
        return self._items.pop() if self._items else None

# Type alias with parameters
type Point[T] = tuple[T, T]
type IntPoint = Point[int]
```

### Pattern Matching
```python
from dataclasses import dataclass

@dataclass
class Success[T]:
    value: T

@dataclass
class Error:
    message: str
    code: int | None = None

def process[T](result: Success[T] | Error) -> str:
    match result:
        case Success(value=val) if val is not None:
            return f"Success: {val}"
        case Error(message=msg, code=code) if code and code >= 500:
            return f"Server error {code}: {msg}"
        case Error(message=msg):
            return f"Error: {msg}"
```

### Exception Groups
```python
class ValidationError(Exception):
    pass

class FieldError(ValidationError):
    def __init__(self, field: str, message: str) -> None:
        self.field = field
        super().__init__(f"{field}: {message}")

async def validate(data: dict[str, any]) -> None:
    errors: list[Exception] = []
    if "email" not in data:
        errors.append(FieldError("email", "required"))
    if errors:
        raise ExceptionGroup("Validation failed", errors)

# Handle exception groups
async def process(data: dict) -> dict:
    try:
        await validate(data)
        return {"status": "success"}
    except* FieldError as eg:
        return {"errors": {e.field: str(e) for e in eg.exceptions}}
```

### F-Strings
```python
# Debug format
value = 42
result = f"{value=}, {value*2=}"  # "value=42, value*2=84"

# Nested f-strings
width, precision = 10, 2
formatted = f"{3.14159:.{precision}f:>{width}}"
```

## Async/Await

```python
import asyncio
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

# Async context manager
@asynccontextmanager
async def database_connection() -> AsyncIterator[Connection]:
    conn = await create_connection()
    try:
        yield conn
    finally:
        await conn.close()

# Task group for concurrent operations
async def process_concurrently[T](items: list[T], processor) -> list:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(processor(item)) for item in items]
    return [task.result() for task in tasks]

# Async retry with exponential backoff
def async_retry(max_attempts=3, delay=1.0, backoff=2.0):
    def decorator(func):
        async def wrapper(*args, **kwargs):
            attempt_delay = delay
            for attempt in range(max_attempts):
                try:
                    return await func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    await asyncio.sleep(attempt_delay)
                    attempt_delay *= backoff
        return wrapper
    return decorator
```

## Type Hinting

```python
from typing import NewType, Protocol, TypedDict, TypeGuard, Required, NotRequired

# Type aliases
UserId = NewType("UserId", int)
type JsonValue = None | bool | int | float | str | list[JsonValue] | dict[str, JsonValue]

# TypedDict for structured data
class UserData(TypedDict, total=False):
    id: Required[UserId]
    email: Required[str]
    age: NotRequired[int]

# Protocol for structural subtyping
class Drawable(Protocol):
    def draw(self) -> None: ...

# Type guards
def is_valid_email(value: str) -> TypeGuard[str]:
    return "@" in value and "." in value.split("@")[1]
```

## Testing

```python
import pytest
from hypothesis import given, strategies as st

@pytest.fixture
def user_data() -> UserData:
    return UserData(id=UserId(1), email="test@ex.com")

@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"), ("", "")
], ids=["lowercase", "empty"])
def test_upper(input: str, expected: str) -> None:
    assert input.upper() == expected

# Property-based testing
@given(numbers=st.lists(st.integers(min_value=-1000, max_value=1000), min_size=1))
def test_sum_order(numbers: list[int]) -> None:
    assert sum(numbers[::-1]) == sum(numbers)

# Async testing
@pytest.mark.asyncio
async def test_async() -> None:
    result = await fetch_data("https://api.ex.com")
    assert result is not None

# Exception groups
@pytest.mark.asyncio
async def test_validation_errors() -> None:
    with pytest.raises(ExceptionGroup) as exc:
        await validate({"email": "invalid"})
    assert len(exc.value.exceptions) == 1
```

## Code Organization

```python
from dataclasses import dataclass, field
from datetime import datetime
from uuid import UUID, uuid4

@dataclass(frozen=True, slots=True)
class Entity:
    """Base class for domain entities."""
    id: UUID = field(default_factory=uuid4)
    created_at: datetime = field(default_factory=datetime.utcnow)

# Protocol for repositories
class Repository(Protocol):
    async def save(self, entity: Entity) -> None: ...
    async def find(self, id: UUID) -> Entity | None: ...
```

## Performance

```python
from functools import cache, lru_cache

# Use slots for memory efficiency
@dataclass(slots=True)
class Point:
    x: float
    y: float

# Cache expensive computations
@cache  # Unbounded cache
def fibonacci(n: int) -> int:
    return n if n < 2 else fibonacci(n-1) + fibonacci(n-2)

@lru_cache(maxsize=128)  # Limited LRU cache
def expensive(param: str) -> str:
    return result

# Use generators for memory efficiency
def read_large_file(path: Path) -> Iterator[str]:
    with open(path) as f:
        for line in f:
            yield line.strip()
```

## Security

```python
import secrets
import hashlib
from pathlib import Path

# Input validation
def validate_username(username: str) -> str:
    if not username or len(username) > 50:
        raise ValueError("Invalid length")
    if not username.replace("_", "").replace("-", "").isalnum():
        raise ValueError("Invalid characters")
    return username.lower().strip()

# Secure random generation
def generate_token(length: int = 32) -> str:
    return secrets.token_urlsafe(length)

# Password hashing
def hash_password(password: str, salt: bytes | None = None) -> tuple[str, bytes]:
    if salt is None:
        salt = secrets.token_bytes(32)
    key = hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 100_000)
    return key.hex(), salt

# Path traversal prevention
def safe_path_join(base: Path, *parts: str) -> Path:
    path = base.joinpath(*parts).resolve()
    if not path.is_relative_to(base):
        raise ValueError("Path traversal detected")
    return path

# SQL injection prevention - use parameterized queries
async def get_user(email: str) -> User | None:
    query = "SELECT * FROM users WHERE email = $1"
    result = await db.fetch_one(query, email)
    return User(**result) if result else None
```

## Documentation

```python
"""Module for user management.

Examples:
    >>> from user_management import UserService
    >>> service = UserService()
    >>> user = await service.create_user({"email": "test@ex.com"})
"""

class UserService:
    """Service for user account management.
    
    Args:
        repository: User repository for persistence
        validator: Data validator
    
    Examples:
        service = UserService(repo, validator)
        user = await service.create_user({"email": "user@ex.com"})
    """
    
    async def create_user(self, data: dict[str, Any]) -> User:
        """Create new user account.
        
        Args:
            data: User data with email, name, etc.
        
        Returns:
            Created user instance
        
        Raises:
            ValidationError: If data invalid
        """
```

## Anti-Patterns

### ❌ Avoid
```python
def add_item(item, items=[]):  # Mutable default
    items.append(item)

try:
    risky()
except:  # Too broad
    pass

if value == None:  # Use 'is'
    pass
```

### ✅ Prefer
```python
def add_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items

try:
    risky()
except (ValueError, TypeError) as e:
    log.error("Failed", error=str(e))

if value is None:
    pass

with open("file.txt") as f:  # Use context managers
    data = f.read()
```
