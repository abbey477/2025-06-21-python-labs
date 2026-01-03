# Troubleshooting %run Command in Databricks Notebooks

## Problem Description

When using `%run` in Databricks:
- Relative paths throw errors
- Full paths run without errors BUT don't show any output
- Functions/variables from imported notebook are not available

---

## Common Issues and Solutions

### Issue 1: Relative Path Errors

**Problem:**
```python
%run ./utils/helper_functions
# Error: Notebook not found: ./utils/helper_functions
```

**Root Causes:**
1. Incorrect current directory
2. Wrong path syntax
3. Notebook doesn't exist at that location

**Solutions:**

#### Solution 1A: Use Absolute Paths (Most Reliable)
```python
# For workspace notebooks
%run /Users/your_email@company.com/project/utils/helper_functions

# For Repos
%run /Repos/your_username/repo_name/utils/helper_functions
```

#### Solution 1B: Fix Relative Paths
```python
# If your structure is:
# /Users/email/project/
#   ├── main/
#   │   └── main_notebook
#   └── utils/
#       └── helper_functions

# From main/main_notebook, use:
%run ../utils/helper_functions

# NOT:
%run ./utils/helper_functions  # Wrong - looks in main/utils/
```

#### Solution 1C: Verify Current Location
```python
# Cell 1: Check where you are
import os
current_path = dbutils.notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get()
print(f"Current notebook path: {current_path}")

# Cell 2: Then construct relative path
%run ../utils/helper_functions
```

---

### Issue 2: No Output or Print Statements Not Showing

**Problem:**
```python
%run /Users/email/project/utils/helper_functions
# Runs without error but prints nothing
# Functions are not available
```

**Root Cause:**
The `%run` command executes silently. Output is suppressed unless there's an error.

**Diagnostic Steps:**

#### Step 1: Verify the Notebook Exists
```python
# Check if notebook exists
try:
    dbutils.notebook.run(
        "/Users/email/project/utils/helper_functions",
        timeout_seconds=10,
        arguments={}
    )
    print("✓ Notebook exists and runs")
except Exception as e:
    print(f"✗ Error: {e}")
```

#### Step 2: Check What Was Imported
```python
# After %run command, list all available variables
%run /Users/email/project/utils/helper_functions

# Check what's available
print("Available variables after import:")
available_vars = [var for var in dir() if not var.startswith('_')]
print(available_vars)
```

#### Step 3: Verify Functions Are Defined
```python
%run /Users/email/project/utils/helper_functions

# Test if function exists
try:
    print(f"clean_string function: {clean_string}")
    print("✓ Function is available")
except NameError:
    print("✗ Function not found - check notebook content")
```

---

## Complete Troubleshooting Workflow

### Workflow: Debug %run Issues

Create this diagnostic notebook to troubleshoot any `%run` issues:

**Notebook: `/Users/your_email/debug_run_command`**

```python
# Cell 1: Configuration
TARGET_NOTEBOOK = "/Users/your_email@company.com/project/utils/helper_functions"
EXPECTED_FUNCTIONS = ["clean_string", "format_phone", "split_and_clean"]
```

```python
# Cell 2: Check current location
import os

current_path = dbutils.notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get()
print("="*70)
print("DIAGNOSTIC INFORMATION")
print("="*70)
print(f"Current notebook: {current_path}")
print(f"Target notebook: {TARGET_NOTEBOOK}")
print()
```

```python
# Cell 3: Verify target notebook exists
print("Step 1: Checking if target notebook exists...")
try:
    # Try to run with dbutils (this will tell us if notebook exists)
    result = dbutils.notebook.run(
        TARGET_NOTEBOOK,
        timeout_seconds=10,
        arguments={}
    )
    print("✓ Target notebook exists and can be executed")
    print(f"  Return value: {result if result else '(empty)'}")
except Exception as e:
    print(f"✗ Error accessing notebook: {e}")
    print("\nPossible issues:")
    print("  1. Notebook doesn't exist at that path")
    print("  2. You don't have permission to access it")
    print("  3. Path is incorrect")
    dbutils.notebook.exit("FAILED: Cannot access target notebook")
```

```python
# Cell 4: Capture variables before import
print("\nStep 2: Capturing current namespace...")
before_import = set(dir())
print(f"Variables before import: {len(before_import)}")
```

```python
# Cell 5: Execute %run command
print("\nStep 3: Running %run command...")
%run /Users/your_email@company.com/project/utils/helper_functions
print("✓ %run command completed")
```

```python
# Cell 6: Check what was imported
print("\nStep 4: Analyzing imported items...")
after_import = set(dir())
newly_imported = after_import - before_import

print(f"\nNewly available items ({len(newly_imported)}):")
for item in sorted(newly_imported):
    if not item.startswith('_'):
        obj = eval(item)
        obj_type = type(obj).__name__
        print(f"  - {item} ({obj_type})")
```

```python
# Cell 7: Verify expected functions
print("\nStep 5: Verifying expected functions...")
missing_functions = []
found_functions = []

for func_name in EXPECTED_FUNCTIONS:
    try:
        func = eval(func_name)
        found_functions.append(func_name)
        print(f"✓ {func_name} - Found ({type(func).__name__})")
    except NameError:
        missing_functions.append(func_name)
        print(f"✗ {func_name} - NOT FOUND")

print(f"\nSummary:")
print(f"  Found: {len(found_functions)}/{len(EXPECTED_FUNCTIONS)}")
print(f"  Missing: {len(missing_functions)}")

if missing_functions:
    print(f"\nMissing functions: {missing_functions}")
    print("\nPossible reasons:")
    print("  1. Functions not defined in target notebook")
    print("  2. Syntax errors in target notebook")
    print("  3. Functions defined inside if __name__ == '__main__' block")
```

```python
# Cell 8: Test a function (if available)
if found_functions:
    print("\nStep 6: Testing imported functions...")
    try:
        # Test first available function
        test_func_name = found_functions[0]
        
        if test_func_name == "clean_string":
            result = clean_string("  TEST  ")
            print(f"✓ Function call successful: clean_string('  TEST  ') = '{result}'")
        elif test_func_name == "format_phone":
            result = format_phone("1234567890")
            print(f"✓ Function call successful: format_phone('1234567890') = '{result}'")
        
        print("\n" + "="*70)
        print("DIAGNOSTIC COMPLETE - %run IS WORKING CORRECTLY")
        print("="*70)
        
    except Exception as e:
        print(f"✗ Error calling function: {e}")
        print("\nThe function exists but cannot be called.")
        print("Check the function definition in the target notebook.")
else:
    print("\n" + "="*70)
    print("DIAGNOSTIC COMPLETE - NO FUNCTIONS WERE IMPORTED")
    print("="*70)
    print("\nAction required: Check target notebook content")
```

---

## Common Mistakes and Fixes

### Mistake 1: Functions Inside `if __name__ == "__main__"` Block

**Problem:**
```python
# In helper_functions notebook
def clean_string(text):
    return text.strip().lower()

if __name__ == "__main__":
    # Testing code
    print("Testing clean_string...")
    result = clean_string("TEST")
    print(f"Result: {result}")
```

When you use `%run`, the `if __name__ == "__main__"` block executes, but in Databricks notebooks, this condition is **always True**, even when imported!

**Solution:**
```python
# In helper_functions notebook
def clean_string(text):
    return text.strip().lower()

# Don't use if __name__ == "__main__" in Databricks
# Instead, use a flag or separate test notebook

# Optional: Add a test flag
_TESTING = False

if _TESTING:
    print("Testing clean_string...")
    result = clean_string("TEST")
    print(f"Result: {result}")
```

### Mistake 2: Expecting Print Output from %run

**Problem:**
```python
# helper_functions notebook has:
print("Loading utilities...")
def clean_string(text):
    return text.strip().lower()
print("Utilities loaded!")

# Main notebook:
%run /path/to/helper_functions
# You won't see the print statements!
```

**Why:** `%run` suppresses output from the imported notebook.

**Solution:**
```python
# If you need to verify import, add a version variable
# In helper_functions:
UTILS_VERSION = "1.0.0"
print(f"Utils version: {UTILS_VERSION}")

# In main notebook:
%run /path/to/helper_functions
print(f"Imported utils version: {UTILS_VERSION}")  # This WILL print
```

### Mistake 3: Wrong Path Separator

**Problem:**
```python
# Windows-style path (WRONG)
%run C:\Users\email\notebook

# Backslash relative path (WRONG)
%run ..\utils\helper
```

**Solution:**
```python
# Always use forward slashes
%run /Users/email/notebook

# For relative paths
%run ../utils/helper
```

### Mistake 4: File Extension in Path

**Problem:**
```python
%run /Users/email/notebook.py  # WRONG
%run /Users/email/notebook.ipynb  # WRONG
```

**Solution:**
```python
%run /Users/email/notebook  # CORRECT - no extension
```

---

## Debugging Checklist

Use this checklist when `%run` isn't working:

```
□ 1. Verify notebook path is correct
   → Run: dbutils.fs.ls("/Users/your_email/project/")
   
□ 2. Check you have read permissions
   → Can you open the notebook in the UI?
   
□ 3. Verify no syntax errors in target notebook
   → Open and run target notebook independently
   
□ 4. Confirm functions are defined at module level
   → Not inside if __name__ == "__main__"
   
□ 5. Check imports in target notebook
   → Missing imports will cause silent failures
   
□ 6. Verify no circular dependencies
   → Notebook A imports B, B imports A
   
□ 7. Test with absolute path first
   → Get it working, then switch to relative
   
□ 8. Check for typos in function names
   → After %run, try: dir() to see what's available
```

---

## Best Practices

### 1. Always Verify Import Success

```python
# Good practice
%run /path/to/utils

# Immediately verify
try:
    assert 'clean_string' in dir(), "clean_string not imported"
    print("✓ Import successful")
except AssertionError as e:
    print(f"✗ Import failed: {e}")
    raise
```

### 2. Use Try-Except for %run

While you can't wrap `%run` in try-except, you can verify after:

```python
%run /path/to/utils

# Verify immediately
expected_items = ['clean_string', 'format_phone']
missing = [item for item in expected_items if item not in dir()]

if missing:
    raise ImportError(f"Failed to import: {missing}")
```

### 3. Create a Testing Cell

```python
# At the top of target notebook
def _test_import():
    """Test function to verify import worked."""
    return "Import successful!"

# In main notebook after %run:
%run /path/to/utils

print(_test_import())  # Should print "Import successful!"
```

### 4. Use Descriptive Error Messages

```python
# In helper_functions notebook
def clean_string(text):
    if not isinstance(text, str):
        raise TypeError(f"Expected str, got {type(text).__name__}")
    return text.strip().lower()

# This makes debugging easier when function is called from main notebook
```

---

## Alternative: Use dbutils.notebook.run() for Better Debugging

If `%run` is causing issues, consider `dbutils.notebook.run()`:

```python
# More verbose but easier to debug
try:
    result = dbutils.notebook.run(
        "/Users/email/utils/helper_functions",
        timeout_seconds=60,
        arguments={}
    )
    print(f"Notebook executed successfully")
    print(f"Return value: {result}")
except Exception as e:
    print(f"Error details: {e}")
    import traceback
    traceback.print_exc()
```

**Pros:**
- Better error messages
- Can catch exceptions
- Returns values
- Can pass parameters

**Cons:**
- Doesn't import functions into namespace
- Runs in separate context
- Need to use dbutils.notebook.exit() to return values

---

## Quick Reference

### Path Syntax Examples

```python
# ✓ CORRECT paths
%run /Users/email@company.com/project/notebook
%run /Repos/username/repo/notebook
%run ../utils/helper
%run ./local/helper

# ✗ WRONG paths
%run C:/Users/notebook  # Windows path
%run \Users\notebook    # Backslashes
%run notebook.py        # File extension
%run ~/project/notebook # ~ not supported
```

### Debugging Commands

```python
# Check current location
dbutils.notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get()

# List notebooks in directory
dbutils.fs.ls("/Users/your_email/project/")

# See what's in namespace
[x for x in dir() if not x.startswith('_')]

# Check if function exists
'function_name' in dir()

# Get function info
help(function_name)
```

---

## Real-World Example

Here's a complete working example:

**Notebook 1: `/Users/email/utils/string_utils`**
```python
# Cell 1: Define version for verification
STRING_UTILS_VERSION = "1.0.0"

# Cell 2: Define functions
def clean_string(text):
    """Clean a string."""
    if text is None:
        return ""
    return text.strip().lower()

def validate_email(email):
    """Basic email validation."""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

# Cell 3: Test function (for verification)
def _test_import():
    """Verify import worked."""
    return f"String utils v{STRING_UTILS_VERSION} loaded successfully"

# Don't add print statements here - they won't show in %run
```

**Notebook 2: `/Users/email/main/processor`**
```python
# Cell 1: Import with verification
print("Importing utilities...")
%run /Users/email/utils/string_utils

# Verify import
try:
    version_message = _test_import()
    print(f"✓ {version_message}")
except NameError:
    print("✗ Import failed - _test_import not found")
    raise

# Cell 2: Verify functions exist
required_functions = ['clean_string', 'validate_email']
missing = [f for f in required_functions if f not in dir()]

if missing:
    raise ImportError(f"Missing functions: {missing}")

print(f"✓ All required functions available: {required_functions}")

# Cell 3: Use the functions
test_string = "  HELLO WORLD  "
cleaned = clean_string(test_string)
print(f"Cleaned: '{cleaned}'")

test_email = "user@example.com"
is_valid = validate_email(test_email)
print(f"Email '{test_email}' valid: {is_valid}")
```

---

## When to Use %run vs dbutils.notebook.run()

### Use `%run` when:
- ✅ You want to import functions/classes
- ✅ You want to share variables
- ✅ Creating reusable utility libraries
- ✅ You need the imported code in the same namespace

### Use `dbutils.notebook.run()` when:
- ✅ You want to run notebooks as jobs
- ✅ You need to pass parameters
- ✅ You want to get return values
- ✅ You need better error handling
- ✅ Running notebooks in parallel

---

## Summary

**Most Common Issue:** Functions not available after %run
**Most Common Cause:** Functions inside `if __name__ == "__main__"` block or syntax errors

**Quick Fix:**
1. Open target notebook and run it independently
2. Remove any `if __name__ == "__main__"` blocks
3. Use absolute paths first
4. Add verification code after %run

**Remember:**
- `%run` executes silently (no print output)
- Functions must be at module level
- Always verify import success
- Use absolute paths when debugging

---

**Created:** January 2026
