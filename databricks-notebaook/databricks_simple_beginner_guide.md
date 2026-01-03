# Databricks Python Modules - Super Simple Guide for Beginners

## Goal
Create **1 Python file** with utility functions and use it in **1 notebook**.

---

## File Structure (Very Simple)

```
/Workspace/19519-pre-prod/sandbox01/
├── my_utils.py          # Your utility functions (1 file)
└── my_notebook          # Your notebook (1 file)
```

**That's it! Just 2 files. No folders, no `__init__.py`, nothing complicated.**

---

## Step 1: Create the Python File

Create a file in Databricks workspace:

**How to create:**
1. In Databricks, click "Workspace" in the sidebar
2. Navigate to `/Workspace/19519-pre-prod/sandbox01/`
3. Click the dropdown arrow → **Create** → **File**
4. Name it: `my_utils.py`
5. Copy the code below into it

**File: `/Workspace/19519-pre-prod/sandbox01/my_utils.py`**

```python
"""
Simple utility functions for data cleaning.
"""


def clean_text(text):
    """
    Clean text by removing spaces and making it lowercase.
    
    Example:
        clean_text("  HELLO  ") returns "hello"
    """
    if text is None:
        return ""
    return text.strip().lower()


def add_numbers(a, b):
    """
    Add two numbers together.
    
    Example:
        add_numbers(5, 3) returns 8
    """
    return a + b


def greet(name):
    """
    Create a greeting message.
    
    Example:
        greet("Alice") returns "Hello, Alice!"
    """
    return f"Hello, {name}!"


# Test the functions (only runs when file is run directly)
if __name__ == "__main__":
    print("Testing my_utils...")
    print(clean_text("  TEST  "))  # Should print: test
    print(add_numbers(2, 3))        # Should print: 5
    print(greet("World"))           # Should print: Hello, World!
```

---

## Step 2: Use in Your Notebook

Create a notebook:

**How to create:**
1. In Databricks, navigate to `/Workspace/19519-pre-prod/sandbox01/`
2. Click dropdown → **Create** → **Notebook**
3. Name it: `my_notebook`
4. Language: **Python**
5. Copy the cells below

**Notebook: `/Workspace/19519-pre-prod/sandbox01/my_notebook`**

### Cell 1: Setup Path

```python
# Add your workspace folder to Python's search path
import sys
sys.path.insert(0, '/Workspace/19519-pre-prod/sandbox01')

print("✓ Path added successfully")
```

### Cell 2: Import Functions

```python
# Import the functions from your Python file
from my_utils import clean_text, add_numbers, greet

print("✓ Functions imported successfully")
```

### Cell 3: Test the Functions

```python
# Test 1: Clean text
dirty_text = "  HELLO WORLD  "
clean = clean_text(dirty_text)
print(f"Original: '{dirty_text}'")
print(f"Cleaned:  '{clean}'")
```

### Cell 4: More Tests

```python
# Test 2: Add numbers
result = add_numbers(10, 20)
print(f"10 + 20 = {result}")

# Test 3: Greet
message = greet("Alice")
print(message)
```

### Cell 5: Use with DataFrame (Optional)

```python
# Use with PySpark DataFrame
from pyspark.sql.functions import udf
from pyspark.sql.types import StringType

# Create sample data
data = [
    ("  ALICE  ",),
    ("  BOB  ",),
    ("  CHARLIE  ",)
]

df = spark.createDataFrame(data, ["name"])
print("Original DataFrame:")
df.show()

# Register function as UDF
clean_text_udf = udf(clean_text, StringType())

# Use it
cleaned_df = df.withColumn("name_cleaned", clean_text_udf(df.name))
print("Cleaned DataFrame:")
cleaned_df.show()
```

---

## That's It! 

You now have:
- ✅ 1 Python file with utility functions
- ✅ 1 notebook that uses those functions
- ✅ Simple, clean, working code

---

## Common Mistakes to Avoid

### ❌ Wrong: Forgetting to add path
```python
# This will NOT work
from my_utils import clean_text  # Error!
```

### ✅ Right: Always add path first
```python
# This WILL work
import sys
sys.path.insert(0, '/Workspace/19519-pre-prod/sandbox01')
from my_utils import clean_text  # Works!
```

---

## How to Add More Functions

Just edit `my_utils.py` and add more functions:

```python
def multiply_numbers(a, b):
    """Multiply two numbers."""
    return a * b


def make_uppercase(text):
    """Make text uppercase."""
    return text.upper()
```

Then import them in your notebook:

```python
from my_utils import clean_text, add_numbers, multiply_numbers, make_uppercase
```

---

## Quick Reference Card

### Create Python File
```
Workspace → Create → File → "my_utils.py"
```

### In Notebook - Every Time
```python
# Step 1: Add path (do this ONCE at top)
import sys
sys.path.insert(0, '/Workspace/19519-pre-prod/sandbox01')

# Step 2: Import functions
from my_utils import clean_text, add_numbers

# Step 3: Use them
result = clean_text("  test  ")
```

---

## Troubleshooting

### Problem: "No module named 'my_utils'"

**Solution:**
```python
# Run this to check
import sys
print(sys.path[:3])  # Check if your path is there

# If not there, add it
sys.path.insert(0, '/Workspace/19519-pre-prod/sandbox01')
```

### Problem: "Function not found"

**Solution:**
```python
# Check what's available
import my_utils
print(dir(my_utils))  # Shows all functions in the file
```

### Problem: Changes not showing

**Solution:**
```python
# Reload the module after making changes
import importlib
importlib.reload(my_utils)
```

---

## Summary

**2 Files Total:**
1. `my_utils.py` - Your functions
2. `my_notebook` - Your notebook

**3 Steps in Notebook:**
1. Add path to sys.path
2. Import functions
3. Use them

**That's it! Simple and easy to understand.**

---

## Next Steps (When You're Ready)

Once you're comfortable with this simple setup, you can:
1. Add more functions to `my_utils.py`
2. Create another file like `my_validators.py`
3. Organize into folders (later, when needed)

But for now, **keep it simple with just these 2 files!**
