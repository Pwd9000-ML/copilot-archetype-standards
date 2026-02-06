---
applyTo: "**/*.ts,**/*.tsx"
description: TypeScript 5.4+ coding standards and best practices
---

# TypeScript 5.4 Development Standards

## Language Version
- **Required**: TypeScript 5.4+
- **Target**: ES2023 or later
- **Module**: ESNext with NodeNext resolution
- **Strict Mode**: Always enabled with all strict flags

## Code Formatting & Linting

- **Linter**: ESLint with `@typescript-eslint`
- **Formatter**: Prettier (120 char line length)
- **Type Checking**: `tsc --noEmit` in CI
- **Import Sorting**: `eslint-plugin-import` or `@trivago/prettier-plugin-sort-imports`

### Configuration (tsconfig.json)
```json
{
  "compilerOptions": {
    "target": "ES2023",
    "lib": ["ES2023"],
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "noPropertyAccessFromIndexSignature": true,
    "exactOptionalPropertyTypes": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### ESLint Configuration (.eslintrc.cjs)
```javascript
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: './tsconfig.json',
    ecmaVersion: 2023,
  },
  plugins: ['@typescript-eslint', 'import'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/strict-type-checked',
    'plugin:@typescript-eslint/stylistic-type-checked',
    'plugin:import/typescript',
    'prettier',
  ],
  rules: {
    '@typescript-eslint/explicit-function-return-type': 'error',
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/prefer-nullish-coalescing': 'error',
    '@typescript-eslint/prefer-optional-chain': 'error',
    '@typescript-eslint/strict-boolean-expressions': 'error',
    'import/order': ['error', {
      'groups': ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
      'newlines-between': 'always',
      'alphabetize': { order: 'asc' }
    }],
  },
};
```

### Prettier Configuration (.prettierrc)
```json
{
  "printWidth": 120,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "bracketSpacing": true,
  "arrowParens": "always"
}
```

## Modern TypeScript 5.4 Features

### Const Type Parameters
```typescript
// Const type parameters preserve literal types
function createTuple<const T extends readonly unknown[]>(...args: T): T {
  return args;
}

// Type is: readonly ["hello", 42, true]
const tuple = createTuple('hello', 42, true);

// Object literals with const
function createConfig<const T extends Record<string, unknown>>(config: T): T {
  return config;
}

// Type preserves literal types
const config = createConfig({
  port: 3000, // type: 3000, not number
  host: 'localhost', // type: "localhost", not string
});
```

### NoInfer Utility Type
```typescript
// Prevent inference from certain parameters
function createFSM<S extends string>(
  initialState: NoInfer<S>,
  states: S[]
): { current: S; transition: (to: S) => void } {
  let current = initialState;
  return {
    get current() { return current; },
    transition(to: S) { current = to; },
  };
}

// Forces explicit state type
const fsm = createFSM('idle', ['idle', 'loading', 'success', 'error']);
```

### Improved Narrowing
```typescript
// Narrowing in closures
function processItems(items: string[] | undefined): void {
  if (items === undefined) return;

  // items is narrowed correctly in callback
  items.forEach((item) => {
    console.log(item.toUpperCase()); // No error
  });
}

// Grouped narrowing
type Shape =
  | { kind: 'circle'; radius: number }
  | { kind: 'square'; size: number }
  | { kind: 'rectangle'; width: number; height: number };

function area(shape: Shape): number {
  switch (shape.kind) {
    case 'circle':
      return Math.PI * shape.radius ** 2;
    case 'square':
      return shape.size ** 2;
    case 'rectangle':
      return shape.width * shape.height;
  }
}
```

## Type Patterns

```typescript
// Branded types for type safety
declare const __brand: unique symbol;
type Brand<T, B> = T & { [__brand]: B };

type UserId = Brand<string, 'UserId'>;
type OrderId = Brand<string, 'OrderId'>;

function createUserId(id: string): UserId {
  return id as UserId;
}

function getUser(id: UserId): Promise<User> {
  // Can only accept UserId, not OrderId or plain string
}

// Discriminated unions
type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

function handleResult<T>(result: Result<T>): T | null {
  if (result.success) {
    return result.data;
  }
  console.error(result.error);
  return null;
}

// Template literal types
type HTTPMethod = 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
type APIRoute = `/api/${string}`;
type Endpoint = `${HTTPMethod} ${APIRoute}`;

const endpoint: Endpoint = 'GET /api/users';

// Mapped types with key remapping
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface Person {
  name: string;
  age: number;
}

type PersonGetters = Getters<Person>;
// { getName: () => string; getAge: () => number }

// Conditional types
type UnwrapPromise<T> = T extends Promise<infer U> ? U : T;
type ArrayElement<T> = T extends (infer U)[] ? U : never;

// Satisfies operator
const config = {
  port: 3000,
  host: 'localhost',
} satisfies Record<string, string | number>;
// Type is preserved as literal but validated against constraint
```

## Error Handling

```typescript
// Custom error classes
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number = 500,
    public readonly isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} with id ${id} not found`, 'NOT_FOUND', 404);
  }
}

export class ValidationError extends AppError {
  constructor(public readonly errors: Record<string, string[]>) {
    super('Validation failed', 'VALIDATION_ERROR', 400);
  }
}

// Result type pattern
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

async function safeAsync<T>(promise: Promise<T>): Promise<Result<T>> {
  try {
    const value = await promise;
    return ok(value);
  } catch (error) {
    return err(error instanceof Error ? error : new Error(String(error)));
  }
}

// Usage
async function getUser(id: string): Promise<Result<User, NotFoundError>> {
  const user = await db.findUser(id);
  if (!user) {
    return err(new NotFoundError('User', id));
  }
  return ok(user);
}
```

## Async Patterns

```typescript
// Async iteration
async function* paginate<T>(
  fetcher: (page: number) => Promise<{ data: T[]; hasMore: boolean }>
): AsyncGenerator<T[], void, unknown> {
  let page = 1;
  let hasMore = true;

  while (hasMore) {
    const result = await fetcher(page);
    yield result.data;
    hasMore = result.hasMore;
    page++;
  }
}

// Usage
for await (const batch of paginate(fetchUsers)) {
  await processUsers(batch);
}

// Concurrent processing with limit
async function processWithConcurrency<T, R>(
  items: T[],
  processor: (item: T) => Promise<R>,
  concurrency: number
): Promise<R[]> {
  const results: R[] = [];
  const executing = new Set<Promise<void>>();

  for (const item of items) {
    const promise = processor(item).then((result) => {
      results.push(result);
      executing.delete(promise);
    });

    executing.add(promise);

    if (executing.size >= concurrency) {
      await Promise.race(executing);
    }
  }

  await Promise.all(executing);
  return results;
}

// Retry with exponential backoff
async function withRetry<T>(
  fn: () => Promise<T>,
  options: { maxAttempts?: number; baseDelay?: number; maxDelay?: number } = {}
): Promise<T> {
  const { maxAttempts = 3, baseDelay = 1000, maxDelay = 10000 } = options;

  let lastError: Error | undefined;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (attempt === maxAttempts) break;

      const delay = Math.min(baseDelay * 2 ** (attempt - 1), maxDelay);
      await new Promise((resolve) => setTimeout(resolve, delay));
    }
  }

  throw lastError;
}
```

## Testing

```typescript
import { describe, it, expect, beforeEach, vi, type Mock } from 'vitest';

// Unit tests with Vitest
describe('UserService', () => {
  let userService: UserService;
  let mockRepository: { findById: Mock; save: Mock };

  beforeEach(() => {
    mockRepository = {
      findById: vi.fn(),
      save: vi.fn(),
    };
    userService = new UserService(mockRepository);
  });

  describe('getUser', () => {
    it('should return user when found', async () => {
      const expectedUser = { id: '1', name: 'John', email: 'john@example.com' };
      mockRepository.findById.mockResolvedValue(expectedUser);

      const result = await userService.getUser('1');

      expect(result).toEqual(expectedUser);
      expect(mockRepository.findById).toHaveBeenCalledWith('1');
    });

    it('should throw NotFoundError when user not found', async () => {
      mockRepository.findById.mockResolvedValue(null);

      await expect(userService.getUser('999')).rejects.toThrow(NotFoundError);
    });
  });
});

// Type testing with expect-type
import { expectTypeOf } from 'expect-type';

describe('type tests', () => {
  it('should have correct return type', () => {
    expectTypeOf(getUser).returns.toEqualTypeOf<Promise<User>>();
  });

  it('should accept correct parameter types', () => {
    expectTypeOf(createUser).parameter(0).toMatchTypeOf<CreateUserDto>();
  });
});

// Integration tests
describe('API Integration', () => {
  it('should create and retrieve user', async () => {
    const app = await createTestApp();

    const createResponse = await app.inject({
      method: 'POST',
      url: '/api/users',
      payload: { name: 'Test', email: 'test@example.com' },
    });

    expect(createResponse.statusCode).toBe(201);
    const user = JSON.parse(createResponse.body) as User;

    const getResponse = await app.inject({
      method: 'GET',
      url: `/api/users/${user.id}`,
    });

    expect(getResponse.statusCode).toBe(200);
    expect(JSON.parse(getResponse.body)).toMatchObject({ name: 'Test' });
  });
});
```

## Project Structure

```
project/
├── src/
│   ├── index.ts              # Application entry point
│   ├── domain/               # Business logic
│   │   ├── user/
│   │   │   ├── user.entity.ts
│   │   │   ├── user.service.ts
│   │   │   └── user.repository.ts
│   │   └── order/
│   ├── infrastructure/       # External integrations
│   │   ├── database/
│   │   │   └── prisma.client.ts
│   │   └── http/
│   │       └── axios.client.ts
│   ├── api/                  # HTTP handlers
│   │   ├── routes.ts
│   │   ├── middleware/
│   │   └── handlers/
│   ├── config/               # Configuration
│   │   └── index.ts
│   └── lib/                  # Shared utilities
│       ├── errors.ts
│       └── validation.ts
├── tests/
│   ├── unit/
│   └── integration/
├── package.json
├── tsconfig.json
├── .eslintrc.cjs
├── .prettierrc
├── vitest.config.ts
└── README.md
```

## Security

```typescript
import { z } from 'zod';
import { randomBytes, scrypt, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';

const scryptAsync = promisify(scrypt);

// Input validation with Zod
const CreateUserSchema = z.object({
  email: z.string().email().max(254),
  password: z.string().min(8).max(128),
  name: z.string().min(1).max(100).trim(),
});

type CreateUserDto = z.infer<typeof CreateUserSchema>;

function validateCreateUser(input: unknown): CreateUserDto {
  return CreateUserSchema.parse(input);
}

// Password hashing
const SALT_LENGTH = 32;
const KEY_LENGTH = 64;

async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(SALT_LENGTH);
  const hash = (await scryptAsync(password, salt, KEY_LENGTH)) as Buffer;
  return `${salt.toString('hex')}:${hash.toString('hex')}`;
}

async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const [saltHex, hashHex] = stored.split(':');
  if (!saltHex || !hashHex) return false;

  const salt = Buffer.from(saltHex, 'hex');
  const storedHash = Buffer.from(hashHex, 'hex');
  const hash = (await scryptAsync(password, salt, KEY_LENGTH)) as Buffer;

  return timingSafeEqual(hash, storedHash);
}

// Secure token generation
function generateToken(length: number = 32): string {
  return randomBytes(length).toString('base64url');
}

// SQL injection prevention - use parameterized queries
async function getUserByEmail(email: string): Promise<User | null> {
  // Always use parameterized queries with your ORM/query builder
  return prisma.user.findUnique({
    where: { email },
  });
}

// XSS prevention - sanitize output
import DOMPurify from 'isomorphic-dompurify';

function sanitizeHtml(dirty: string): string {
  return DOMPurify.sanitize(dirty, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
    ALLOWED_ATTR: ['href'],
  });
}

// Environment variables
const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
});

export const env = EnvSchema.parse(process.env);
```

## Best Practices

```typescript
// Prefer unknown over any
function processData(data: unknown): string {
  if (typeof data === 'string') {
    return data.toUpperCase();
  }
  if (typeof data === 'number') {
    return data.toString();
  }
  return String(data);
}

// Use readonly for immutability
interface Config {
  readonly apiUrl: string;
  readonly timeout: number;
}

function processItems(items: readonly string[]): void {
  // Cannot mutate items
  items.forEach(console.log);
}

// Prefer interface for object shapes
interface User {
  id: string;
  email: string;
  name: string;
}

// Use type for unions, intersections, mapped types
type UserRole = 'admin' | 'user' | 'guest';
type UserWithRole = User & { role: UserRole };

// Avoid boolean parameters - use options object
// Bad
function fetchUser(id: string, includeOrders: boolean, includeProfile: boolean): Promise<User>;

// Good
interface FetchUserOptions {
  includeOrders?: boolean;
  includeProfile?: boolean;
}

function fetchUser(id: string, options?: FetchUserOptions): Promise<User>;

// Use exhaustive checks
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`);
}

type Status = 'pending' | 'approved' | 'rejected';

function handleStatus(status: Status): string {
  switch (status) {
    case 'pending':
      return 'Waiting for review';
    case 'approved':
      return 'Approved';
    case 'rejected':
      return 'Rejected';
    default:
      return assertNever(status); // Compile error if case missed
  }
}
```

## Links to Additional Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [TypeScript Deep Dive](https://basarat.gitbook.io/typescript/)
- [Total TypeScript](https://www.totaltypescript.com/)
- [Organisation Global Standards](https://github.com/Pwd9000-ML/copilot-archetype-standards/tree/master/.github/instructions/global.instructions.md)

---

By following these TypeScript standards, teams can build type-safe, maintainable applications while leveraging the latest TypeScript 5.4+ features and best practices.
