---
applyTo: "**/*.go"
description: Go 1.22+ coding standards and best practices
---

# Go 1.22 Development Standards

## Language Version
- **Required**: Go 1.22+
- **Generics**: Use type parameters for reusable code (Go 1.18+)
- **Range Over Functions**: Use iterators with range-over-func (Go 1.22+)
- **Enhanced Routing**: Use `net/http` enhanced ServeMux patterns (Go 1.22+)

## Code Formatting & Linting

- **Formatter**: `gofmt` or `goimports` (automatic)
- **Linter**: `golangci-lint` with recommended rules
- **Static Analysis**: `go vet`, `staticcheck`
- **Security**: `gosec` for vulnerability scanning

### Configuration (.golangci.yml)
```yaml
run:
  timeout: 5m
  go: "1.22"

linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gosec
    - gofmt
    - goimports
    - misspell
    - unconvert
    - unparam
    - gocritic
    - revive
    - prealloc

linters-settings:
  govet:
    enable-all: true
  gosec:
    severity: medium
    confidence: medium
  revive:
    rules:
      - name: var-naming
      - name: unexported-return

issues:
  exclude-use-default: false
  max-issues-per-linter: 0
  max-same-issues: 0
```

## Modern Go 1.22 Features

### Range Over Functions (Iterators)
```go
package collections

import "iter"

// Iterator for custom collections
func (s *Set[T]) All() iter.Seq[T] {
    return func(yield func(T) bool) {
        for v := range s.items {
            if !yield(v) {
                return
            }
        }
    }
}

// Using range over function
func ProcessItems[T any](items iter.Seq[T], process func(T) error) error {
    for item := range items {
        if err := process(item); err != nil {
            return err
        }
    }
    return nil
}

// Two-value iterator
func Enumerate[T any](s []T) iter.Seq2[int, T] {
    return func(yield func(int, T) bool) {
        for i, v := range s {
            if !yield(i, v) {
                return
            }
        }
    }
}
```

### Enhanced HTTP Routing (Go 1.22)
```go
package main

import (
    "encoding/json"
    "net/http"
)

func main() {
    mux := http.NewServeMux()

    // Method-specific routing
    mux.HandleFunc("GET /api/users", listUsers)
    mux.HandleFunc("POST /api/users", createUser)

    // Path parameters with wildcards
    mux.HandleFunc("GET /api/users/{id}", getUser)
    mux.HandleFunc("PUT /api/users/{id}", updateUser)
    mux.HandleFunc("DELETE /api/users/{id}", deleteUser)

    // Catch-all pattern
    mux.HandleFunc("GET /files/{path...}", serveFiles)

    http.ListenAndServe(":8080", mux)
}

func getUser(w http.ResponseWriter, r *http.Request) {
    // Extract path parameter
    id := r.PathValue("id")

    user, err := userService.FindByID(r.Context(), id)
    if err != nil {
        http.Error(w, "User not found", http.StatusNotFound)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(user)
}
```

### Generics
```go
package collections

import (
    "cmp"
    "slices"
)

// Generic ordered set
type OrderedSet[T cmp.Ordered] struct {
    items []T
}

func NewOrderedSet[T cmp.Ordered]() *OrderedSet[T] {
    return &OrderedSet[T]{items: make([]T, 0)}
}

func (s *OrderedSet[T]) Add(item T) bool {
    if slices.Contains(s.items, item) {
        return false
    }
    s.items = append(s.items, item)
    slices.Sort(s.items)
    return true
}

func (s *OrderedSet[T]) Contains(item T) bool {
    _, found := slices.BinarySearch(s.items, item)
    return found
}

// Generic result type
type Result[T any] struct {
    Value T
    Err   error
}

func Ok[T any](value T) Result[T] {
    return Result[T]{Value: value}
}

func Err[T any](err error) Result[T] {
    return Result[T]{Err: err}
}

func (r Result[T]) Unwrap() (T, error) {
    return r.Value, r.Err
}

// Generic map function
func Map[T, U any](items []T, fn func(T) U) []U {
    result := make([]U, len(items))
    for i, item := range items {
        result[i] = fn(item)
    }
    return result
}

// Generic filter function
func Filter[T any](items []T, predicate func(T) bool) []T {
    result := make([]T, 0, len(items))
    for _, item := range items {
        if predicate(item) {
            result = append(result, item)
        }
    }
    return result
}
```

## Error Handling

```go
package errors

import (
    "errors"
    "fmt"
)

// Sentinel errors
var (
    ErrNotFound     = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
    ErrValidation   = errors.New("validation failed")
)

// Custom error type
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

func (e *ValidationError) Unwrap() error {
    return ErrValidation
}

// Error wrapping
func GetUser(id string) (*User, error) {
    user, err := db.FindUser(id)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, fmt.Errorf("user %s: %w", id, ErrNotFound)
        }
        return nil, fmt.Errorf("get user %s: %w", id, err)
    }
    return user, nil
}

// Error checking
func ProcessUser(id string) error {
    user, err := GetUser(id)
    if err != nil {
        if errors.Is(err, ErrNotFound) {
            return handleNotFound(id)
        }
        var validErr *ValidationError
        if errors.As(err, &validErr) {
            return handleValidation(validErr)
        }
        return err
    }
    return process(user)
}
```

## Concurrency

```go
package concurrent

import (
    "context"
    "sync"
    "time"

    "golang.org/x/sync/errgroup"
)

// Worker pool pattern
func ProcessItems[T, R any](ctx context.Context, items []T, workers int, process func(T) (R, error)) ([]R, error) {
    g, ctx := errgroup.WithContext(ctx)
    g.SetLimit(workers)

    results := make([]R, len(items))

    for i, item := range items {
        i, item := i, item // Capture loop variables
        g.Go(func() error {
            result, err := process(item)
            if err != nil {
                return err
            }
            results[i] = result
            return nil
        })
    }

    if err := g.Wait(); err != nil {
        return nil, err
    }
    return results, nil
}

// Context-aware operation with timeout
func FetchWithTimeout(ctx context.Context, url string, timeout time.Duration) ([]byte, error) {
    ctx, cancel := context.WithTimeout(ctx, timeout)
    defer cancel()

    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}

// Safe concurrent map
type SafeMap[K comparable, V any] struct {
    mu   sync.RWMutex
    data map[K]V
}

func NewSafeMap[K comparable, V any]() *SafeMap[K, V] {
    return &SafeMap[K, V]{data: make(map[K]V)}
}

func (m *SafeMap[K, V]) Get(key K) (V, bool) {
    m.mu.RLock()
    defer m.mu.RUnlock()
    val, ok := m.data[key]
    return val, ok
}

func (m *SafeMap[K, V]) Set(key K, value V) {
    m.mu.Lock()
    defer m.mu.Unlock()
    m.data[key] = value
}
```

## Testing

```go
package user_test

import (
    "context"
    "testing"
    "time"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "github.com/stretchr/testify/require"
)

// Table-driven tests
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {name: "valid email", email: "user@example.com", wantErr: false},
        {name: "missing @", email: "userexample.com", wantErr: true},
        {name: "empty string", email: "", wantErr: true},
        {name: "unicode domain", email: "user@例え.jp", wantErr: false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateEmail(tt.email)
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
            }
        })
    }
}

// Mock interface
type MockUserRepository struct {
    mock.Mock
}

func (m *MockUserRepository) FindByID(ctx context.Context, id string) (*User, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*User), args.Error(1)
}

func TestUserService_GetUser(t *testing.T) {
    mockRepo := new(MockUserRepository)
    service := NewUserService(mockRepo)

    expectedUser := &User{ID: "123", Email: "test@example.com"}
    mockRepo.On("FindByID", mock.Anything, "123").Return(expectedUser, nil)

    user, err := service.GetUser(context.Background(), "123")

    require.NoError(t, err)
    assert.Equal(t, expectedUser, user)
    mockRepo.AssertExpectations(t)
}

// Parallel tests
func TestConcurrentAccess(t *testing.T) {
    t.Parallel()

    cache := NewSafeMap[string, int]()

    t.Run("concurrent writes", func(t *testing.T) {
        t.Parallel()
        for i := 0; i < 100; i++ {
            cache.Set(fmt.Sprintf("key%d", i), i)
        }
    })
}

// Benchmark
func BenchmarkProcessItems(b *testing.B) {
    items := make([]int, 1000)
    for i := range items {
        items[i] = i
    }

    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        Map(items, func(n int) int { return n * 2 })
    }
}
```

## Project Structure

```
project/
├── cmd/
│   └── myapp/
│       └── main.go           # Application entry point
├── internal/
│   ├── domain/               # Business logic
│   │   ├── user.go
│   │   └── order.go
│   ├── repository/           # Data access
│   │   ├── user_repo.go
│   │   └── order_repo.go
│   ├── service/              # Application services
│   │   └── user_service.go
│   └── handler/              # HTTP handlers
│       └── user_handler.go
├── pkg/                      # Public reusable packages
│   └── validator/
│       └── validator.go
├── api/                      # API definitions (OpenAPI, Proto)
├── scripts/                  # Build and deploy scripts
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

## Security

```go
package security

import (
    "crypto/rand"
    "crypto/sha256"
    "crypto/subtle"
    "encoding/base64"
    "regexp"

    "golang.org/x/crypto/bcrypt"
)

// Input validation
var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

func ValidateEmail(email string) error {
    if len(email) > 254 {
        return fmt.Errorf("email too long")
    }
    if !emailRegex.MatchString(email) {
        return fmt.Errorf("invalid email format")
    }
    return nil
}

// Secure random token
func GenerateToken(length int) (string, error) {
    bytes := make([]byte, length)
    if _, err := rand.Read(bytes); err != nil {
        return "", err
    }
    return base64.URLEncoding.EncodeToString(bytes), nil
}

// Password hashing with bcrypt
func HashPassword(password string) (string, error) {
    bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
    return string(bytes), err
}

func CheckPassword(password, hash string) bool {
    err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
    return err == nil
}

// Constant-time comparison
func SecureCompare(a, b string) bool {
    return subtle.ConstantTimeCompare([]byte(a), []byte(b)) == 1
}

// SQL injection prevention - use parameterized queries
func GetUserByEmail(ctx context.Context, db *sql.DB, email string) (*User, error) {
    // Always use parameterized queries
    query := "SELECT id, email, name FROM users WHERE email = $1"
    row := db.QueryRowContext(ctx, query, email)

    var user User
    if err := row.Scan(&user.ID, &user.Email, &user.Name); err != nil {
        return nil, err
    }
    return &user, nil
}
```

## Configuration

```go
package config

import (
    "os"
    "strconv"
    "time"
)

type Config struct {
    Server   ServerConfig
    Database DatabaseConfig
    Redis    RedisConfig
}

type ServerConfig struct {
    Port         int
    ReadTimeout  time.Duration
    WriteTimeout time.Duration
}

type DatabaseConfig struct {
    Host     string
    Port     int
    User     string
    Password string
    DBName   string
    SSLMode  string
}

func Load() (*Config, error) {
    return &Config{
        Server: ServerConfig{
            Port:         getEnvInt("SERVER_PORT", 8080),
            ReadTimeout:  getEnvDuration("SERVER_READ_TIMEOUT", 10*time.Second),
            WriteTimeout: getEnvDuration("SERVER_WRITE_TIMEOUT", 10*time.Second),
        },
        Database: DatabaseConfig{
            Host:     getEnv("DB_HOST", "localhost"),
            Port:     getEnvInt("DB_PORT", 5432),
            User:     getEnv("DB_USER", "postgres"),
            Password: os.Getenv("DB_PASSWORD"), // Required, no default
            DBName:   getEnv("DB_NAME", "app"),
            SSLMode:  getEnv("DB_SSLMODE", "require"),
        },
    }, nil
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
    if value := os.Getenv(key); value != "" {
        if intValue, err := strconv.Atoi(value); err == nil {
            return intValue
        }
    }
    return defaultValue
}

func getEnvDuration(key string, defaultValue time.Duration) time.Duration {
    if value := os.Getenv(key); value != "" {
        if duration, err := time.ParseDuration(value); err == nil {
            return duration
        }
    }
    return defaultValue
}
```

## Best Practices

```go
// Accept interfaces, return structs
type Reader interface {
    Read(p []byte) (n int, err error)
}

func ProcessData(r Reader) (*Result, error) {
    // Implementation
}

// Use defer for cleanup
func ReadFile(path string) ([]byte, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer f.Close()

    return io.ReadAll(f)
}

// Check errors immediately
func SaveUser(user *User) error {
    if err := validate(user); err != nil {
        return fmt.Errorf("validate: %w", err)
    }
    if err := db.Save(user); err != nil {
        return fmt.Errorf("save: %w", err)
    }
    return nil
}

// Use context for cancellation
func LongOperation(ctx context.Context) error {
    select {
    case <-ctx.Done():
        return ctx.Err()
    case result := <-doWork():
        return process(result)
    }
}
```

## Links to Additional Resources

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)
- [Organisation Global Standards](https://github.com/Pwd9000-ML/copilot-archetype-standards/tree/master/.github/instructions/global.instructions.md)

---

By following these Go standards, teams can build efficient, maintainable, and idiomatic Go applications while leveraging the latest Go 1.22+ features and best practices.
