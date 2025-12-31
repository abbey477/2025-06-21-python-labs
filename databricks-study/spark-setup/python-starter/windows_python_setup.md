# Python Virtual Environment Setup - Windows 10

This guide will help you set up a Python virtual environment for Spark projects on Windows 10.

## Prerequisites

- Windows 10
- Python 3.x installed from [python.org](https://www.python.org/downloads/)
- Python added to PATH during installation

## Verify Python Installation

Open PowerShell or Command Prompt and check:

```powershell
python --version
pip --version
```

If these commands don't work, you may need to reinstall Python and check "Add Python to PATH" during installation.

## Step-by-Step Setup

### 1. Open PowerShell or Command Prompt

**PowerShell (Recommended):**
- Press `Win + X` and select "Windows PowerShell"

**Command Prompt:**
- Press `Win + R`, type `cmd`, press Enter

### 2. Create Project Directory

```powershell
mkdir C:\spark-project
cd C:\spark-project
```

**Note:** You can use any directory path, such as:
- `C:\Projects\my-spark-app`
- `%USERPROFILE%\Documents\spark-project`

### 3. Create Virtual Environment

```powershell
python -m venv venv
```

This creates a folder named `venv` containing the isolated Python environment.

### 4. Activate Virtual Environment

**PowerShell:**
```powershell
.\venv\Scripts\Activate.ps1
```

**Command Prompt:**
```batch
venv\Scripts\activate.bat
```

**You'll know it's activated when:**
- Your prompt shows `(venv)` at the beginning
- Example: `(venv) C:\spark-project>`

### PowerShell Execution Policy Issue

If you get an error about execution policy in PowerShell:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try activating again.

### 5. Upgrade pip

```powershell
pip install --upgrade pip
```

### 6. Install Packages

```powershell
pip install pyspark jupyter pandas numpy
```

**Common packages:**
- `pyspark` - Apache Spark Python API
- `jupyter` - Jupyter Notebook
- `pandas` - Data manipulation library
- `numpy` - Numerical computing library

### 7. Save Requirements

```powershell
pip freeze > requirements.txt
```

This creates a file listing all installed packages and versions.

### 8. Deactivate Virtual Environment

```powershell
deactivate
```

Run this when you're done working on your project.

## Daily Usage

### Starting Work

**PowerShell:**
```powershell
cd C:\spark-project
.\venv\Scripts\Activate.ps1
```

**Command Prompt:**
```batch
cd C:\spark-project
venv\Scripts\activate.bat
```

### Finishing Work

```powershell
deactivate
```

## Import into PyCharm

### Method 1: Open Project

1. Open PyCharm
2. Click **File → Open**
3. Navigate to `C:\spark-project`
4. Click **OK**

### Method 2: Configure Interpreter (if needed)

1. **File → Settings** (Ctrl+Alt+S)
2. Navigate to **Project → Python Interpreter**
3. Click the **gear icon** → **Add Interpreter** → **Add Local Interpreter**
4. Select **Existing environment**
5. Click **...** and navigate to:
   ```
   C:\spark-project\venv\Scripts\python.exe
   ```
6. Click **OK**

### Verify Setup

Create a new Python file in PyCharm and test:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("test").getOrCreate()
print(f"Spark version: {spark.version}")
spark.stop()
```

## Restoring Environment on Another Machine

If you have a `requirements.txt` file:

```powershell
# Create and activate virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install all packages from requirements.txt
pip install -r requirements.txt
```

## Troubleshooting

### Python Command Not Found

**Solution:** Reinstall Python from python.org and check "Add Python to PATH" during installation.

### Execution Policy Error (PowerShell)

**Error:** "cannot be loaded because running scripts is disabled"

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Permission Issues

**Solution:** Run PowerShell or Command Prompt as Administrator:
- Right-click → "Run as administrator"

### Virtual Environment Not Activating

**Solution:** Make sure you're in the correct directory:
```powershell
cd C:\spark-project
dir venv  # Verify venv folder exists
```

### Module Not Found After Installation

**Solution:** Ensure virtual environment is activated before installing packages.

## Useful Commands

```powershell
# Check Python version
python --version

# Check pip version
pip --version

# List installed packages
pip list

# Show package details
pip show pyspark

# Uninstall a package
pip uninstall package_name

# Update a package
pip install --upgrade package_name

# Clear pip cache
pip cache purge
```

## Directory Structure

After setup, your project will look like this:

```
C:\spark-project\
├── venv\                 # Virtual environment (don't commit to git)
│   ├── Scripts\
│   ├── Lib\
│   └── ...
└── requirements.txt      # List of installed packages
```

## Best Practices

1. **Always activate** the virtual environment before working
2. **Don't commit** the `venv` folder to version control
3. **Do commit** the `requirements.txt` file
4. **Update requirements.txt** after installing new packages:
   ```powershell
   pip freeze > requirements.txt
   ```
5. **Use descriptive project names** instead of generic names
6. **Use PowerShell** for better compatibility and features

## Git Configuration

If using Git, create a `.gitignore` file:

```
# .gitignore
venv/
__pycache__/
*.pyc
.idea/
.vscode/
```

## Using Different Python Versions

If you have multiple Python versions installed:

```powershell
# Use specific Python version
py -3.11 -m venv venv
py -3.12 -m venv venv

# Check available Python versions
py --list
```

## Creating Desktop Shortcut (Optional)

Create a batch file `activate_env.bat`:

```batch
@echo off
cd /d C:\spark-project
call venv\Scripts\activate.bat
cmd /k
```

Double-click this file to open a command prompt with the environment activated.

## Additional Resources

- [Python Virtual Environments Documentation](https://docs.python.org/3/library/venv.html)
- [PySpark Documentation](https://spark.apache.org/docs/latest/api/python/)
- [pip Documentation](https://pip.pypa.io/en/stable/)
- [Python Downloads](https://www.python.org/downloads/)

## Quick Reference Card

| Task | PowerShell | Command Prompt |
|------|-----------|----------------|
| Create venv | `python -m venv venv` | `python -m venv venv` |
| Activate | `.\venv\Scripts\Activate.ps1` | `venv\Scripts\activate.bat` |
| Deactivate | `deactivate` | `deactivate` |
| Install package | `pip install package_name` | `pip install package_name` |
| List packages | `pip list` | `pip list` |
| Save requirements | `pip freeze > requirements.txt` | `pip freeze > requirements.txt` |
