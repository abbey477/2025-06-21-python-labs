# Python Type Safety Guide for Java Developers

## Basic Type Hints

### Function Parameters and Return Types
```python
def add_numbers(a: int, b: int) -> int:
    return a + b

def format_name(first: str, last: str) -> str:
    return f"{first} {last}"

def calculate_average(numbers: list[float]) -> float:
    return sum(numbers) / len(numbers)
```

### Variable Annotations
```python
# Basic types
name: str = "Alice"
age: int = 30
height: float = 5.8
is_active: bool = True

# Collections
numbers: list[int] = [1, 2, 3, 4, 5]
grades: dict[str, float] = {"math": 95.5, "science": 87.2}
coordinates: tuple[float, float] = (10.5, 20.3)
unique_ids: set[int] = {1, 2, 3, 4}
```

### Optional and Union Types
```python
from typing import Optional, Union

def find_user(user_id: int) -> Optional[str]:
    # Returns string or None
    users = {1: "Alice", 2: "Bob"}
    return users.get(user_id)

def process_input(value: Union[str, int]) -> str:
    # Accepts either string or int
    return str(value).upper()

# Python 3.10+ syntax
def modern_optional(value: str | None) -> str:
    return value or "default"
```

## Advanced Type Hints

### Generic Types
```python
from typing import TypeVar, Generic

T = TypeVar('T')

class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []
    
    def push(self, item: T) -> None:
        self._items.append(item)
    
    def pop(self) -> T:
        return self._items.pop()

# Usage
int_stack: Stack[int] = Stack()
str_stack: Stack[str] = Stack()
```

### Callable Types
```python
from typing import Callable

def apply_operation(numbers: list[int], operation: Callable[[int], int]) -> list[int]:
    return [operation(num) for num in numbers]

def square(x: int) -> int:
    return x * x

# Usage
result = apply_operation([1, 2, 3], square)
```

### Protocol (Structural Typing)
```python
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...

class Circle:
    def draw(self) -> None:
        print("Drawing circle")

class Rectangle:
    def draw(self) -> None:
        print("Drawing rectangle")

def render_shape(shape: Drawable) -> None:
    shape.draw()

# Both Circle and Rectangle satisfy the Drawable protocol
```

## Runtime Type Validation with Pydantic

### Basic Models
```python
from pydantic import BaseModel, ValidationError
from typing import Optional
from datetime import datetime

class User(BaseModel):
    id: int
    name: str
    email: str
    age: Optional[int] = None
    created_at: datetime = datetime.now()

# Usage
try:
    user = User(id=1, name="John", email="john@example.com", age=25)
    print(user.model_dump())  # Convert to dict
except ValidationError as e:
    print(f"Validation error: {e}")
```

### Advanced Pydantic Features
```python
from pydantic import BaseModel, validator, Field
from typing import List

class Product(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    price: float = Field(..., gt=0)
    tags: List[str] = Field(default_factory=list)
    
    @validator('name')
    def validate_name(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.title()
    
    @validator('tags')
    def validate_tags(cls, v):
        return [tag.lower() for tag in v]

# Nested models
class Order(BaseModel):
    id: int
    products: List[Product]
    total: float
    
    @validator('total')
    def validate_total(cls, v, values):
        if 'products' in values:
            calculated_total = sum(p.price for p in values['products'])
            if abs(v - calculated_total) > 0.01:
                raise ValueError('Total does not match sum of product prices')
        return v
```

## Runtime Type Checking with typeguard

### Function Decoration
```python
from typeguard import typechecked

@typechecked
def process_data(items: list[str], multiplier: int) -> list[str]:
    return [item * multiplier for item in items]

@typechecked
def calculate_stats(numbers: list[float]) -> dict[str, float]:
    return {
        'mean': sum(numbers) / len(numbers),
        'min': min(numbers),
        'max': max(numbers)
    }

# These will raise TypeError at runtime if wrong types are passed
```

### Class-Level Type Checking
```python
from typeguard import typechecked

@typechecked
class BankAccount:
    def __init__(self, account_number: str, initial_balance: float) -> None:
        self.account_number = account_number
        self.balance = initial_balance
    
    def deposit(self, amount: float) -> None:
        if amount <= 0:
            raise ValueError("Deposit amount must be positive")
        self.balance += amount
    
    def withdraw(self, amount: float) -> bool:
        if amount <= 0:
            raise ValueError("Withdrawal amount must be positive")
        if amount <= self.balance:
            self.balance -= amount
            return True
        return False
    
    def get_balance(self) -> float:
        return self.balance
```

## Custom Type Guards

### Type Guard Functions
```python
from typing import TypeGuard

def is_string_list(value: list[object]) -> TypeGuard[list[str]]:
    return all(isinstance(item, str) for item in value)

def process_strings(items: list[object]) -> None:
    if is_string_list(items):
        # Type checker knows items is list[str] here
        for item in items:
            print(item.upper())  # No type error
    else:
        print("Not all items are strings")
```

### Assertion Functions
```python
from typing import assert_type

def assert_positive(value: float) -> None:
    assert value > 0, f"Expected positive number, got {value}"

def safe_divide(a: float, b: float) -> float:
    assert_positive(b)  # Runtime check
    return a / b
```

## Data Classes with Type Safety

### Basic DataClass
```python
from dataclasses import dataclass
from typing import Optional

@dataclass
class Employee:
    id: int
    name: str
    department: str
    salary: float
    manager: Optional['Employee'] = None
    
    def __post_init__(self):
        if self.salary < 0:
            raise ValueError("Salary cannot be negative")
        if not self.name.strip():
            raise ValueError("Name cannot be empty")

# Usage
emp = Employee(id=1, name="Alice", department="Engineering", salary=75000)
```

### Frozen DataClass (Immutable)
```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Point:
    x: float
    y: float
    
    def distance_from_origin(self) -> float:
        return (self.x ** 2 + self.y ** 2) ** 0.5

# Instances are immutable
point = Point(3.0, 4.0)
# point.x = 5.0  # This would raise an error
```

## Error Handling with Types

### Custom Exception Classes
```python
from typing import Optional

class ValidationError(Exception):
    def __init__(self, field: str, value: object, message: str) -> None:
        self.field = field
        self.value = value
        self.message = message
        super().__init__(f"Validation failed for {field}: {message}")

def validate_email(email: str) -> str:
    if "@" not in email:
        raise ValidationError("email", email, "Must contain @ symbol")
    return email.lower()

def safe_divide(a: float, b: float) -> Optional[float]:
    try:
        if b == 0:
            return None
        return a / b
    except TypeError as e:
        raise ValidationError("operands", (a, b), f"Invalid types: {e}")
```

## Configuration and Setup

### mypy Configuration (mypy.ini)
```ini
[mypy]
python_version = 3.9
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True
check_untyped_defs = True
disallow_untyped_decorators = True
no_implicit_optional = True
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_unreachable = True
strict_equality = True
```

### Pre-commit Hook Example
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.0.0
    hooks:
      - id: mypy
        additional_dependencies: [pydantic, types-requests]
```

## Best Practices

### Gradual Typing Strategy
```python
# Start with critical functions
def calculate_tax(income: float, rate: float) -> float:
    return income * rate

# Add types to public APIs
class PaymentProcessor:
    def process_payment(self, amount: float, card_number: str) -> bool:
        # Implementation here
        pass

# Use Any for legacy code initially
from typing import Any

def legacy_function(data: Any) -> Any:
    # Gradually add more specific types
    return data
```

### Type Aliases for Clarity
```python
from typing import NewType, Dict, List

# Create semantic types
UserId = NewType('UserId', int)
Email = NewType('Email', str)

# Type aliases for complex types
UserDatabase = Dict[UserId, str]
EmailList = List[Email]

def send_notification(user_id: UserId, email: Email) -> bool:
    # Type checker ensures correct usage
    return True

# Usage
user_id = UserId(123)
email = Email("user@example.com")
send_notification(user_id, email)
```

## Testing with Types

### Typed Test Cases
```python
import unittest
from typing import List, Callable

class TypedTestCase(unittest.TestCase):
    def test_calculator(self) -> None:
        def add(a: int, b: int) -> int:
            return a + b
        
        result: int = add(2, 3)
        self.assertEqual(result, 5)
    
    def test_list_operations(self) -> None:
        numbers: List[int] = [1, 2, 3, 4, 5]
        filtered: List[int] = [n for n in numbers if n % 2 == 0]
        self.assertEqual(filtered, [2, 4])
```

This guide provides comprehensive examples for implementing type safety in Python, making the transition from Java smoother while leveraging Python's flexibility.