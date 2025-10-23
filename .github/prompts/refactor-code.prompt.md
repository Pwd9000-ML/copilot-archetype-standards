---
mode: 'agent'
description: Refactor code safely with comprehensive testing using agent mode
---

# Refactor Code Prompt for Agent Mode

Use this prompt when working with GitHub Copilot's Coding Agent to refactor code while maintaining functionality and improving code quality.

## Refactoring Principles

### The Golden Rules
1. **Tests First**: Ensure comprehensive tests exist BEFORE refactoring
2. **Small Steps**: Make incremental changes, testing after each step
3. **Preserve Behavior**: Functionality should not change (unless that's the goal)
4. **Measure Twice, Cut Once**: Understand the code fully before changing it
5. **No混合Changes**: Don't mix refactoring with feature additions or bug fixes

### When to Refactor
✅ Code is difficult to understand or maintain
✅ Code violates DRY (Don't Repeat Yourself) principle
✅ Code has poor naming or structure
✅ Code has high complexity or coupling
✅ Tests exist and pass
✅ You understand what the code does

❌ Tests don't exist or fail
❌ You don't understand the code
❌ Under time pressure
❌ Production issues exist
❌ No clear improvement goal

## Refactoring Workflow

### Phase 1: Preparation
**Goal**: Understand the code and ensure safety net is in place

#### Steps
1. **Understand the Code**
   - Read the code thoroughly
   - Identify dependencies and call sites
   - Understand the business logic
   - Note any edge cases or special handling

2. **Verify Tests**
   - Run existing tests to ensure they pass
   - Check test coverage for the code to be refactored
   - Add missing tests if coverage is inadequate
   - Document test baseline (all tests passing)

3. **Plan the Refactoring**
   - Define clear goals for the refactoring
   - Break down into small, testable steps
   - Identify potential risks
   - Plan verification strategy

#### Agent Commands
```bash
# Check test coverage (Python)
pytest --cov=src tests/ --cov-report=term-missing

# Check test coverage (Java)
./gradlew test jacocoTestReport

# Run tests to establish baseline
pytest tests/ -v  # Python
./gradlew test    # Java

# Search for usages of code to refactor
grep -r "function_name" src/
grep -r "ClassName" src/
```

### Phase 2: Add Missing Tests
**Goal**: Ensure adequate test coverage before refactoring

#### Test Coverage Requirements
- **Unit Tests**: Test individual functions/methods
- **Integration Tests**: Test interactions between components
- **Edge Cases**: Test boundary conditions and error cases
- **Regression Tests**: Capture current behavior

#### Python Test Examples
Reference: [Python Instructions](../instructions/python.instructions.md)

```python
import pytest
from src.module import function_to_refactor

class TestFunctionBehavior:
    """Comprehensive tests for current behavior before refactoring."""
    
    def test_typical_input(self):
        """Test with typical valid input."""
        result = function_to_refactor(10, 20)
        assert result == 30
    
    def test_edge_case_zero(self):
        """Test with zero values."""
        result = function_to_refactor(0, 0)
        assert result == 0
    
    def test_edge_case_negative(self):
        """Test with negative values."""
        result = function_to_refactor(-5, 10)
        assert result == 5
    
    def test_error_handling_invalid_type(self):
        """Test error handling for invalid types."""
        with pytest.raises(TypeError):
            function_to_refactor("string", 10)
    
    def test_error_handling_none(self):
        """Test error handling for None values."""
        with pytest.raises(ValueError):
            function_to_refactor(None, 10)
```

#### Java Test Examples
Reference: [Java Instructions](../instructions/java.instructions.md)

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import static org.assertj.core.api.Assertions.*;

@DisplayName("MethodName behavior tests before refactoring")
class MethodNameTest {
    
    @Test
    @DisplayName("Should handle typical valid input correctly")
    void testTypicalInput() {
        var instance = new ClassName();
        var result = instance.methodName(10, 20);
        assertThat(result).isEqualTo(30);
    }
    
    @Test
    @DisplayName("Should handle edge case with zero values")
    void testEdgeCaseZero() {
        var instance = new ClassName();
        var result = instance.methodName(0, 0);
        assertThat(result).isEqualTo(0);
    }
    
    @Test
    @DisplayName("Should throw exception for invalid input")
    void testInvalidInput() {
        var instance = new ClassName();
        assertThatThrownBy(() -> instance.methodName(-1, 0))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("invalid");
    }
}
```

### Phase 3: Incremental Refactoring
**Goal**: Make small, safe changes while maintaining test passes

#### Common Refactoring Patterns

##### 1. Extract Method/Function
**When**: Method is too long or does multiple things

**Before (Python):**
```python
def process_order(order_data):
    # Validate order
    if not order_data.get('items'):
        raise ValueError("No items in order")
    if not order_data.get('customer_id'):
        raise ValueError("No customer ID")
    
    # Calculate total
    total = 0
    for item in order_data['items']:
        total += item['price'] * item['quantity']
    
    # Apply discount
    if total > 100:
        total *= 0.9
    
    # Create order
    order = Order(
        customer_id=order_data['customer_id'],
        items=order_data['items'],
        total=total
    )
    return order
```

**After (Python):**
```python
def process_order(order_data):
    _validate_order(order_data)
    total = _calculate_order_total(order_data['items'])
    total = _apply_discount(total)
    return _create_order(order_data, total)

def _validate_order(order_data):
    if not order_data.get('items'):
        raise ValueError("No items in order")
    if not order_data.get('customer_id'):
        raise ValueError("No customer ID")

def _calculate_order_total(items):
    return sum(item['price'] * item['quantity'] for item in items)

def _apply_discount(total):
    return total * 0.9 if total > 100 else total

def _create_order(order_data, total):
    return Order(
        customer_id=order_data['customer_id'],
        items=order_data['items'],
        total=total
    )
```

**Refactoring Steps:**
1. Extract `_validate_order` → Run tests
2. Extract `_calculate_order_total` → Run tests
3. Extract `_apply_discount` → Run tests
4. Extract `_create_order` → Run tests

##### 2. Rename for Clarity
**When**: Names are unclear or misleading

**Steps:**
1. Identify all usages of the identifier
2. Rename in one atomic change (use str_replace multiple times)
3. Run tests to ensure nothing broke
4. Update documentation

**Agent tip:** Use str_replace for each occurrence in the same response

##### 3. Remove Duplication
**When**: Same or similar code appears multiple times

**Before (Java):**
```java
public void processUserData(User user) {
    if (user == null) {
        logger.error("User is null");
        throw new IllegalArgumentException("User cannot be null");
    }
    // ... process user
}

public void processOrderData(Order order) {
    if (order == null) {
        logger.error("Order is null");
        throw new IllegalArgumentException("Order cannot be null");
    }
    // ... process order
}
```

**After (Java):**
```java
private <T> void validateNotNull(T obj, String name) {
    if (obj == null) {
        logger.error("{} is null", name);
        throw new IllegalArgumentException(name + " cannot be null");
    }
}

public void processUserData(User user) {
    validateNotNull(user, "User");
    // ... process user
}

public void processOrderData(Order order) {
    validateNotNull(order, "Order");
    // ... process order
}
```

##### 4. Simplify Conditional Logic
**When**: Complex nested conditionals are hard to understand

**Before:**
```python
def get_discount(customer, order_total):
    if customer is not None:
        if customer.is_premium:
            if order_total > 100:
                return 0.15
            else:
                return 0.10
        else:
            if order_total > 100:
                return 0.05
            else:
                return 0
    else:
        return 0
```

**After:**
```python
def get_discount(customer, order_total):
    if customer is None:
        return 0
    
    if customer.is_premium:
        return 0.15 if order_total > 100 else 0.10
    
    return 0.05 if order_total > 100 else 0
```

##### 5. Replace Magic Numbers with Constants
**When**: Unexplained numbers appear in code

**Before:**
```java
public boolean isValidAge(int age) {
    return age >= 18 && age <= 120;
}

public double calculateSeniorDiscount(int age, double price) {
    if (age >= 65) {
        return price * 0.15;
    }
    return 0;
}
```

**After:**
```java
private static final int MINIMUM_ADULT_AGE = 18;
private static final int MAXIMUM_REALISTIC_AGE = 120;
private static final int SENIOR_AGE_THRESHOLD = 65;
private static final double SENIOR_DISCOUNT_RATE = 0.15;

public boolean isValidAge(int age) {
    return age >= MINIMUM_ADULT_AGE && age <= MAXIMUM_REALISTIC_AGE;
}

public double calculateSeniorDiscount(int age, double price) {
    if (age >= SENIOR_AGE_THRESHOLD) {
        return price * SENIOR_DISCOUNT_RATE;
    }
    return 0;
}
```

### Phase 4: Verification
**Goal**: Ensure refactoring didn't break anything

#### Verification Checklist
- [ ] All existing tests still pass
- [ ] New tests added for refactored code pass
- [ ] Code coverage maintained or improved
- [ ] Linting passes with no new warnings
- [ ] Build succeeds
- [ ] Performance hasn't degraded (if applicable)
- [ ] Documentation updated

#### Verification Commands
```bash
# Python
pytest tests/ -v
pytest --cov=src tests/ --cov-report=term
ruff check .
mypy src/

# Java
./gradlew test
./gradlew jacocoTestReport
./gradlew spotlessCheck
./gradlew build

# Terraform
terraform validate
terraform fmt -check -recursive
tflint
```

### Phase 5: Documentation
**Goal**: Update documentation to reflect changes

#### What to Document
- Update function/method docstrings if signatures changed
- Update README if public API changed
- Update architecture docs if structure changed
- Add comments explaining complex refactored logic
- Update examples if behavior or usage changed

## Language-Specific Refactoring Patterns

### Python Refactoring
Reference: [Python Instructions](../instructions/python.instructions.md)

**Common patterns:**
- Use list/dict comprehensions instead of loops
- Use dataclasses for simple data structures
- Use context managers for resource management
- Use type hints for clarity
- Use pathlib instead of os.path
- Use f-strings instead of % or .format()

**Example: Modernizing Python code**
```python
# Before
def read_config(filename):
    import os
    filepath = os.path.join(os.path.dirname(__file__), filename)
    with open(filepath, 'r') as f:
        return json.load(f)

# After
from pathlib import Path

def read_config(filename: str) -> dict:
    filepath = Path(__file__).parent / filename
    return json.loads(filepath.read_text())
```

### Java Refactoring
Reference: [Java Instructions](../instructions/java.instructions.md)

**Common patterns:**
- Use records for immutable data classes (Java 14+)
- Use var for local variable type inference (Java 10+)
- Use switch expressions (Java 14+)
- Use Optional instead of null checks
- Use streams for collection processing
- Use sealed classes for restricted hierarchies (Java 17+)

**Example: Modernizing Java code**
```java
// Before
public class UserData {
    private final String name;
    private final String email;
    
    public UserData(String name, String email) {
        this.name = name;
        this.email = email;
    }
    
    public String getName() { return name; }
    public String getEmail() { return email; }
    
    @Override
    public boolean equals(Object o) { /* ... */ }
    @Override
    public int hashCode() { /* ... */ }
}

// After (Java 17+)
public record UserData(String name, String email) {
    public UserData {
        Objects.requireNonNull(name, "Name cannot be null");
        Objects.requireNonNull(email, "Email cannot be null");
    }
}
```

### Terraform Refactoring
Reference: [Terraform Instructions](../instructions/terraform.instructions.md)

**Common patterns:**
- Extract repeated blocks into modules
- Use variables for hardcoded values
- Use locals for computed values
- Use for_each instead of count
- Use dynamic blocks for repeated nested blocks
- Organize resources logically

**Example: Extracting to module**
```hcl
# Before: main.tf with repeated pattern
resource "azurerm_resource_group" "rg1" {
  name     = "rg-app1-prod-eastus"
  location = "eastus"
  tags = {
    environment = "prod"
    application = "app1"
  }
}

resource "azurerm_resource_group" "rg2" {
  name     = "rg-app2-prod-eastus"
  location = "eastus"
  tags = {
    environment = "prod"
    application = "app2"
  }
}

# After: Using module
module "resource_groups" {
  source = "./modules/resource-group"
  
  for_each = toset(["app1", "app2"])
  
  name        = "rg-${each.key}-prod-eastus"
  location    = "eastus"
  environment = "prod"
  application = each.key
}
```

## Refactoring Anti-Patterns

### ❌ Big Bang Refactoring
**Problem**: Refactoring everything at once
**Impact**: High risk, difficult to debug if something breaks
**Instead**: Make small, incremental changes

### ❌ Refactoring Without Tests
**Problem**: No safety net to catch regressions
**Impact**: Breaks functionality without detection
**Instead**: Write tests first, then refactor

### ❌ Mixing Concerns
**Problem**: Refactoring + adding features + fixing bugs all at once
**Impact**: Difficult to review, hard to rollback
**Instead**: Separate refactoring from functional changes

### ❌ Over-engineering
**Problem**: Adding abstraction for hypothetical future needs
**Impact**: Complexity without benefit
**Instead**: Refactor for current needs, YAGNI principle

### ❌ Perfection Paralysis
**Problem**: Trying to make code perfect in one go
**Impact**: Never finishing, never shipping
**Instead**: Make it better, not perfect

## Agent-Specific Refactoring Tips

### Efficient Refactoring with Agent

**1. Batch Similar Changes**
Use str_replace multiple times in same response for related changes:
```
- Rename function in definition
- Rename function in all call sites
- Update function in tests
All in the same response
```

**2. Run Tests Frequently**
After each logical step:
```bash
# Make change
str_replace in file1.py

# Test immediately
pytest tests/test_file1.py -v

# Report if tests pass
report_progress
```

**3. Use Parallel Operations**
When refactoring multiple independent files:
```
- Refactor file1.py
- Refactor file2.py
- Refactor file3.py
All in the same response if changes are independent
```

**4. Leverage Language Servers**
For rename operations, consider:
- Using IDE refactoring tools when possible
- Verifying all usages found with grep/search

## Progress Reporting for Refactoring

### Initial Plan
```markdown
## Refactoring: [Component Name]

### Goals
- Improve code readability
- Reduce duplication
- Better naming
- [Other specific goals]

### Preparation
- [x] Tests exist and pass (baseline)
- [x] Code coverage measured: XX%
- [x] All usages identified
- [ ] Refactoring steps planned

### Refactoring Plan
1. [ ] Extract method for [specific functionality]
2. [ ] Rename [old_name] to [new_name]
3. [ ] Remove duplication in [area]
4. [ ] Simplify [complex logic]
5. [ ] Update documentation

### Next Steps
Starting with step 1: Extract method
```

### Progress Update
```markdown
## Refactoring: [Component Name]

### Progress
- [x] Tests exist and pass (baseline)
- [x] Code coverage measured: XX%
- [x] All usages identified
- [x] Refactoring steps planned

### Completed Steps
- [x] Extract method for [specific functionality]
  - Extracted `_validate_input` from `process_data`
  - All tests still passing
- [x] Rename [old_name] to [new_name]
  - Renamed in 15 locations
  - Tests passing

### In Progress
- [ ] Remove duplication in [area]
- [ ] Simplify [complex logic]
- [ ] Update documentation

### Next Steps
Removing duplication in validation logic
```

## Refactoring Checklist

```markdown
### Preparation
- [ ] Code behavior understood
- [ ] All usages identified
- [ ] Tests exist and pass
- [ ] Test coverage adequate (>80%)
- [ ] Refactoring goal clear
- [ ] Steps planned

### Refactoring
- [ ] Step 1 completed → Tests pass
- [ ] Step 2 completed → Tests pass
- [ ] Step 3 completed → Tests pass
- [ ] [Continue for each step]

### Verification
- [ ] All tests passing
- [ ] No new linter warnings
- [ ] Build successful
- [ ] Code coverage maintained
- [ ] Performance acceptable

### Documentation
- [ ] Docstrings updated
- [ ] Comments updated
- [ ] README updated (if needed)
- [ ] Examples updated (if needed)

### Completion
- [ ] Changes reviewed
- [ ] Progress reported
- [ ] Ready for code review
```

## Remember

Refactoring is about improving code structure without changing behavior. Always have tests as a safety net, make small incremental changes, and test after each step. The goal is to make the code more maintainable, not just different.

**The Refactoring Mantra:**
1. Tests pass (green)
2. Refactor (still green)
3. Tests still pass (verify green)
4. Commit/Report progress
5. Repeat
