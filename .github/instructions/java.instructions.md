---
applyTo: "**/*.java"
description: Java 21 LTS coding standards and best practices
---

# Java 21 LTS Development Standards

## Language Version
- **Required**: Java 21 LTS (Long Term Support)
- **Virtual Threads**: Prefer virtual threads for I/O-bound operations
- **Preview Features**: Document usage with `--enable-preview` flag when necessary
- **Pattern Matching**: Use pattern matching for switch expressions and instanceof
- **Records**: Prefer records for immutable data carriers
- **Sealed Classes**: Use for controlled inheritance hierarchies

## Code Formatting & Linting

- **Build Tool**: Gradle 8.5+ (preferred) or Maven 3.9+
- **Code Style**: Google Java Style Guide with adjustments for Java 21
- **Formatter**: `google-java-format` v1.18+ or IDE formatter
- **Static Analysis**: SpotBugs, PMD, Checkstyle, ErrorProne
- **Line Length**: 120 characters maximum
- **Null Safety**: Use `@Nullable` and `@NonNull` annotations

### Gradle Configuration (Recommended)
```gradle
plugins {
    id 'java'
    id 'com.diffplug.spotless' version '6.23.0'
    id 'com.github.spotbugs' version '6.0.0'
    id 'net.ltgt.errorprone' version '3.1.0'
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

spotless {
    java {
        googleJavaFormat('1.18.1')
        removeUnusedImports()
        trimTrailingWhitespace()
        endWithNewline()
    }
}

tasks.withType(JavaCompile) {
    options.encoding = 'UTF-8'
    options.compilerArgs += ['-Xlint:all', '-Werror']
}
```

### Maven Configuration
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.11.0</version>
    <configuration>
        <release>21</release>
        <compilerArgs>
            <arg>-Xlint:all</arg>
            <arg>-Werror</arg>
        </compilerArgs>
    </configuration>
</plugin>

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

## Modern Java 21 Features

### Virtual Threads (Project Loom)
```java
// Prefer virtual threads for I/O-bound operations
public class UserService {
    private final ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
    
    public CompletableFuture<User> fetchUserAsync(String userId) {
        return CompletableFuture.supplyAsync(
            () -> fetchUserFromDatabase(userId),
            executor
        );
    }
    
    // For blocking I/O operations
    public List<User> fetchAllUsers() {
        try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
            return userIds.stream()
                .map(id -> executor.submit(() -> fetchUser(id)))
                .map(future -> {
                    try {
                        return future.get();
                    } catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                })
                .toList();
        }
    }
}
```

### Pattern Matching & Switch Expressions
```java
// Pattern matching with sealed classes
public sealed interface Result<T> permits Success<T>, Failure<T> {
    default T getOrThrow() {
        return switch (this) {
            case Success<T>(var value) -> value;
            case Failure<T>(var error) -> throw new RuntimeException(error);
        };
    }
}

// Record patterns in switch
public String formatShape(Shape shape) {
    return switch (shape) {
        case Circle(var radius) -> "Circle with radius: " + radius;
        case Rectangle(var width, var height) -> 
            "Rectangle: " + width + "x" + height;
        case Triangle(var base, var height) -> 
            "Triangle with base: " + base + ", height: " + height;
    };
}

// Guarded patterns
public String categorizeNumber(Object obj) {
    return switch (obj) {
        case Integer i when i < 0 -> "Negative integer: " + i;
        case Integer i when i > 0 -> "Positive integer: " + i;
        case Integer i -> "Zero";
        case Double d -> "Double: " + d;
        case null -> "Null value";
        default -> "Unknown type";
    };
}
```

### String Templates (Preview in Java 21)
```java
// When using --enable-preview
public String formatUser(User user) {
    // String template processor (preview feature)
    return STR."""
        User Details:
        Name: \{user.name()}
        Email: \{user.email()}
        Age: \{user.age()}
        Registration: \{user.registrationDate().format(DateTimeFormatter.ISO_DATE)}
        """;
}
```

### Sequenced Collections
```java
// Use new sequenced collection methods
public class OrderService {
    private final SequencedCollection<Order> recentOrders = new LinkedHashSet<>();
    
    public void processOrder(Order order) {
        recentOrders.addFirst(order);  // Add to beginning
        if (recentOrders.size() > 100) {
            recentOrders.removeLast();  // Remove oldest
        }
    }
    
    public Order getMostRecentOrder() {
        return recentOrders.getFirst();  // Get first element
    }
    
    public List<Order> getRecentOrdersReversed() {
        return recentOrders.reversed().stream().toList();
    }
}
```

## Testing

- **Framework**: JUnit 5.10+ (Jupiter)
- **Mocking**: Mockito 5.x
- **Assertions**: AssertJ 3.24+
- **Integration Tests**: Testcontainers for external dependencies
- **Performance Tests**: JMH for benchmarking
- **Mutation Testing**: PITest
- **Coverage**: Minimum 80% with JaCoCo

### Comprehensive Test Example
```java
import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.*;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    
    @Mock
    private UserRepository repository;
    
    private UserService userService;
    
    @BeforeEach
    void setUp() {
        userService = new UserService(repository);
    }
    
    @Nested
    @DisplayName("User Creation Tests")
    class UserCreation {
        
        @Test
        @DisplayName("Should create user with valid data")
        void createUser_ValidData_Success() {
            // Given
            var userData = new UserData("John", "john@example.com", 25);
            when(repository.save(any())).thenAnswer(i -> i.getArgument(0));
            
            // When
            var user = userService.createUser(userData);
            
            // Then
            assertThat(user)
                .isNotNull()
                .satisfies(u -> {
                    assertThat(u.name()).isEqualTo("John");
                    assertThat(u.email()).isEqualTo("john@example.com");
                    assertThat(u.age()).isEqualTo(25);
                });
            
            verify(repository).save(argThat(u -> 
                u.name().equals("John") && u.email().equals("john@example.com")
            ));
        }
        
        @ParameterizedTest
        @NullAndEmptySource
        @ValueSource(strings = {" ", "\t", "\n"})
        @DisplayName("Should reject invalid names")
        void createUser_InvalidName_ThrowsException(String name) {
            var userData = new UserData(name, "john@example.com", 25);
            
            assertThatThrownBy(() -> userService.createUser(userData))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Invalid name");
        }
        
        @ParameterizedTest
        @CsvSource({
            "invalid-email, Invalid email format",
            "@example.com, Invalid email format",
            "user@, Invalid email format"
        })
        @DisplayName("Should validate email format")
        void createUser_InvalidEmail_ThrowsException(String email, String expectedMessage) {
            var userData = new UserData("John", email, 25);
            
            assertThatThrownBy(() -> userService.createUser(userData))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining(expectedMessage);
        }
    }
    
    @Test
    @Timeout(value = 2, unit = TimeUnit.SECONDS)
    @DisplayName("Should handle concurrent user creation")
    void createUser_Concurrent_ThreadSafe() throws InterruptedException {
        var latch = new CountDownLatch(10);
        var errors = new CopyOnWriteArrayList<Exception>();
        
        IntStream.range(0, 10).forEach(i -> {
            Thread.startVirtualThread(() -> {
                try {
                    userService.createUser(
                        new UserData("User" + i, "user" + i + "@example.com", 20 + i)
                    );
                } catch (Exception e) {
                    errors.add(e);
                } finally {
                    latch.countDown();
                }
            });
        });
        
        assertThat(latch.await(2, TimeUnit.SECONDS)).isTrue();
        assertThat(errors).isEmpty();
    }
}
```

## Code Style & Best Practices

### Naming Conventions
- **Classes**: `PascalCase` (e.g., `UserService`)
- **Interfaces**: `PascalCase` without 'I' prefix (e.g., `Repository`, not `IRepository`)
- **Methods**: `camelCase` (e.g., `findUserById`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
- **Packages**: `lowercase` (e.g., `com.example.service`)

### Records and Data Classes
```java
// Use records for immutable data
public record UserDto(
    String id,
    String name,
    String email,
    Instant createdAt
) {
    // Compact constructor for validation
    public UserDto {
        Objects.requireNonNull(id, "ID cannot be null");
        Objects.requireNonNull(name, "Name cannot be null");
        Objects.requireNonNull(email, "Email cannot be null");
        
        if (!email.contains("@")) {
            throw new IllegalArgumentException("Invalid email format");
        }
    }
    
    // Additional methods if needed
    public UserDto withEmail(String newEmail) {
        return new UserDto(id, name, newEmail, createdAt);
    }
}
```

### Sealed Classes for Domain Modeling
```java
public sealed interface PaymentMethod 
    permits CreditCard, DebitCard, PayPal, BankTransfer {
    
    String getDescription();
    
    default double calculateFee(double amount) {
        return switch (this) {
            case CreditCard cc -> amount * 0.029 + 0.30;
            case DebitCard dc -> amount * 0.022 + 0.10;
            case PayPal pp -> amount * 0.034 + 0.35;
            case BankTransfer bt -> 5.00;
        };
    }
}

public record CreditCard(String number, String cvv, YearMonth expiry) 
    implements PaymentMethod {
    @Override
    public String getDescription() {
        return "Credit Card ending in " + number.substring(number.length() - 4);
    }
}
```

## Error Handling

### Custom Exceptions
```java
// Domain-specific exception hierarchy
public sealed class DomainException extends Exception 
    permits ValidationException, BusinessRuleException, ResourceNotFoundException {
    
    public DomainException(String message) {
        super(message);
    }
    
    public DomainException(String message, Throwable cause) {
        super(message, cause);
    }
}

public final class ValidationException extends DomainException {
    private final List<String> errors;
    
    public ValidationException(List<String> errors) {
        super("Validation failed: " + String.join(", ", errors));
        this.errors = List.copyOf(errors);
    }
    
    public List<String> getErrors() {
        return errors;
    }
}
```

### Result Type Pattern
```java
public sealed interface Result<T, E> {
    record Success<T, E>(T value) implements Result<T, E> {}
    record Failure<T, E>(E error) implements Result<T, E> {}
    
    static <T, E> Result<T, E> success(T value) {
        return new Success<>(value);
    }
    
    static <T, E> Result<T, E> failure(E error) {
        return new Failure<>(error);
    }
    
    default T getOrElse(T defaultValue) {
        return switch (this) {
            case Success(var value) -> value;
            case Failure(_) -> defaultValue;
        };
    }
    
    default <U> Result<U, E> map(Function<T, U> mapper) {
        return switch (this) {
            case Success(var value) -> success(mapper.apply(value));
            case Failure(var error) -> failure(error);
        };
    }
}
```

## Performance Best Practices

### Virtual Threads Usage
```java
public class AsyncService {
    // Use virtual threads for I/O operations
    private static final ExecutorService VIRTUAL_EXECUTOR = 
        Executors.newVirtualThreadPerTaskExecutor();
    
    // Use platform threads for CPU-intensive operations
    private static final ExecutorService CPU_EXECUTOR = 
        Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
    
    public CompletableFuture<String> fetchData(String url) {
        return CompletableFuture.supplyAsync(
            () -> httpClient.send(request, BodyHandlers.ofString()).body(),
            VIRTUAL_EXECUTOR
        );
    }
    
    public CompletableFuture<Integer> computeHash(byte[] data) {
        return CompletableFuture.supplyAsync(
            () -> calculateComplexHash(data),
            CPU_EXECUTOR
        );
    }
}
```

### Memory Optimization
```java
// Use primitive collections when possible
import it.unimi.dsi.fastutil.ints.IntArrayList;
import it.unimi.dsi.fastutil.longs.Long2ObjectOpenHashMap;

public class PerformantCache {
    // Avoid boxing overhead
    private final IntArrayList userIds = new IntArrayList();
    private final Long2ObjectOpenHashMap<User> userCache = new Long2ObjectOpenHashMap<>();
    
    // Use record patterns to avoid unnecessary object creation
    public Optional<User> findUser(long id) {
        return Optional.ofNullable(userCache.get(id));
    }
}
```

## Security Best Practices

### Input Validation
```java
public class SecurityService {
    private static final Pattern SAFE_PATTERN = Pattern.compile("^[a-zA-Z0-9_-]+$");
    
    public void validateInput(String input) {
        Objects.requireNonNull(input, "Input cannot be null");
        
        if (input.length() > 255) {
            throw new ValidationException("Input too long");
        }
        
        if (!SAFE_PATTERN.matcher(input).matches()) {
            throw new ValidationException("Input contains invalid characters");
        }
    }
    
    // Prevent SQL injection with parameterized queries
    public User findUserByEmail(String email) {
        return jdbcTemplate.queryForObject(
            "SELECT * FROM users WHERE email = ?",
            new Object[]{email},
            new UserRowMapper()
        );
    }
}
```

### Secrets Management
```java
// Never hardcode secrets
public class ConfigService {
    private final String apiKey;
    
    public ConfigService() {
        // Read from environment variables
        this.apiKey = System.getenv("API_KEY");
        if (this.apiKey == null || this.apiKey.isBlank()) {
            throw new IllegalStateException("API_KEY environment variable not set");
        }
    }
    
    // Use char[] for sensitive data when possible
    public void processPassword(char[] password) {
        try {
            // Process password
        } finally {
            // Clear sensitive data from memory
            Arrays.fill(password, ' ');
        }
    }
}
```

## Documentation

### Class-Level Documentation
```java
/**
 * Service for managing user accounts with support for virtual threads.
 * 
 * <p>This service provides thread-safe operations for creating, updating, 
 * and deleting user accounts. All I/O operations use virtual threads for 
 * optimal performance.
 * 
 * <p>Example usage:
 * <pre>{@code
 * var service = new UserService(repository, validator);
 * 
 * // Async operation with virtual threads
 * service.createUserAsync(userData)
 *     .thenAccept(user -> System.out.println("Created: " + user))
 *     .exceptionally(ex -> {
 *         logger.error("Failed to create user", ex);
 *         return null;
 *     });
 * }</pre>
 * 
 * @since 1.0
 * @see UserRepository
 * @see UserValidator
 */
public class UserService {
    // Implementation
}
```

### Method Documentation
```java
/**
 * Creates a new user account asynchronously using virtual threads.
 * 
 * <p>This method validates the input data, checks for duplicate emails,
 * and persists the user to the database. The operation is performed
 * on a virtual thread for optimal resource utilization.
 * 
 * @param userData the user data to create account from, must not be null
 * @return a CompletableFuture containing the created user
 * @throws ValidationException if userData is invalid
 * @throws DuplicateEmailException if email already exists
 * @apiNote This method is thread-safe and can be called concurrently
 * @implNote Uses virtual threads for I/O operations
 */
public CompletableFuture<User> createUserAsync(UserData userData) {
    // Implementation
}
```

## Dependency Management

### Recommended Libraries
```gradle
dependencies {
    // Core
    implementation 'org.slf4j:slf4j-api:2.0.9'
    implementation 'ch.qos.logback:logback-classic:1.4.14'
    
    // Validation
    implementation 'jakarta.validation:jakarta.validation-api:3.0.2'
    implementation 'org.hibernate.validator:hibernate-validator:8.0.1.Final'
    
    // JSON Processing
    implementation 'com.fasterxml.jackson.core:jackson-databind:2.16.0'
    implementation 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310:2.16.0'
    
    // Utilities
    implementation 'org.apache.commons:commons-lang3:3.14.0'
    implementation 'com.google.guava:guava:32.1.3-jre'
    
    // Testing
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.1'
    testImplementation 'org.assertj:assertj-core:3.24.2'
    testImplementation 'org.mockito:mockito-core:5.7.0'
    testImplementation 'org.testcontainers:testcontainers:1.19.3'
    
    // Performance
    testImplementation 'org.openjdk.jmh:jmh-core:1.37'
    testAnnotationProcessor 'org.openjdk.jmh:jmh-generator-annprocess:1.37'
}
```

## Common Anti-Patterns to Avoid

### ❌ Don't Do This
```java
// Catching generic exceptions
try {
    // code
} catch (Exception e) {  // Too broad
    e.printStackTrace();  // Don't use printStackTrace
}

// Mutable static state
public class Service {
    private static Map<String, User> cache = new HashMap<>();  // Thread-unsafe
}

// Nullable returns without Optional
public User findUser(String id) {
    return userMap.get(id);  // Can return null
}

// String concatenation in loops
String result = "";
for (String item : items) {
    result += item + ", ";  // Inefficient
}
```

### ✅ Do This Instead
```java
// Catch specific exceptions
try {
    // code
} catch (IOException e) {
    logger.error("Failed to read file", e);
    throw new DataAccessException("File read failed", e);
}

// Immutable or thread-safe collections
public class Service {
    private static final Map<String, User> CACHE = 
        Collections.synchronizedMap(new HashMap<>());
    // Or use ConcurrentHashMap
}

// Use Optional for nullable returns
public Optional<User> findUser(String id) {
    return Optional.ofNullable(userMap.get(id));
}

// Use StringBuilder or StringJoiner
String result = String.join(", ", items);
// Or
StringJoiner joiner = new StringJoiner(", ");
items.forEach(joiner::add);
String result = joiner.toString();
```

## IDE Configuration

### IntelliJ IDEA Settings
- Enable all Java 21 inspections
- Configure Google Java Format plugin
- Enable annotation processing
- Set project SDK to Java 21
- Enable preview features if needed

### VS Code Settings
```json
{
    "java.configuration.runtimes": [
        {
            "name": "JavaSE-21",
            "path": "/path/to/jdk-21",
            "default": true
        }
    ],
    "java.format.settings.url": "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
    "java.compile.nullAnalysis.mode": "automatic"
}
```

## Additional Resources

- [Java 21 Release Notes](https://openjdk.org/projects/jdk/21/)
- [Effective Java 3rd Edition](https://www.oreilly.com/library/view/effective-java-3rd/9780134686097/)
- [Java Concurrency in Practice](http://jcip.net/)
- [Virtual Threads Documentation](https://docs.oracle.com/en/java/javase/21/core/virtual-threads.html)
- [Pattern Matching Guide](https://docs.oracle.com/en/java/javase/21/language/pattern-matching.html)
