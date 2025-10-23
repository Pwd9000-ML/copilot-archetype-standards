# Java Style Guide

This document provides extended Java coding guidelines and best practices for projects following the organization's standards.

## Table of Contents
1. [Code Organization](#code-organization)
2. [Naming Conventions](#naming-conventions)
3. [Modern Java Features](#modern-java-features)
4. [Documentation](#documentation)
5. [Error Handling](#error-handling)
6. [Testing](#testing)
7. [Security](#security)
8. [Performance](#performance)
9. [Common Patterns](#common-patterns)

## Code Organization

### Package Structure
```
com.example.myapp
├── config          # Configuration classes
├── controller      # REST controllers
├── service         # Business logic
├── repository      # Data access
├── model           # Domain models
│   ├── entity      # JPA entities
│   ├── dto         # Data transfer objects
│   └── mapper      # Model mappers
├── exception       # Custom exceptions
└── util            # Utility classes
```

### Class Structure
Order class members consistently:
1. Static constants
2. Static variables
3. Instance variables
4. Constructors
5. Static methods
6. Instance methods
7. Nested classes

```java
public class UserService {
    // Constants
    private static final int MAX_RETRY_ATTEMPTS = 3;
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    
    // Instance variables
    private final UserRepository userRepository;
    private final EmailService emailService;
    
    // Constructor
    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }
    
    // Public methods
    public User createUser(String name, String email) {
        // Implementation
    }
    
    // Private methods
    private void sendWelcomeEmail(User user) {
        // Implementation
    }
}
```

## Naming Conventions

### Classes and Interfaces
- Classes: `PascalCase` nouns
- Interfaces: `PascalCase` adjectives or nouns
- Abstract classes: Consider `Abstract` prefix

```java
// Classes
public class UserAccount { }
public class OrderProcessor { }

// Interfaces
public interface Serializable { }
public interface UserRepository { }
public interface PaymentProcessor { }

// Abstract classes
public abstract class AbstractEntity { }
```

### Methods and Variables
- Methods: `camelCase` verbs
- Variables: `camelCase` nouns
- Constants: `UPPER_SNAKE_CASE`
- Boolean methods: Start with `is`, `has`, `can`, `should`

```java
public class Product {
    // Constants
    private static final int DEFAULT_QUANTITY = 1;
    private static final String DEFAULT_CATEGORY = "GENERAL";
    
    // Variables
    private String productName;
    private double unitPrice;
    private boolean inStock;
    
    // Methods
    public void updatePrice(double newPrice) {
        this.unitPrice = newPrice;
    }
    
    public boolean isAvailable() {
        return inStock;
    }
    
    public boolean hasDiscount() {
        return getDiscountRate() > 0;
    }
}
```

## Modern Java Features

### Records (Java 14+)
Use records for immutable data carriers:

```java
// Simple record
public record User(String name, String email, LocalDate birthDate) {}

// Record with validation
public record Product(String name, double price, int quantity) {
    // Compact constructor
    public Product {
        if (price < 0) {
            throw new IllegalArgumentException("Price cannot be negative");
        }
        if (quantity < 0) {
            throw new IllegalArgumentException("Quantity cannot be negative");
        }
    }
    
    // Derived method
    public double totalValue() {
        return price * quantity;
    }
}

// Record with custom method
public record Order(String id, List<Product> products) {
    // Make defensive copy
    public Order {
        products = List.copyOf(products);
    }
    
    public double calculateTotal() {
        return products.stream()
            .mapToDouble(Product::totalValue)
            .sum();
    }
}
```

### Sealed Classes (Java 17+)
Restrict class hierarchies:

```java
public sealed interface Payment permits CreditCardPayment, PayPalPayment, CashPayment {}

public final class CreditCardPayment implements Payment {
    private final String cardNumber;
    private final String cvv;
    // Implementation
}

public final class PayPalPayment implements Payment {
    private final String email;
    // Implementation
}

public final class CashPayment implements Payment {
    private final double amount;
    // Implementation
}
```

### Pattern Matching (Java 17+)
```java
// instanceof pattern matching
public String formatShape(Object obj) {
    if (obj instanceof Circle c) {
        return "Circle with radius " + c.radius();
    } else if (obj instanceof Rectangle r) {
        return "Rectangle " + r.width() + "x" + r.height();
    }
    return "Unknown shape";
}

// Switch pattern matching (Java 21+)
public double calculateArea(Shape shape) {
    return switch (shape) {
        case Circle c -> Math.PI * c.radius() * c.radius();
        case Rectangle r -> r.width() * r.height();
        case Triangle t -> 0.5 * t.base() * t.height();
    };
}

// Guarded patterns
public String categorizeNumber(Object obj) {
    return switch (obj) {
        case Integer i when i < 0 -> "negative integer";
        case Integer i when i > 0 -> "positive integer";
        case Integer i -> "zero";
        case Double d -> "decimal";
        default -> "not a number";
    };
}
```

### Text Blocks (Java 15+)
```java
public class SqlQueries {
    private static final String SELECT_USER = """
        SELECT u.id, u.name, u.email, u.created_at
        FROM users u
        WHERE u.active = true
          AND u.created_at > ?
        ORDER BY u.created_at DESC
        """;
    
    private static final String JSON_TEMPLATE = """
        {
            "name": "%s",
            "email": "%s",
            "active": %b
        }
        """;
}
```

### Stream API
```java
import java.util.stream.Collectors;

public class DataProcessor {
    public List<String> getActiveUserEmails(List<User> users) {
        return users.stream()
            .filter(User::isActive)
            .map(User::getEmail)
            .sorted()
            .collect(Collectors.toList());
    }
    
    public Map<String, List<Order>> groupOrdersByStatus(List<Order> orders) {
        return orders.stream()
            .collect(Collectors.groupingBy(Order::getStatus));
    }
    
    public double calculateTotalRevenue(List<Order> orders) {
        return orders.stream()
            .mapToDouble(Order::getTotal)
            .sum();
    }
}
```

## Documentation

### Javadoc
```java
/**
 * Service for managing user accounts and authentication.
 * 
 * <p>This service provides comprehensive user management functionality including
 * registration, authentication, profile updates, and account deletion. All operations
 * are transactional and include appropriate security checks.
 * 
 * <p><b>Thread Safety:</b> This class is thread-safe. All methods can be safely
 * called from multiple threads.
 * 
 * <p><b>Example usage:</b>
 * <pre>{@code
 * UserService service = new UserService(userRepository, emailService);
 * User newUser = service.registerUser("john@example.com", "password123");
 * boolean authenticated = service.authenticate("john@example.com", "password123");
 * }</pre>
 * 
 * @author Jane Developer
 * @since 1.0
 * @see User
 * @see UserRepository
 */
public class UserService {
    
    /**
     * Registers a new user with the provided credentials.
     * 
     * <p>This method creates a new user account, hashes the password, and sends
     * a welcome email. The operation is transactional and will rollback if any
     * step fails.
     * 
     * @param email the user's email address, must be unique and valid
     * @param password the user's password, must meet complexity requirements
     * @return the created user with generated ID and metadata
     * @throws IllegalArgumentException if email or password is invalid
     * @throws DuplicateUserException if email already exists
     * @throws EmailServiceException if welcome email fails to send
     */
    public User registerUser(String email, String password) {
        // Implementation
    }
}
```

## Error Handling

### Exception Hierarchy
```java
// Base application exception
public class ApplicationException extends RuntimeException {
    public ApplicationException(String message) {
        super(message);
    }
    
    public ApplicationException(String message, Throwable cause) {
        super(message, cause);
    }
}

// Specific exceptions
public class ValidationException extends ApplicationException {
    public ValidationException(String message) {
        super(message);
    }
}

public class ResourceNotFoundException extends ApplicationException {
    public ResourceNotFoundException(String resourceType, String resourceId) {
        super(String.format("%s with ID %s not found", resourceType, resourceId));
    }
}

public class DuplicateResourceException extends ApplicationException {
    public DuplicateResourceException(String message) {
        super(message);
    }
}
```

### Try-with-Resources
```java
// Single resource
public String readFile(Path path) throws IOException {
    try (BufferedReader reader = Files.newBufferedReader(path)) {
        return reader.lines().collect(Collectors.joining("\n"));
    }
}

// Multiple resources
public void copyFile(Path source, Path destination) throws IOException {
    try (InputStream in = Files.newInputStream(source);
         OutputStream out = Files.newOutputStream(destination)) {
        in.transferTo(out);
    }
}

// Custom AutoCloseable
public class DatabaseTransaction implements AutoCloseable {
    private final Connection connection;
    
    public DatabaseTransaction(Connection connection) {
        this.connection = connection;
        try {
            connection.setAutoCommit(false);
        } catch (SQLException e) {
            throw new DatabaseException("Failed to start transaction", e);
        }
    }
    
    public void commit() throws SQLException {
        connection.commit();
    }
    
    @Override
    public void close() {
        try {
            if (!connection.isClosed()) {
                connection.rollback();
            }
        } catch (SQLException e) {
            logger.error("Failed to rollback transaction", e);
        }
    }
}
```

## Testing

### JUnit 5 Tests
```java
import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;
import static org.assertj.core.api.Assertions.*;

@DisplayName("User Service Tests")
class UserServiceTest {
    
    private UserService userService;
    private UserRepository userRepository;
    
    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        userService = new UserService(userRepository);
    }
    
    @Test
    @DisplayName("Should create user with valid data")
    void createUser_ValidData_Success() {
        // Given
        String email = "test@example.com";
        String name = "Test User";
        
        // When
        User result = userService.createUser(name, email);
        
        // Then
        assertThat(result)
            .isNotNull()
            .hasFieldOrPropertyWithValue("name", name)
            .hasFieldOrPropertyWithValue("email", email);
    }
    
    @Test
    @DisplayName("Should throw exception for invalid email")
    void createUser_InvalidEmail_ThrowsException() {
        // Given
        String invalidEmail = "not-an-email";
        
        // When & Then
        assertThatThrownBy(() -> userService.createUser("Name", invalidEmail))
            .isInstanceOf(ValidationException.class)
            .hasMessageContaining("Invalid email");
    }
    
    @ParameterizedTest
    @ValueSource(strings = {"", "  ", "a", "ab"})
    @DisplayName("Should reject invalid names")
    void createUser_InvalidName_ThrowsException(String invalidName) {
        assertThatThrownBy(() -> userService.createUser(invalidName, "test@example.com"))
            .isInstanceOf(ValidationException.class);
    }
    
    @ParameterizedTest
    @CsvSource({
        "john@example.com, true",
        "invalid-email, false",
        "@example.com, false",
        "test@, false"
    })
    @DisplayName("Should validate email correctly")
    void validateEmail(String email, boolean expected) {
        boolean result = userService.isValidEmail(email);
        assertThat(result).isEqualTo(expected);
    }
    
    @Nested
    @DisplayName("Authentication Tests")
    class AuthenticationTests {
        @Test
        @DisplayName("Should authenticate valid credentials")
        void authenticate_ValidCredentials_Success() {
            // Test implementation
        }
        
        @Test
        @DisplayName("Should reject invalid password")
        void authenticate_InvalidPassword_Failure() {
            // Test implementation
        }
    }
}
```

## Security

### Input Validation
```java
import java.util.regex.Pattern;

public class ValidationUtils {
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern ALPHANUMERIC_PATTERN = 
        Pattern.compile("^[a-zA-Z0-9]+$");
    
    public static void validateEmail(String email) {
        if (email == null || !EMAIL_PATTERN.matcher(email).matches()) {
            throw new ValidationException("Invalid email format");
        }
    }
    
    public static void validateNotBlank(String value, String fieldName) {
        if (value == null || value.isBlank()) {
            throw new ValidationException(fieldName + " cannot be blank");
        }
    }
    
    public static String sanitizeInput(String input) {
        if (input == null) {
            return null;
        }
        // Remove potentially dangerous characters
        return input.replaceAll("[<>\"']", "");
    }
}
```

### SQL Injection Prevention
```java
// Bad - SQL injection vulnerable
public User findUserBad(String username) {
    String sql = "SELECT * FROM users WHERE username = '" + username + "'"; // NEVER!
    // Execute query
}

// Good - Use PreparedStatement
public User findUser(String username) {
    String sql = "SELECT * FROM users WHERE username = ?";
    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();
        // Process results
    }
}

// Best - Use JPA/Hibernate
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
}
```

## Performance

### Efficient Collections
```java
// Pre-size collections when size is known
List<String> items = new ArrayList<>(expectedSize);
Map<String, User> userMap = new HashMap<>(expectedSize);

// Use appropriate collection type
Set<String> uniqueIds = new HashSet<>();  // Fast lookup
List<String> orderedIds = new ArrayList<>();  // Ordered
Map<String, Object> config = new HashMap<>();  // Key-value pairs
```

### String Building
```java
// Bad for concatenation in loops
String result = "";
for (String item : items) {
    result += item + ", ";  // Creates new string each time
}

// Good
StringBuilder builder = new StringBuilder();
for (String item : items) {
    builder.append(item).append(", ");
}
String result = builder.toString();

// Best for joining
String result = String.join(", ", items);
```

## Common Patterns

### Builder Pattern
```java
public class User {
    private final String name;
    private final String email;
    private final LocalDate birthDate;
    private final String phone;
    private final String address;
    
    private User(Builder builder) {
        this.name = builder.name;
        this.email = builder.email;
        this.birthDate = builder.birthDate;
        this.phone = builder.phone;
        this.address = builder.address;
    }
    
    public static Builder builder() {
        return new Builder();
    }
    
    public static class Builder {
        private String name;
        private String email;
        private LocalDate birthDate;
        private String phone;
        private String address;
        
        public Builder name(String name) {
            this.name = name;
            return this;
        }
        
        public Builder email(String email) {
            this.email = email;
            return this;
        }
        
        public Builder birthDate(LocalDate birthDate) {
            this.birthDate = birthDate;
            return this;
        }
        
        public Builder phone(String phone) {
            this.phone = phone;
            return this;
        }
        
        public Builder address(String address) {
            this.address = address;
            return this;
        }
        
        public User build() {
            // Validation
            if (name == null || email == null) {
                throw new IllegalStateException("Name and email are required");
            }
            return new User(this);
        }
    }
}

// Usage
User user = User.builder()
    .name("John Doe")
    .email("john@example.com")
    .birthDate(LocalDate.of(1990, 1, 1))
    .build();
```

## Additional Resources

- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Effective Java by Joshua Bloch](https://www.oreilly.com/library/view/effective-java/9780134686097/)
- [Java Language Specification](https://docs.oracle.com/javase/specs/)
- [Spring Framework Best Practices](https://spring.io/guides)
