# Databricks Multiple Notebooks Guide with Type Hints

## Table of Contents
- [Introduction](#introduction)
- [Method 1: Using %run](#method-1-using-run)
- [Method 2: Using dbutils.notebook.run()](#method-2-using-dbutilsnotebookrun)
- [Working with Type Hints](#working-with-type-hints)
- [Complete Examples](#complete-examples)
- [Best Practices](#best-practices)
- [Common Type Imports](#common-type-imports)

---

## Introduction

Databricks allows you to organize your code across multiple notebooks and reference them from each other. This guide covers two main approaches with proper type hints for better code quality and maintainability.

---

## Method 1: Using %run

The `%run` magic command executes another notebook and imports all its variables, functions, and classes into your current notebook's namespace.

### Basic Syntax

```python
%run /path/to/your/other/notebook
```

### Example: Helper Functions Notebook

**Notebook Location:** `/Shared/utils/helper_functions`

```python
from typing import List, Dict, Optional, Union
from pyspark.sql import DataFrame

def clean_data(df: DataFrame) -> DataFrame:
    """Remove null values from DataFrame."""
    return df.dropna()

def transform_data(df: DataFrame, columns: List[str]) -> DataFrame:
    """Select specific columns from DataFrame."""
    return df.select(*columns)

def filter_by_value(
    df: DataFrame, 
    column: str, 
    value: Union[str, int, float]
) -> DataFrame:
    """Filter DataFrame by column value."""
    return df.filter(df[column] == value)

def aggregate_data(
    df: DataFrame, 
    group_cols: List[str], 
    agg_dict: Dict[str, str]
) -> DataFrame:
    """Group and aggregate DataFrame."""
    return df.groupBy(*group_cols).agg(agg_dict)
```

### Using the Helper Functions

**Your Main Notebook:**

```python
from pyspark.sql import DataFrame
from typing import List

# Import all functions from helper notebook
%run /Shared/utils/helper_functions

# Now use the functions with type hints
my_data: DataFrame = spark.read.parquet("/path/to/data")
cleaned_df: DataFrame = clean_data(my_data)

selected_cols: List[str] = ["col1", "col2", "col3"]
transformed_df: DataFrame = transform_data(cleaned_df, selected_cols)

filtered_df: DataFrame = filter_by_value(transformed_df, "status", "active")
```

---

## Method 2: Using dbutils.notebook.run()

This approach runs a notebook as a separate job and returns a value. It does not share the namespace, making it ideal for workflow pipelines.

### Basic Syntax

```python
result = dbutils.notebook.run(
    path="/path/to/notebook",
    timeout_seconds=60,
    arguments={"param1": "value1", "param2": "value2"}
)
```

### Example: Data Processing Notebook

**Notebook Location:** `/Shared/jobs/data_processor`

```python
# Define widgets for parameters
dbutils.widgets.text("input_path", "")
dbutils.widgets.text("output_path", "")
dbutils.widgets.text("filter_column", "status")
dbutils.widgets.text("filter_value", "active")

from typing import Dict, Any
from pyspark.sql import DataFrame
import json

def process_data(
    input_path: str, 
    output_path: str,
    filter_column: str,
    filter_value: str
) -> Dict[str, Any]:
    """
    Process data with filtering and return metrics.
    
    Args:
        input_path: Path to input data
        output_path: Path to save output
        filter_column: Column to filter on
        filter_value: Value to filter by
        
    Returns:
        Dictionary with processing results
    """
    # Read data
    df: DataFrame = spark.read.parquet(input_path)
    initial_count: int = df.count()
    
    # Process
    processed_df: DataFrame = df.filter(df[filter_column] == filter_value)
    final_count: int = processed_df.count()
    
    # Write output
    processed_df.write.mode("overwrite").parquet(output_path)
    
    return {
        "status": "success",
        "initial_records": initial_count,
        "final_records": final_count,
        "records_filtered": initial_count - final_count
    }

# Get parameters and process
result: Dict[str, Any] = process_data(
    dbutils.widgets.get("input_path"),
    dbutils.widgets.get("output_path"),
    dbutils.widgets.get("filter_column"),
    dbutils.widgets.get("filter_value")
)

# Return result (dbutils.notebook.exit only accepts strings)
dbutils.notebook.exit(json.dumps(result))
```

### Calling the Notebook

**Your Main Notebook:**

```python
import json
from typing import Dict, Any, List

def run_data_pipeline(
    input_path: str,
    output_path: str,
    timeout: int = 600
) -> Dict[str, Any]:
    """Run the data processing pipeline."""
    
    result_str: str = dbutils.notebook.run(
        "/Shared/jobs/data_processor",
        timeout_seconds=timeout,
        arguments={
            "input_path": input_path,
            "output_path": output_path,
            "filter_column": "status",
            "filter_value": "active"
        }
    )
    
    result: Dict[str, Any] = json.loads(result_str)
    return result

# Execute pipeline
pipeline_result: Dict[str, Any] = run_data_pipeline(
    input_path="/data/raw/customers",
    output_path="/data/processed/active_customers"
)

print(f"Processing complete!")
print(f"Initial records: {pipeline_result['initial_records']}")
print(f"Final records: {pipeline_result['final_records']}")
print(f"Filtered out: {pipeline_result['records_filtered']}")
```

---

## Working with Type Hints

### Basic Types for Databricks

```python
from typing import (
    List, Dict, Set, Tuple, 
    Optional, Union, Any, 
    Callable
)
from pyspark.sql import DataFrame, SparkSession, Column, Row
from pyspark.sql.types import (
    StructType, StructField, 
    StringType, IntegerType, 
    DoubleType, DateType, 
    TimestampType
)
```

### Example with Complex Types

**Notebook:** `/Shared/utils/schema_helpers`

```python
from typing import List, Dict, Optional, Tuple
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, DoubleType

def create_customer_schema() -> StructType:
    """Create schema for customer data."""
    return StructType([
        StructField("customer_id", IntegerType(), False),
        StructField("name", StringType(), False),
        StructField("email", StringType(), True),
        StructField("balance", DoubleType(), True)
    ])

def get_column_types(schema: StructType) -> Dict[str, str]:
    """Extract column names and their types."""
    return {field.name: str(field.dataType) for field in schema.fields}

def validate_schema(
    actual_schema: StructType,
    expected_schema: StructType
) -> Tuple[bool, List[str]]:
    """
    Compare two schemas and return validation result.
    
    Returns:
        Tuple of (is_valid, list_of_errors)
    """
    errors: List[str] = []
    
    actual_cols: Set[str] = {f.name for f in actual_schema.fields}
    expected_cols: Set[str] = {f.name for f in expected_schema.fields}
    
    missing: Set[str] = expected_cols - actual_cols
    extra: Set[str] = actual_cols - expected_cols
    
    if missing:
        errors.append(f"Missing columns: {missing}")
    if extra:
        errors.append(f"Extra columns: {extra}")
        
    return (len(errors) == 0, errors)
```

---

## Complete Examples

### Example 1: Data Validation Class

**Notebook:** `/Shared/classes/data_validator`

```python
from typing import List, Set, Optional, Dict, Any
from pyspark.sql import DataFrame
from dataclasses import dataclass
from datetime import datetime

@dataclass
class ValidationResult:
    """Store validation results."""
    is_valid: bool
    errors: List[str]
    warnings: List[str]
    row_count: int
    null_counts: Dict[str, int]
    timestamp: str

class DataValidator:
    """Validate DataFrame structure and content."""
    
    def __init__(
        self, 
        df: DataFrame, 
        required_columns: List[str],
        nullable_columns: Optional[List[str]] = None
    ) -> None:
        self.df: DataFrame = df
        self.required_columns: List[str] = required_columns
        self.nullable_columns: List[str] = nullable_columns or []
        
    def validate(self) -> ValidationResult:
        """Run all validation checks."""
        errors: List[str] = []
        warnings: List[str] = []
        
        # Check columns exist
        df_columns: Set[str] = set(self.df.columns)
        required_set: Set[str] = set(self.required_columns)
        missing: Set[str] = required_set - df_columns
        
        if missing:
            errors.append(f"Missing required columns: {missing}")
            
        # Check row count
        row_count: int = self.df.count()
        if row_count == 0:
            errors.append("DataFrame is empty")
            
        # Check for nulls
        null_counts: Dict[str, int] = {}
        for col in self.df.columns:
            null_count: int = self.df.filter(self.df[col].isNull()).count()
            null_counts[col] = null_count
            
            if null_count > 0 and col not in self.nullable_columns:
                warnings.append(f"Column '{col}' has {null_count} null values")
                
        return ValidationResult(
            is_valid=len(errors) == 0,
            errors=errors,
            warnings=warnings,
            row_count=row_count,
            null_counts=null_counts,
            timestamp=datetime.now().isoformat()
        )
    
    def validate_unique(self, column: str) -> bool:
        """Check if a column has unique values."""
        total: int = self.df.count()
        distinct: int = self.df.select(column).distinct().count()
        return total == distinct
```

**Using the Validator:**

```python
from pyspark.sql import DataFrame
from typing import List

%run /Shared/classes/data_validator

# Load data
customer_df: DataFrame = spark.read.csv("/data/customers.csv", header=True)

# Define requirements
required_cols: List[str] = ["customer_id", "name", "email", "created_date"]
nullable_cols: List[str] = ["phone", "address"]

# Validate
validator: DataValidator = DataValidator(
    df=customer_df,
    required_columns=required_cols,
    nullable_columns=nullable_cols
)

result: ValidationResult = validator.validate()

# Print results
if result.is_valid:
    print(f"✓ Validation passed!")
    print(f"  Row count: {result.row_count}")
    if result.warnings:
        print(f"  Warnings: {len(result.warnings)}")
        for warning in result.warnings:
            print(f"    - {warning}")
else:
    print(f"✗ Validation failed!")
    for error in result.errors:
        print(f"  - {error}")

# Check uniqueness
if validator.validate_unique("customer_id"):
    print("✓ customer_id is unique")
else:
    print("✗ customer_id has duplicates")
```

### Example 2: ETL Pipeline with Multiple Notebooks

**Notebook 1:** `/Shared/etl/extract`

```python
from typing import Dict, Any
from pyspark.sql import DataFrame
import json

dbutils.widgets.text("source_path", "")
dbutils.widgets.text("file_format", "parquet")

def extract_data(source_path: str, file_format: str) -> DataFrame:
    """Extract data from source."""
    if file_format == "parquet":
        return spark.read.parquet(source_path)
    elif file_format == "csv":
        return spark.read.csv(source_path, header=True, inferSchema=True)
    elif file_format == "json":
        return spark.read.json(source_path)
    else:
        raise ValueError(f"Unsupported format: {file_format}")

df: DataFrame = extract_data(
    dbutils.widgets.get("source_path"),
    dbutils.widgets.get("file_format")
)

# Save to temp location
temp_path: str = "/tmp/extracted_data"
df.write.mode("overwrite").parquet(temp_path)

result: Dict[str, Any] = {
    "status": "success",
    "record_count": df.count(),
    "temp_path": temp_path
}

dbutils.notebook.exit(json.dumps(result))
```

**Notebook 2:** `/Shared/etl/transform`

```python
from typing import Dict, Any, List
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, when, trim, upper
import json

dbutils.widgets.text("input_path", "")
dbutils.widgets.text("output_path", "")

def transform_data(df: DataFrame) -> DataFrame:
    """Apply transformations to data."""
    return df \
        .withColumn("name", trim(upper(col("name")))) \
        .withColumn("email", trim(col("email"))) \
        .withColumn("status", 
            when(col("balance") > 1000, "premium")
            .when(col("balance") > 100, "standard")
            .otherwise("basic")
        ) \
        .filter(col("email").isNotNull())

input_df: DataFrame = spark.read.parquet(dbutils.widgets.get("input_path"))
transformed_df: DataFrame = transform_data(input_df)

output_path: str = dbutils.widgets.get("output_path")
transformed_df.write.mode("overwrite").parquet(output_path)

result: Dict[str, Any] = {
    "status": "success",
    "record_count": transformed_df.count(),
    "output_path": output_path
}

dbutils.notebook.exit(json.dumps(result))
```

**Main Pipeline Orchestrator:**

```python
from typing import Dict, Any, List
import json

def run_etl_pipeline(
    source_path: str,
    output_path: str,
    file_format: str = "parquet"
) -> Dict[str, Any]:
    """
    Orchestrate the complete ETL pipeline.
    
    Args:
        source_path: Path to source data
        output_path: Path for final output
        file_format: Format of source data
        
    Returns:
        Dictionary with pipeline results
    """
    print("Step 1: Extracting data...")
    extract_result: str = dbutils.notebook.run(
        "/Shared/etl/extract",
        timeout_seconds=300,
        arguments={
            "source_path": source_path,
            "file_format": file_format
        }
    )
    extract_data: Dict[str, Any] = json.loads(extract_result)
    print(f"  ✓ Extracted {extract_data['record_count']} records")
    
    print("Step 2: Transforming data...")
    transform_result: str = dbutils.notebook.run(
        "/Shared/etl/transform",
        timeout_seconds=300,
        arguments={
            "input_path": extract_data['temp_path'],
            "output_path": output_path
        }
    )
    transform_data: Dict[str, Any] = json.loads(transform_result)
    print(f"  ✓ Transformed {transform_data['record_count']} records")
    
    return {
        "status": "completed",
        "extract": extract_data,
        "transform": transform_data
    }

# Run pipeline
pipeline_result: Dict[str, Any] = run_etl_pipeline(
    source_path="/data/raw/customers",
    output_path="/data/processed/customers",
    file_format="csv"
)

print("\n" + "="*50)
print("Pipeline completed successfully!")
print(f"Final output: {pipeline_result['transform']['output_path']}")
print("="*50)
```

---

## Best Practices

### 1. Organize Your Notebooks

```
/Shared/
├── utils/
│   ├── helper_functions
│   ├── schema_helpers
│   └── validators
├── classes/
│   ├── data_validator
│   └── data_processor
├── etl/
│   ├── extract
│   ├── transform
│   └── load
└── jobs/
    ├── daily_processing
    └── weekly_reports
```

### 2. Use Relative Paths When Possible

```python
# Good - relative to current workspace
%run ./utils/helper_functions

# Also good - absolute from Shared
%run /Shared/utils/helper_functions
```

### 3. Always Add Type Hints

```python
# Bad
def process_data(df, columns):
    return df.select(columns)

# Good
def process_data(df: DataFrame, columns: List[str]) -> DataFrame:
    """Process DataFrame by selecting specific columns."""
    return df.select(*columns)
```

### 4. Document Your Functions

```python
def aggregate_sales(
    df: DataFrame,
    group_by: List[str],
    date_column: str,
    amount_column: str
) -> DataFrame:
    """
    Aggregate sales data by specified dimensions.
    
    Args:
        df: Input DataFrame containing sales data
        group_by: List of columns to group by
        date_column: Name of the date column
        amount_column: Name of the amount/value column
        
    Returns:
        Aggregated DataFrame with sum of amounts by group
        
    Example:
        >>> result = aggregate_sales(
        ...     df=sales_df,
        ...     group_by=["region", "product"],
        ...     date_column="sale_date",
        ...     amount_column="revenue"
        ... )
    """
    from pyspark.sql.functions import sum as _sum, count
    
    return df.groupBy(*group_by).agg(
        _sum(amount_column).alias("total_amount"),
        count("*").alias("transaction_count")
    )
```

### 5. Handle Errors Gracefully

```python
from typing import Optional, Tuple
from pyspark.sql import DataFrame

def safe_read_data(
    path: str,
    format: str = "parquet"
) -> Tuple[Optional[DataFrame], Optional[str]]:
    """
    Safely read data with error handling.
    
    Returns:
        Tuple of (DataFrame or None, error_message or None)
    """
    try:
        if format == "parquet":
            df = spark.read.parquet(path)
        elif format == "csv":
            df = spark.read.csv(path, header=True, inferSchema=True)
        else:
            return None, f"Unsupported format: {format}"
            
        return df, None
    except Exception as e:
        return None, f"Error reading data: {str(e)}"

# Usage
df, error = safe_read_data("/data/customers", "parquet")
if error:
    print(f"Failed to load data: {error}")
else:
    print(f"Successfully loaded {df.count()} records")
```

### 6. Use Dataclasses for Complex Return Types

```python
from dataclasses import dataclass
from typing import List, Dict
from datetime import datetime

@dataclass
class ProcessingResult:
    """Result of data processing operation."""
    success: bool
    records_processed: int
    records_failed: int
    errors: List[str]
    warnings: List[str]
    execution_time_seconds: float
    timestamp: datetime
    metadata: Dict[str, Any]

def process_with_result(df: DataFrame) -> ProcessingResult:
    """Process data and return detailed results."""
    import time
    start_time = time.time()
    
    # Processing logic here
    errors: List[str] = []
    warnings: List[str] = []
    
    # ... processing ...
    
    return ProcessingResult(
        success=len(errors) == 0,
        records_processed=df.count(),
        records_failed=0,
        errors=errors,
        warnings=warnings,
        execution_time_seconds=time.time() - start_time,
        timestamp=datetime.now(),
        metadata={"source": "databricks", "version": "1.0"}
    )
```

---

## Common Type Imports

### Complete Import Block for Databricks

```python
# Standard library types
from typing import (
    List, Dict, Set, Tuple,
    Optional, Union, Any,
    Callable, Iterator, Generator
)
from dataclasses import dataclass, field
from datetime import datetime, date, timedelta
from enum import Enum

# PySpark types
from pyspark.sql import DataFrame, SparkSession, Column, Row, Window
from pyspark.sql.functions import (
    col, lit, when, concat, sum as _sum,
    count, avg, max as _max, min as _min
)
from pyspark.sql.types import (
    StructType, StructField,
    StringType, IntegerType, LongType,
    DoubleType, FloatType, DecimalType,
    BooleanType, DateType, TimestampType,
    ArrayType, MapType
)

# For pandas operations (if using pandas UDFs)
import pandas as pd
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from pandas import Series as PandasSeries
```

### Type Aliases for Clarity

```python
from typing import Dict, Any, List
from pyspark.sql import DataFrame

# Define type aliases
JSONDict = Dict[str, Any]
ColumnList = List[str]
SchemaDict = Dict[str, str]

def process_config(config: JSONDict, columns: ColumnList) -> DataFrame:
    """Use type aliases for cleaner signatures."""
    pass
```

---

## Summary

### When to Use %run
- Sharing utility functions across notebooks
- Creating reusable libraries
- When you need shared namespace
- For simple imports and code reuse

### When to Use dbutils.notebook.run()
- Orchestrating multi-step workflows
- Running notebooks in parallel
- When you need to pass parameters
- Creating pipeline jobs
- When notebooks should run independently

### Type Hints Benefits
- Better IDE autocomplete
- Catch errors before runtime
- Self-documenting code
- Easier refactoring
- Better collaboration

---

## Additional Resources

- [Databricks Documentation](https://docs.databricks.com/)
- [PySpark Type Hints](https://spark.apache.org/docs/latest/api/python/)
- [Python Type Hints (PEP 484)](https://www.python.org/dev/peps/pep-0484/)
- [Dataclasses Documentation](https://docs.python.org/3/library/dataclasses.html)

---

**Last Updated:** January 2026
