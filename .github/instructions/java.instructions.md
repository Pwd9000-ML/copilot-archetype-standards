---
applyTo: "**/*.java"
description: Java coding standards and best practices
---

# Java Development Standards

## Language Version
- Use Java 17 LTS or later (Java 21 LTS recommended)
- Enable preview features only when necessary and document why
- Use modern Java features (records, sealed classes, pattern matching, etc.)

## Code Formatting & Linting

- **Build Tool**: Use Maven or Gradle (Gradle preferred for new projects)
- **Code Style**: Follow Google Java Style Guide
- **Formatter**: Use `google-java-format` or IDE formatter configured to match
- **Static Analysis**: Use SpotBugs, PMD, and Checkstyle
- **Line Length**: 120 characters maximum

### Maven Configuration Example
```xml
<plugin>
    <groupId>com.diffplug.spotless</groupId>
    <artifactId>spotless-maven-plugin</artifactId>
    <version>2.40.0</version>
    <configuration>
        <java>
            <googleJavaFormat>
                <version>1.18.1</version>
                <style>GOOGLE</style>
            </googleJavaFormat>
        </java>
    </configuration>
</plugin>
```

## Testing

- **Framework**: Use JUnit 5 (Jupiter)
- **Mocking**: Use Mockito for mocking dependencies
- **Assertions**: Use AssertJ for fluent assertions
- **Location**: Place tests in `src/test/java` (Maven structure)
- **Naming**: Test classes should end with `Test` (e.g., `UserServiceTest`)
- **Coverage**: Aim for >80% code coverage using JaCoCo

### Test Structure
```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.assertj.core.api.Assertions.*;

class UserServiceTest {
    private UserService userService;
    
    @BeforeEach
    void setUp() {
        userService = new UserService();
    }
    
    @Test
    void testCreateUser_Success() {
        User user = userService.createUser("John", "john@example.com");
        assertThat(user).isNotNull();
        assertThat(user.getName()).isEqualTo("John");
    }
    
    @Test
    void testCreateUser_InvalidEmail_ThrowsException() {
        assertThatThrownBy(() -> userService.createUser("John", "invalid"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid email");
    }
}
```

## Code Style

- Use meaningful names for classes, methods, and variables
- Follow Java naming conventions:
  - `PascalCase` for classes and interfaces
  - `camelCase` for methods and variables
  - `UPPER_SNAKE_CASE` for constants
- Prefer composition over inheritance
- Use interfaces for abstraction
- Favor immutability (use `final` liberally, prefer records for data classes)

### Modern Java Features
```java
// Use records for data classes
public record User(String name, String email, LocalDate birthDate) {
    // Compact constructor for validation
    public User {
        Objects.requireNonNull(name, "Name cannot be null");
        Objects.requireNonNull(email, "Email cannot be null");
    }
}

// Use sealed classes for restricted hierarchies
public sealed interface Shape permits Circle, Rectangle, Triangle {}

// Use pattern matching
public double calculateArea(Shape shape) {
    return switch (shape) {
        case Circle c -> Math.PI * c.radius() * c.radius();
        case Rectangle r -> r.width() * r.height();
        case Triangle t -> 0.5 * t.base() * t.height();
    };
}
```

## Documentation

- Use Javadoc for all public APIs
- Include `@param`, `@return`, `@throws` tags
- Provide usage examples in class-level Javadoc
- Keep comments up-to-date with code changes

### Example
```java
/**
 * Service for managing user accounts.
 * 
 * <p>This service provides methods for creating, updating, and deleting user accounts.
 * All operations are transactional and thread-safe.
 * 
 * <p>Example usage:
 * <pre>{@code
 * UserService service = new UserService(repository);
 * User user = service.createUser("John Doe", "john@example.com");
 * }</pre>
 */
public class UserService {
    /**
     * Creates a new user account.
     * 
     * @param name the user's full name, must not be null or empty
     * @param email the user's email address, must be valid format
     * @return the created user with generated ID
     * @throws IllegalArgumentException if name or email is invalid
     * @throws DuplicateUserException if email already exists
     */
    public User createUser(String name, String email) {
        // Implementation
    }
}
```

## Error Handling

- Use specific exception types
- Create custom exceptions for domain-specific errors
- Don't catch generic `Exception` unless re-throwing
- Use try-with-resources for AutoCloseable resources
- Log exceptions with appropriate context

## Dependencies

- Use dependency injection (Spring, Guice, or CDI)
- Keep dependencies up-to-date and minimal
- Use Bill of Materials (BOM) for version management
- Avoid circular dependencies

## Additional Resources

See [Java Style Guide](../docs/java-style.md) for extended guidelines.
