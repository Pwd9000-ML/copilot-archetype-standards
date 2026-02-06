---
applyTo: "**/*.rs"
description: Rust 2024 edition coding standards and best practices
---

# Rust 2024 Edition Development Standards

## Language Version
- **Required**: Rust 2024 edition (1.85+)
- **MSRV**: Document in Cargo.toml when supporting older versions
- **Unsafe**: Minimize usage, document safety invariants thoroughly
- **Async**: Use `async`/`await` with tokio or async-std runtime

## Code Formatting & Linting

- **Formatter**: `rustfmt` with project configuration
- **Linter**: `clippy` with pedantic warnings
- **Documentation**: `rustdoc` with examples
- **Security**: `cargo-audit` for vulnerability scanning

### Configuration (Cargo.toml)
```toml
[package]
name = "myapp"
version = "0.1.0"
edition = "2024"
rust-version = "1.85"

[lints.rust]
unsafe_code = "forbid"

[lints.clippy]
pedantic = { level = "warn", priority = -1 }
nursery = { level = "warn", priority = -1 }
unwrap_used = "warn"
expect_used = "warn"
panic = "warn"
todo = "warn"
unimplemented = "warn"

[profile.release]
lto = true
codegen-units = 1
strip = true
```

### rustfmt.toml
```toml
edition = "2024"
max_width = 120
tab_spaces = 4
use_small_heuristics = "Max"
imports_granularity = "Crate"
group_imports = "StdExternalCrate"
reorder_imports = true
```

## Modern Rust 2024 Features

### Let Chains (Stabilized)
```rust
fn process_user(user: Option<&User>) -> Result<String, Error> {
    // Let chains for cleaner conditionals
    if let Some(user) = user
        && user.is_active()
        && let Some(email) = user.email()
    {
        return Ok(format!("Active user: {email}"));
    }

    Err(Error::InvalidUser)
}
```

### Async Closures
```rust
use std::future::Future;

// Async closures (Rust 2024)
async fn process_items<T, F, Fut>(items: Vec<T>, processor: F) -> Vec<Result<(), Error>>
where
    F: AsyncFn(T) -> Result<(), Error>,
{
    let mut results = Vec::with_capacity(items.len());
    for item in items {
        results.push(processor(item).await);
    }
    results
}

// Usage
let process = async |item: Item| -> Result<(), Error> {
    validate(&item).await?;
    save(&item).await
};
```

### Pattern Matching Enhancements
```rust
#[derive(Debug)]
enum Message {
    Text { content: String, sender: UserId },
    Image { url: String, caption: Option<String> },
    File { path: PathBuf, size: usize },
}

fn handle_message(msg: Message) -> String {
    match msg {
        // Binding with guards
        Message::Text { content, sender } if content.len() > 1000 => {
            format!("Long message from {sender:?}")
        }
        Message::Text { content, .. } => content,

        // @ bindings with nested patterns
        Message::Image { url, caption: Some(cap @ _) } => {
            format!("{url}: {cap}")
        }
        Message::Image { url, caption: None } => url,

        // Or patterns
        Message::File { size, .. } if size == 0 => "Empty file".into(),
        Message::File { path, size } => {
            format!("{}: {} bytes", path.display(), size)
        }
    }
}
```

## Error Handling

```rust
use thiserror::Error;

// Custom error types with thiserror
#[derive(Error, Debug)]
pub enum AppError {
    #[error("User not found: {0}")]
    NotFound(String),

    #[error("Validation failed: {field} - {message}")]
    Validation { field: String, message: String },

    #[error("Database error")]
    Database(#[from] sqlx::Error),

    #[error("IO error")]
    Io(#[from] std::io::Error),

    #[error("Unauthorized")]
    Unauthorized,
}

// Result type alias
pub type Result<T> = std::result::Result<T, AppError>;

// Error propagation
async fn get_user(id: &str) -> Result<User> {
    let user = db::find_user(id)
        .await?
        .ok_or_else(|| AppError::NotFound(id.to_owned()))?;

    validate_user(&user)?;
    Ok(user)
}

// Using anyhow for application code
use anyhow::{Context, Result};

async fn process_file(path: &Path) -> Result<Data> {
    let content = tokio::fs::read_to_string(path)
        .await
        .with_context(|| format!("Failed to read {}", path.display()))?;

    serde_json::from_str(&content)
        .context("Failed to parse JSON")
}
```

## Async/Await

```rust
use tokio::sync::{mpsc, Mutex, RwLock};
use std::sync::Arc;

// Async service pattern
#[derive(Clone)]
pub struct UserService {
    db: Arc<DatabasePool>,
    cache: Arc<RwLock<HashMap<String, User>>>,
}

impl UserService {
    pub async fn get_user(&self, id: &str) -> Result<User> {
        // Check cache first
        if let Some(user) = self.cache.read().await.get(id) {
            return Ok(user.clone());
        }

        // Fetch from database
        let user = self.db.fetch_user(id).await?;

        // Update cache
        self.cache.write().await.insert(id.to_owned(), user.clone());

        Ok(user)
    }
}

// Concurrent processing with bounded concurrency
use futures::stream::{self, StreamExt};

async fn process_batch<T: Send>(
    items: Vec<T>,
    concurrency: usize,
    processor: impl Fn(T) -> impl Future<Output = Result<()>> + Send,
) -> Vec<Result<()>> {
    stream::iter(items)
        .map(|item| processor(item))
        .buffer_unordered(concurrency)
        .collect()
        .await
}

// Graceful shutdown
async fn run_server(shutdown: tokio::sync::broadcast::Receiver<()>) -> Result<()> {
    let listener = TcpListener::bind("0.0.0.0:8080").await?;

    loop {
        tokio::select! {
            Ok((socket, _)) = listener.accept() => {
                tokio::spawn(handle_connection(socket));
            }
            _ = shutdown.recv() => {
                tracing::info!("Shutting down server");
                break;
            }
        }
    }

    Ok(())
}
```

## Type System

```rust
use std::marker::PhantomData;

// Newtype pattern for type safety
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct UserId(uuid::Uuid);

impl UserId {
    pub fn new() -> Self {
        Self(uuid::Uuid::new_v4())
    }

    pub fn as_uuid(&self) -> &uuid::Uuid {
        &self.0
    }
}

impl std::fmt::Display for UserId {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

// Type-state pattern
pub struct Email<State = Unverified> {
    address: String,
    _state: PhantomData<State>,
}

pub struct Unverified;
pub struct Verified;

impl Email<Unverified> {
    pub fn new(address: String) -> Result<Self, ValidationError> {
        if !address.contains('@') {
            return Err(ValidationError::InvalidEmail);
        }
        Ok(Self {
            address,
            _state: PhantomData,
        })
    }

    pub fn verify(self, code: &str) -> Result<Email<Verified>, VerificationError> {
        // Verification logic
        Ok(Email {
            address: self.address,
            _state: PhantomData,
        })
    }
}

impl Email<Verified> {
    pub fn send(&self, message: &str) -> Result<(), SendError> {
        // Only verified emails can send
        todo!()
    }
}

// Builder pattern
#[derive(Default)]
pub struct RequestBuilder {
    url: Option<String>,
    method: Method,
    headers: HashMap<String, String>,
    body: Option<Vec<u8>>,
}

impl RequestBuilder {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn url(mut self, url: impl Into<String>) -> Self {
        self.url = Some(url.into());
        self
    }

    pub fn method(mut self, method: Method) -> Self {
        self.method = method;
        self
    }

    pub fn header(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.headers.insert(key.into(), value.into());
        self
    }

    pub fn body(mut self, body: impl Into<Vec<u8>>) -> Self {
        self.body = Some(body.into());
        self
    }

    pub fn build(self) -> Result<Request, BuildError> {
        let url = self.url.ok_or(BuildError::MissingUrl)?;
        Ok(Request {
            url,
            method: self.method,
            headers: self.headers,
            body: self.body,
        })
    }
}
```

## Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use rstest::{fixture, rstest};
    use mockall::predicate::*;

    // Fixture
    #[fixture]
    fn user() -> User {
        User {
            id: UserId::new(),
            email: "test@example.com".into(),
            name: "Test User".into(),
        }
    }

    // Parameterized tests
    #[rstest]
    #[case("test@example.com", true)]
    #[case("invalid", false)]
    #[case("", false)]
    #[case("user@domain.co.uk", true)]
    fn test_email_validation(#[case] email: &str, #[case] expected: bool) {
        assert_eq!(validate_email(email).is_ok(), expected);
    }

    // Async test
    #[tokio::test]
    async fn test_get_user() {
        let service = UserService::new(mock_db());
        let user = service.get_user("123").await.unwrap();
        assert_eq!(user.id.to_string(), "123");
    }

    // Mock trait
    #[automock]
    trait Repository {
        async fn find(&self, id: &str) -> Result<Option<User>>;
        async fn save(&self, user: &User) -> Result<()>;
    }

    #[tokio::test]
    async fn test_with_mock() {
        let mut mock = MockRepository::new();
        mock.expect_find()
            .with(eq("123"))
            .returning(|_| Ok(Some(User::default())));

        let service = Service::new(Arc::new(mock));
        let result = service.get("123").await;

        assert!(result.is_ok());
    }

    // Property-based testing
    use proptest::prelude::*;

    proptest! {
        #[test]
        fn test_roundtrip_serialization(s in "\\PC*") {
            let encoded = encode(&s);
            let decoded = decode(&encoded)?;
            prop_assert_eq!(s, decoded);
        }
    }
}

// Integration tests in tests/ directory
// tests/integration_test.rs
use myapp::App;

#[tokio::test]
async fn test_full_workflow() {
    let app = App::new_test().await;

    let user = app.create_user("test@example.com").await.unwrap();
    let fetched = app.get_user(&user.id).await.unwrap();

    assert_eq!(user, fetched);
}
```

## Project Structure

```
project/
├── src/
│   ├── main.rs               # Binary entry point
│   ├── lib.rs                # Library root
│   ├── domain/               # Business logic
│   │   ├── mod.rs
│   │   ├── user.rs
│   │   └── order.rs
│   ├── repository/           # Data access
│   │   ├── mod.rs
│   │   └── user_repo.rs
│   ├── service/              # Application services
│   │   ├── mod.rs
│   │   └── user_service.rs
│   ├── api/                  # HTTP handlers
│   │   ├── mod.rs
│   │   ├── routes.rs
│   │   └── handlers.rs
│   └── config.rs             # Configuration
├── tests/                    # Integration tests
│   └── integration_test.rs
├── benches/                  # Benchmarks
│   └── bench.rs
├── Cargo.toml
├── Cargo.lock
├── rustfmt.toml
├── clippy.toml
└── README.md
```

## Security

```rust
use argon2::{password_hash::SaltString, Argon2, PasswordHash, PasswordHasher, PasswordVerifier};
use rand::rngs::OsRng;
use secrecy::{ExposeSecret, Secret};

// Secret handling
pub struct Credentials {
    pub username: String,
    pub password: Secret<String>,
}

impl Credentials {
    pub fn verify(&self, hash: &str) -> Result<bool, AuthError> {
        let parsed_hash = PasswordHash::new(hash)
            .map_err(|_| AuthError::InvalidHash)?;

        Ok(Argon2::default()
            .verify_password(
                self.password.expose_secret().as_bytes(),
                &parsed_hash,
            )
            .is_ok())
    }
}

// Password hashing
pub fn hash_password(password: &str) -> Result<String, HashError> {
    let salt = SaltString::generate(&mut OsRng);
    let argon2 = Argon2::default();

    argon2
        .hash_password(password.as_bytes(), &salt)
        .map(|hash| hash.to_string())
        .map_err(|e| HashError::Failed(e.to_string()))
}

// Secure random token
pub fn generate_token() -> String {
    use rand::Rng;
    let mut rng = OsRng;
    let bytes: [u8; 32] = rng.gen();
    base64::engine::general_purpose::URL_SAFE_NO_PAD.encode(bytes)
}

// Input validation
use validator::Validate;

#[derive(Debug, Validate)]
pub struct CreateUserRequest {
    #[validate(email)]
    pub email: String,

    #[validate(length(min = 8, max = 128))]
    pub password: String,

    #[validate(length(min = 1, max = 100))]
    pub name: String,
}

// SQL injection prevention with sqlx
async fn get_user_by_email(pool: &PgPool, email: &str) -> Result<Option<User>, sqlx::Error> {
    sqlx::query_as!(
        User,
        r#"SELECT id, email, name, created_at FROM users WHERE email = $1"#,
        email
    )
    .fetch_optional(pool)
    .await
}
```

## Best Practices

```rust
// Prefer &str over String in function parameters
fn process(data: &str) -> String {
    data.to_uppercase()
}

// Use impl Trait for return types
fn get_items() -> impl Iterator<Item = i32> {
    (0..10).filter(|x| x % 2 == 0)
}

// Use Into<T> for flexible APIs
fn set_name(&mut self, name: impl Into<String>) {
    self.name = name.into();
}

// Avoid unwrap() in production code
fn safe_parse(s: &str) -> Option<i32> {
    s.parse().ok()
}

// Use ? operator for error propagation
fn read_config(path: &Path) -> Result<Config> {
    let content = std::fs::read_to_string(path)?;
    let config: Config = toml::from_str(&content)?;
    Ok(config)
}

// Document public APIs
/// Processes the given data and returns the result.
///
/// # Arguments
///
/// * `data` - The input data to process
///
/// # Returns
///
/// The processed result, or an error if processing fails.
///
/// # Examples
///
/// ```
/// let result = process("hello")?;
/// assert_eq!(result, "HELLO");
/// ```
///
/// # Errors
///
/// Returns `ProcessError::Empty` if the input is empty.
pub fn process(data: &str) -> Result<String, ProcessError> {
    if data.is_empty() {
        return Err(ProcessError::Empty);
    }
    Ok(data.to_uppercase())
}
```

## Links to Additional Resources

- [The Rust Programming Language](https://doc.rust-lang.org/book/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [Rust Design Patterns](https://rust-unofficial.github.io/patterns/)
- [Organisation Global Standards](https://github.com/Pwd9000-ML/copilot-archetype-standards/tree/master/.github/instructions/global.instructions.md)

---

By following these Rust standards, teams can build safe, performant, and maintainable applications while leveraging the latest Rust 2024 edition features and best practices.
