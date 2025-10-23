---
applyTo: "**/*.java"
description: Java 21 LTS coding standards and best practices
---

# Java 21 LTS Development Standards

## Language Version
- **Required**: Java 21 LTS
- **Virtual Threads**: Use for I/O-bound operations (`Executors.newVirtualThreadPerTaskExecutor()`)
- **Pattern Matching**: Use in switch expressions and instanceof
- **Records**: Prefer for immutable data carriers
- **Sealed Classes**: Use for controlled inheritance

## Code Formatting & Linting

- **Build Tool**: Gradle 8.5+ (preferred) or Maven 3.9+
- **Formatter**: `google-java-format` v1.18+, 120 char line length
- **Static Analysis**: SpotBugs, PMD, Checkstyle, ErrorProne
- **Null Safety**: Use `@Nullable` and `@NonNull` annotations

### Gradle Configuration
```gradle
plugins {
    id 'java'
    id 'com.diffplug.spotless' version '6.23.0'
}

java {
    toolchain { languageVersion = JavaLanguageVersion.of(21) }
}

spotless {
    java {
        googleJavaFormat('1.18.1')
        removeUnusedImports()
    }
}
```

## Modern Java 21 Features

### Virtual Threads
```java
public class UserService {
    private final ExecutorService executor = Executors.newVirtualThreadPerTaskExecutor();
    
    public CompletableFuture<User> fetchUserAsync(String userId) {
        return CompletableFuture.supplyAsync(() -> fetchFromDB(userId), executor);
    }
}
```

### Pattern Matching
```java
// Sealed interfaces with pattern matching
public sealed interface Result<T> permits Success<T>, Failure<T> {
    default T getOrThrow() {
        return switch (this) {
            case Success<T>(var value) -> value;
            case Failure<T>(var error) -> throw new RuntimeException(error);
        };
    }
}

// Guarded patterns
public String categorize(Object obj) {
    return switch (obj) {
        case Integer i when i < 0 -> "Negative";
        case Integer i when i > 0 -> "Positive";
        case Integer i -> "Zero";
        case null -> "Null";
        default -> "Unknown";
    };
}
```

### Sequenced Collections
```java
SequencedCollection<Order> orders = new LinkedHashSet<>();
orders.addFirst(newOrder);  // Add to beginning
Order latest = orders.getFirst();
orders.reversed();  // Reverse view
```

## Testing

- **Framework**: JUnit 5.10+ (Jupiter), Mockito 5.x, AssertJ 3.24+
- **Integration**: Testcontainers, **Coverage**: 80% minimum (JaCoCo)

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock private UserRepository repository;
    private UserService userService;
    
    @BeforeEach
    void setUp() {
        userService = new UserService(repository);
    }
    
    @Test
    void createUser_ValidData_Success() {
        when(repository.save(any())).thenAnswer(i -> i.getArgument(0));
        var user = userService.createUser(new UserData("John", "j@ex.com", 25));
        assertThat(user).isNotNull();
        verify(repository).save(any());
    }
    
    @ParameterizedTest
    @CsvSource({"invalid, Invalid format", "@ex.com, Invalid format"})
    void createUser_InvalidEmail_Throws(String email, String msg) {
        assertThatThrownBy(() -> userService.createUser(new UserData("J", email, 25)))
            .hasMessageContaining(msg);
    }
}
```

## Code Style

### Naming Conventions
- Classes: `PascalCase` | Interfaces: `PascalCase` (no 'I' prefix)
- Methods: `camelCase` | Constants: `UPPER_SNAKE_CASE` | Packages: `lowercase`

### Records
```java
public record UserDto(String id, String name, String email, Instant createdAt) {
    public UserDto {  // Compact constructor
        Objects.requireNonNull(id);
        if (!email.contains("@")) throw new IllegalArgumentException("Invalid email");
    }
    
    public UserDto withEmail(String newEmail) {
        return new UserDto(id, name, newEmail, createdAt);
    }
}
```

### Sealed Classes
```java
public sealed interface PaymentMethod permits CreditCard, PayPal {
    double calculateFee(double amount);
}

public record CreditCard(String number) implements PaymentMethod {
    public double calculateFee(double amount) { return amount * 0.029 + 0.30; }
}
```

## Error Handling

### Result Pattern
```java
public sealed interface Result<T, E> {
    record Success<T, E>(T value) implements Result<T, E> {}
    record Failure<T, E>(E error) implements Result<T, E> {}
    
    default T getOrElse(T defaultValue) {
        return switch (this) {
            case Success(var value) -> value;
            case Failure(_) -> defaultValue;
        };
    }
}
```

### Custom Exceptions
```java
public sealed class DomainException extends Exception 
    permits ValidationException, BusinessRuleException {
    public DomainException(String message) { super(message); }
}

public final class ValidationException extends DomainException {
    private final List<String> errors;
    public ValidationException(List<String> errors) {
        super("Validation failed: " + String.join(", ", errors));
        this.errors = List.copyOf(errors);
    }
}
```

## Performance

### Virtual Thread Usage
```java
// Use virtual threads for I/O, platform threads for CPU-intensive
private static final ExecutorService VIRTUAL = Executors.newVirtualThreadPerTaskExecutor();
private static final ExecutorService CPU = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());

public CompletableFuture<String> fetchData(String url) {
    return CompletableFuture.supplyAsync(() -> httpClient.send(request).body(), VIRTUAL);
}
```

### Memory Optimization
```java
// Use primitive collections to avoid boxing
import it.unimi.dsi.fastutil.ints.IntArrayList;

public class Cache {
    private final IntArrayList ids = new IntArrayList();  // No boxing overhead
}
```

## Security

### Input Validation
```java
private static final Pattern SAFE = Pattern.compile("^[a-zA-Z0-9_-]+$");

public void validate(String input) {
    Objects.requireNonNull(input);
    if (input.length() > 255) throw new ValidationException("Too long");
    if (!SAFE.matcher(input).matches()) throw new ValidationException("Invalid chars");
}

// Parameterized queries prevent SQL injection
public User findByEmail(String email) {
    return jdbcTemplate.queryForObject("SELECT * FROM users WHERE email = ?", 
        new Object[]{email}, new UserRowMapper());
}
```

### Secrets Management
```java
public class Config {
    private final String apiKey;
    
    public Config() {
        String key = System.getenv("API_KEY");
        if (key == null || key.isBlank()) {
            throw new IllegalStateException("API_KEY environment variable must be set and non-blank");
        }
        this.apiKey = key;
    }
    public void processPassword(char[] password) {
        try {
            // Process
        } finally {
            Arrays.fill(password, ' ');  // Clear from memory
        }
    }
}
```

## Documentation

```java
/**
 * Service for user account management with virtual thread support.
 * 
 * <p>Example:
 * <pre>{@code
 * var service = new UserService(repo);
 * service.createUserAsync(data)
 *     .thenAccept(user -> log.info("Created: {}", user));
 * }</pre>
 * 
 * @since 1.0
 */
public class UserService {
    /**
     * Creates user asynchronously using virtual threads.
     * 
     * @param userData user data, must not be null
     * @return CompletableFuture with created user
     * @throws ValidationException if data invalid
     */
    public CompletableFuture<User> createUserAsync(UserData userData) { }
}
```

## Recommended Libraries

```gradle
dependencies {
    implementation 'org.slf4j:slf4j-api:2.0.9'
    implementation 'jakarta.validation:jakarta.validation-api:3.0.2'
    implementation 'com.fasterxml.jackson.core:jackson-databind:2.16.0'
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.1'
    testImplementation 'org.mockito:mockito-core:5.7.0'
}
```

## Anti-Patterns

### ❌ Avoid
```java
catch (Exception e) { e.printStackTrace(); }  // Too broad, use logger
private static Map<String, User> cache = new HashMap<>();  // Not thread-safe
public User findUser(String id) { return map.get(id); }  // Can return null
```

### ✅ Prefer
```java
catch (IOException e) { log.error("Failed", e); }
private static final Map<String, User> CACHE = new ConcurrentHashMap<>();
public Optional<User> findUser(String id) { return Optional.ofNullable(map.get(id)); }
```

