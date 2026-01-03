# Databricks Workspace Files - Simple Guide for Beginners

## Important Limitation ⚠️

**You CANNOT import `.py` files directly from `/Workspace` in Databricks!**

This is a Databricks platform limitation. The `/Workspace` directory is designed for notebooks, not Python modules.

---

## Two Simple Solutions

### Solution 1: Use Notebooks with %run (Recommended for Beginners) ✅
### Solution 2: Use Databricks Repos with .py files (For Real Projects) ✅

---

## Solution 1: Notebooks with %run (EASIEST)

This is the **simplest** solution. Instead of creating `.py` files, create notebooks!

### File Structure
```
/Workspace/19519-pre-prod/sandbox01/
├── my_utilities         # Notebook with functions
└── my_main_notebook     # Your main notebook
```

**Just 2 notebooks - no .py files needed!**

---

### Step 1: Create Your Utilities Notebook

**How to create:**
1. In Databricks, click **Workspace** in sidebar
2. Navigate to `/Workspace/19519-pre-prod/sandbox01/`
3. Click dropdown → **Create** → **Notebook**
4. Name: `my_utilities`
5. Language: **Python**
6. Copy the code below

**Notebook: `/Workspace/19519-pre-prod/sandbox01/my_utilities`**

```python
# Cell 1: Define your utility functions
"""
My utility functions for data cleaning.

This notebook contains reusable functions.
"""

def clean_text(text):
    """
    Clean text by removing spaces and making it lowercase.
    
    Args:
        text: Input text string
        
    Returns:
        Cleaned text string
        
    Example:
        clean_text("  HELLO  ") returns "hello"
    """
    if text is None:
        return ""
    return text.strip().lower()


def add_numbers(a, b):
    """
    Add two numbers together.
    
    Args:
        a: First number
        b: Second number
        
    Returns:
        Sum of a and b
        
    Example:
        add_numbers(5, 3) returns 8
    """
    return a + b


def greet(name):
    """
    Create a greeting message.
    
    Args:
        name: Person's name
        
    Returns:
        Greeting message
        
    Example:
        greet("Alice") returns "Hello, Alice!"
    """
    return f"Hello, {name}!"


def format_currency(amount):
    """
    Format a number as currency.
    
    Args:
        amount: Dollar amount
        
    Returns:
        Formatted currency string
        
    Example:
        format_currency(1234.56) returns "$1,234.56"
    """
    return f"${amount:,.2f}"


# Optional: Display a message when loaded
print("✓ Utility functions loaded successfully")
print("  Available functions:")
print("    - clean_text(text)")
print("    - add_numbers(a, b)")
print("    - greet(name)")
print("    - format_currency(amount)")
```

---

### Step 2: Use in Your Main Notebook

**How to create:**
1. In Databricks, navigate to `/Workspace/19519-pre-prod/sandbox01/`
2. Click dropdown → **Create** → **Notebook**
3. Name: `my_main_notebook`
4. Language: **Python**
5. Copy the cells below

**Notebook: `/Workspace/19519-pre-prod/sandbox01/my_main_notebook`**

```python
# Cell 1: Import the utility functions using %run
%run /Workspace/19519-pre-prod/sandbox01/my_utilities

# The functions are now available!
```

```python
# Cell 2: Test clean_text function
print("Testing clean_text function:")
print("-" * 50)

test_text = "  HELLO DATABRICKS  "
cleaned = clean_text(test_text)

print(f"Original: '{test_text}'")
print(f"Cleaned:  '{cleaned}'")
print()

# More examples
examples = [
    "  ALICE SMITH  ",
    "BOB jones",
    "  charlie BROWN  "
]

print("Cleaning multiple texts:")
for text in examples:
    print(f"  '{text}' → '{clean_text(text)}'")
```

```python
# Cell 3: Test add_numbers function
print("Testing add_numbers function:")
print("-" * 50)

result1 = add_numbers(10, 20)
print(f"10 + 20 = {result1}")

result2 = add_numbers(100, 250)
print(f"100 + 250 = {result2}")

# Calculate total
numbers = [5, 10, 15, 20]
total = sum([add_numbers(n, 0) for n in numbers])
print(f"Sum of {numbers} = {total}")
```

```python
# Cell 4: Test greet function
print("Testing greet function:")
print("-" * 50)

names = ["Alice", "Bob", "Charlie"]
for name in names:
    message = greet(name)
    print(message)
```

```python
# Cell 5: Test format_currency function
print("Testing format_currency function:")
print("-" * 50)

amounts = [100, 1234.56, 999999.99, 0.99]
for amount in amounts:
    formatted = format_currency(amount)
    print(f"{amount:>12} → {formatted}")
```

```python
# Cell 6: Use with PySpark DataFrame
from pyspark.sql import DataFrame
from pyspark.sql.functions import udf, col
from pyspark.sql.types import StringType, DoubleType

print("Using utility functions with PySpark:")
print("-" * 50)

# Create sample data
data = [
    (1, "  ALICE SMITH  ", 1234.56),
    (2, "bob JONES", 567.89),
    (3, "  CHARLIE Brown  ", 9999.99)
]

df = spark.createDataFrame(data, ["id", "name", "balance"])

print("\nOriginal DataFrame:")
df.show(truncate=False)

# Register UDFs
clean_text_udf = udf(clean_text, StringType())
format_currency_udf = udf(format_currency, StringType())

# Apply transformations
result_df = (
    df
    .withColumn("name_cleaned", clean_text_udf(col("name")))
    .withColumn("balance_formatted", format_currency_udf(col("balance")))
)

print("\nTransformed DataFrame:")
result_df.show(truncate=False)
```

```python
# Cell 7: Real-world example - Data cleaning pipeline
print("Real-world example: Customer data cleaning")
print("=" * 70)

# Sample messy customer data
messy_data = [
    (1, "  ACME Corp  ", "  JOHN DOE  ", 15000.50),
    (2, "XYZ company", "jane SMITH", 22500.75),
    (3, "  ABC Inc  ", "  BOB Jones  ", 8750.25)
]

messy_df = spark.createDataFrame(
    messy_data, 
    ["customer_id", "company", "contact_name", "revenue"]
)

print("\n📥 Input Data (Messy):")
messy_df.show(truncate=False)

# Clean the data using our utility functions
clean_text_udf = udf(clean_text, StringType())
format_currency_udf = udf(format_currency, StringType())

clean_df = (
    messy_df
    .withColumn("company_clean", clean_text_udf(col("company")))
    .withColumn("contact_clean", clean_text_udf(col("contact_name")))
    .withColumn("revenue_formatted", format_currency_udf(col("revenue")))
    .select(
        "customer_id",
        "company_clean",
        "contact_clean", 
        "revenue",
        "revenue_formatted"
    )
)

print("\n✨ Output Data (Clean):")
clean_df.show(truncate=False)

print("\n✓ Data cleaning pipeline completed successfully!")
```

```python
# Cell 8: Summary
print("=" * 70)
print("SUMMARY")
print("=" * 70)
print("\n✓ Imported utility functions using %run")
print("✓ Tested all functions successfully:")
print("   - clean_text()")
print("   - add_numbers()")
print("   - greet()")
print("   - format_currency()")
print("✓ Used functions with PySpark DataFrames")
print("✓ Built a complete data cleaning pipeline")
print("\n🎉 Everything working perfectly!")
print("=" * 70)
```

---

## Solution 2: Databricks Repos with .py Files

This solution is for **real projects** where you want proper version control and standard Python practices.

### Prerequisites
- GitHub, GitLab, or Azure DevOps account
- Basic Git knowledge

### Step 1: Set Up Databricks Repos

**Option A: Connect Existing Git Repo**
1. In Databricks, click **Repos** in sidebar
2. Click **Add Repo**
3. Enter your Git repo URL
4. Click **Create Repo**

**Option B: Create New Repo**
1. Create a repo on GitHub/GitLab first
2. Follow Option A to connect it

### Step 2: Create Project Structure

In your repo, create this structure:

```
/Repos/your-username/my-project/
├── src/
│   └── utils.py              # Your Python module
└── notebooks/
    └── main_notebook.py      # Your notebook
```

### Step 3: Create utils.py

**File: `/Repos/your-username/my-project/src/utils.py`**

```python
"""
Utility functions for data processing.

This is a proper Python module that can be imported.
"""


def clean_text(text):
    """
    Clean text by removing spaces and making it lowercase.
    
    Args:
        text: Input text string
        
    Returns:
        Cleaned text string
        
    Example:
        >>> clean_text("  HELLO  ")
        'hello'
    """
    if text is None:
        return ""
    return text.strip().lower()


def add_numbers(a, b):
    """
    Add two numbers together.
    
    Args:
        a: First number
        b: Second number
        
    Returns:
        Sum of a and b
        
    Example:
        >>> add_numbers(5, 3)
        8
    """
    return a + b


def greet(name):
    """
    Create a greeting message.
    
    Args:
        name: Person's name
        
    Returns:
        Greeting message
        
    Example:
        >>> greet("Alice")
        'Hello, Alice!'
    """
    return f"Hello, {name}!"


def format_currency(amount):
    """
    Format a number as currency.
    
    Args:
        amount: Dollar amount
        
    Returns:
        Formatted currency string
        
    Example:
        >>> format_currency(1234.56)
        '$1,234.56'
    """
    return f"${amount:,.2f}"


# Module-level test (runs when file is executed directly)
if __name__ == "__main__":
    print("Testing utils module...")
    
    # Test clean_text
    assert clean_text("  TEST  ") == "test"
    print("✓ clean_text works")
    
    # Test add_numbers
    assert add_numbers(2, 3) == 5
    print("✓ add_numbers works")
    
    # Test greet
    assert greet("World") == "Hello, World!"
    print("✓ greet works")
    
    # Test format_currency
    assert format_currency(1234.56) == "$1,234.56"
    print("✓ format_currency works")
    
    print("\n✓ All tests passed!")
```

### Step 4: Use in Notebook

**Notebook: `/Repos/your-username/my-project/notebooks/main_notebook.py`**

```python
# Cell 1: Add the src directory to Python path
import sys
import os

# Get the repo root directory
repo_root = '/Workspace/Repos/your-username/my-project'
src_path = os.path.join(repo_root, 'src')

# Add to Python path
if src_path not in sys.path:
    sys.path.insert(0, src_path)
    print(f"✓ Added to path: {src_path}")

print(f"Python path: {sys.path[0]}")
```

```python
# Cell 2: Import from the Python module
from utils import clean_text, add_numbers, greet, format_currency

print("✓ Successfully imported utility functions")
```

```python
# Cell 3: Use the functions
print("Testing imported functions:")
print(clean_text("  HELLO  "))
print(add_numbers(5, 3))
print(greet("Alice"))
print(format_currency(1234.56))
```

```python
# Cell 4: Use with PySpark
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType

data = [("  ALICE  ",), ("  BOB  ",)]
df = spark.createDataFrame(data, ["name"])

clean_udf = udf(clean_text, StringType())
df.withColumn("clean_name", clean_udf("name")).show()
```

---

## Comparison: Which Solution Should You Use?

| Feature | Solution 1 (%run) | Solution 2 (Repos) |
|---------|-------------------|-------------------|
| **Difficulty** | ⭐ Very Easy | ⭐⭐⭐ Moderate |
| **Setup Time** | 2 minutes | 15 minutes |
| **Git Integration** | ❌ No | ✅ Yes |
| **Standard Python** | ❌ No | ✅ Yes |
| **IDE Support** | ⚠️ Limited | ✅ Full |
| **Best For** | Learning, Quick scripts | Production, Team projects |
| **Version Control** | ❌ Manual | ✅ Automatic |
| **Testing** | ⚠️ Basic | ✅ Full pytest support |

---

## Quick Start Guide

### For Beginners: Use Solution 1

**Step 1:** Create utilities notebook
```
Workspace → Create → Notebook → "my_utilities"
```

**Step 2:** Add functions to utilities notebook
```python
def clean_text(text):
    if text is None:
        return ""
    return text.strip().lower()
```

**Step 3:** Use in main notebook
```python
%run /Workspace/path/to/my_utilities
result = clean_text("  TEST  ")
```

**Done!** ✅

---

### For Real Projects: Use Solution 2

**Step 1:** Connect Git repo
```
Databricks → Repos → Add Repo → Enter URL
```

**Step 2:** Create src/utils.py
```python
def clean_text(text):
    if text is None:
        return ""
    return text.strip().lower()
```

**Step 3:** Import in notebook
```python
import sys
sys.path.insert(0, '/Workspace/Repos/username/project/src')
from utils import clean_text
```

**Done!** ✅

---

## Common Errors and Solutions

### Error 1: "No module named 'my_utils'"

**Cause:** You created a `.py` file in `/Workspace` and tried to import it

**Solution:** Use Solution 1 (%run with notebooks) or Solution 2 (Repos with .py)

```python
# ❌ WRONG - Cannot import .py from /Workspace
from my_utils import clean_text

# ✅ RIGHT - Use %run for notebooks
%run /Workspace/path/to/my_utilities

# ✅ RIGHT - Or use Repos for .py files
import sys
sys.path.insert(0, '/Workspace/Repos/username/project/src')
from utils import clean_text
```

### Error 2: "Name 'clean_text' is not defined"

**Cause:** Forgot to run the %run cell

**Solution:** Always run the %run cell first

```python
# Cell 1: MUST RUN THIS FIRST
%run /Workspace/path/to/my_utilities

# Cell 2: Then use functions
clean_text("test")
```

### Error 3: Changes not showing up

**Cause:** Notebook was modified but not reloaded

**Solution for %run:**
```python
# Re-run the %run cell to reload
%run /Workspace/path/to/my_utilities
```

**Solution for Repos:**
```python
# Reload the module
import importlib
import utils
importlib.reload(utils)
```

---

## Best Practices

### DO ✅
- Use notebooks with `%run` for simple utilities (Solution 1)
- Use Repos with `.py` files for team projects (Solution 2)
- Document your functions with docstrings
- Test your functions before using them
- Use descriptive function names

### DON'T ❌
- Don't try to import `.py` files from `/Workspace`
- Don't skip the `sys.path.insert()` step when using Repos
- Don't forget to run `%run` cell before using functions
- Don't put complex logic in notebooks (use .py files in Repos)

---

## Summary

**The Problem:**
- Cannot import `.py` files from `/Workspace` in Databricks

**The Solutions:**

**Solution 1 (Easiest):**
- Create notebooks instead of `.py` files
- Use `%run` to import
- Perfect for learning and simple projects

**Solution 2 (Professional):**
- Use Databricks Repos
- Create proper `.py` files
- Use `sys.path.insert()` and `import`
- Best for team projects and production code

---

## Next Steps

**After mastering this guide:**

1. **Add more functions** to your utilities
2. **Create multiple utility notebooks** for different purposes
3. **Learn Git** to use Repos effectively
4. **Explore PySpark** integration with your utilities
5. **Build complete data pipelines** using modular code

---

## Additional Resources

- [Databricks Repos Documentation](https://docs.databricks.com/repos/)
- [Databricks Notebooks Documentation](https://docs.databricks.com/notebooks/)
- [PySpark Documentation](https://spark.apache.org/docs/latest/api/python/)

---

**Created:** January 2026  
**For:** Databricks Beginners  
**Difficulty:** Easy to Moderate
