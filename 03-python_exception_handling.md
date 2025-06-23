# Python Exception Handling for Java Developers

## Basic Syntax Comparison

### Java
```java
try {
    // risky code
} catch (SpecificException e) {
    // handle specific exception
} catch (Exception e) {
    // handle general exception
} finally {
    // cleanup code always runs
}
```

### Python
```python
try:
    # risky code
except SpecificException as e:
    # handle specific exception
except Exception as e:
    # handle general exception
finally:
    # cleanup code always runs
```

## Key Differences

| Java | Python | Notes |
|------|--------|-------|
| `catch` | `except` | Different keyword |
| `catch (Exception e)` | `except Exception as e:` | Different syntax for catching exception object |
| `throw` | `raise` | Different keyword for throwing exceptions |
| `throws` | No equivalent | Python doesn't require declaring exceptions in method signatures |

## Example 1: File Operations

### Java
```java
FileReader file = null;
try {
    file = new FileReader("data.txt");
    // read file operations
} catch (FileNotFoundException e) {
    System.out.println("File not found: " + e.getMessage());
} catch (IOException e) {
    System.out.println("IO error: " + e.getMessage());
} finally {
    if (file != null) {
        try {
            file.close();
        } catch (IOException e) {
            System.out.println("Error closing file");
        }
    }
}
```

### Python
```python
file = None
try:
    file = open("data.txt", "r")
    # read file operations
    content = file.read()
    print(content)
except FileNotFoundError as e:
    print(f"File not found: {e}")
except IOError as e:
    print(f"IO error: {e}")
finally:
    if file:
        file.close()
```

### Python (Better approach with context manager)
```python
try:
    with open("data.txt", "r") as file:
        content = file.read()
        print(content)
except FileNotFoundError as e:
    print(f"File not found: {e}")
except IOError as e:
    print(f"IO error: {e}")
# No finally needed - 'with' statement handles file closing automatically
```

## Example 2: Number Conversion and Division

### Java
```java
public class NumberProcessor {
    public static double processNumbers(String num1, String num2) {
        try {
            int a = Integer.parseInt(num1);
            int b = Integer.parseInt(num2);
            return (double) a / b;
        } catch (NumberFormatException e) {
            System.out.println("Invalid number format: " + e.getMessage());
            return 0.0;
        } catch (ArithmeticException e) {
            System.out.println("Division by zero: " + e.getMessage());
            return Double.POSITIVE_INFINITY;
        } finally {
            System.out.println("Number processing completed");
        }
    }
}
```

### Python
```python
def process_numbers(num1, num2):
    try:
        a = int(num1)
        b = int(num2)
        return a / b
    except ValueError as e:
        print(f"Invalid number format: {e}")
        return 0.0
    except ZeroDivisionError as e:
        print(f"Division by zero: {e}")
        return float('inf')
    finally:
        print("Number processing completed")

# Usage
result = process_numbers("10", "2")  # Returns 5.0
result = process_numbers("10", "0")  # Handles division by zero
result = process_numbers("abc", "2")  # Handles invalid format
```

## Example 3: Database Connection (Conceptual)

### Java
```java
Connection conn = null;
PreparedStatement stmt = null;
try {
    conn = DriverManager.getConnection(url, username, password);
    stmt = conn.prepareStatement("SELECT * FROM users WHERE id = ?");
    stmt.setInt(1, userId);
    ResultSet rs = stmt.executeQuery();
    // process results
} catch (SQLException e) {
    System.out.println("Database error: " + e.getMessage());
} finally {
    try {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    } catch (SQLException e) {
        System.out.println("Error closing resources");
    }
}
```

### Python
```python
import sqlite3

conn = None
try:
    conn = sqlite3.connect('database.db')
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    results = cursor.fetchall()
    # process results
    for row in results:
        print(row)
except sqlite3.Error as e:
    print(f"Database error: {e}")
finally:
    if conn:
        conn.close()
```

### Python (Better approach with context manager)
```python
import sqlite3

try:
    with sqlite3.connect('database.db') as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
        results = cursor.fetchall()
        for row in results:
            print(row)
except sqlite3.Error as e:
    print(f"Database error: {e}")
# Connection is automatically closed
```

## Example 4: Multiple Exception Types

### Java
```java
try {
    String[] array = {"1", "2", "3"};
    int index = Integer.parseInt(userInput);
    int value = Integer.parseInt(array[index]);
    int result = 100 / value;
    System.out.println("Result: " + result);
} catch (NumberFormatException e) {
    System.out.println("Invalid number: " + e.getMessage());
} catch (ArrayIndexOutOfBoundsException e) {
    System.out.println("Invalid index: " + e.getMessage());
} catch (ArithmeticException e) {
    System.out.println("Math error: " + e.getMessage());
} catch (Exception e) {
    System.out.println("Unexpected error: " + e.getMessage());
} finally {
    System.out.println("Operation completed");
}
```

### Python
```python
def process_array_operation(user_input):
    try:
        array = ["1", "2", "3"]
        index = int(user_input)
        value = int(array[index])
        result = 100 / value
        print(f"Result: {result}")
    except ValueError as e:
        print(f"Invalid number: {e}")
    except IndexError as e:
        print(f"Invalid index: {e}")
    except ZeroDivisionError as e:
        print(f"Math error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    finally:
        print("Operation completed")

# Usage examples
process_array_operation("1")      # Normal case
process_array_operation("abc")    # ValueError
process_array_operation("5")      # IndexError
process_array_operation("2")      # ZeroDivisionError (if array[2] is "0")
```

## Python-Specific Features

### 1. `else` clause (No Java equivalent)
```python
try:
    result = 10 / 2
except ZeroDivisionError:
    print("Cannot divide by zero")
else:
    # This runs only if no exception occurred
    print(f"Division successful: {result}")
finally:
    print("Cleanup")
```

### 2. Raising Exceptions
```python
def validate_age(age):
    try:
        age = int(age)
        if age < 0:
            raise ValueError("Age cannot be negative")
        if age > 150:
            raise ValueError("Age seems unrealistic")
        return age
    except ValueError as e:
        print(f"Invalid age: {e}")
        raise  # Re-raise the exception

# Usage
try:
    valid_age = validate_age("-5")
except ValueError:
    print("Age validation failed")
```

### 3. Exception Chaining (Python 3+)
```python
def process_data(data):
    try:
        return int(data) * 2
    except ValueError as e:
        raise RuntimeError("Data processing failed") from e

try:
    result = process_data("abc")
except RuntimeError as e:
    print(f"Error: {e}")
    print(f"Original cause: {e.__cause__}")
```

## Common Python Exception Types (vs Java)

| Python Exception | Java Equivalent | Description |
|------------------|-----------------|-------------|
| `ValueError` | `NumberFormatException`, `IllegalArgumentException` | Invalid value for operation |
| `TypeError` | `ClassCastException` | Wrong type for operation |
| `IndexError` | `ArrayIndexOutOfBoundsException` | Invalid sequence index |
| `KeyError` | No direct equivalent | Invalid dictionary key |
| `FileNotFoundError` | `FileNotFoundException` | File doesn't exist |
| `IOError` | `IOException` | Input/output error |
| `ZeroDivisionError` | `ArithmeticException` | Division by zero |
| `AttributeError` | `NoSuchFieldException` | Object has no attribute |

## Best Practices

1. **Use specific exceptions first, general ones last**
2. **Use context managers (`with` statement) when possible**
3. **Don't catch exceptions you can't handle meaningfully**
4. **Use `finally` for cleanup, but prefer context managers**
5. **Use `else` clause for code that should run only when no exception occurs**

## Quick Reference

```python
# Basic structure
try:
    # risky code
except SpecificException as e:
    # handle specific exception
except Exception as e:
    # handle any other exception
else:
    # runs only if no exception occurred
finally:
    # always runs (cleanup code)
```