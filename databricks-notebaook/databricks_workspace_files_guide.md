# Databricks Workspace Files - Python Module Approach

## Why Use Workspace Files Instead of %run?

### Advantages of Workspace Files (.py)
- ✅ **Standard Python imports** - Use `import` instead of `%run`
- ✅ **Better IDE support** - Autocomplete, type hints, linting
- ✅ **Easier testing** - Standard Python testing frameworks
- ✅ **Version control friendly** - Git integration
- ✅ **No magic commands** - Pure Python, portable code
- ✅ **Package structure** - Create proper Python packages
- ✅ **Cleaner separation** - Code vs notebooks

### When to Use Each Approach

| Use Case | Workspace Files (.py) | Notebooks (%run) |
|----------|----------------------|------------------|
| Utility functions | ✅ **Best choice** | ⚠️ Works but verbose |
| Data classes | ✅ **Best choice** | ⚠️ Works |
| Complex logic | ✅ **Best choice** | ⚠️ Hard to debug |
| Interactive exploration | ❌ Not ideal | ✅ **Best choice** |
| Quick prototyping | ❌ Not ideal | ✅ **Best choice** |
| Production code | ✅ **Best choice** | ❌ Not recommended |

---

## Setup: Creating Workspace Files

### Step 1: Create Python Files in Workspace

**Option A: Using Databricks UI**

1. Go to Workspace in left sidebar
2. Navigate to your folder (e.g., `/Users/your_email/tutorial/`)
3. Click dropdown → **Create** → **File**
4. Name it with `.py` extension (e.g., `string_utils.py`)
5. Add your Python code

**Option B: Using Databricks CLI**

```bash
# Install Databricks CLI
pip install databricks-cli

# Configure
databricks configure --token

# Create a file
databricks workspace mkdirs /Users/your_email/tutorial/utils
databricks workspace import string_utils.py /Users/your_email/tutorial/utils/string_utils.py
```

**Option C: Using Databricks Repos (Recommended)**

```bash
# Connect your Git repo to Databricks
# Then your .py files are automatically synced
```

---

## Example 1: Simple Python Module (Beginner)

### File Structure

```
/Users/your_email/tutorial/
├── utils/
│   ├── __init__.py          # Makes it a package
│   ├── string_utils.py      # String utilities
│   └── validators.py        # Validation functions
└── notebooks/
    └── main_notebook        # Your notebook
```

### Step 1.1: Create Package Structure

**File: `/Users/your_email/tutorial/utils/__init__.py`**

```python
"""
Utility functions package.

This file makes the utils directory a Python package.
"""

# Import key functions to make them available at package level
from .string_utils import clean_string, format_phone, split_and_clean
from .validators import validate_email, validate_phone

# Package metadata
__version__ = "1.0.0"
__all__ = [
    "clean_string",
    "format_phone", 
    "split_and_clean",
    "validate_email",
    "validate_phone"
]

# Optional: Package-level initialization
print(f"Utils package v{__version__} loaded")
```

### Step 1.2: Create String Utilities Module

**File: `/Users/your_email/tutorial/utils/string_utils.py`**

```python
"""
String utility functions for data cleaning.

This module provides functions for common string manipulation tasks
like cleaning, formatting, and parsing.
"""

from typing import List, Optional, Final
from functools import lru_cache
import re

# Module constants
PHONE_PATTERN: Final[str] = r'\D'
PHONE_LENGTH: Final[int] = 10


def clean_string(text: str | None) -> str:
    """
    Clean a string by removing extra spaces and converting to lowercase.
    
    Args:
        text: Input string to clean
        
    Returns:
        Cleaned string (empty string if None)
        
    Examples:
        >>> clean_string("  Hello WORLD  ")
        'hello world'
        >>> clean_string(None)
        ''
    """
    if text is None:
        return ""
    return text.strip().lower()


def split_and_clean(text: str, delimiter: str = ",") -> List[str]:
    """
    Split a string and clean each part.
    
    Args:
        text: Input string to split
        delimiter: Character to split on (default: ',')
        
    Returns:
        List of cleaned strings
        
    Examples:
        >>> split_and_clean("apple, BANANA , Orange")
        ['apple', 'banana', 'orange']
    """
    if not text:
        return []
    return [clean_string(part) for part in text.split(delimiter)]


@lru_cache(maxsize=1024)
def format_phone(phone: str) -> Optional[str]:
    """
    Format phone number to standard US format.
    
    Args:
        phone: Phone number string (any format)
        
    Returns:
        Formatted phone number or None if invalid
        
    Examples:
        >>> format_phone("1234567890")
        '(123) 456-7890'
        >>> format_phone("invalid")
        None
    """
    digits = re.sub(PHONE_PATTERN, '', phone)
    
    if len(digits) == PHONE_LENGTH:
        return f"({digits[:3]}) {digits[3:6]}-{digits[6:]}"
    return None


def batch_clean_strings(texts: List[str]) -> List[str]:
    """
    Batch process strings for better performance.
    
    Args:
        texts: List of strings to clean
        
    Returns:
        List of cleaned strings
    """
    return [clean_string(text) for text in texts]


# Module-level test
if __name__ == "__main__":
    # This only runs when file is executed directly (for testing)
    print("Testing string_utils module...")
    assert clean_string("  TEST  ") == "test"
    assert format_phone("1234567890") == "(123) 456-7890"
    print("✓ All tests passed")
```

### Step 1.3: Create Validators Module

**File: `/Users/your_email/tutorial/utils/validators.py`**

```python
"""
Data validation functions.

This module provides validation functions for common data types
like emails, phone numbers, etc.
"""

import re
from typing import Final

# Validation patterns
EMAIL_PATTERN: Final[str] = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
PHONE_PATTERN: Final[str] = r'^\d{10}$'


def validate_email(email: str) -> bool:
    """
    Validate email address format.
    
    Args:
        email: Email address to validate
        
    Returns:
        True if valid, False otherwise
        
    Examples:
        >>> validate_email("user@example.com")
        True
        >>> validate_email("invalid.email")
        False
    """
    if not email:
        return False
    return bool(re.match(EMAIL_PATTERN, email))


def validate_phone(phone: str) -> bool:
    """
    Validate US phone number (10 digits).
    
    Args:
        phone: Phone number to validate (digits only)
        
    Returns:
        True if valid, False otherwise
        
    Examples:
        >>> validate_phone("1234567890")
        True
        >>> validate_phone("123")
        False
    """
    if not phone:
        return False
    # Remove non-digits
    digits = re.sub(r'\D', '', phone)
    return bool(re.match(PHONE_PATTERN, digits))


# Module-level test
if __name__ == "__main__":
    print("Testing validators module...")
    assert validate_email("test@example.com") == True
    assert validate_email("invalid") == False
    assert validate_phone("1234567890") == True
    assert validate_phone("123") == False
    print("✓ All tests passed")
```

### Step 1.4: Use in Notebook with Python Imports

**Notebook: `/Users/your_email/tutorial/notebooks/main_notebook`**

```python
# Cell 1: Add parent directory to Python path
import sys
import os

# Get the parent directory of the notebook
notebook_path = dbutils.notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get()
parent_dir = os.path.dirname(os.path.dirname(notebook_path))

# Add to Python path if not already there
if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)
    print(f"Added to path: {parent_dir}")

print(f"Python path: {sys.path[:3]}")  # Show first 3 entries
```

```python
# Cell 2: Import using standard Python imports
from utils import clean_string, format_phone, validate_email

print("✓ Functions imported successfully")
print(f"  - clean_string: {type(clean_string)}")
print(f"  - format_phone: {type(format_phone)}")
print(f"  - validate_email: {type(validate_email)}")
```

```python
# Cell 3: Test imported functions
# Test clean_string
test_text = "   DATABRICKS IS AWESOME   "
cleaned = clean_string(test_text)
print(f"Original: '{test_text}'")
print(f"Cleaned: '{cleaned}'")
print()

# Test format_phone
phone = "1234567890"
formatted = format_phone(phone)
print(f"Phone: {phone} → {formatted}")
print()

# Test validate_email
emails = ["valid@email.com", "invalid.email"]
print("Email validation:")
for email in emails:
    is_valid = validate_email(email)
    status = "✓" if is_valid else "✗"
    print(f"  {status} {email}: {is_valid}")
```

```python
# Cell 4: Use with PySpark
from pyspark.sql import DataFrame
from pyspark.sql.functions import udf, col
from pyspark.sql.types import StringType, BooleanType

# Create sample data
data = [
    (1, "  ALICE SMITH  ", "alice@email.com", "1234567890"),
    (2, "bob JONES", "bob.email.com", "555-123-4567"),
    (3, "  CHARLIE Brown  ", "charlie@email.com", "9998887777")
]

df: DataFrame = spark.createDataFrame(
    data, 
    ["id", "name", "email", "phone"]
)

print("Original DataFrame:")
df.show()

# Register UDFs
clean_string_udf = udf(clean_string, StringType())
format_phone_udf = udf(format_phone, StringType())
validate_email_udf = udf(validate_email, BooleanType())

# Apply transformations
result_df = (
    df
    .withColumn("name_cleaned", clean_string_udf(col("name")))
    .withColumn("phone_formatted", format_phone_udf(col("phone")))
    .withColumn("email_valid", validate_email_udf(col("email")))
)

print("\nTransformed DataFrame:")
result_df.show(truncate=False)
```

```python
# Cell 5: Alternative - Import entire module
import utils.string_utils as su
import utils.validators as val

# Use with module prefix
text = "  TEST  "
cleaned = su.clean_string(text)
print(f"Using module prefix: su.clean_string('{text}') = '{cleaned}'")

email = "test@example.com"
is_valid = val.validate_email(email)
print(f"Using module prefix: val.validate_email('{email}') = {is_valid}")
```

---

## Example 2: Data Classes and Complex Structures (Intermediate)

### File Structure

```
/Users/your_email/tutorial/
├── models/
│   ├── __init__.py
│   ├── customer.py          # Customer data model
│   └── validation.py        # Validation result model
├── processors/
│   ├── __init__.py
│   └── data_processor.py    # Data processing logic
└── notebooks/
    └── processing_pipeline
```

### Step 2.1: Create Data Models

**File: `/Users/your_email/tutorial/models/customer.py`**

```python
"""
Customer data models.

This module defines data classes and types for customer data.
"""

from dataclasses import dataclass, field
from typing import Optional
from datetime import datetime


@dataclass
class Customer:
    """
    Customer data model.
    
    Attributes:
        customer_id: Unique customer identifier
        first_name: Customer first name
        last_name: Customer last name
        email: Customer email address
        phone: Customer phone number
        balance: Account balance
        created_at: Account creation timestamp
    """
    customer_id: int
    first_name: str
    last_name: str
    email: str
    phone: Optional[str] = None
    balance: float = 0.0
    created_at: datetime = field(default_factory=datetime.now)
    
    @property
    def full_name(self) -> str:
        """Get full name."""
        return f"{self.first_name} {self.last_name}"
    
    @property
    def is_premium(self) -> bool:
        """Check if customer has premium status (balance > 1000)."""
        return self.balance > 1000
    
    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return {
            "customer_id": self.customer_id,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "phone": self.phone,
            "balance": self.balance,
            "created_at": self.created_at.isoformat(),
            "full_name": self.full_name,
            "is_premium": self.is_premium
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'Customer':
        """Create Customer from dictionary."""
        # Handle datetime conversion
        if isinstance(data.get('created_at'), str):
            data['created_at'] = datetime.fromisoformat(data['created_at'])
        
        return cls(**{k: v for k, v in data.items() 
                      if k in cls.__dataclass_fields__})


# Example usage and tests
if __name__ == "__main__":
    customer = Customer(
        customer_id=1,
        first_name="Alice",
        last_name="Smith",
        email="alice@example.com",
        balance=1500.0
    )
    
    print(f"Customer: {customer.full_name}")
    print(f"Premium: {customer.is_premium}")
    print(f"Dict: {customer.to_dict()}")
```

**File: `/Users/your_email/tutorial/models/validation.py`**

```python
"""
Validation result models.

This module defines data structures for validation results.
"""

from dataclasses import dataclass, field
from typing import List, Dict, Any
from datetime import datetime
from enum import Enum


class ValidationSeverity(Enum):
    """Validation issue severity levels."""
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"


@dataclass(frozen=True)
class ValidationIssue:
    """Single validation issue."""
    severity: ValidationSeverity
    message: str
    column: Optional[str] = None
    count: Optional[int] = None


@dataclass
class ValidationResult:
    """
    Comprehensive validation results.
    
    Attributes:
        is_valid: Whether validation passed
        issues: List of validation issues
        row_count: Total rows validated
        null_counts: Null counts by column
        duplicate_count: Number of duplicates
        timestamp: Validation timestamp
        metadata: Additional metadata
    """
    is_valid: bool
    issues: List[ValidationIssue] = field(default_factory=list)
    row_count: int = 0
    null_counts: Dict[str, int] = field(default_factory=dict)
    duplicate_count: int = 0
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    @property
    def errors(self) -> List[ValidationIssue]:
        """Get only error-level issues."""
        return [i for i in self.issues if i.severity == ValidationSeverity.ERROR]
    
    @property
    def warnings(self) -> List[ValidationIssue]:
        """Get only warning-level issues."""
        return [i for i in self.issues if i.severity == ValidationSeverity.WARNING]
    
    def to_dict(self) -> Dict[str, Any]:
        """Export as dictionary."""
        return {
            "is_valid": self.is_valid,
            "row_count": self.row_count,
            "duplicate_count": self.duplicate_count,
            "error_count": len(self.errors),
            "warning_count": len(self.warnings),
            "null_counts": self.null_counts,
            "timestamp": self.timestamp,
            "metadata": self.metadata
        }
    
    def print_summary(self) -> None:
        """Print formatted summary."""
        status = "✓ PASSED" if self.is_valid else "✗ FAILED"
        print("=" * 70)
        print(f"VALIDATION SUMMARY - {status}")
        print("=" * 70)
        print(f"Rows: {self.row_count:,}")
        print(f"Errors: {len(self.errors)}")
        print(f"Warnings: {len(self.warnings)}")
        print("=" * 70)
```

**File: `/Users/your_email/tutorial/models/__init__.py`**

```python
"""Models package."""

from .customer import Customer
from .validation import ValidationResult, ValidationIssue, ValidationSeverity

__all__ = [
    "Customer",
    "ValidationResult",
    "ValidationIssue", 
    "ValidationSeverity"
]
```

### Step 2.2: Create Data Processor

**File: `/Users/your_email/tutorial/processors/data_processor.py`**

```python
"""
Data processing logic.

This module contains the main data processing functions.
"""

from typing import List, Dict
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, trim, lower, struct, to_json

import sys
import os

# Import models (assuming processors and models are at same level)
from models import Customer, ValidationResult, ValidationIssue, ValidationSeverity


class CustomerDataProcessor:
    """Process customer data with validation."""
    
    def __init__(self, catalog: str, schema: str):
        """
        Initialize processor.
        
        Args:
            catalog: Unity Catalog catalog name
            schema: Schema name
        """
        self.catalog = catalog
        self.schema = schema
    
    def validate_dataframe(
        self,
        df: DataFrame,
        required_columns: List[str]
    ) -> ValidationResult:
        """
        Validate a DataFrame.
        
        Args:
            df: DataFrame to validate
            required_columns: List of required column names
            
        Returns:
            ValidationResult with findings
        """
        issues: List[ValidationIssue] = []
        
        # Check columns
        missing_cols = set(required_columns) - set(df.columns)
        if missing_cols:
            issues.append(ValidationIssue(
                severity=ValidationSeverity.ERROR,
                message=f"Missing columns: {missing_cols}"
            ))
        
        # Check row count
        row_count = df.count()
        if row_count == 0:
            issues.append(ValidationIssue(
                severity=ValidationSeverity.ERROR,
                message="DataFrame is empty"
            ))
        
        # Check nulls
        null_counts = {}
        for col_name in df.columns:
            null_count = df.filter(col(col_name).isNull()).count()
            if null_count > 0:
                null_counts[col_name] = null_count
        
        # Check duplicates
        duplicate_count = row_count - df.distinct().count()
        
        is_valid = all(i.severity != ValidationSeverity.ERROR for i in issues)
        
        return ValidationResult(
            is_valid=is_valid,
            issues=issues,
            row_count=row_count,
            null_counts=null_counts,
            duplicate_count=duplicate_count,
            metadata={"catalog": self.catalog, "schema": self.schema}
        )
    
    def clean_customer_data(self, df: DataFrame) -> DataFrame:
        """
        Clean customer DataFrame.
        
        Args:
            df: Raw customer DataFrame
            
        Returns:
            Cleaned DataFrame
        """
        return (
            df
            .dropDuplicates(["customer_id"])
            .filter(col("first_name").isNotNull())
            .filter(col("last_name").isNotNull())
            .filter(col("email").isNotNull())
            .withColumn("first_name", trim(col("first_name")))
            .withColumn("last_name", trim(col("last_name")))
            .withColumn("email", lower(trim(col("email"))))
        )
    
    def process_to_customers(self, df: DataFrame) -> List[Customer]:
        """
        Convert DataFrame to Customer objects.
        
        Args:
            df: Customer DataFrame
            
        Returns:
            List of Customer objects
        """
        customers = []
        
        for row in df.collect():
            customer = Customer(
                customer_id=row.customer_id,
                first_name=row.first_name,
                last_name=row.last_name,
                email=row.email,
                phone=row.phone if hasattr(row, 'phone') else None,
                balance=row.balance if hasattr(row, 'balance') else 0.0
            )
            customers.append(customer)
        
        return customers


# Example usage
if __name__ == "__main__":
    print("CustomerDataProcessor module loaded")
```

**File: `/Users/your_email/tutorial/processors/__init__.py`**

```python
"""Processors package."""

from .data_processor import CustomerDataProcessor

__all__ = ["CustomerDataProcessor"]
```

### Step 2.3: Use in Notebook

**Notebook: `/Users/your_email/tutorial/notebooks/processing_pipeline`**

```python
# Cell 1: Setup Python path
import sys
import os

notebook_path = dbutils.notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get()
parent_dir = os.path.dirname(os.path.dirname(notebook_path))

if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)

print(f"✓ Python path configured: {parent_dir}")
```

```python
# Cell 2: Import modules
from models import Customer, ValidationResult, ValidationSeverity
from processors import CustomerDataProcessor
from pyspark.sql import DataFrame

print("✓ All modules imported successfully")
print(f"  - Customer: {Customer}")
print(f"  - ValidationResult: {ValidationResult}")
print(f"  - CustomerDataProcessor: {CustomerDataProcessor}")
```

```python
# Cell 3: Create sample data
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType

schema = StructType([
    StructField("customer_id", IntegerType(), False),
    StructField("first_name", StringType(), True),
    StructField("last_name", StringType(), True),
    StructField("email", StringType(), True),
    StructField("phone", StringType(), True),
    StructField("balance", DoubleType(), True)
])

sample_data = [
    (1, "Alice", "Smith", "alice@email.com", "1234567890", 1500.00),
    (2, "Bob", "Jones", "bob@email.com", "555-123-4567", 250.50),
    (3, "Charlie", "Brown", "charlie@email.com", "999-888-7777", 3200.00),
    (1, "Alice", "Smith", "alice@email.com", "1234567890", 1500.00),  # Duplicate
]

df: DataFrame = spark.createDataFrame(sample_data, schema)
print("Sample data created:")
df.show()
```

```python
# Cell 4: Process data using imported classes
# Initialize processor
processor = CustomerDataProcessor(
    catalog="tutorial_catalog",
    schema="notebook_examples"
)

# Validate
print("\n" + "="*70)
print("VALIDATION")
print("="*70)
validation_result = processor.validate_dataframe(
    df,
    required_columns=["customer_id", "first_name", "last_name", "email"]
)
validation_result.print_summary()

# Clean
print("\n" + "="*70)
print("CLEANING")
print("="*70)
cleaned_df = processor.clean_customer_data(df)
print(f"Records before: {df.count()}")
print(f"Records after: {cleaned_df.count()}")
cleaned_df.show()
```

```python
# Cell 5: Convert to Customer objects
customers = processor.process_to_customers(cleaned_df)

print(f"\n✓ Processed {len(customers)} customers")
print("\nCustomer objects:")
for customer in customers:
    print(f"  - {customer.full_name}: {customer.email}")
    print(f"    Balance: ${customer.balance:.2f}, Premium: {customer.is_premium}")
```

```python
# Cell 6: Work with Customer objects
# Filter premium customers
premium_customers = [c for c in customers if c.is_premium]
print(f"\nPremium customers: {len(premium_customers)}")

for customer in premium_customers:
    customer_dict = customer.to_dict()
    print(f"\n{customer.full_name}:")
    print(f"  Balance: ${customer_dict['balance']:.2f}")
    print(f"  Email: {customer_dict['email']}")
```

---

## Example 3: Complete Package Structure (Advanced)

### Full Project Structure

```
/Repos/your_username/customer_analytics/     # Git repo (recommended)
├── src/
│   ├── __init__.py
│   ├── config/
│   │   ├── __init__.py
│   │   └── settings.py                      # Configuration
│   ├── models/
│   │   ├── __init__.py
│   │   ├── customer.py
│   │   └── validation.py
│   ├── processors/
│   │   ├── __init__.py
│   │   ├── validators.py
│   │   └── transformers.py
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── string_utils.py
│   │   └── spark_utils.py
│   └── pipelines/
│       ├── __init__.py
│       └── etl_pipeline.py
├── tests/
│   ├── __init__.py
│   ├── test_models.py
│   └── test_processors.py
├── notebooks/
│   ├── 01_data_ingestion.py
│   ├── 02_data_processing.py
│   └── 03_analysis.py
├── setup.py                                 # Package setup
└── README.md
```

### Step 3.1: Create Configuration Module

**File: `/Repos/your_username/customer_analytics/src/config/settings.py`**

```python
"""
Application configuration.

This module defines configuration settings for the application.
"""

from dataclasses import dataclass
from typing import Final
import os


@dataclass(frozen=True)
class DatabaseConfig:
    """Database configuration."""
    catalog: str
    schema: str
    warehouse: str = "default"
    
    @property
    def full_schema(self) -> str:
        """Get fully qualified schema name."""
        return f"{self.catalog}.{self.schema}"


@dataclass(frozen=True)
class AppConfig:
    """Application configuration."""
    env: str = "development"
    debug: bool = False
    log_level: str = "INFO"
    
    # Database configs for different environments
    database: DatabaseConfig = None
    
    def __post_init__(self):
        """Initialize database config based on environment."""
        if self.database is None:
            if self.env == "production":
                db_config = DatabaseConfig(
                    catalog="prod_catalog",
                    schema="customer_data"
                )
            else:
                db_config = DatabaseConfig(
                    catalog="dev_catalog",
                    schema="customer_data"
                )
            
            # Use object.__setattr__ because dataclass is frozen
            object.__setattr__(self, 'database', db_config)


# Default configurations
DEV_CONFIG = AppConfig(env="development", debug=True)
PROD_CONFIG = AppConfig(env="production", debug=False, log_level="WARNING")

# Get active config from environment
def get_config() -> AppConfig:
    """Get active configuration based on environment."""
    env = os.getenv("APP_ENV", "development")
    
    if env == "production":
        return PROD_CONFIG
    return DEV_CONFIG


# Example usage
if __name__ == "__main__":
    config = get_config()
    print(f"Environment: {config.env}")
    print(f"Schema: {config.database.full_schema}")
```

**File: `/Repos/your_username/customer_analytics/src/config/__init__.py`**

```python
"""Configuration package."""

from .settings import AppConfig, DatabaseConfig, get_config, DEV_CONFIG, PROD_CONFIG

__all__ = [
    "AppConfig",
    "DatabaseConfig", 
    "get_config",
    "DEV_CONFIG",
    "PROD_CONFIG"
]
```

### Step 3.2: Create Complete ETL Pipeline

**File: `/Repos/your_username/customer_analytics/src/pipelines/etl_pipeline.py`**

```python
"""
Complete ETL pipeline implementation.

This module provides a complete ETL pipeline for customer data processing.
"""

from typing import Dict, Any, List
from pyspark.sql import DataFrame, SparkSession
from datetime import datetime
import logging

# Import from our package
from models import Customer, ValidationResult
from processors.validators import DataValidator
from processors.transformers import CustomerTransformer
from config import AppConfig

# Setup logging
logger = logging.getLogger(__name__)


class CustomerETLPipeline:
    """
    Complete ETL pipeline for customer data.
    
    This pipeline handles:
    - Data extraction from source
    - Data validation
    - Data transformation
    - Data loading to target
    """
    
    def __init__(self, spark: SparkSession, config: AppConfig):
        """
        Initialize pipeline.
        
        Args:
            spark: Active Spark session
            config: Application configuration
        """
        self.spark = spark
        self.config = config
        self.validator = DataValidator(config.database.catalog, config.database.schema)
        self.transformer = CustomerTransformer()
        
        logger.info(f"Initialized ETL pipeline for {config.env} environment")
    
    def extract(self, source_table: str) -> DataFrame:
        """
        Extract data from source.
        
        Args:
            source_table: Source table name
            
        Returns:
            Extracted DataFrame
        """
        logger.info(f"Extracting data from {source_table}")
        
        full_table = f"{self.config.database.full_schema}.{source_table}"
        df = self.spark.table(full_table)
        
        logger.info(f"Extracted {df.count()} records")
        return df
    
    def validate(self, df: DataFrame, required_columns: List[str]) -> ValidationResult:
        """
        Validate extracted data.
        
        Args:
            df: DataFrame to validate
            required_columns: Required column names
            
        Returns:
            ValidationResult
        """
        logger.info("Validating data")
        result = self.validator.validate(df, required_columns)
        
        if result.is_valid:
            logger.info("✓ Validation passed")
        else:
            logger.warning(f"✗ Validation failed with {len(result.errors)} errors")
        
        return result
    
    def transform(self, df: DataFrame) -> DataFrame:
        """
        Transform data.
        
        Args:
            df: Input DataFrame
            
        Returns:
            Transformed DataFrame
        """
        logger.info("Transforming data")
        transformed_df = self.transformer.transform(df)
        
        logger.info(f"Transformed {transformed_df.count()} records")
        return transformed_df
    
    def load(self, df: DataFrame, target_table: str) -> None:
        """
        Load data to target.
        
        Args:
            df: DataFrame to load
            target_table: Target table name
        """
        logger.info(f"Loading data to {target_table}")
        
        full_table = f"{self.config.database.full_schema}.{target_table}"
        
        (df.write
         .format("delta")
         .mode("overwrite")
         .option("overwriteSchema", "true")
         .saveAsTable(full_table))
        
        logger.info(f"✓ Data loaded to {full_table}")
    
    def run(
        self,
        source_table: str,
        target_table: str,
        required_columns: List[str]
    ) -> Dict[str, Any]:
        """
        Run complete ETL pipeline.
        
        Args:
            source_table: Source table name
            target_table: Target table name
            required_columns: Required columns for validation
            
        Returns:
            Pipeline execution results
        """
        start_time = datetime.now()
        logger.info("="*70)
        logger.info("STARTING ETL PIPELINE")
        logger.info("="*70)
        
        try:
            # Extract
            raw_df = self.extract(source_table)
            
            # Validate
            validation_result = self.validate(raw_df, required_columns)
            if not validation_result.is_valid:
                raise ValueError(f"Validation failed: {validation_result.errors}")
            
            # Transform
            transformed_df = self.transform(raw_df)
            
            # Load
            self.load(transformed_df, target_table)
            
            # Calculate metrics
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            
            result = {
                "status": "success",
                "source_table": source_table,
                "target_table": target_table,
                "records_processed": transformed_df.count(),
                "duration_seconds": duration,
                "timestamp": end_time.isoformat()
            }
            
            logger.info("="*70)
            logger.info("PIPELINE COMPLETED SUCCESSFULLY")
            logger.info(f"Duration: {duration:.2f} seconds")
            logger.info("="*70)
            
            return result
            
        except Exception as e:
            logger.error(f"Pipeline failed: {e}", exc_info=True)
            return {
                "status": "failed",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }


# Example usage
if __name__ == "__main__":
    print("ETL Pipeline module loaded")
```

### Step 3.3: Create setup.py for Package Installation

**File: `/Repos/your_username/customer_analytics/setup.py`**

```python
"""
Package setup for customer analytics.

This allows the package to be installed with pip.
"""

from setuptools import setup, find_packages

setup(
    name="customer-analytics",
    version="1.0.0",
    description="Customer data analytics package for Databricks",
    author="Your Name",
    author_email="your.email@company.com",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    python_requires=">=3.10",
    install_requires=[
        "pyspark>=3.5.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "black>=23.0.0",
            "mypy>=1.0.0",
        ]
    }
)
```

### Step 3.4: Use Complete Package in Notebook

**Notebook: `/Repos/your_username/customer_analytics/notebooks/01_run_pipeline.py`**

```python
# Cell 1: Install package (if not already installed)
# Run this once to install the package in development mode
# %pip install -e /Workspace/Repos/your_username/customer_analytics

# Or add to path
import sys
sys.path.insert(0, '/Workspace/Repos/your_username/customer_analytics/src')
```

```python
# Cell 2: Import everything from your package
from config import get_config
from pipelines import CustomerETLPipeline
from models import Customer
from processors import CustomerDataProcessor

config = get_config()
print(f"✓ Configuration loaded: {config.env}")
print(f"  Database: {config.database.full_schema}")
```

```python
# Cell 3: Initialize and run pipeline
pipeline = CustomerETLPipeline(spark, config)

result = pipeline.run(
    source_table="raw_customers",
    target_table="processed_customers",
    required_columns=["customer_id", "first_name", "last_name", "email"]
)

print("\nPipeline Results:")
print(f"  Status: {result['status']}")
if result['status'] == 'success':
    print(f"  Records: {result['records_processed']}")
    print(f"  Duration: {result['duration_seconds']:.2f}s")
else:
    print(f"  Error: {result['error']}")
```

```python
# Cell 4: Verify results
processed_df = spark.table(f"{config.database.full_schema}.processed_customers")
print(f"\nProcessed data:")
processed_df.show(10)

print(f"\nTotal records: {processed_df.count()}")
```

---

## Key Advantages of Workspace Files Approach

### 1. **Standard Python Development**
```python
# Just use normal imports!
from utils import clean_string
from models import Customer
from processors import DataProcessor

# No magic commands needed
```

### 2. **Better IDE Support**
- Full autocomplete
- Type checking
- Refactoring tools
- Go to definition

### 3. **Easier Testing**
```python
# In tests/test_models.py
import pytest
from models import Customer

def test_customer_creation():
    customer = Customer(
        customer_id=1,
        first_name="Test",
        last_name="User",
        email="test@example.com"
    )
    assert customer.full_name == "Test User"
```

### 4. **Version Control**
- Git works naturally with .py files
- Easy diffs and merges
- Proper code review workflow

### 5. **Package Distribution**
```bash
# Build and distribute your package
python setup.py sdist bdist_wheel

# Install in any environment
pip install customer-analytics-1.0.0.tar.gz
```

---

## Best Practices Summary

### DO:
✅ Use .py files for reusable code
✅ Create proper package structure with `__init__.py`
✅ Add type hints to all functions
✅ Write docstrings
✅ Use dataclasses for data models
✅ Add the repo/folder to sys.path in notebooks
✅ Use Databricks Repos for Git integration

### DON'T:
❌ Mix code and exploration in .py files
❌ Use `%run` for importing Python code
❌ Put business logic in notebooks
❌ Forget to add `__init__.py` files
❌ Hardcode configuration in .py files

---

## Quick Reference

### Adding to Python Path
```python
import sys
sys.path.insert(0, '/Workspace/Repos/your_username/repo_name/src')
```

### Importing from Package
```python
# Import specific items
from utils import clean_string, format_phone

# Import module
import utils.string_utils as su

# Import from subpackage
from models.customer import Customer
```

### Reloading Modules (during development)
```python
import importlib
import utils.string_utils

# After making changes to the .py file
importlib.reload(utils.string_utils)
```

---

**Summary:** Workspace Files (.py) + standard Python imports = Better code organization, easier testing, and proper software engineering practices!
