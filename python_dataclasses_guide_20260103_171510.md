# Python Dataclasses - Complete Guide

**Created:** 2026-01-03 17:15:10 UTC  
**Last Updated:** 2026-01-03 17:15:10 UTC

---

## Table of Contents
- [Basic Usage](#basic-usage)
- [Fields and Default Values](#fields-and-default-values)
- [Advanced Features](#advanced-features)
- [Methods and Properties](#methods-and-properties)
- [Comparison and Ordering](#comparison-and-ordering)
- [Immutable Dataclasses](#immutable-dataclasses)
- [Field Customization](#field-customization)
- [Conversion Methods](#conversion-methods)
- [Real-World Examples](#real-world-examples)
- [PySpark Integration](#pyspark-integration)

---

## Basic Usage

### Simple Dataclass

```python
from dataclasses import dataclass

@dataclass
class Person:
    name: str
    age: int
    email: str

# Create instance
person = Person("Alice", 30, "alice@email.com")
print(person)
# Output: Person(name='Alice', age=30, email='alice@email.com')

# Access fields
print(person.name)   # Alice
print(person.age)    # 30
print(person.email)  # alice@email.com
```

### Without Dataclass (Traditional Way)

```python
# Compare: Without dataclass (verbose!)
class PersonOld:
    def __init__(self, name, age, email):
        self.name = name
        self.age = age
        self.email = email
    
    def __repr__(self):
        return f"Person(name={self.name}, age={self.age}, email={self.email})"
    
    def __eq__(self, other):
        return (self.name, self.age, self.email) == (other.name, other.age, other.email)

# Dataclass does all this automatically! ✨
```

---

## Fields and Default Values

### Default Values

```python
@dataclass
class Product:
    name: str
    price: float
    quantity: int = 0           # Default value
    available: bool = True       # Default value
    category: str = "General"    # Default value

# Use defaults
p1 = Product("Laptop", 999.99)
print(p1)
# Product(name='Laptop', price=999.99, quantity=0, available=True, category='General')

# Override defaults
p2 = Product("Mouse", 25.99, quantity=50, available=True, category="Electronics")
print(p2)
# Product(name='Mouse', price=25.99, quantity=50, available=True, category='Electronics')
```

### Optional Fields

```python
from typing import Optional

@dataclass
class Employee:
    employee_id: int
    name: str
    department: str
    phone: Optional[str] = None      # Optional field
    email: Optional[str] = None      # Optional field
    manager: Optional[str] = None    # Optional field

# Create with minimal info
emp1 = Employee(1, "Bob", "IT")
print(emp1)
# Employee(employee_id=1, name='Bob', department='IT', phone=None, email=None, manager=None)

# Create with full info
emp2 = Employee(2, "Alice", "Sales", "555-1234", "alice@company.com", "Bob")
print(emp2)
# Employee(employee_id=2, name='Alice', department='Sales', phone='555-1234', email='alice@company.com', manager='Bob')
```

### Multiple Data Types

```python
from typing import List, Dict
from datetime import datetime

@dataclass
class Order:
    order_id: int
    customer_name: str
    items: List[str]              # List of strings
    prices: Dict[str, float]      # Dictionary
    order_date: datetime          # DateTime
    shipped: bool = False
    tracking_number: Optional[str] = None

# Create instance
order = Order(
    order_id=1001,
    customer_name="John Doe",
    items=["Laptop", "Mouse", "Keyboard"],
    prices={"Laptop": 999.99, "Mouse": 25.99, "Keyboard": 75.00},
    order_date=datetime.now()
)

print(order)
print(f"Total items: {len(order.items)}")
print(f"Total price: ${sum(order.prices.values()):.2f}")
```

---

## Advanced Features

### field() Function

```python
from dataclasses import dataclass, field

@dataclass
class ShoppingCart:
    customer_id: int
    items: List[str] = field(default_factory=list)      # Empty list for each instance
    quantities: Dict[str, int] = field(default_factory=dict)
    created_at: datetime = field(default_factory=datetime.now)
    
    # Exclude from repr
    internal_id: str = field(default="", repr=False)
    
    # Exclude from comparison
    last_modified: datetime = field(default_factory=datetime.now, compare=False)

cart1 = ShoppingCart(customer_id=1)
cart2 = ShoppingCart(customer_id=2)

cart1.items.append("apple")
print(cart1.items)  # ['apple']
print(cart2.items)  # [] - Each instance has separate list!
```

### Post-Init Processing

```python
@dataclass
class Rectangle:
    width: float
    height: float
    area: float = field(init=False)      # Not in __init__, calculated after
    perimeter: float = field(init=False)
    
    def __post_init__(self):
        """Called after __init__"""
        self.area = self.width * self.height
        self.perimeter = 2 * (self.width + self.height)

rect = Rectangle(10, 5)
print(f"Area: {rect.area}")           # Area: 50.0
print(f"Perimeter: {rect.perimeter}") # Perimeter: 30.0
```

### Validation in Post-Init

```python
@dataclass
class BankAccount:
    account_number: str
    balance: float
    account_type: str
    
    def __post_init__(self):
        # Validate balance
        if self.balance < 0:
            raise ValueError("Balance cannot be negative")
        
        # Validate account type
        valid_types = ["checking", "savings"]
        if self.account_type not in valid_types:
            raise ValueError(f"Account type must be one of {valid_types}")
        
        # Format account number
        self.account_number = self.account_number.upper()

# Valid account
acc1 = BankAccount("acc123", 1000.0, "checking")
print(acc1)

# Invalid - will raise error
# acc2 = BankAccount("acc456", -100.0, "checking")  # ValueError!
```

---

## Methods and Properties

### Instance Methods

```python
@dataclass
class Customer:
    customer_id: int
    first_name: str
    last_name: str
    email: str
    balance: float = 0.0
    
    def full_name(self) -> str:
        """Get full name"""
        return f"{self.first_name} {self.last_name}"
    
    def deposit(self, amount: float) -> None:
        """Add money to balance"""
        if amount > 0:
            self.balance += amount
    
    def withdraw(self, amount: float) -> bool:
        """Withdraw money if sufficient balance"""
        if amount > 0 and self.balance >= amount:
            self.balance -= amount
            return True
        return False
    
    def is_premium(self) -> bool:
        """Check if customer is premium (balance > 1000)"""
        return self.balance > 1000

# Use it
customer = Customer(1, "John", "Doe", "john@email.com", 1500.0)
print(customer.full_name())      # John Doe
print(customer.is_premium())     # True

customer.withdraw(600)
print(customer.balance)          # 900.0
print(customer.is_premium())     # False
```

### Properties

```python
@dataclass
class Temperature:
    celsius: float
    
    @property
    def fahrenheit(self) -> float:
        """Convert to Fahrenheit"""
        return (self.celsius * 9/5) + 32
    
    @property
    def kelvin(self) -> float:
        """Convert to Kelvin"""
        return self.celsius + 273.15
    
    @fahrenheit.setter
    def fahrenheit(self, value: float) -> None:
        """Set temperature from Fahrenheit"""
        self.celsius = (value - 32) * 5/9

temp = Temperature(25.0)
print(f"{temp.celsius}°C")        # 25.0°C
print(f"{temp.fahrenheit}°F")     # 77.0°F
print(f"{temp.kelvin}K")          # 298.15K

# Use setter
temp.fahrenheit = 68.0
print(f"{temp.celsius}°C")        # 20.0°C
```

---

## Comparison and Ordering

### Automatic Equality

```python
@dataclass
class Point:
    x: int
    y: int

p1 = Point(1, 2)
p2 = Point(1, 2)
p3 = Point(3, 4)

print(p1 == p2)  # True - same values
print(p1 == p3)  # False - different values
print(p1 is p2)  # False - different objects
```

### Ordering

```python
@dataclass(order=True)
class Student:
    name: str = field(compare=False)  # Don't use in comparison
    grade: float                       # Used for comparison
    student_id: int = field(compare=False)

students = [
    Student("Alice", 85.5, 1001),
    Student("Bob", 92.0, 1002),
    Student("Charlie", 78.5, 1003)
]

# Sort by grade (automatically!)
sorted_students = sorted(students)
for s in sorted_students:
    print(f"{s.name}: {s.grade}")
# Output:
# Charlie: 78.5
# Alice: 85.5
# Bob: 92.0
```

### Custom Sorting Key

```python
from dataclasses import dataclass, field

@dataclass(order=True)
class Product:
    sort_index: float = field(init=False, repr=False)
    name: str
    price: float
    
    def __post_init__(self):
        self.sort_index = self.price  # Sort by price

products = [
    Product("Laptop", 999.99),
    Product("Mouse", 25.99),
    Product("Keyboard", 75.00)
]

sorted_products = sorted(products)
for p in sorted_products:
    print(f"{p.name}: ${p.price}")
# Output (sorted by price):
# Mouse: $25.99
# Keyboard: $75.0
# Laptop: $999.99
```

---

## Immutable Dataclasses

### Frozen Dataclass

```python
@dataclass(frozen=True)
class Config:
    api_key: str
    endpoint: str
    timeout: int = 30
    retry_count: int = 3

config = Config("ABC123", "https://api.example.com")
print(config.api_key)  # ABC123

# Cannot modify!
# config.api_key = "XYZ789"  # FrozenInstanceError!

# Can be used as dictionary key (hashable)
configs = {
    config: "Production"
}
```

### Immutable with Mutable Defaults

```python
from typing import Tuple

@dataclass(frozen=True)
class ImmutableRecord:
    record_id: int
    values: Tuple[float, ...]  # Use tuple instead of list
    metadata: Tuple[str, ...]
    
record = ImmutableRecord(1, (1.0, 2.0, 3.0), ("key1", "key2"))
print(record.values)  # (1.0, 2.0, 3.0)
# record.values = (4.0, 5.0)  # Error! Frozen
```

---

## Field Customization

### Field Parameters

```python
from dataclasses import dataclass, field

@dataclass
class Article:
    # Required fields (no default)
    title: str
    content: str
    
    # Optional with defaults
    author: str = "Anonymous"
    
    # Exclude from __repr__
    internal_id: str = field(default="", repr=False)
    
    # Exclude from comparison
    view_count: int = field(default=0, compare=False)
    
    # Not in __init__, calculated after
    word_count: int = field(init=False, repr=False)
    
    # Factory for mutable defaults
    tags: List[str] = field(default_factory=list)
    
    def __post_init__(self):
        self.word_count = len(self.content.split())

article = Article("Python Tips", "Learn Python dataclasses...")
print(article)  # internal_id and word_count not shown
print(f"Words: {article.word_count}")
```

### Metadata

```python
@dataclass
class Person:
    name: str = field(metadata={"description": "Full name", "max_length": 100})
    age: int = field(metadata={"description": "Age in years", "min": 0, "max": 150})
    email: str = field(metadata={"description": "Email address", "format": "email"})

# Access metadata
import dataclasses
fields = dataclasses.fields(Person)
for f in fields:
    print(f"{f.name}: {f.metadata}")
# Output:
# name: {'description': 'Full name', 'max_length': 100}
# age: {'description': 'Age in years', 'min': 0, 'max': 150}
# email: {'description': 'Email address', 'format': 'email'}
```

---

## Conversion Methods

### To Dictionary

```python
from dataclasses import dataclass, asdict, astuple

@dataclass
class User:
    user_id: int
    username: str
    email: str
    is_active: bool = True

user = User(1, "alice", "alice@example.com")

# Convert to dict
user_dict = asdict(user)
print(user_dict)
# {'user_id': 1, 'username': 'alice', 'email': 'alice@example.com', 'is_active': True}

# Convert to tuple
user_tuple = astuple(user)
print(user_tuple)
# (1, 'alice', 'alice@example.com', True)
```

### Custom to_dict Method

```python
@dataclass
class Customer:
    customer_id: int
    name: str
    email: str
    balance: float
    created_at: datetime = field(default_factory=datetime.now)
    
    def to_dict(self) -> dict:
        """Custom dict conversion with formatting"""
        return {
            "id": self.customer_id,
            "name": self.name,
            "email": self.email,
            "balance": f"${self.balance:.2f}",
            "created_at": self.created_at.isoformat()
        }
    
    @classmethod
    def from_dict(cls, data: dict):
        """Create instance from dict"""
        return cls(
            customer_id=data["id"],
            name=data["name"],
            email=data["email"],
            balance=float(data["balance"].replace("$", "")),
            created_at=datetime.fromisoformat(data["created_at"])
        )

customer = Customer(1, "Alice", "alice@example.com", 1500.50)
data = customer.to_dict()
print(data)

# Recreate from dict
customer2 = Customer.from_dict(data)
print(customer2)
```

---

## Real-World Examples

### E-commerce Order System

```python
from dataclasses import dataclass, field
from typing import List, Optional
from datetime import datetime
from enum import Enum

class OrderStatus(Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

@dataclass
class OrderItem:
    product_id: int
    product_name: str
    quantity: int
    unit_price: float
    
    @property
    def total_price(self) -> float:
        return self.quantity * self.unit_price

@dataclass
class Order:
    order_id: int
    customer_id: int
    customer_name: str
    items: List[OrderItem] = field(default_factory=list)
    status: OrderStatus = OrderStatus.PENDING
    order_date: datetime = field(default_factory=datetime.now)
    shipping_address: Optional[str] = None
    tracking_number: Optional[str] = None
    
    @property
    def total_items(self) -> int:
        return sum(item.quantity for item in self.items)
    
    @property
    def total_amount(self) -> float:
        return sum(item.total_price for item in self.items)
    
    def add_item(self, product_id: int, product_name: str, quantity: int, unit_price: float):
        item = OrderItem(product_id, product_name, quantity, unit_price)
        self.items.append(item)
    
    def update_status(self, new_status: OrderStatus):
        self.status = new_status
    
    def print_summary(self):
        print(f"Order #{self.order_id} - {self.customer_name}")
        print(f"Status: {self.status.value}")
        print(f"Items: {self.total_items}")
        print(f"Total: ${self.total_amount:.2f}")

# Use it
order = Order(1001, 501, "John Doe")
order.add_item(1, "Laptop", 1, 999.99)
order.add_item(2, "Mouse", 2, 25.99)
order.add_item(3, "Keyboard", 1, 75.00)

order.print_summary()
# Output:
# Order #1001 - John Doe
# Status: pending
# Items: 4
# Total: $1126.97
```

### Banking System

```python
@dataclass
class Transaction:
    transaction_id: int
    account_number: str
    transaction_type: str  # 'deposit' or 'withdrawal'
    amount: float
    timestamp: datetime = field(default_factory=datetime.now)
    description: Optional[str] = None

@dataclass
class BankAccount:
    account_number: str
    account_holder: str
    balance: float
    account_type: str  # 'checking' or 'savings'
    transactions: List[Transaction] = field(default_factory=list)
    created_date: datetime = field(default_factory=datetime.now)
    interest_rate: float = 0.01  # 1% default
    
    def deposit(self, amount: float, description: str = None) -> bool:
        if amount <= 0:
            return False
        
        self.balance += amount
        transaction = Transaction(
            len(self.transactions) + 1,
            self.account_number,
            'deposit',
            amount,
            description=description
        )
        self.transactions.append(transaction)
        return True
    
    def withdraw(self, amount: float, description: str = None) -> bool:
        if amount <= 0 or amount > self.balance:
            return False
        
        self.balance -= amount
        transaction = Transaction(
            len(self.transactions) + 1,
            self.account_number,
            'withdrawal',
            amount,
            description=description
        )
        self.transactions.append(transaction)
        return True
    
    def apply_interest(self):
        interest = self.balance * self.interest_rate
        self.deposit(interest, "Monthly interest")
    
    def get_statement(self) -> str:
        lines = [
            f"Account Statement - {self.account_number}",
            f"Holder: {self.account_holder}",
            f"Type: {self.account_type}",
            f"Current Balance: ${self.balance:.2f}",
            "\nRecent Transactions:"
        ]
        
        for txn in self.transactions[-5:]:  # Last 5 transactions
            lines.append(
                f"  {txn.timestamp.strftime('%Y-%m-%d %H:%M')} | "
                f"{txn.transaction_type:12} | ${txn.amount:8.2f}"
            )
        
        return "\n".join(lines)

# Use it
account = BankAccount("ACC-001", "Alice Smith", 1000.0, "savings", interest_rate=0.02)
account.deposit(500.0, "Paycheck")
account.withdraw(200.0, "Rent")
account.apply_interest()

print(account.get_statement())
```

### Student Gradebook

```python
@dataclass
class Assignment:
    name: str
    points_earned: float
    points_possible: float
    
    @property
    def percentage(self) -> float:
        return (self.points_earned / self.points_possible) * 100

@dataclass
class Student:
    student_id: int
    first_name: str
    last_name: str
    email: str
    assignments: List[Assignment] = field(default_factory=list)
    
    @property
    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}"
    
    def add_assignment(self, name: str, points_earned: float, points_possible: float):
        assignment = Assignment(name, points_earned, points_possible)
        self.assignments.append(assignment)
    
    @property
    def total_points_earned(self) -> float:
        return sum(a.points_earned for a in self.assignments)
    
    @property
    def total_points_possible(self) -> float:
        return sum(a.points_possible for a in self.assignments)
    
    @property
    def grade_percentage(self) -> float:
        if self.total_points_possible == 0:
            return 0.0
        return (self.total_points_earned / self.total_points_possible) * 100
    
    @property
    def letter_grade(self) -> str:
        percentage = self.grade_percentage
        if percentage >= 90:
            return "A"
        elif percentage >= 80:
            return "B"
        elif percentage >= 70:
            return "C"
        elif percentage >= 60:
            return "D"
        else:
            return "F"
    
    def print_report(self):
        print(f"Student: {self.full_name} (ID: {self.student_id})")
        print(f"Email: {self.email}")
        print(f"\nAssignments:")
        for a in self.assignments:
            print(f"  {a.name:20} {a.points_earned:5.1f}/{a.points_possible:5.1f} ({a.percentage:5.1f}%)")
        print(f"\nOverall Grade: {self.grade_percentage:.1f}% ({self.letter_grade})")

# Use it
student = Student(1001, "John", "Doe", "john.doe@university.edu")
student.add_assignment("Homework 1", 85, 100)
student.add_assignment("Quiz 1", 18, 20)
student.add_assignment("Midterm", 88, 100)
student.add_assignment("Project", 95, 100)

student.print_report()
```

---

## PySpark Integration

### Dataclass with PySpark

```python
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType

@dataclass
class Product:
    product_id: int
    name: str
    category: str
    price: float
    stock: int = 0
    
    def to_row(self):
        """Convert to Spark Row format"""
        return (self.product_id, self.name, self.category, self.price, self.stock)
    
    @classmethod
    def get_schema(cls):
        """Get Spark schema"""
        return StructType([
            StructField("product_id", IntegerType(), False),
            StructField("name", StringType(), False),
            StructField("category", StringType(), False),
            StructField("price", DoubleType(), False),
            StructField("stock", IntegerType(), False)
        ])

# Create products
products = [
    Product(1, "Laptop", "Electronics", 999.99, 10),
    Product(2, "Mouse", "Electronics", 25.99, 50),
    Product(3, "Desk", "Furniture", 299.99, 5)
]

# Convert to Spark DataFrame
spark = SparkSession.builder.getOrCreate()
product_rows = [p.to_row() for p in products]
df = spark.createDataFrame(product_rows, schema=Product.get_schema())

df.show()
# Output:
# +----------+------+-----------+------+-----+
# |product_id|  name|   category| price|stock|
# +----------+------+-----------+------+-----+
# |         1|Laptop|Electronics|999.99|   10|
# |         2| Mouse|Electronics| 25.99|   50|
# |         3|  Desk|  Furniture|299.99|    5|
# +----------+------+-----------+------+-----+
```

### Processing Spark Rows with Dataclass

```python
@dataclass
class SalesRecord:
    sale_id: int
    product_name: str
    quantity: int
    unit_price: float
    
    @property
    def total_amount(self) -> float:
        return self.quantity * self.unit_price
    
    @classmethod
    def from_row(cls, row):
        """Create instance from Spark Row"""
        return cls(
            sale_id=row.sale_id,
            product_name=row.product_name,
            quantity=row.quantity,
            unit_price=row.unit_price
        )

# Collect and process
# sales_df is your Spark DataFrame
# for row in sales_df.collect():
#     sale = SalesRecord.from_row(row)
#     print(f"Sale #{sale.sale_id}: {sale.product_name} - ${sale.total_amount:.2f}")
```

---

## Best Practices

### DO ✅

```python
# Use type hints
@dataclass
class Good:
    name: str
    age: int
    balance: float

# Use default_factory for mutable defaults
@dataclass
class Good2:
    items: List[str] = field(default_factory=list)

# Use frozen for immutable data
@dataclass(frozen=True)
class Config:
    api_key: str
    timeout: int

# Add methods when needed
@dataclass
class Account:
    balance: float
    
    def deposit(self, amount: float):
        self.balance += amount
```

### DON'T ❌

```python
# Don't use mutable defaults directly
@dataclass
class Bad:
    items: List[str] = []  # WRONG! Shared between instances

# Don't over-complicate
@dataclass
class TooBusy:
    # Too many fields, consider splitting
    field1: str
    field2: str
    # ... 20 more fields
    field22: str

# Don't ignore type hints
@dataclass
class NoTypes:
    name  # Missing type hint!
    age   # Missing type hint!
```

---

## Quick Reference

### Common Parameters

```python
@dataclass(
    init=True,        # Generate __init__? (default: True)
    repr=True,        # Generate __repr__? (default: True)
    eq=True,          # Generate __eq__? (default: True)
    order=False,      # Generate ordering methods? (default: False)
    frozen=False,     # Make immutable? (default: False)
)
class MyClass:
    pass
```

### Field Options

```python
field(
    default=None,           # Default value
    default_factory=None,   # Callable to generate default
    init=True,             # Include in __init__?
    repr=True,             # Include in __repr__?
    compare=True,          # Include in comparisons?
    hash=None,             # Include in __hash__?
    metadata=None          # Extra metadata dict
)
```

---

## Summary

**Dataclasses replace:**
- Manual `__init__` methods
- Manual `__repr__` methods
- Manual `__eq__` methods
- Lots of boilerplate code

**Use dataclasses for:**
- Simple data containers
- Configuration objects
- API request/response models
- Database records
- Any class that's mostly data with few methods

**Don't use dataclasses for:**
- Classes with complex inheritance
- Classes with lots of behavior (use regular classes)
- When you need full control over `__init__`

---

**Created:** 2026-01-03 17:15:10 UTC  
**Document Version:** 1.0  
**Python Version:** 3.7+
