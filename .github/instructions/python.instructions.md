---
applyTo: "**/*.py"
description: Python 3.12 coding standards and best practices
---

# Python 3.12 Development Standards

## Language Version
- **Required**: Python 3.12+ (minimum 3.12)
- **Type Hints**: Mandatory for all public APIs (PEP 484, PEP 604, PEP 695)
- **Pattern Matching**: Use `match` statements for complex conditionals (PEP 634)
- **Type Parameter Syntax**: Use new generic syntax (PEP 695)
- **f-string Improvements**: Leverage nested f-strings and debug format
- **Exception Groups**: Use for concurrent error handling (PEP 654)

## Code Formatting & Linting

- **Linter**: `ruff` (fast, comprehensive) with all stable rules enabled
- **Formatter**: `black` with 120 character line length
- **Import Sorting**: `ruff` import sorting (replaces isort)
- **Type Checking**: `mypy` in strict mode or `pyright`
- **Security**: `bandit` for security vulnerability scanning
- **Docstring**: `pydocstyle` for docstring consistency

### Configuration (pyproject.toml)
```toml
[tool.black]
line-length = 120
target-version = ['py312']
preview = true

[tool.ruff]
line-length = 120
target-version = "py312"
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "UP",   # pyupgrade
    "ARG",  # flake8-unused-arguments
    "SIM",  # flake8-simplify
    "TCH",  # flake8-type-checking
    "DTZ",  # flake8-datetimez
    "RUF",  # Ruff-specific rules
    "PTH",  # flake8-use-pathlib
    "ASYNC", # flake8-async
    "S",    # flake8-bandit (security)
]
ignore = ["E501"]  # Line length handled by black
fixable = ["ALL"]

[tool.ruff.per-file-ignores]
"tests/**/*.py" = ["S101"]  # Allow assert in tests

[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_generics = true
check_untyped_defs = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_unreachable = true
strict_equality = true

[tool.pytest.ini_options]
minversion = "7.0"
testpaths = ["tests"]
python_files = "test_*.py"
python_classes = "Test*"
python_functions = "test_*"
addopts = [
    "--strict-markers",
    "--cov=src",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-fail-under=80",
]

[tool.coverage.run]
branch = true
source = ["src"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
]
```

## Modern Python 3.12 Features

### Type Parameter Syntax (PEP 695)
```python
# New generic syntax in Python 3.12
from typing import Protocol

# Generic class with type parameter
class Stack[T]:
    def __init__(self) -> None:
        self._items: list[T] = []
    
    def push(self, item: T) -> None:
        self._items.append(item)
    
    def pop(self) -> T | None:
        return self._items.pop() if self._items else None

# Generic function with constraints
def find_max[T: (int, float)](items: list[T]) -> T | None:
    return max(items) if items else None

# Type alias with parameters
type Point[T] = tuple[T, T]
type IntPoint = Point[int]

# Protocol with type parameter
class Comparable[T](Protocol):
    def __lt__(self, other: T) -> bool: ...
    def __le__(self, other: T) -> bool: ...
```

### Pattern Matching (Enhanced)
```python
from dataclasses import dataclass
from typing import assert_never

@dataclass
class Success[T]:
    value: T

@dataclass
class Error:
    message: str
    code: int | None = None

Result[T] = Success[T] | Error

def process_result[T](result: Result[T]) -> str:
    match result:
        case Success(value=val) if val is not None:
            return f"Success: {val}"
        case Success(value=None):
            return "Success with null value"
        case Error(message=msg, code=code) if code and code >= 500:
            return f"Server error {code}: {msg}"
        case Error(message=msg, code=code) if code:
            return f"Error {code}: {msg}"
        case Error(message=msg):
            return f"Error: {msg}"
        case _:
            assert_never(result)

# Advanced pattern matching with guards
def categorize_data(data: object) -> str:
    match data:
        case list() as lst if len(lst) > 10:
            return f"Large list with {len(lst)} items"
        case list() as lst:
            return f"Small list with {len(lst)} items"
        case dict() as d if "id" in d:
            return f"Dictionary with id: {d['id']}"
        case str() as s if s.startswith("http"):
            return f"URL: {s}"
        case int() | float() as num if num < 0:
            return f"Negative number: {num}"
        case _:
            return f"Unknown type: {type(data).__name__}"
```

### Exception Groups & Error Handling
```python
import asyncio
from typing import Never

class ValidationError(Exception):
    """Base exception for validation errors."""
    pass

class FieldError(ValidationError):
    """Error for field-level validation."""
    def __init__(self, field: str, message: str) -> None:
        self.field = field
        super().__init__(f"{field}: {message}")

async def validate_data(data: dict[str, any]) -> None:
    """Validate data using exception groups for multiple errors."""
    errors: list[Exception] = []
    
    if "email" not in data:
        errors.append(FieldError("email", "required field"))
    elif "@" not in data["email"]:
        errors.append(FieldError("email", "invalid format"))
    
    if "age" in data and data["age"] < 0:
        errors.append(FieldError("age", "must be positive"))
    
    if errors:
        raise ExceptionGroup("Validation failed", errors)

# Handling exception groups
async def process_user_data(data: dict[str, any]) -> dict[str, any]:
    try:
        await validate_data(data)
        return {"status": "success", "data": data}
    except* FieldError as eg:
        # Handle each field error
        field_errors = {
            e.field: str(e) for e in eg.exceptions
        }
        return {"status": "error", "errors": field_errors}
    except* Exception as eg:
        # Handle any other exceptions
        return {"status": "error", "message": "Unexpected error occurred"}
```

### Enhanced f-strings and String Formatting
```python
from datetime import datetime
from decimal import Decimal

# Debug f-strings with = specifier
value = 42
result = f"{value=}, {value*2=}, {value**2=}"

# Nested f-strings (Python 3.12+)
width = 10
precision = 2
number = 3.14159
formatted = f"{number:.{precision}f:>{width}}"

# Multi-line f-strings with proper formatting
def format_report(data: dict[str, any]) -> str:
    return f"""
    Report Generated: {datetime.now():%Y-%m-%d %H:%M:%S}
    =====================================
    Total Items: {data.get('count', 0):,}
    Average Value: ${data.get('avg', 0):.2f}
    Status: {data.get('status', 'N/A').upper()}
    
    Details:
    {chr(10).join(f'  - {k}: {v}' for k, v in data.items())}
    """

# Using format specifications with type hints
def format_currency(amount: Decimal, currency: str = "USD") -> str:
    return f"{currency} {amount:,.2f}"
```

## Async/Await Best Practices

```python
import asyncio
from collections.abc import AsyncIterator, Coroutine
from contextlib import asynccontextmanager
from typing import Any, TypeVar

T = TypeVar("T")

# Async context manager
@asynccontextmanager
async def database_connection() -> AsyncIterator[Connection]:
    conn = await create_connection()
    try:
        yield conn
    finally:
        await conn.close()

# Async generator with proper typing
async def fetch_pages(urls: list[str]) -> AsyncIterator[str]:
    async with aiohttp.ClientSession() as session:
        for url in urls:
            async with session.get(url) as response:
                yield await response.text()

# Task group for concurrent operations (Python 3.11+)
async def process_items_concurrently[T](
    items: list[T],
    processor: Callable[[T], Coroutine[Any, Any, Any]]
) -> list[Any]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(processor(item)) for item in items]
    return [task.result() for task in tasks]

# Async retry decorator with exponential backoff
def async_retry(
    max_attempts: int = 3,
    delay: float = 1.0,
    backoff: float = 2.0,
    exceptions: tuple[type[Exception], ...] = (Exception,)
) -> Callable[[Callable[..., Coroutine[Any, Any, T]]], Callable[..., Coroutine[Any, Any, T]]]:
    def decorator(func: Callable[..., Coroutine[Any, Any, T]]) -> Callable[..., Coroutine[Any, Any, T]]:
        async def wrapper(*args: Any, **kwargs: Any) -> T:
            attempt_delay = delay
            for attempt in range(max_attempts):
                try:
                    return await func(*args, **kwargs)
                except exceptions as e:
                    if attempt == max_attempts - 1:
                        raise
                    await asyncio.sleep(attempt_delay)
                    attempt_delay *= backoff
            raise RuntimeError(f"Failed after {max_attempts} attempts")
        return wrapper
    return decorator
```

## Type Hinting Best Practices

```python
from collections.abc import Callable, Sequence, Mapping
from typing import (
    Any, ClassVar, Final, Literal, NewType, NotRequired,
    Protocol, Required, Self, TypeAlias, TypedDict, TypeGuard,
    assert_never, overload, reveal_type
)

# Type aliases for readability
UserId = NewType("UserId", int)
Email = NewType("Email", str)
type JsonValue = None | bool | int | float | str | list[JsonValue] | dict[str, JsonValue]

# TypedDict for structured data
class UserData(TypedDict, total=False):
    id: Required[UserId]
    email: Required[Email]
    name: Required[str]
    age: NotRequired[int]
    metadata: NotRequired[dict[str, Any]]

# Protocol for structural subtyping
class Drawable(Protocol):
    def draw(self) -> None: ...
    @property
    def visible(self) -> bool: ...

# Type guards for runtime checking
def is_valid_email(value: str) -> TypeGuard[Email]:
    return "@" in value and "." in value.split("@")[1]

# Overloading for different signatures
@overload
def process(data: str) -> str: ...

@overload
def process(data: int) -> int: ...

@overload
def process(data: list[T]) -> list[T]: ...

def process(data: str | int | list[T]) -> str | int | list[T]:
    match data:
        case str():
            return data.upper()
        case int():
            return data * 2
        case list():
            return data[::-1]
        case _:
            assert_never(data)

# Self type for fluent interfaces
class Builder:
    def __init__(self) -> None:
        self._config: dict[str, Any] = {}
    
    def set(self, key: str, value: Any) -> Self:
        self._config[key] = value
        return self
    
    def build(self) -> dict[str, Any]:
        return self._config.copy()
```

## Testing Best Practices

```python
# tests/test_example.py
import pytest
from unittest.mock import Mock, AsyncMock, patch
from hypothesis import given, strategies as st
import pytest_asyncio
from freezegun import freeze_time

# Fixtures with proper typing
@pytest.fixture
def user_data() -> UserData:
    return UserData(
        id=UserId(1),
        email=Email("test@example.com"),
        name="Test User"
    )

# Async fixtures
@pytest_asyncio.fixture
async def async_client() -> AsyncIterator[AsyncClient]:
    async with AsyncClient(app=app) as client:
        yield client

# Parametrized tests with multiple scenarios
@pytest.mark.parametrize(
    "input_value,expected",
    [
        ("hello", "HELLO"),
        ("World", "WORLD"),
        ("", ""),
        ("123", "123"),
    ],
    ids=["lowercase", "mixed", "empty", "numbers"]
)
def test_uppercase_conversion(input_value: str, expected: str) -> None:
    assert input_value.upper() == expected

# Property-based testing with Hypothesis
@given(
    numbers=st.lists(
        st.integers(min_value=-1000, max_value=1000),
        min_size=1,
        max_size=100
    )
)
def test_sum_properties(numbers: list[int]) -> None:
    total = sum(numbers)
    assert sum(numbers[::-1]) == total  # Order doesn't matter
    assert sum(numbers + [0]) == total  # Adding zero doesn't change sum

# Async testing
@pytest.mark.asyncio
async def test_async_operation() -> None:
    result = await fetch_data("https://api.example.com/data")
    assert result is not None
    assert "status" in result

# Testing exception groups
@pytest.mark.asyncio
async def test_validation_errors() -> None:
    invalid_data = {"email": "invalid"}
    
    with pytest.raises(ExceptionGroup) as exc_info:
        await validate_data(invalid_data)
    
    group = exc_info.value
    assert len(group.exceptions) == 1
    assert isinstance(group.exceptions[0], FieldError)

# Mocking with type safety
def test_service_with_mock() -> None:
    mock_repo = Mock(spec=Repository)
    mock_repo.find.return_value = User(id=1, name="Test")
    
    service = UserService(mock_repo)
    user = service.get_user(1)
    
    assert user.name == "Test"
    mock_repo.find.assert_called_once_with(1)

# Time-based testing
@freeze_time("2024-01-01 12:00:00")
def test_timestamp_creation() -> None:
    obj = TimestampedModel()
    assert obj.created_at == datetime(2024, 1, 1, 12, 0, 0)
```

## Code Organization & Architecture

```python
# src/domain/models.py
from dataclasses import dataclass, field
from datetime import datetime
from uuid import UUID, uuid4

@dataclass(frozen=True, slots=True)
class Entity:
    """Base class for domain entities."""
    id: UUID = field(default_factory=uuid4)
    created_at: datetime = field(default_factory=datetime.utcnow)
    updated_at: datetime = field(default_factory=datetime.utcnow)

# src/domain/value_objects.py
@dataclass(frozen=True, slots=True)
class Money:
    """Value object representing money."""
    amount: Decimal
    currency: Literal["USD", "EUR", "GBP"]
    
    def __post_init__(self) -> None:
        if self.amount < 0:
            raise ValueError("Amount cannot be negative")
    
    def add(self, other: Self) -> Self:
        if self.currency != other.currency:
            raise ValueError("Cannot add different currencies")
        return Money(self.amount + other.amount, self.currency)

# src/application/services.py
from typing import Protocol

class Repository(Protocol):
    """Repository interface."""
    async def save(self, entity: Entity) -> None: ...
    async def find(self, id: UUID) -> Entity | None: ...
    async def delete(self, id: UUID) -> None: ...

class UserService:
    """Application service for user management."""
    
    def __init__(self, repo: Repository) -> None:
        self._repo = repo
    
    async def create_user(self, data: UserData) -> User:
        user = User.from_data(data)
        await self._repo.save(user)
        return user
```

## Performance Optimization

```python
from functools import cache, lru_cache
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import multiprocessing as mp

# Use slots for memory efficiency
@dataclass(slots=True)
class Point:
    x: float
    y: float
    z: float

# Cache expensive computations
@cache  # Unbounded cache for pure functions
def fibonacci(n: int) -> int:
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

@lru_cache(maxsize=128)  # Limited cache with LRU eviction
def expensive_computation(param: str) -> str:
    # Expensive operation
    return result

# Use generators for memory efficiency
def read_large_file(path: Path) -> Iterator[str]:
    with open(path) as f:
        for line in f:
            yield line.strip()

# Parallel processing for CPU-bound tasks
def process_parallel(items: list[T], func: Callable[[T], R]) -> list[R]:
    with ProcessPoolExecutor(max_workers=mp.cpu_count()) as executor:
        return list(executor.map(func, items))

# Use __slots__ to reduce memory footprint
class OptimizedClass:
    __slots__ = ("_x", "_y", "_cache")
    
    def __init__(self, x: int, y: int) -> None:
        self._x = x
        self._y = y
        self._cache: dict[str, Any] = {}
```

## Security Best Practices

```python
import secrets
import hashlib
from pathlib import Path
import hmac

# Input validation
def validate_username(username: str) -> str:
    """Validate and sanitize username."""
    if not username or len(username) > 50:
        raise ValueError("Invalid username length")
    
    # Allow only alphanumeric and certain special characters
    if not username.replace("_", "").replace("-", "").isalnum():
        raise ValueError("Username contains invalid characters")
    
    return username.lower().strip()

# Secure random generation
def generate_secure_token(length: int = 32) -> str:
    """Generate cryptographically secure random token."""
    return secrets.token_urlsafe(length)

# Password hashing (use bcrypt or argon2 in production)
def hash_password(password: str, salt: bytes | None = None) -> tuple[str, bytes]:
    """Hash password with salt."""
    if salt is None:
        salt = secrets.token_bytes(32)
    
    key = hashlib.pbkdf2_hmac(
        "sha256",
        password.encode("utf-8"),
        salt,
        100_000  # iterations
    )
    return key.hex(), salt

# Path traversal prevention
def safe_path_join(base: Path, *parts: str) -> Path:
    """Safely join path components preventing traversal attacks."""
    base = base.resolve()
    path = base.joinpath(*parts).resolve()
    
    if not path.is_relative_to(base):
        raise ValueError("Path traversal attempt detected")
    
    return path

# SQL injection prevention (use ORM or parameterized queries)
async def get_user_by_email(email: str) -> User | None:
    """Fetch user by email using parameterized query."""
    query = "SELECT * FROM users WHERE email = $1"
    result = await db.fetch_one(query, email)
    return User(**result) if result else None
```

## Documentation Standards

```python
"""Module for user management functionality.

This module provides classes and functions for managing user accounts,
including creation, authentication, and authorization.

Examples:
    Basic usage::
    
        >>> from user_management import UserService
        >>> service = UserService()
        >>> user = await service.create_user({"email": "test@example.com"})
        >>> print(user.id)
"""

from typing import Final

# Module-level constants with documentation
MAX_LOGIN_ATTEMPTS: Final[int] = 5
"""Maximum number of login attempts before account lockout."""

class UserService:
    """Service for managing user accounts.
    
    This service provides methods for creating, updating, and deleting
    user accounts with proper validation and authorization.
    
    Attributes:
        repository: User repository for data persistence
        validator: Validator for user data validation
        cache: Optional cache for performance optimization
    
    Examples:
        Create a new user::
        
            service = UserService(repo, validator)
            user = await service.create_user({
                "email": "user@example.com",
                "name": "John Doe"
            })
    """
    
    def __init__(
        self,
        repository: UserRepository,
        validator: UserValidator,
        cache: Cache | None = None
    ) -> None:
        """Initialize the user service.
        
        Args:
            repository: Repository for user persistence
            validator: Validator for user data
            cache: Optional cache implementation
        """
        self._repository = repository
        self._validator = validator
        self._cache = cache
    
    async def create_user(self, data: dict[str, Any]) -> User:
        """Create a new user account.
        
        Args:
            data: User data containing email, name, and optional fields
        
        Returns:
            Created user instance
        
        Raises:
            ValidationError: If data is invalid
            DuplicateEmailError: If email already exists
        
        Note:
            This method performs email uniqueness validation and
            sends a welcome email upon successful creation.
        """
        # Implementation
```

## Logging & Monitoring

```python
import logging
import structlog
from contextlib import contextmanager
from time import perf_counter

# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Context manager for performance monitoring
@contextmanager
def monitor_performance(operation: str) -> Iterator[None]:
    """Monitor operation performance."""
    start = perf_counter()
    logger.info("operation_started", operation=operation)
    
    try:
        yield
    except Exception as e:
        logger.error(
            "operation_failed",
            operation=operation,
            error=str(e),
            duration=perf_counter() - start
        )
        raise
    else:
        logger.info(
            "operation_completed",
            operation=operation,
            duration=perf_counter() - start
        )

# Decorator for method logging
def log_method_calls(level: str = "info") -> Callable:
    """Log method calls with arguments and results."""
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def async_wrapper(*args: Any, **kwargs: Any) -> Any:
            logger.log(
                level,
                "method_called",
                method=func.__name__,
                args=args[1:] if args else [],  # Skip self
                kwargs=kwargs
            )
            try:
                result = await func(*args, **kwargs)
                logger.log(level, "method_completed", method=func.__name__)
                return result
            except Exception as e:
                logger.error(
                    "method_failed",
                    method=func.__name__,
                    error=str(e)
                )
                raise
        
        @wraps(func)
        def sync_wrapper(*args: Any, **kwargs: Any) -> Any:
            # Similar implementation for sync methods
            pass
        
        return async_wrapper if asyncio.iscoroutinefunction(func) else sync_wrapper
    return decorator
```

## Common Anti-Patterns to Avoid

### ❌ Don't Do This
```python
# Mutable default arguments
def add_item(item, items=[]):  # Bad!
    items.append(item)
    return items

# Bare except clauses
try:
    risky_operation()
except:  # Too broad!
    pass

# Using == for None comparison
if value == None:  # Use 'is' instead
    pass

# Not using context managers
f = open("file.txt")
data = f.read()
f.close()  # What if read() raises?
```

### ✅ Do This Instead
```python
# Use None as default, create new list
def add_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items

# Catch specific exceptions
try:
    risky_operation()
except (ValueError, TypeError) as e:
    logger.error("Operation failed", error=str(e))
    raise

# Use 'is' for None comparison
if value is None:
    pass

# Always use context managers
with open("file.txt") as f:
    data = f.read()
```

## IDE Configuration

### VS Code settings.json
```json
{
    "python.linting.enabled": true,
    "python.linting.ruffEnabled": true,
    "python.formatting.provider": "black",
    "python.formatting.blackArgs": ["--line-length", "120"],
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false,
    "python.analysis.typeCheckingMode": "strict",
    "python.analysis.autoImportCompletions": true,
    "[python]": {
        "editor.formatOnSave": true,
        "editor.codeActionsOnSave": {
            "source.organizeImports": true
        }
    }
}
```

## Additional Resources

- [Python 3.12 Release Notes](https://docs.python.org/3/whatsnew/3.12.html)
- [PEP 695 - Type Parameter Syntax](https://peps.python.org/pep-0695/)
- [Effective Python by Brett Slatkin](https://effectivepython.com/)
- [Python Type Hints Cheat Sheet](https://mypy.readthedocs.io/en/stable/cheat_sheet_py3.html)
- [Async/Await Best Practices](https://docs.python.org/3/library/asyncio-task.html)
