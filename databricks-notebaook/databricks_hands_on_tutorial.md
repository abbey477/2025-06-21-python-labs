# Databricks Multiple Notebooks - Hands-On Tutorial

## Prerequisites
- Access to Databricks workspace
- Basic Python and PySpark knowledge
- Ability to create notebooks in your workspace

---

## Tutorial Overview

We'll build 3 complete examples:
1. **Simple Example**: Basic utility functions shared across notebooks
2. **Intermediate Example**: Data processing pipeline with validation
3. **Advanced Example**: Complete ETL workflow with error handling and monitoring

---

## Setup Instructions

### Step 1: Create Folder Structure

In your Databricks workspace, create the following folder structure:

```
/Users/your_email@company.com/
└── tutorial/
    ├── utils/
    ├── validators/
    ├── pipelines/
    └── main/
```

**How to create folders:**
1. In Databricks workspace, click "Workspace" in the left sidebar
2. Navigate to your user folder
3. Click the dropdown arrow next to your folder name
4. Select "Create" → "Folder"
5. Name it "tutorial"
6. Repeat to create subfolders inside "tutorial"

---

## Example 1: Simple Utility Functions (Beginner)

### Goal
Create reusable utility functions and use them in a main notebook.

### Step 1.1: Create Utility Notebook

**Notebook Path:** `/Users/your_email/tutorial/utils/string_utils`

**Create the notebook:**
1. Navigate to `/Users/your_email/tutorial/utils/`
2. Click dropdown → Create → Notebook
3. Name: `string_utils`
4. Language: Python

**Add this code:**

```python
# Cell 1: String utility functions with type hints
from typing import List, Optional

def clean_string(text: str) -> str:
    """
    Clean a string by removing extra spaces and converting to lowercase.
    
    Args:
        text: Input string to clean
        
    Returns:
        Cleaned string
        
    Example:
        >>> clean_string("  Hello WORLD  ")
        "hello world"
    """
    if text is None:
        return ""
    return text.strip().lower()


def split_and_clean(text: str, delimiter: str = ",") -> List[str]:
    """
    Split a string and clean each part.
    
    Args:
        text: Input string to split
        delimiter: Character to split on
        
    Returns:
        List of cleaned strings
    """
    if not text:
        return []
    return [clean_string(part) for part in text.split(delimiter)]


def format_phone(phone: str) -> Optional[str]:
    """
    Format phone number to standard format.
    
    Args:
        phone: Phone number string
        
    Returns:
        Formatted phone number or None if invalid
    """
    # Remove all non-numeric characters
    digits = ''.join(filter(str.isdigit, phone))
    
    if len(digits) == 10:
        return f"({digits[:3]}) {digits[3:6]}-{digits[6:]}"
    return None


# Test the functions
print("Testing string_utils functions:")
print(f"clean_string: {clean_string('  HELLO World  ')}")
print(f"split_and_clean: {split_and_clean('apple, BANANA , Orange')}")
print(f"format_phone: {format_phone('1234567890')}")
```

### Step 1.2: Create Main Notebook

**Notebook Path:** `/Users/your_email/tutorial/main/simple_example`

```python
# Cell 1: Import utility functions using %run
%run ../utils/string_utils
```

```python
# Cell 2: Test imported functions
from typing import List

# Test 1: Clean strings
test_text: str = "   DATABRICKS IS AWESOME   "
cleaned: str = clean_string(test_text)
print(f"Original: '{test_text}'")
print(f"Cleaned: '{cleaned}'")
print()

# Test 2: Split and clean
csv_data: str = "Alice, BOB , charlie,  DAVID  "
names: List[str] = split_and_clean(csv_data)
print(f"CSV Input: '{csv_data}'")
print(f"Parsed names: {names}")
print()

# Test 3: Format phones
phone_numbers: List[str] = ["1234567890", "555-123-4567", "(555) 999-8888"]
print("Phone number formatting:")
for phone in phone_numbers:
    formatted: str = format_phone(phone)
    print(f"  {phone} → {formatted}")
```

```python
# Cell 3: Use with PySpark DataFrame
from pyspark.sql import DataFrame
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType

# Create sample data
data = [
    (1, "  ALICE SMITH  ", "1234567890"),
    (2, "bob JONES", "555-123-4567"),
    (3, "  CHARLIE Brown  ", "9998887777")
]

df: DataFrame = spark.createDataFrame(data, ["id", "name", "phone"])
print("Original DataFrame:")
df.show()

# Register UDFs
clean_string_udf = udf(clean_string, StringType())
format_phone_udf = udf(format_phone, StringType())

# Apply transformations
cleaned_df: DataFrame = df \
    .withColumn("name_cleaned", clean_string_udf(df.name)) \
    .withColumn("phone_formatted", format_phone_udf(df.phone))

print("\nCleaned DataFrame:")
cleaned_df.show(truncate=False)
```

**Expected Output:**
```
Original: '   DATABRICKS IS AWESOME   '
Cleaned: 'databricks is awesome'

CSV Input: 'Alice, BOB , charlie,  DAVID  '
Parsed names: ['alice', 'bob', 'charlie', 'david']

Phone number formatting:
  1234567890 → (123) 456-7890
  555-123-4567 → (555) 123-4567
  (555) 999-8888 → (555) 999-8888

Original DataFrame:
+---+------------------+------------+
| id|              name|       phone|
+---+------------------+------------+
|  1|    ALICE SMITH  |  1234567890|
|  2|         bob JONES|555-123-4567|
|  3|  CHARLIE Brown  |  9998887777|
+---+------------------+------------+

Cleaned DataFrame:
+---+------------------+------------+-------------+----------------+
| id|              name|       phone| name_cleaned|  phone_formatted|
+---+------------------+------------+-------------+----------------+
|  1|    ALICE SMITH  |  1234567890|  alice smith|  (123) 456-7890|
|  2|         bob JONES|555-123-4567|    bob jones|  (555) 123-4567|
|  3|  CHARLIE Brown  |  9998887777|charlie brown|  (999) 888-7777|
+---+------------------+------------+-------------+----------------+
```

---

## Example 2: Data Validation Pipeline (Intermediate)

### Goal
Create a data validator class and use it in a processing pipeline.

### Step 2.1: Create Validator Notebook

**Notebook Path:** `/Users/your_email/tutorial/validators/data_validator`

```python
# Cell 1: Import dependencies
from typing import List, Dict, Set, Optional, Any
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, count, when
from dataclasses import dataclass
from datetime import datetime
```

```python
# Cell 2: Define ValidationResult dataclass
@dataclass
class ValidationResult:
    """Store validation results with detailed metrics."""
    is_valid: bool
    errors: List[str]
    warnings: List[str]
    row_count: int
    null_counts: Dict[str, int]
    duplicate_count: int
    timestamp: str
    
    def print_summary(self) -> None:
        """Print a formatted summary of validation results."""
        print("=" * 60)
        print("VALIDATION SUMMARY")
        print("=" * 60)
        print(f"Status: {'✓ PASSED' if self.is_valid else '✗ FAILED'}")
        print(f"Timestamp: {self.timestamp}")
        print(f"Total Rows: {self.row_count:,}")
        print(f"Duplicate Rows: {self.duplicate_count:,}")
        print()
        
        if self.errors:
            print(f"Errors ({len(self.errors)}):")
            for error in self.errors:
                print(f"  ✗ {error}")
            print()
        
        if self.warnings:
            print(f"Warnings ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"  ⚠ {warning}")
            print()
        
        if self.null_counts:
            print("Null Value Counts:")
            for col_name, null_count in self.null_counts.items():
                if null_count > 0:
                    percentage = (null_count / self.row_count) * 100
                    print(f"  {col_name}: {null_count:,} ({percentage:.2f}%)")
        
        print("=" * 60)
```

```python
# Cell 3: Define DataValidator class
class DataValidator:
    """
    Comprehensive data validation for DataFrames.
    
    Validates:
    - Required columns exist
    - Row count is non-zero
    - Null values in non-nullable columns
    - Duplicate records
    """
    
    def __init__(
        self,
        df: DataFrame,
        required_columns: List[str],
        nullable_columns: Optional[List[str]] = None,
        unique_columns: Optional[List[str]] = None
    ) -> None:
        """
        Initialize validator.
        
        Args:
            df: DataFrame to validate
            required_columns: Columns that must exist
            nullable_columns: Columns allowed to have nulls
            unique_columns: Columns that should have unique values
        """
        self.df: DataFrame = df
        self.required_columns: List[str] = required_columns
        self.nullable_columns: List[str] = nullable_columns or []
        self.unique_columns: List[str] = unique_columns or []
        
    def validate(self) -> ValidationResult:
        """
        Run all validation checks.
        
        Returns:
            ValidationResult with detailed findings
        """
        errors: List[str] = []
        warnings: List[str] = []
        
        # Check 1: Required columns exist
        df_columns: Set[str] = set(self.df.columns)
        required_set: Set[str] = set(self.required_columns)
        missing_cols: Set[str] = required_set - df_columns
        
        if missing_cols:
            errors.append(f"Missing required columns: {missing_cols}")
        
        # Check 2: Row count
        row_count: int = self.df.count()
        if row_count == 0:
            errors.append("DataFrame is empty (0 rows)")
        
        # Check 3: Null values
        null_counts: Dict[str, int] = {}
        for col_name in self.df.columns:
            null_count: int = self.df.filter(col(col_name).isNull()).count()
            null_counts[col_name] = null_count
            
            if null_count > 0 and col_name not in self.nullable_columns:
                percentage = (null_count / row_count * 100) if row_count > 0 else 0
                warnings.append(
                    f"Column '{col_name}' has {null_count} null values ({percentage:.1f}%)"
                )
        
        # Check 4: Duplicate rows
        duplicate_count: int = row_count - self.df.distinct().count()
        if duplicate_count > 0:
            warnings.append(f"Found {duplicate_count} duplicate rows")
        
        # Check 5: Unique column constraints
        for col_name in self.unique_columns:
            if col_name in df_columns:
                distinct_count: int = self.df.select(col_name).distinct().count()
                if distinct_count != row_count:
                    errors.append(
                        f"Column '{col_name}' should be unique but has {row_count - distinct_count} duplicates"
                    )
        
        return ValidationResult(
            is_valid=len(errors) == 0,
            errors=errors,
            warnings=warnings,
            row_count=row_count,
            null_counts=null_counts,
            duplicate_count=duplicate_count,
            timestamp=datetime.now().isoformat()
        )
    
    def validate_schema(self, expected_types: Dict[str, str]) -> List[str]:
        """
        Validate column data types.
        
        Args:
            expected_types: Dictionary of column_name: expected_type
            
        Returns:
            List of type mismatch errors
        """
        errors: List[str] = []
        
        for col_name, expected_type in expected_types.items():
            if col_name not in self.df.columns:
                errors.append(f"Column '{col_name}' not found")
                continue
            
            actual_type = str(self.df.schema[col_name].dataType)
            if expected_type.lower() not in actual_type.lower():
                errors.append(
                    f"Column '{col_name}': expected {expected_type}, got {actual_type}"
                )
        
        return errors


# Test the validator
print("✓ DataValidator class loaded successfully")
print("  Available methods:")
print("    - validate()")
print("    - validate_schema()")
```

### Step 2.2: Create Processing Pipeline Notebook

**Notebook Path:** `/Users/your_email/tutorial/pipelines/customer_processing`

```python
# Cell 1: Import dependencies and validator
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, trim, upper, lower, regexp_replace
from typing import List, Dict

%run ../validators/data_validator
```

```python
# Cell 2: Create sample customer data
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType

# Define schema
schema = StructType([
    StructField("customer_id", IntegerType(), False),
    StructField("first_name", StringType(), True),
    StructField("last_name", StringType(), True),
    StructField("email", StringType(), True),
    StructField("phone", StringType(), True),
    StructField("balance", DoubleType(), True)
])

# Create sample data with some data quality issues
sample_data = [
    (1, "Alice", "Smith", "alice@email.com", "1234567890", 1500.00),
    (2, "Bob", None, "bob@email.com", "555-123-4567", 250.50),  # Missing last name
    (3, "Charlie", "Brown", None, "999-888-7777", 3200.00),     # Missing email
    (4, "  DAVID  ", "  jones  ", "david@email.com", "1112223333", None),  # Needs cleaning, null balance
    (5, "Eve", "Wilson", "eve@email.com", "4445556666", 890.00),
    (1, "Alice", "Smith", "alice@email.com", "1234567890", 1500.00),  # Duplicate
    (6, None, "Taylor", "taylor@email.com", "7778889999", 450.00),    # Missing first name
]

raw_df: DataFrame = spark.createDataFrame(sample_data, schema)

print("Sample Customer Data (with data quality issues):")
raw_df.show()
print(f"Total records: {raw_df.count()}")
```

```python
# Cell 3: Validate raw data
print("\n" + "🔍 VALIDATING RAW DATA".center(60, "="))

# Define validation rules
required_cols: List[str] = ["customer_id", "first_name", "last_name", "email", "phone", "balance"]
nullable_cols: List[str] = ["balance"]  # Balance can be null (new customers)
unique_cols: List[str] = ["customer_id"]

# Create validator and run validation
validator = DataValidator(
    df=raw_df,
    required_columns=required_cols,
    nullable_columns=nullable_cols,
    unique_columns=unique_cols
)

validation_result: ValidationResult = validator.validate()
validation_result.print_summary()

# Check schema types
expected_types: Dict[str, str] = {
    "customer_id": "IntegerType",
    "first_name": "StringType",
    "last_name": "StringType",
    "email": "StringType",
    "phone": "StringType",
    "balance": "DoubleType"
}

schema_errors: List[str] = validator.validate_schema(expected_types)
if schema_errors:
    print("Schema Validation Errors:")
    for error in schema_errors:
        print(f"  ✗ {error}")
else:
    print("✓ Schema validation passed")
```

```python
# Cell 4: Clean and transform data
def clean_customer_data(df: DataFrame) -> DataFrame:
    """
    Clean and standardize customer data.
    
    Args:
        df: Raw customer DataFrame
        
    Returns:
        Cleaned DataFrame
    """
    print("\n🧹 Cleaning data...")
    
    cleaned_df = df \
        .dropDuplicates(["customer_id"]) \
        .withColumn("first_name", trim(col("first_name"))) \
        .withColumn("last_name", trim(col("last_name"))) \
        .withColumn("email", lower(trim(col("email")))) \
        .withColumn("phone", regexp_replace(col("phone"), "[^0-9]", "")) \
        .filter(col("first_name").isNotNull()) \
        .filter(col("last_name").isNotNull()) \
        .filter(col("email").isNotNull())
    
    print(f"  Records before cleaning: {df.count()}")
    print(f"  Records after cleaning: {cleaned_df.count()}")
    print(f"  Records removed: {df.count() - cleaned_df.count()}")
    
    return cleaned_df

# Clean the data
cleaned_df: DataFrame = clean_customer_data(raw_df)

print("\nCleaned Customer Data:")
cleaned_df.show()
```

```python
# Cell 5: Validate cleaned data
print("\n" + "🔍 VALIDATING CLEANED DATA".center(60, "="))

# Validate cleaned data (with stricter rules)
cleaned_validator = DataValidator(
    df=cleaned_df,
    required_columns=required_cols,
    nullable_columns=nullable_cols,
    unique_columns=unique_cols
)

cleaned_validation: ValidationResult = cleaned_validator.validate()
cleaned_validation.print_summary()

# Final status
if cleaned_validation.is_valid:
    print("\n✅ Data is ready for processing!")
    print(f"   Final record count: {cleaned_validation.row_count}")
else:
    print("\n❌ Data still has issues that need attention")
```

**Expected Output:**
```
Sample Customer Data (with data quality issues):
+-----------+----------+---------+----------------+------------+-------+
|customer_id|first_name|last_name|           email|       phone|balance|
+-----------+----------+---------+----------------+------------+-------+
|          1|     Alice|    Smith| alice@email.com|  1234567890|1500.00|
|          2|       Bob|     null|   bob@email.com|555-123-4567| 250.50|
|          3|   Charlie|    Brown|            null|999-888-7777|3200.00|
|          4|    DAVID|    jones| david@email.com|  1112223333|   null|
|          5|       Eve|   Wilson|   eve@email.com|  4445556666| 890.00|
|          1|     Alice|    Smith| alice@email.com|  1234567890|1500.00|
|          6|      null|   Taylor|taylor@email.com|  7778889999| 450.00|
+-----------+----------+---------+----------------+------------+-------+
Total records: 7

============================================================
🔍 VALIDATING RAW DATA
============================================================
VALIDATION SUMMARY
============================================================
Status: ✗ FAILED
Timestamp: 2026-01-02T10:30:45.123456
Total Rows: 7
Duplicate Rows: 1

Errors (1):
  ✗ Column 'customer_id' should be unique but has 1 duplicates

Warnings (3):
  ⚠ Column 'first_name' has 1 null values (14.3%)
  ⚠ Column 'last_name' has 1 null values (14.3%)
  ⚠ Column 'email' has 1 null values (14.3%)
  ⚠ Found 1 duplicate rows

Null Value Counts:
  first_name: 1 (14.29%)
  last_name: 1 (14.29%)
  email: 1 (14.29%)
  balance: 1 (14.29%)
============================================================

🧹 Cleaning data...
  Records before cleaning: 7
  Records after cleaning: 4
  Records removed: 3

Cleaned Customer Data:
+-----------+----------+---------+----------------+----------+-------+
|customer_id|first_name|last_name|           email|     phone|balance|
+-----------+----------+---------+----------------+----------+-------+
|          1|     Alice|    Smith| alice@email.com|1234567890|1500.00|
|          2|       Bob|     null|   bob@email.com|5551234567| 250.50|
|          4|     DAVID|    jones| david@email.com|1112223333|   null|
|          5|       Eve|   Wilson|   eve@email.com|4445556666| 890.00|
+-----------+----------+---------+----------------+----------+-------+

============================================================
🔍 VALIDATING CLEANED DATA
============================================================
✅ Data is ready for processing!
   Final record count: 4
```

---

## Example 3: Complete ETL Workflow (Advanced)

### Goal
Build a multi-notebook ETL pipeline with separate extract, transform, and load notebooks, orchestrated by a main notebook using `dbutils.notebook.run()`.

### Step 3.1: Create Extract Notebook

**Notebook Path:** `/Users/your_email/tutorial/pipelines/etl_extract`

```python
# Cell 1: Import dependencies
from pyspark.sql import DataFrame
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType, DateType
from typing import Dict, Any
import json
from datetime import datetime, timedelta
import random
```

```python
# Cell 2: Create widgets for parameters
dbutils.widgets.text("output_path", "/tmp/tutorial/extracted_data")
dbutils.widgets.text("record_count", "100")
dbutils.widgets.dropdown("data_quality", "good", ["good", "poor"])
```

```python
# Cell 3: Generate sample sales data
def generate_sample_data(num_records: int, quality: str = "good") -> DataFrame:
    """
    Generate sample sales data for the tutorial.
    
    Args:
        num_records: Number of records to generate
        quality: 'good' or 'poor' (introduces data quality issues)
        
    Returns:
        DataFrame with sample sales data
    """
    print(f"📊 Generating {num_records} sample records...")
    print(f"   Data quality: {quality}")
    
    # Generate data
    data = []
    products = ["Laptop", "Mouse", "Keyboard", "Monitor", "Headphones"]
    regions = ["North", "South", "East", "West"]
    statuses = ["completed", "pending", "cancelled"]
    
    base_date = datetime(2024, 1, 1)
    
    for i in range(num_records):
        sale_id = i + 1
        product = random.choice(products)
        region = random.choice(regions)
        quantity = random.randint(1, 10)
        price = round(random.uniform(10.0, 500.0), 2)
        sale_date = base_date + timedelta(days=random.randint(0, 365))
        status = random.choice(statuses)
        
        # Introduce data quality issues for 'poor' quality
        if quality == "poor":
            if random.random() < 0.1:  # 10% chance
                product = None  # Missing product
            if random.random() < 0.05:  # 5% chance
                quantity = None  # Missing quantity
            if random.random() < 0.15:  # 15% chance
                price = None  # Missing price
        
        data.append((sale_id, product, region, quantity, price, sale_date, status))
    
    # Create schema
    schema = StructType([
        StructField("sale_id", IntegerType(), False),
        StructField("product", StringType(), True),
        StructField("region", StringType(), True),
        StructField("quantity", IntegerType(), True),
        StructField("price", DoubleType(), True),
        StructField("sale_date", DateType(), True),
        StructField("status", StringType(), True)
    ])
    
    df = spark.createDataFrame(data, schema)
    
    print(f"✓ Generated {df.count()} records")
    return df
```

```python
# Cell 4: Extract and save data
def extract_data() -> Dict[str, Any]:
    """
    Extract data and save to temporary location.
    
    Returns:
        Dictionary with extraction results
    """
    start_time = datetime.now()
    
    # Get parameters
    output_path: str = dbutils.widgets.get("output_path")
    record_count: int = int(dbutils.widgets.get("record_count"))
    data_quality: str = dbutils.widgets.get("data_quality")
    
    print("="*60)
    print("EXTRACT PHASE")
    print("="*60)
    print(f"Output path: {output_path}")
    print(f"Record count: {record_count}")
    print(f"Data quality: {data_quality}")
    print()
    
    # Generate data
    df: DataFrame = generate_sample_data(record_count, data_quality)
    
    # Show sample
    print("\nSample of extracted data:")
    df.show(5)
    
    # Save data
    print(f"\n💾 Saving data to: {output_path}")
    df.write.mode("overwrite").parquet(output_path)
    print("✓ Data saved successfully")
    
    # Calculate statistics
    null_counts = {}
    for col_name in df.columns:
        null_count = df.filter(df[col_name].isNull()).count()
        if null_count > 0:
            null_counts[col_name] = null_count
    
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()
    
    result = {
        "status": "success",
        "phase": "extract",
        "record_count": df.count(),
        "output_path": output_path,
        "null_counts": null_counts,
        "duration_seconds": duration,
        "timestamp": end_time.isoformat()
    }
    
    print(f"\n⏱️  Extraction completed in {duration:.2f} seconds")
    return result

# Execute extraction
extract_result: Dict[str, Any] = extract_data()

# Return result to caller
dbutils.notebook.exit(json.dumps(extract_result))
```

### Step 3.2: Create Transform Notebook

**Notebook Path:** `/Users/your_email/tutorial/pipelines/etl_transform`

```python
# Cell 1: Import dependencies and validator
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, when, round as spark_round, coalesce, lit
from typing import Dict, Any, List
import json
from datetime import datetime

%run ../validators/data_validator
```

```python
# Cell 2: Create widgets
dbutils.widgets.text("input_path", "/tmp/tutorial/extracted_data")
dbutils.widgets.text("output_path", "/tmp/tutorial/transformed_data")
dbutils.widgets.dropdown("validation_level", "strict", ["strict", "lenient"])
```

```python
# Cell 3: Transform functions
def validate_input_data(df: DataFrame, validation_level: str) -> ValidationResult:
    """Validate input data before transformation."""
    print("🔍 Validating input data...")
    
    required_cols = ["sale_id", "product", "region", "quantity", "price", "sale_date", "status"]
    
    if validation_level == "strict":
        nullable_cols = []
    else:
        nullable_cols = ["quantity", "price"]
    
    validator = DataValidator(
        df=df,
        required_columns=required_cols,
        nullable_columns=nullable_cols,
        unique_columns=["sale_id"]
    )
    
    result = validator.validate()
    result.print_summary()
    
    return result


def transform_sales_data(df: DataFrame) -> DataFrame:
    """
    Transform and enrich sales data.
    
    Transformations:
    - Calculate total_amount (quantity * price)
    - Categorize sales as 'small', 'medium', 'large'
    - Fill missing quantities with 1
    - Fill missing prices with average price
    - Filter out cancelled transactions
    """
    print("\n🔄 Transforming data...")
    
    # Calculate average price for filling nulls
    avg_price = df.select(spark_round(col("price"), 2)).agg({"price": "avg"}).collect()[0][0]
    if avg_price is None:
        avg_price = 0.0
    
    print(f"   Average price for null filling: ${avg_price:.2f}")
    
    # Apply transformations
    transformed_df = df \
        .filter(col("status") != "cancelled") \
        .withColumn("quantity", coalesce(col("quantity"), lit(1))) \
        .withColumn("price", coalesce(col("price"), lit(avg_price))) \
        .withColumn("total_amount", spark_round(col("quantity") * col("price"), 2)) \
        .withColumn("sale_category",
            when(col("total_amount") < 100, "small")
            .when(col("total_amount") < 500, "medium")
            .otherwise("large")
        ) \
        .withColumn("is_high_value", col("total_amount") >= 500)
    
    print(f"   Records before transformation: {df.count()}")
    print(f"   Records after transformation: {transformed_df.count()}")
    print(f"   Records filtered out: {df.count() - transformed_df.count()}")
    
    return transformed_df


def generate_transformation_summary(original_df: DataFrame, transformed_df: DataFrame) -> Dict[str, Any]:
    """Generate summary statistics about the transformation."""
    from pyspark.sql.functions import sum as spark_sum, avg, max as spark_max, min as spark_min, count
    
    print("\n📊 Generating transformation summary...")
    
    # Aggregate statistics
    stats = transformed_df.agg(
        count("*").alias("total_records"),
        spark_sum("total_amount").alias("total_sales"),
        avg("total_amount").alias("avg_sale"),
        spark_min("total_amount").alias("min_sale"),
        spark_max("total_amount").alias("max_sale")
    ).collect()[0]
    
    # Category breakdown
    category_counts = transformed_df.groupBy("sale_category").count().collect()
    categories = {row["sale_category"]: row["count"] for row in category_counts}
    
    # Region breakdown
    region_sales = transformed_df.groupBy("region") \
        .agg(spark_sum("total_amount").alias("total")) \
        .collect()
    regions = {row["region"]: float(row["total"]) for row in region_sales}
    
    summary = {
        "total_records": stats["total_records"],
        "total_sales": float(stats["total_sales"]) if stats["total_sales"] else 0.0,
        "avg_sale": float(stats["avg_sale"]) if stats["avg_sale"] else 0.0,
        "min_sale": float(stats["min_sale"]) if stats["min_sale"] else 0.0,
        "max_sale": float(stats["max_sale"]) if stats["max_sale"] else 0.0,
        "categories": categories,
        "regions": regions
    }
    
    return summary
```

```python
# Cell 4: Execute transformation
def transform_data() -> Dict[str, Any]:
    """
    Main transformation function.
    
    Returns:
        Dictionary with transformation results
    """
    start_time = datetime.now()
    
    # Get parameters
    input_path: str = dbutils.widgets.get("input_path")
    output_path: str = dbutils.widgets.get("output_path")
    validation_level: str = dbutils.widgets.get("validation_level")
    
    print("="*60)
    print("TRANSFORM PHASE")
    print("="*60)
    print(f"Input path: {input_path}")
    print(f"Output path: {output_path}")
    print(f"Validation level: {validation_level}")
    print()
    
    # Load data
    print("📂 Loading data...")
    df: DataFrame = spark.read.parquet(input_path)
    print(f"✓ Loaded {df.count()} records")
    
    # Validate input
    validation_result: ValidationResult = validate_input_data(df, validation_level)
    
    if not validation_result.is_valid and validation_level == "strict":
        error_result = {
            "status": "failed",
            "phase": "transform",
            "error": "Input validation failed",
            "errors": validation_result.errors,
            "timestamp": datetime.now().isoformat()
        }
        return error_result
    
    # Transform data
    transformed_df: DataFrame = transform_sales_data(df)
    
    print("\nSample of transformed data:")
    transformed_df.show(5)
    
    # Generate summary
    summary: Dict[str, Any] = generate_transformation_summary(df, transformed_df)
    
    print("\n📈 Transformation Summary:")
    print(f"   Total Records: {summary['total_records']:,}")
    print(f"   Total Sales: ${summary['total_sales']:,.2f}")
    print(f"   Average Sale: ${summary['avg_sale']:.2f}")
    print(f"   Min Sale: ${summary['min_sale']:.2f}")
    print(f"   Max Sale: ${summary['max_sale']:.2f}")
    print(f"\n   By Category:")
    for category, count in summary['categories'].items():
        print(f"     {category}: {count:,}")
    print(f"\n   By Region:")
    for region, total in summary['regions'].items():
        print(f"     {region}: ${total:,.2f}")
    
    # Save transformed data
    print(f"\n💾 Saving transformed data to: {output_path}")
    transformed_df.write.mode("overwrite").parquet(output_path)
    print("✓ Data saved successfully")
    
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()
    
    result = {
        "status": "success",
        "phase": "transform",
        "record_count": transformed_df.count(),
        "input_path": input_path,
        "output_path": output_path,
        "summary": summary,
        "validation_passed": validation_result.is_valid,
        "warnings": validation_result.warnings,
        "duration_seconds": duration,
        "timestamp": end_time.isoformat()
    }
    
    print(f"\n⏱️  Transformation completed in {duration:.2f} seconds")
    return result

# Execute transformation
transform_result: Dict[str, Any] = transform_data()

# Return result to caller
dbutils.notebook.exit(json.dumps(transform_result))
```

### Step 3.3: Create Load Notebook

**Notebook Path:** `/Users/your_email/tutorial/pipelines/etl_load`

```python
# Cell 1: Import dependencies
from pyspark.sql import DataFrame
from typing import Dict, Any
import json
from datetime import datetime
```

```python
# Cell 2: Create widgets
dbutils.widgets.text("input_path", "/tmp/tutorial/transformed_data")
dbutils.widgets.text("final_output_path", "/tmp/tutorial/final_sales_data")
dbutils.widgets.dropdown("partition_by", "region", ["region", "sale_category", "none"])
```

```python
# Cell 3: Load functions
def load_data() -> Dict[str, Any]:
    """
    Load transformed data to final destination.
    
    Returns:
        Dictionary with load results
    """
    start_time = datetime.now()
    
    # Get parameters
    input_path: str = dbutils.widgets.get("input_path")
    output_path: str = dbutils.widgets.get("final_output_path")
    partition_by: str = dbutils.widgets.get("partition_by")
    
    print("="*60)
    print("LOAD PHASE")
    print("="*60)
    print(f"Input path: {input_path}")
    print(f"Output path: {output_path}")
    print(f"Partition by: {partition_by}")
    print()
    
    # Load data
    print("📂 Loading transformed data...")
    df: DataFrame = spark.read.parquet(input_path)
    record_count: int = df.count()
    print(f"✓ Loaded {record_count:,} records")
    
    print("\nSample of data to load:")
    df.show(5)
    
    # Write data with optional partitioning
    print(f"\n💾 Writing data to final destination...")
    
    if partition_by != "none":
        print(f"   Partitioning by: {partition_by}")
        df.write.mode("overwrite").partitionBy(partition_by).parquet(output_path)
        
        # Count partitions
        partition_counts = df.groupBy(partition_by).count().collect()
        print(f"   Created {len(partition_counts)} partitions:")
        for row in partition_counts:
            print(f"     {row[partition_by]}: {row['count']:,} records")
    else:
        df.write.mode("overwrite").parquet(output_path)
    
    print("✓ Data loaded successfully")
    
    # Verify written data
    print("\n✓ Verifying written data...")
    verification_df = spark.read.parquet(output_path)
    verification_count = verification_df.count()
    
    if verification_count == record_count:
        print(f"✓ Verification passed: {verification_count:,} records")
    else:
        print(f"⚠️  Warning: Record count mismatch!")
        print(f"   Expected: {record_count:,}")
        print(f"   Found: {verification_count:,}")
    
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()
    
    result = {
        "status": "success",
        "phase": "load",
        "record_count": record_count,
        "input_path": input_path,
        "output_path": output_path,
        "partition_by": partition_by,
        "verification_count": verification_count,
        "verification_passed": verification_count == record_count,
        "duration_seconds": duration,
        "timestamp": end_time.isoformat()
    }
    
    print(f"\n⏱️  Load completed in {duration:.2f} seconds")
    return result

# Execute load
load_result: Dict[str, Any] = load_data()

# Return result to caller
dbutils.notebook.exit(json.dumps(load_result))
```

### Step 3.4: Create Orchestrator Notebook

**Notebook Path:** `/Users/your_email/tutorial/main/etl_orchestrator`

```python
# Cell 1: Import dependencies
from typing import Dict, Any, List
import json
from datetime import datetime
```

```python
# Cell 2: Define orchestration functions
def print_phase_header(phase: str, phase_num: int, total_phases: int) -> None:
    """Print formatted phase header."""
    print("\n" + "="*70)
    print(f"PHASE {phase_num}/{total_phases}: {phase.upper()}")
    print("="*70)


def print_phase_result(result: Dict[str, Any]) -> None:
    """Print formatted phase result."""
    print(f"\n✓ Phase completed successfully")
    print(f"  Status: {result['status']}")
    print(f"  Records: {result.get('record_count', 'N/A'):,}")
    print(f"  Duration: {result.get('duration_seconds', 0):.2f} seconds")
    
    if 'summary' in result:
        summary = result['summary']
        print(f"\n  Summary Statistics:")
        print(f"    Total Sales: ${summary['total_sales']:,.2f}")
        print(f"    Average Sale: ${summary['avg_sale']:.2f}")


def run_etl_pipeline(
    record_count: int = 100,
    data_quality: str = "good",
    validation_level: str = "strict",
    partition_by: str = "region"
) -> Dict[str, Any]:
    """
    Orchestrate the complete ETL pipeline.
    
    Args:
        record_count: Number of records to generate
        data_quality: 'good' or 'poor'
        validation_level: 'strict' or 'lenient'
        partition_by: Column to partition by ('region', 'sale_category', 'none')
        
    Returns:
        Dictionary with complete pipeline results
    """
    pipeline_start = datetime.now()
    
    print("="*70)
    print("ETL PIPELINE ORCHESTRATOR")
    print("="*70)
    print(f"Start Time: {pipeline_start.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"\nConfiguration:")
    print(f"  Record Count: {record_count}")
    print(f"  Data Quality: {data_quality}")
    print(f"  Validation Level: {validation_level}")
    print(f"  Partition By: {partition_by}")
    
    results: Dict[str, Any] = {
        "pipeline_start": pipeline_start.isoformat(),
        "configuration": {
            "record_count": record_count,
            "data_quality": data_quality,
            "validation_level": validation_level,
            "partition_by": partition_by
        },
        "phases": {}
    }
    
    try:
        # Phase 1: Extract
        print_phase_header("extract", 1, 3)
        extract_result_str = dbutils.notebook.run(
            "../pipelines/etl_extract",
            timeout_seconds=300,
            arguments={
                "output_path": "/tmp/tutorial/extracted_data",
                "record_count": str(record_count),
                "data_quality": data_quality
            }
        )
        extract_result: Dict[str, Any] = json.loads(extract_result_str)
        results["phases"]["extract"] = extract_result
        print_phase_result(extract_result)
        
        # Phase 2: Transform
        print_phase_header("transform", 2, 3)
        transform_result_str = dbutils.notebook.run(
            "../pipelines/etl_transform",
            timeout_seconds=300,
            arguments={
                "input_path": extract_result["output_path"],
                "output_path": "/tmp/tutorial/transformed_data",
                "validation_level": validation_level
            }
        )
        transform_result: Dict[str, Any] = json.loads(transform_result_str)
        
        if transform_result["status"] == "failed":
            print(f"\n❌ Transform phase failed!")
            print(f"   Error: {transform_result['error']}")
            results["status"] = "failed"
            results["failed_phase"] = "transform"
            return results
        
        results["phases"]["transform"] = transform_result
        print_phase_result(transform_result)
        
        # Phase 3: Load
        print_phase_header("load", 3, 3)
        load_result_str = dbutils.notebook.run(
            "../pipelines/etl_load",
            timeout_seconds=300,
            arguments={
                "input_path": transform_result["output_path"],
                "final_output_path": "/tmp/tutorial/final_sales_data",
                "partition_by": partition_by
            }
        )
        load_result: Dict[str, Any] = json.loads(load_result_str)
        results["phases"]["load"] = load_result
        print_phase_result(load_result)
        
        # Pipeline completed successfully
        pipeline_end = datetime.now()
        total_duration = (pipeline_end - pipeline_start).total_seconds()
        
        results["status"] = "success"
        results["pipeline_end"] = pipeline_end.isoformat()
        results["total_duration_seconds"] = total_duration
        
        # Print final summary
        print("\n" + "="*70)
        print("PIPELINE COMPLETED SUCCESSFULLY! 🎉")
        print("="*70)
        print(f"Start Time: {pipeline_start.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"End Time: {pipeline_end.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Total Duration: {total_duration:.2f} seconds")
        print(f"\nPhase Durations:")
        for phase, phase_result in results["phases"].items():
            duration = phase_result.get("duration_seconds", 0)
            print(f"  {phase.capitalize()}: {duration:.2f}s")
        
        if "summary" in transform_result:
            summary = transform_result["summary"]
            print(f"\nFinal Statistics:")
            print(f"  Total Records: {summary['total_records']:,}")
            print(f"  Total Sales: ${summary['total_sales']:,.2f}")
            print(f"  Average Sale: ${summary['avg_sale']:.2f}")
            print(f"  Output Location: {load_result['output_path']}")
        
        return results
        
    except Exception as e:
        pipeline_end = datetime.now()
        total_duration = (pipeline_end - pipeline_start).total_seconds()
        
        print(f"\n❌ PIPELINE FAILED!")
        print(f"   Error: {str(e)}")
        
        results["status"] = "failed"
        results["error"] = str(e)
        results["pipeline_end"] = pipeline_end.isoformat()
        results["total_duration_seconds"] = total_duration
        
        return results
```

```python
# Cell 3: Run pipeline with different configurations

# Test 1: Good quality data with strict validation
print("TEST 1: Good Quality Data + Strict Validation")
print("-" * 70)
result1 = run_etl_pipeline(
    record_count=50,
    data_quality="good",
    validation_level="strict",
    partition_by="region"
)
```

```python
# Cell 4: Run with poor quality data
print("\n\nTEST 2: Poor Quality Data + Lenient Validation")
print("-" * 70)
result2 = run_etl_pipeline(
    record_count=75,
    data_quality="poor",
    validation_level="lenient",
    partition_by="sale_category"
)
```

```python
# Cell 5: Query final results
from pyspark.sql import DataFrame

print("\n\n" + "="*70)
print("QUERYING FINAL RESULTS")
print("="*70)

final_df: DataFrame = spark.read.parquet("/tmp/tutorial/final_sales_data")

print(f"\nTotal records in final dataset: {final_df.count():,}")
print("\nSchema:")
final_df.printSchema()

print("\nSample records:")
final_df.show(10)

print("\nSales by Region:")
final_df.groupBy("region").agg({"total_amount": "sum", "*": "count"}).show()

print("\nSales by Category:")
final_df.groupBy("sale_category").agg({"total_amount": "sum", "*": "count"}).show()

print("\n✅ Pipeline demonstration complete!")
```

---

## Running the Examples

### For Example 1 (Simple):
1. Create the `string_utils` notebook in `/tutorial/utils/`
2. Create the `simple_example` notebook in `/tutorial/main/`
3. Run all cells in `simple_example`

### For Example 2 (Intermediate):
1. Create the `data_validator` notebook in `/tutorial/validators/`
2. Create the `customer_processing` notebook in `/tutorial/pipelines/`
3. Run all cells in `customer_processing`

### For Example 3 (Advanced):
1. Create all four ETL notebooks:
   - `etl_extract` in `/tutorial/pipelines/`
   - `etl_transform` in `/tutorial/pipelines/`
   - `etl_load` in `/tutorial/pipelines/`
   - `etl_orchestrator` in `/tutorial/main/`
2. Run all cells in `etl_orchestrator`

---

## Troubleshooting

### Common Issues

**Issue 1: "Notebook not found" error**
- Solution: Verify the path in your `%run` command matches the actual notebook location
- Use relative paths (`../utils/notebook`) or absolute paths (`/Users/your_email/tutorial/utils/notebook`)

**Issue 2: "NameError: name 'function_name' is not defined"**
- Solution: Make sure you've run the `%run` command before trying to use the functions
- Check that the function is defined in the imported notebook

**Issue 3: dbutils.notebook.run() timeout**
- Solution: Increase the `timeout_seconds` parameter
- Check if the called notebook has any infinite loops or long-running operations

**Issue 4: Path issues**
- Solution: Always use absolute paths starting with `/Users/` or `/Repos/`
- Or use relative paths starting with `./` or `../`

---

## Next Steps

1. **Experiment**: Modify the examples to work with your own data
2. **Extend**: Add more validation rules or transformation logic
3. **Optimize**: Add caching, partitioning strategies
4. **Monitor**: Add logging and error tracking
5. **Schedule**: Use Databricks Jobs to schedule your pipelines

---

## Summary

You've learned:
- ✓ How to use `%run` for sharing code
- ✓ How to use `dbutils.notebook.run()` for orchestration
- ✓ How to add type hints to your code
- ✓ How to create reusable validators and utilities
- ✓ How to build complete ETL pipelines

Happy coding in Databricks! 🚀
