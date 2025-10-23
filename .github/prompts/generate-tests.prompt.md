---
mode: 'ask'
description: Generate comprehensive unit tests for selected code
---

# Generate Tests Prompt

Generate comprehensive unit tests for the selected code following best practices for the specific language.

## Test Generation Guidelines

### General Requirements
- Cover happy path scenarios
- Test edge cases and boundary conditions
- Test error handling and exceptions
- Include input validation tests
- Test for null/undefined/empty inputs where applicable
- Ensure tests are independent and can run in any order
- Use descriptive test names that explain what is being tested

### Python Tests
Reference: [Python Instructions](../instructions/python.instructions.md)

Use `pytest` framework with these patterns:
```python
# tests/test_module_name.py
import pytest
from module_name import function_to_test

def test_function_happy_path():
    """Test function with valid inputs."""
    result = function_to_test(valid_input)
    assert result == expected_output

def test_function_edge_case():
    """Test function with edge case input."""
    result = function_to_test(edge_case_input)
    assert result == expected_edge_output

def test_function_error_handling():
    """Test function raises appropriate exception."""
    with pytest.raises(ValueError, match="expected error message"):
        function_to_test(invalid_input)

@pytest.fixture
def sample_data():
    """Provide sample data for tests."""
    return {"key": "value"}

def test_function_with_fixture(sample_data):
    """Test function using fixture."""
    result = function_to_test(sample_data)
    assert result is not None
```

### Java Tests
Reference: [Java Instructions](../instructions/java.instructions.md)

Use JUnit 5 and AssertJ:
```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.BeforeEach;
import static org.assertj.core.api.Assertions.*;

class ClassNameTest {
    private ClassName instance;
    
    @BeforeEach
    void setUp() {
        instance = new ClassName();
    }
    
    @Test
    @DisplayName("Should return expected result for valid input")
    void testMethodName_ValidInput_ReturnsExpectedResult() {
        // Arrange
        var input = createValidInput();
        
        // Act
        var result = instance.methodName(input);
        
        // Assert
        assertThat(result)
            .isNotNull()
            .hasFieldOrPropertyWithValue("field", expectedValue);
    }
    
    @Test
    @DisplayName("Should throw exception for invalid input")
    void testMethodName_InvalidInput_ThrowsException() {
        // Arrange
        var invalidInput = createInvalidInput();
        
        // Act & Assert
        assertThatThrownBy(() -> instance.methodName(invalidInput))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("expected error message");
    }
}
```

### Terraform Tests
Reference: [Terraform Instructions](../instructions/terraform.instructions.md)

While Terraform doesn't have traditional unit tests, you can:
1. Use `terraform validate` for syntax checking
2. Use `terraform plan` to verify expected resources
3. Use Terratest for integration testing (Go-based)

Example Terratest pattern:
```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestTerraformModule(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../",
        Vars: map[string]interface{}{
            "environment": "test",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    output := terraform.Output(t, terraformOptions, "resource_group_name")
    assert.Contains(t, output, "test")
}
```

## Test Coverage Goals

- Aim for >80% code coverage
- Focus on critical business logic
- Don't test framework code or external libraries
- Test public APIs, not implementation details

## Test Naming Conventions

### Python
- Use descriptive function names: `test_<function>_<scenario>_<expected>`
- Example: `test_calculate_total_with_discount_returns_reduced_price`

### Java
- Use descriptive method names: `test<Method>_<Scenario>_<Expected>`
- Example: `testCalculateTotal_WithDiscount_ReturnsReducedPrice`
- Use `@DisplayName` for human-readable descriptions

## Mocking and Test Doubles

- Mock external dependencies (databases, APIs, file systems)
- Use appropriate mocking frameworks:
  - Python: `unittest.mock` or `pytest-mock`
  - Java: Mockito
- Don't mock the code under test
- Prefer fakes over mocks when practical

## Assertions

### Python (pytest)
```python
assert result == expected
assert result is not None
assert len(result) == 5
assert "substring" in result
```

### Java (AssertJ)
```java
assertThat(result).isEqualTo(expected);
assertThat(result).isNotNull();
assertThat(result).hasSize(5);
assertThat(result).contains("substring");
```

## Additional Considerations

- Parameterized tests for similar scenarios with different inputs
- Test async/concurrent code appropriately
- Consider performance tests for critical paths
- Include integration tests where needed
- Document complex test setups

Generate tests that are:
✅ Readable and maintainable
✅ Fast to execute
✅ Reliable and deterministic
✅ Independent from each other
✅ Focused on behavior, not implementation
