# Python Virtual Environment Setup - Ubuntu 24.04

This guide will help you set up a Python virtual environment for Spark projects on Ubuntu 24.04.

## Prerequisites

- Ubuntu 24.04
- Terminal access
- sudo privileges

## Step-by-Step Setup

### 1. Install Required Packages

```bash
sudo apt update
sudo apt install python3-pip python3-venv python3-dev build-essential -y
```

**What this installs:**
- `python3-pip` - Package installer for Python
- `python3-venv` - Virtual environment module
- `python3-dev` - Python development headers
- `build-essential` - Compilation tools

### 2. Create Project Directory

```bash
mkdir -p ~/spark-project
cd ~/spark-project
```

**Note:** You can replace `spark-project` with your preferred project name.

### 3. Create Virtual Environment

```bash
python3 -m venv venv
```

This creates a folder named `venv` containing the isolated Python environment.

### 4. Activate Virtual Environment

```bash
source venv/bin/activate
```

**You'll know it's activated when:**
- Your terminal prompt shows `(venv)` at the beginning
- Example: `(venv) user@hostname:~/spark-project$`

### 5. Upgrade pip

```bash
pip install --upgrade pip
```

### 6. Install Packages

```bash
pip install pyspark jupyter pandas numpy
```

**Common packages:**
- `pyspark` - Apache Spark Python API
- `jupyter` - Jupyter Notebook
- `pandas` - Data manipulation library
- `numpy` - Numerical computing library

### 7. Save Requirements

```bash
pip freeze > requirements.txt
```

This creates a file listing all installed packages and versions.

### 8. Deactivate Virtual Environment

```bash
deactivate
```

Run this when you're done working on your project.

## Daily Usage

### Starting Work

```bash
cd ~/spark-project
source venv/bin/activate
```

### Finishing Work

```bash
deactivate
```

## Import into PyCharm

### Method 1: Open Project

1. Open PyCharm
2. Click **File → Open**
3. Navigate to `~/spark-project`
4. Click **OK**

### Method 2: Configure Interpreter (if needed)

1. **File → Settings** (Ctrl+Alt+S)
2. Navigate to **Project → Python Interpreter**
3. Click the **gear icon** → **Add Interpreter** → **Add Local Interpreter**
4. Select **Existing environment**
5. Click **...** and navigate to:
   ```
   ~/spark-project/venv/bin/python3
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

```bash
# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install all packages from requirements.txt
pip install -r requirements.txt
```

## Troubleshooting

### Error: "externally-managed-environment"

**Solution:** Make sure you've activated the virtual environment first with `source venv/bin/activate`

### Error: "source: not found"

**Solution:** Make sure you're using bash, not sh:
```bash
bash
source venv/bin/activate
```

### Permission Denied

**Solution:** Ensure you have write permissions to the project directory:
```bash
chmod -R u+w ~/spark-project
```

## Useful Commands

```bash
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
```

## Directory Structure

After setup, your project will look like this:

```
~/spark-project/
├── venv/                 # Virtual environment (don't commit to git)
│   ├── bin/
│   ├── lib/
│   └── ...
└── requirements.txt      # List of installed packages
```

## Best Practices

1. **Always activate** the virtual environment before working
2. **Don't commit** the `venv` folder to version control
3. **Do commit** the `requirements.txt` file
4. **Update requirements.txt** after installing new packages:
   ```bash
   pip freeze > requirements.txt
   ```
5. **Use descriptive project names** instead of generic names

## Additional Resources

- [Python Virtual Environments Documentation](https://docs.python.org/3/library/venv.html)
- [PySpark Documentation](https://spark.apache.org/docs/latest/api/python/)
- [pip Documentation](https://pip.pypa.io/en/stable/)
