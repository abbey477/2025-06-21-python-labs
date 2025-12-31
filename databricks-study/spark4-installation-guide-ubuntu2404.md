# Apache Spark 4 Installation Checklist & Validation Guide
## Ubuntu 24.04 LTS | PySpark | Jupyter Notebook

**Date:** December 26, 2024  
**Target:** Local laptop setup for learning Spark before Databricks  
**Ubuntu Version:** 24.04 LTS (Noble Numbat)

---

## 📋 PRE-INSTALLATION CHECKLIST

### System Requirements
- [ ] Ubuntu 24.04 LTS (Noble Numbat)
- [ ] Minimum 4GB RAM (8GB+ recommended for Spark)
- [ ] Minimum 10GB free disk space (15GB recommended)
- [ ] Internet connection for downloads
- [ ] Terminal/shell access (Ctrl+Alt+T)
- [ ] User account with sudo privileges

### Ubuntu 24.04 Specifics
**What comes pre-installed on Ubuntu 24.04:**
- ✅ Python 3.12.3 (system default)
- ✅ No Python 2 (completely removed in 24.04)
- ✅ Basic build tools (may need updates)
- ⚠️ No Java by default (you have Java 25 installed)

### Current System Status
Check what's already installed:

```bash
# Check Ubuntu version (should show 24.04 LTS Noble Numbat)
lsb_release -a

# Check current Java version (you have Java 25 LTS)
java -version

# Check Python version (should show Python 3.12.x)
python3 --version

# Check if pip is installed
pip3 --version

# Check available disk space (need at least 10GB free)
df -h ~

# Check available memory (need at least 4GB)
free -h

# Check CPU cores (Spark can use all cores)
nproc
```

### Ubuntu 24.04 Important Notes
⚠️ **PEP 668 Compliance:** Ubuntu 24.04 follows PEP 668, which prevents pip from installing packages system-wide to avoid conflicts. We'll use the `--break-system-packages` flag or virtual environments.

---

## 🎯 INSTALLATION PLAN

### Component Versions to Install

| Component | Version | Status |
|-----------|---------|--------|
| Java JDK | 17 LTS (alongside Java 25) | ⬜ Not Installed |
| Python | 3.12 (system default) | ⬜ To Verify |
| Apache Spark | 4.0.1 | ⬜ Not Installed |
| PySpark | 4.0.1 | ⬜ Not Installed |
| Jupyter Notebook | Latest | ⬜ Not Installed |
| pip | Latest | ⬜ To Verify |

---

## 📥 STEP 1: JAVA INSTALLATION & CONFIGURATION

### Ubuntu 24.04 Java Details
- **Your System:** Java 25 LTS (already installed)
- **Spark Requirement:** Java 17 LTS (need to install)
- **Package Name:** `openjdk-17-jdk` and `openjdk-17-jre`
- **Installation Path:** `/usr/lib/jvm/java-17-openjdk-amd64/`

### 1.1 Install Java 17 LTS (alongside your Java 25)

```bash
# Update package list (important for Ubuntu 24.04)
sudo apt update

# Install OpenJDK 17 JDK and JRE from official Ubuntu 24.04 repositories
sudo apt install openjdk-17-jdk openjdk-17-jre -y

# Wait for installation to complete
```

**Validation:**
```bash
# List all installed Java versions
ls /usr/lib/jvm/

# You should see both:
# - java-17-openjdk-amd64
# - java-25-openjdk-amd64 (your existing installation)

# Check currently active Java version
java -version
```

### 1.2 Configure Java Alternatives (Switch between Java versions)

Ubuntu 24.04 uses the `update-alternatives` system to manage multiple Java versions:

```bash
# Configure default Java runtime (java command)
sudo update-alternatives --config java

# You will see a menu like this:
# Selection    Path                                         Priority
# 0            /usr/lib/jvm/java-25-openjdk-amd64/bin/java   2511
# 1            /usr/lib/jvm/java-17-openjdk-amd64/bin/java   1711
# 2            /usr/lib/jvm/java-25-openjdk-amd64/bin/java   2511

# Type the number for Java 17 (usually option 1) and press Enter

# Also configure Java compiler (javac command)
sudo update-alternatives --config javac

# Again, select Java 17
```

**Alternative Method - Set Java 17 directly:**
```bash
# Set Java 17 as default without interactive prompt
sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
```

### 1.3 Set JAVA_HOME Environment Variable

```bash
# Edit your bash configuration file
nano ~/.bashrc

# Scroll to the end of the file and add these lines:
# ========== Java Configuration for Spark ==========
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
# ==================================================

# Save and exit:
# Press Ctrl+X, then Y, then Enter

# Reload the configuration immediately
source ~/.bashrc
```

**Alternative - Add to .profile for all shells:**
```bash
# If you use other shells besides bash, add to .profile too
nano ~/.profile

# Add the same JAVA_HOME lines at the end
# Save and exit (Ctrl+X, Y, Enter)

# Reload
source ~/.profile
```

**Validation:**
```bash
# Verify JAVA_HOME is set correctly
echo $JAVA_HOME
# Expected: /usr/lib/jvm/java-17-openjdk-amd64

# Verify Java version is 17 (not 25)
java -version
# Expected output (first line):
# openjdk version "17.0.x" 2024-xx-xx

# Verify javac (compiler) is also Java 17
javac -version
# Expected: javac 17.0.x

# Verify PATH includes Java 17
which java
# Expected: /usr/lib/jvm/java-17-openjdk-amd64/bin/java

# Complete verification
java -version 2>&1 | head -1
```

**Expected Full Output:**
```
openjdk version "17.0.13" 2024-10-15
OpenJDK Runtime Environment (build 17.0.13+11-Ubuntu-2ubuntu124.04)
OpenJDK 64-Bit Server VM (build 17.0.13+11-Ubuntu-2ubuntu124.04, mixed mode, sharing)
```

### 1.4 How to Switch Back to Java 25 (When Needed)

If you need to use Java 25 for other projects:

```bash
# Switch to Java 25
sudo update-alternatives --set java /usr/lib/jvm/java-25-openjdk-amd64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-25-openjdk-amd64/bin/javac

# Update JAVA_HOME (edit ~/.bashrc and change the path)
export JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64

# Reload
source ~/.bashrc
```

✅ **Checkpoint:** Java 17 LTS installed and configured as default

---

## 📥 STEP 2: PYTHON & PIP SETUP

### Ubuntu 24.04 Python Details
- **Pre-installed:** Python 3.12.3 (system default)
- **Python 2:** Completely removed (not available)
- **Command:** `python3` (no `/usr/bin/python` symlink by default)
- **Package Manager:** pip3 with PEP 668 restrictions

### 2.1 Verify Python 3.12 Installation

```bash
# Check Python version (should show 3.12.x)
python3 --version
# Expected: Python 3.12.3

# Check if python3 is available
which python3
# Expected: /usr/bin/python3

# Verify Python can run
python3 -c "print('Python is working!')"
```

### 2.2 Install pip3 for Python Package Management

Ubuntu 24.04 may not have pip installed by default:

```bash
# Install pip3 from official repositories
sudo apt install python3-pip -y

# Install python development headers (needed for some packages)
sudo apt install python3-dev -y

# Install venv for virtual environments (recommended)
sudo apt install python3-venv -y

# Install build essentials (needed for some Python packages)
sudo apt install build-essential -y
```

**Validation:**
```bash
# Check pip3 version
pip3 --version
# Expected: pip 24.x.x from /usr/lib/python3/dist-packages/pip (python 3.12)

# Check pip installation location
which pip3
# Expected: /usr/bin/pip3
```

### 2.3 Understanding PEP 668 in Ubuntu 24.04

⚠️ **Important:** Ubuntu 24.04 implements PEP 668 to prevent pip from modifying system Python packages. You have **three options** for installing Python packages:

#### **Option 1: Use --break-system-packages flag (Quick & Simple)**
Best for learning environments and single-user systems:

```bash
# Install packages with the flag
pip3 install pyspark==4.0.1 --break-system-packages
```

#### **Option 2: Use Virtual Environments (Recommended Best Practice)**
Best for isolated project environments:

```bash
# Create a virtual environment for Spark
python3 -m venv ~/spark-env

# Activate the virtual environment
source ~/spark-env/bin/activate

# Now pip works normally inside the venv
pip install pyspark==4.0.1

# Deactivate when done
deactivate
```

#### **Option 3: Use pipx (For Command-Line Tools)**
Best for installing applications like Jupyter:

```bash
# Install pipx
sudo apt install pipx -y

# Install applications
pipx install jupyter
```

### 2.4 Our Approach for This Tutorial

For simplicity in this learning setup, we'll use **Option 1** (--break-system-packages), which is acceptable for:
- ✅ Personal learning laptops
- ✅ Single-user development systems
- ✅ Non-production environments

We'll add the flag to pip commands or set it as an environment variable:

```bash
# Method A: Add flag to each pip command (we'll do this)
pip3 install package-name --break-system-packages

# Method B: Set environment variable (makes pip always use the flag)
echo 'export PIP_BREAK_SYSTEM_PACKAGES=1' >> ~/.bashrc
source ~/.bashrc
```

**Let's set the environment variable for convenience:**

```bash
# Edit .bashrc
nano ~/.bashrc

# Add this line at the end:
# ========== Python/Pip Configuration ==========
export PIP_BREAK_SYSTEM_PACKAGES=1
# =============================================

# Save and exit (Ctrl+X, Y, Enter)

# Reload configuration
source ~/.bashrc

# Verify
echo $PIP_BREAK_SYSTEM_PACKAGES
# Expected: 1
```

### 2.5 Upgrade pip to Latest Version

```bash
# Upgrade pip itself
pip3 install --upgrade pip

# Verify upgrade
pip3 --version
```

**Validation:**
```bash
# Verify Python 3.12 works
python3 -c "import sys; print(f'Python {sys.version}')"

# Verify pip works
pip3 list | head -5

# Test package installation (we'll uninstall immediately)
pip3 install --dry-run numpy
```

**Expected Output for Python:**
```
Python 3.12.3 (main, Nov  6 2024, 18:32:19) [GCC 13.2.0]
```

### 2.6 Install Essential Python Development Tools

```bash
# Install useful Python tools for development
pip3 install wheel setuptools

# Verify installations
python3 -c "import setuptools, wheel; print('Tools installed successfully')"
```

✅ **Checkpoint:** Python 3.12.3 and pip3 verified and configured for Ubuntu 24.04

---

## 📥 STEP 3: APACHE SPARK INSTALLATION

### 3.1 Download Apache Spark 4.0.1

```bash
# Create a directory for Spark
cd ~
mkdir -p spark-setup
cd spark-setup

# Download Spark 4.0.1 (pre-built with Hadoop 3)
wget https://dlcdn.apache.org/spark/spark-4.0.1/spark-4.0.1-bin-hadoop3.tgz

# Verify download (optional)
ls -lh spark-4.0.1-bin-hadoop3.tgz
```

### 3.2 Extract and Install Spark

```bash
# Extract the archive
tar -xzf spark-4.0.1-bin-hadoop3.tgz

# Move to a permanent location
sudo mv spark-4.0.1-bin-hadoop3 /opt/spark

# Create a symbolic link for easier updates
sudo ln -s /opt/spark /usr/local/spark

# Set proper permissions
sudo chown -R $USER:$USER /opt/spark
```

### 3.3 Configure Spark Environment Variables

```bash
# Open .bashrc file
nano ~/.bashrc

# Add these lines at the end (after JAVA_HOME section):
export SPARK_HOME=/opt/spark
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=python3

# Save and exit (Ctrl+X, then Y, then Enter)

# Reload the configuration
source ~/.bashrc
```

**Validation:**
```bash
# Verify SPARK_HOME is set
echo $SPARK_HOME

# Verify Spark binaries are in PATH
which spark-shell
which pyspark

# Test Spark installation
spark-shell --version
# Should show: version 4.0.1
```

**Expected Output:**
```
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 4.0.1
      /_/
                        
Using Scala version 2.13.x
```

**Test Basic Spark Functionality:**
```bash
# Quick test (this will start and exit immediately)
spark-shell --version 2>&1 | grep "version"
```

✅ **Checkpoint:** Apache Spark 4.0.1 installed

---

## 📥 STEP 4: PYSPARK INSTALLATION

### 4.1 Install PySpark 4.0.1 via pip3

Now we'll install PySpark using pip. Since we set `PIP_BREAK_SYSTEM_PACKAGES=1`, pip will work normally:

```bash
# Install PySpark 4.0.1 (must match Spark version exactly)
pip3 install pyspark==4.0.1

# This will download and install PySpark and its dependencies
# Wait for installation to complete (may take a few minutes)
```

### 4.2 Install Essential Data Science Libraries

Install additional Python libraries that work well with PySpark:

```bash
# Install NumPy (numerical computing)
pip3 install numpy

# Install Pandas (data manipulation)
pip3 install pandas

# Install PyArrow (columnar data format, used by Spark)
pip3 install pyarrow

# Install Matplotlib (plotting - optional but useful)
pip3 install matplotlib

# Install all at once (alternative):
pip3 install numpy pandas pyarrow matplotlib
```

**Installation Notes for Ubuntu 24.04:**
- These packages may take a few minutes to compile
- NumPy and Pandas require build tools (we installed them earlier)
- PyArrow is required for optimal Spark performance with Pandas

**Validation:**
```bash
# Verify PySpark installation
pip3 show pyspark

# Check installed version
pip3 show pyspark | grep Version
# Expected: Version: 4.0.1

# List all installed packages
pip3 list | grep -E "pyspark|numpy|pandas|pyarrow"
```

**Expected Output:**
```
Name: pyspark
Version: 4.0.1
Summary: Apache Spark Python API
Home-page: https://github.com/apache/spark/tree/master/python
Author: Spark Developers
Author-email: dev@spark.apache.org
License: http://www.apache.org/licenses/LICENSE-2.0
Location: /usr/local/lib/python3.12/dist-packages
Requires: py4j
Required-by:
```

### 4.3 Test PySpark Import

```bash
# Test PySpark can be imported
python3 -c "import pyspark; print(f'PySpark Version: {pyspark.__version__}')"
# Expected: PySpark Version: 4.0.1

# Test PySpark can find Spark installation
python3 -c "from pyspark.sql import SparkSession; print('PySpark imports successfully!')"
# Expected: PySpark imports successfully!

# Verify all data libraries
python3 << 'EOF'
import pyspark
import numpy
import pandas
import pyarrow
print(f"✓ PySpark {pyspark.__version__}")
print(f"✓ NumPy {numpy.__version__}")
print(f"✓ Pandas {pandas.__version__}")
print(f"✓ PyArrow {pyarrow.__version__}")
EOF
```

### 4.4 Advanced Validation - Test PySpark with Python Script

Create a quick test to ensure PySpark can access Spark:

```bash
# Create a test script
python3 << 'EOF'
from pyspark import SparkConf, SparkContext

try:
    # Create Spark configuration
    conf = SparkConf().setAppName("QuickTest").setMaster("local[*]")
    sc = SparkContext(conf=conf)
    
    # Create a simple RDD
    data = [1, 2, 3, 4, 5]
    rdd = sc.parallelize(data)
    
    # Perform a simple operation
    result = rdd.map(lambda x: x * 2).collect()
    
    print(f"✓ PySpark is working correctly!")
    print(f"✓ Test result: {result}")
    
    sc.stop()
except Exception as e:
    print(f"✗ Error: {e}")
EOF
```

**Expected Output:**
```
✓ PySpark is working correctly!
✓ Test result: [2, 4, 6, 8, 10]
```

✅ **Checkpoint:** PySpark 4.0.1 and data science libraries installed on Ubuntu 24.04

---

## 📥 STEP 5: JUPYTER NOTEBOOK INSTALLATION

### Ubuntu 24.04 Jupyter Notes
- Jupyter works well with Python 3.12
- We'll install using pip3 (with our PIP_BREAK_SYSTEM_PACKAGES setting)
- Jupyter will automatically detect our Python 3.12 kernel

### 5.1 Install Jupyter Notebook and JupyterLab

```bash
# Install Jupyter Notebook (classic interface)
pip3 install jupyter notebook

# Install JupyterLab (modern interface - optional)
pip3 install jupyterlab

# Install IPython (enhanced interactive Python shell)
pip3 install ipython

# Install Jupyter widgets for interactive visualizations
pip3 install ipywidgets

# Install all at once (alternative):
pip3 install jupyter notebook jupyterlab ipython ipywidgets
```

**Installation may take a few minutes on Ubuntu 24.04.**

**Validation:**
```bash
# Verify Jupyter installation
jupyter --version

# Check Jupyter Notebook
jupyter notebook --version

# Check JupyterLab (if installed)
jupyter lab --version

# List installed Jupyter kernels
jupyter kernelspec list
```

**Expected Output:**
```
Selected Jupyter core packages...
IPython          : 8.x.x
ipykernel        : 6.x.x
ipywidgets       : 8.x.x
jupyter_client   : 8.x.x
jupyter_core     : 5.x.x
jupyter_server   : 2.x.x
jupyterlab       : 4.x.x
nbclient         : 0.x.x
nbconvert        : 7.x.x
nbformat         : 5.x.x
notebook         : 7.x.x
```

### 5.2 Test Jupyter Notebook Launch

```bash
# Test Jupyter Notebook (will open in browser)
# This is just a test - press Ctrl+C in terminal to stop it
jupyter notebook --no-browser

# You should see output like:
# [I 2024-12-26 10:30:00.000 ServerApp] Jupyter Server is running at:
# [I 2024-12-26 10:30:00.000 ServerApp] http://localhost:8888/tree?token=...

# Press Ctrl+C to stop the test
```

### 5.3 Configure PySpark for Jupyter (Method 1 - Direct Integration)

**Option A: Configure for automatic Jupyter launch with pyspark command**

Add these environment variables to make `pyspark` command automatically launch Jupyter:

```bash
# Edit .bashrc
nano ~/.bashrc

# Add these lines at the end (in the Spark section):
# ========== PySpark-Jupyter Integration ==========
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
# Or for JupyterLab:
# export PYSPARK_DRIVER_PYTHON_OPTS='lab'
# ================================================

# Save and exit (Ctrl+X, Y, Enter)

# Reload
source ~/.bashrc
```

**Note:** With these settings, typing `pyspark` in terminal will launch Jupyter Notebook instead of the PySpark shell. To use the regular PySpark shell, you'll need to temporarily unset these variables.

### 5.4 Configure PySpark for Jupyter (Method 2 - Manual, More Flexible)

**Option B: Keep pyspark as shell, use jupyter manually** (Recommended)

If you prefer to keep `pyspark` as a command-line shell and manually start Jupyter when needed:

```bash
# Edit .bashrc
nano ~/.bashrc

# Add only these (remove or comment out PYSPARK_DRIVER_PYTHON if added):
# ========== PySpark Configuration ==========
export PYSPARK_PYTHON=python3
# ==========================================

# Save and exit (Ctrl+X, Y, Enter)

# Reload
source ~/.bashrc
```

With this method:
- `pyspark` → Opens PySpark shell
- `jupyter notebook` → Opens Jupyter, and you manually import PySpark

### 5.5 Create Jupyter Configuration (Optional but Recommended)

```bash
# Generate Jupyter configuration file
jupyter notebook --generate-config

# The config file is created at: ~/.jupyter/jupyter_notebook_config.py

# Optional: Set notebook directory
mkdir -p ~/spark-notebooks

# Edit config to set default directory (optional)
nano ~/.jupyter/jupyter_notebook_config.py

# Find and uncomment/modify this line:
# c.ServerApp.notebook_dir = '/home/yourusername/spark-notebooks'

# Save and exit
```

### 5.6 Verify Jupyter Can Import PySpark

```bash
# Create a test notebook directory
mkdir -p ~/spark-notebooks
cd ~/spark-notebooks

# Start Jupyter Notebook (will open in default browser)
jupyter notebook

# In the browser:
# 1. Click "New" → "Python 3"
# 2. In the first cell, type:
#    import pyspark
#    print(pyspark.__version__)
# 3. Press Shift+Enter to run
# 4. You should see: 4.0.1
```

### 5.7 Ubuntu 24.04 Browser Considerations

If Jupyter doesn't open in your browser automatically:

```bash
# Start Jupyter and copy the URL manually
jupyter notebook --no-browser

# Copy the URL shown (looks like http://localhost:8888/?token=...)
# Paste it into your browser (Firefox, Chrome, etc.)

# Or specify a browser:
BROWSER=firefox jupyter notebook
```

✅ **Checkpoint:** Jupyter Notebook installed and can import PySpark on Ubuntu 24.04

---

## ✅ STEP 6: COMPREHENSIVE VALIDATION TESTS

### 6.1 System Environment Validation

Create and run this validation script:

```bash
# Create validation script
cat > ~/validate-spark-setup.sh << 'EOF'
#!/bin/bash

echo "=========================================="
echo "SPARK 4.0.1 INSTALLATION VALIDATION"
echo "=========================================="
echo ""

echo "1. Java Version:"
java -version 2>&1 | head -1
echo ""

echo "2. Python Version:"
python3 --version
echo ""

echo "3. Pip Version:"
pip3 --version
echo ""

echo "4. Environment Variables:"
echo "   JAVA_HOME: $JAVA_HOME"
echo "   SPARK_HOME: $SPARK_HOME"
echo "   PYSPARK_PYTHON: $PYSPARK_PYTHON"
echo ""

echo "5. Spark Installation:"
ls -ld /opt/spark 2>/dev/null && echo "   ✓ Spark directory exists" || echo "   ✗ Spark directory missing"
echo ""

echo "6. PySpark Version:"
python3 -c "import pyspark; print('   ' + pyspark.__version__)"
echo ""

echo "7. Jupyter Installation:"
jupyter --version 2>&1 | head -1
echo ""

echo "8. Required Python Packages:"
for pkg in pyspark numpy pandas pyarrow; do
    python3 -c "import $pkg; print('   ✓ $pkg installed')" 2>/dev/null || echo "   ✗ $pkg missing"
done
echo ""

echo "=========================================="
echo "VALIDATION COMPLETE"
echo "=========================================="
EOF

# Make it executable
chmod +x ~/validate-spark-setup.sh

# Run the validation
~/validate-spark-setup.sh
```

### 6.2 PySpark Functionality Test

Create a simple Python test:

```bash
# Create a test script
cat > ~/test-pyspark.py << 'EOF'
#!/usr/bin/env python3

print("Testing PySpark Installation...")
print("=" * 50)

try:
    from pyspark.sql import SparkSession
    
    # Create Spark session
    spark = SparkSession.builder \
        .appName("InstallationTest") \
        .master("local[*]") \
        .getOrCreate()
    
    print("✓ Spark Session created successfully")
    print(f"✓ Spark Version: {spark.version}")
    print(f"✓ Master URL: {spark.sparkContext.master}")
    
    # Create a simple DataFrame
    data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
    columns = ["Name", "Age"]
    df = spark.createDataFrame(data, columns)
    
    print("✓ DataFrame created successfully")
    print("\nSample Data:")
    df.show()
    
    # Perform a simple operation
    result = df.filter(df.Age > 25).count()
    print(f"✓ Filter operation successful: {result} rows with Age > 25")
    
    # Stop the session
    spark.stop()
    print("\n✓ All tests passed!")
    print("=" * 50)
    
except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()
EOF

# Make it executable
chmod +x ~/test-pyspark.py

# Run the test
python3 ~/test-pyspark.py
```

**Expected Output:**
```
Testing PySpark Installation...
==================================================
✓ Spark Session created successfully
✓ Spark Version: 4.0.1
✓ Master URL: local[*]
✓ DataFrame created successfully

Sample Data:
+-------+---+
|   Name|Age|
+-------+---+
|  Alice| 25|
|    Bob| 30|
|Charlie| 35|
+-------+---+

✓ Filter operation successful: 2 rows with Age > 25

✓ All tests passed!
==================================================
```

### 6.3 Jupyter Notebook Test

```bash
# Create a test notebook directory
mkdir -p ~/spark-notebooks
cd ~/spark-notebooks

# Start Jupyter Notebook (will open in browser)
jupyter notebook
```

In the Jupyter Notebook interface:
1. Create a new Python 3 notebook
2. Run this code in the first cell:

```python
from pyspark.sql import SparkSession

# Create Spark Session
spark = SparkSession.builder \
    .appName("JupyterTest") \
    .master("local[*]") \
    .getOrCreate()

print(f"Spark Version: {spark.version}")

# Create test DataFrame
data = [(1, "A"), (2, "B"), (3, "C")]
df = spark.createDataFrame(data, ["id", "letter"])
df.show()

# Check Spark UI
print(f"Spark UI available at: http://localhost:4040")
```

3. Expected output: DataFrame displays correctly in Jupyter

✅ **Checkpoint:** All components validated and working

---

## 🎯 QUICK REFERENCE COMMANDS

### Start PySpark Shell
```bash
# Basic PySpark shell
pyspark

# PySpark with custom configuration
pyspark --master local[4] --driver-memory 4g
```

### Start Jupyter Notebook with PySpark
```bash
# Method 1: Using environment variables (if configured)
pyspark

# Method 2: Direct Jupyter start
jupyter notebook
```

### Check Versions
```bash
# Java
java -version

# Python
python3 --version

# Spark
spark-shell --version

# PySpark
python3 -c "import pyspark; print(pyspark.__version__)"

# Jupyter
jupyter --version
```

### Switch Java Versions (if needed)
```bash
# Interactive selection
sudo update-alternatives --config java

# Set back to Java 25
sudo update-alternatives --set java /usr/lib/jvm/java-25-openjdk-amd64/bin/java
```

---

## 🔧 TROUBLESHOOTING CHECKLIST

### Common Issues and Solutions (Ubuntu 24.04 Specific)

#### ❌ Issue: "error: externally-managed-environment"
**Cause:** Ubuntu 24.04 PEP 668 protection
**Solution:**
```bash
# Method 1: Use --break-system-packages flag
pip3 install package-name --break-system-packages

# Method 2: Set environment variable (we did this)
export PIP_BREAK_SYSTEM_PACKAGES=1

# Method 3: Use virtual environment (best practice)
python3 -m venv myenv
source myenv/bin/activate
pip install package-name
```

#### ❌ Issue: "JAVA_HOME is not set"
**Solution:**
```bash
# Check if JAVA_HOME is set
echo $JAVA_HOME

# If empty, add to ~/.bashrc:
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
source ~/.bashrc

# Verify
echo $JAVA_HOME
```

#### ❌ Issue: "Command 'pyspark' not found"
**Solution:**
```bash
# Verify SPARK_HOME
echo $SPARK_HOME

# If empty, add to ~/.bashrc:
export SPARK_HOME=/opt/spark
export PATH=$SPARK_HOME/bin:$PATH
source ~/.bashrc

# Verify
which pyspark
```

#### ❌ Issue: Wrong Java version (shows Java 25 instead of 17)
**Solution:**
```bash
# Check current Java
java -version

# Switch to Java 17
sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

# Verify
java -version
```

#### ❌ Issue: "Python version mismatch"
**Solution:**
```bash
# Ubuntu 24.04 uses Python 3.12
# Ensure PYSPARK_PYTHON points to python3
export PYSPARK_PYTHON=python3

# Verify
python3 --version
```

#### ❌ Issue: "Py4J error" or "Cannot find Spark"
**Solution:**
```bash
# Ensure PySpark version matches Spark version
pip3 show pyspark | grep Version

# If mismatch, reinstall matching version
pip3 uninstall pyspark -y
pip3 install pyspark==4.0.1

# Verify
python3 -c "import pyspark; print(pyspark.__version__)"
```

#### ❌ Issue: Jupyter cannot import PySpark
**Solution:**
```bash
# Make sure PySpark is installed for the same Python
which python3
pip3 show pyspark

# Reinstall if needed
pip3 install --force-reinstall pyspark==4.0.1

# Restart Jupyter kernel (in Jupyter: Kernel → Restart)
```

#### ❌ Issue: "Permission denied" when accessing /opt/spark
**Solution:**
```bash
# Fix ownership
sudo chown -R $USER:$USER /opt/spark

# Verify
ls -ld /opt/spark
```

#### ❌ Issue: Jupyter doesn't open in browser
**Solution:**
```bash
# Ubuntu 24.04 may have different default browser
# Method 1: Start without browser and copy URL
jupyter notebook --no-browser

# Copy the URL (http://localhost:8888/?token=...) and paste in browser

# Method 2: Specify browser explicitly
BROWSER=firefox jupyter notebook
# or
BROWSER=google-chrome jupyter notebook
```

#### ❌ Issue: "bash: /opt/spark/bin/pyspark: No such file or directory"
**Solution:**
```bash
# Check Spark installation
ls -la /opt/spark/bin/

# If directory doesn't exist, Spark wasn't installed correctly
# Verify extraction:
ls -la ~/spark-setup/

# Re-extract if needed:
cd ~/spark-setup
sudo rm -rf /opt/spark
tar -xzf spark-4.0.1-bin-hadoop3.tgz
sudo mv spark-4.0.1-bin-hadoop3 /opt/spark
```

#### ❌ Issue: Slow pip install on Ubuntu 24.04
**Solution:**
```bash
# Ubuntu 24.04 builds some packages from source
# Install pre-compiled dependencies:
sudo apt install python3-numpy python3-pandas -y

# Then install PySpark
pip3 install pyspark==4.0.1
```

#### ❌ Issue: "Could not find or load main class org.apache.spark.deploy.SparkSubmit"
**Solution:**
```bash
# Check SPARK_HOME
echo $SPARK_HOME

# Verify Spark files exist
ls $SPARK_HOME/jars/ | head

# If empty, reinstall Spark
```

### Ubuntu 24.04 Specific Notes

**Memory Warnings:**
If you see warnings about memory when running Spark:
```bash
# Check available memory
free -h

# Adjust Spark memory settings (if needed)
# In ~/.bashrc, add:
export SPARK_DRIVER_MEMORY=2g
export SPARK_EXECUTOR_MEMORY=2g
```

**Firewall Issues:**
If Spark UI (localhost:4040) doesn't work:
```bash
# Ubuntu 24.04 firewall shouldn't block localhost by default
# But verify:
sudo ufw status

# If active and blocking, allow local connections:
sudo ufw allow from 127.0.0.1
```

---

## 📝 INSTALLATION SUMMARY CHECKLIST

Use this final checklist to confirm everything is ready on **Ubuntu 24.04 LTS**:

### Core Components
- [ ] **Java 17 LTS** installed from Ubuntu repositories (`openjdk-17-jdk`)
- [ ] Java 17 set as default (not Java 25)
- [ ] JAVA_HOME environment variable set to `/usr/lib/jvm/java-17-openjdk-amd64`
- [ ] Can switch between Java 17 and Java 25 using `update-alternatives`

### Python & Package Management
- [ ] **Python 3.12.3** working (Ubuntu 24.04 default)
- [ ] pip3 installed and working
- [ ] `PIP_BREAK_SYSTEM_PACKAGES=1` environment variable set (for Ubuntu 24.04 PEP 668)
- [ ] Can install packages with pip3 without errors

### Apache Spark
- [ ] **Apache Spark 4.0.1** extracted to `/opt/spark`
- [ ] SPARK_HOME environment variable set to `/opt/spark`
- [ ] Spark binaries (`pyspark`, `spark-shell`) in PATH
- [ ] Can run `spark-shell --version` successfully

### PySpark & Libraries
- [ ] **PySpark 4.0.1** installed via pip3 (matches Spark version)
- [ ] NumPy, Pandas, PyArrow installed
- [ ] PySpark can be imported in Python 3.12
- [ ] Can create SparkSession successfully

### Jupyter Notebook
- [ ] **Jupyter Notebook** (and optionally JupyterLab) installed
- [ ] Jupyter can launch in browser
- [ ] Python 3.12 kernel available in Jupyter
- [ ] Can import PySpark in Jupyter notebook

### Validation & Testing
- [ ] Validation script (`~/validate-spark-setup.sh`) runs without errors
- [ ] Test PySpark script (`~/test-pyspark.py`) completes successfully
- [ ] Can create and manipulate DataFrames in Jupyter
- [ ] Spark UI accessible at `http://localhost:4040`

### Environment Configuration (.bashrc)
Verify your `~/.bashrc` contains:
```bash
# ========== Java Configuration for Spark ==========
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# ========== Apache Spark Configuration ==========
export SPARK_HOME=/opt/spark
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
export PYSPARK_PYTHON=python3

# ========== Python/Pip Configuration (Ubuntu 24.04) ==========
export PIP_BREAK_SYSTEM_PACKAGES=1

# ========== Optional: PySpark-Jupyter Integration ==========
# Uncomment these if you want 'pyspark' command to launch Jupyter
# export PYSPARK_DRIVER_PYTHON=jupyter
# export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
```

### Quick Verification Commands
```bash
# All these should work without errors:
java -version                    # Should show Java 17
python3 --version               # Should show Python 3.12.3
pip3 --version                  # Should work without errors
echo $JAVA_HOME                 # Should show /usr/lib/jvm/java-17-openjdk-amd64
echo $SPARK_HOME                # Should show /opt/spark
which pyspark                   # Should find pyspark
python3 -c "import pyspark; print(pyspark.__version__)"  # Should show 4.0.1
jupyter --version               # Should show Jupyter version
```

---

## 🎓 NEXT STEPS

Once all checkboxes above are complete:

1. ✅ **Installation Complete on Ubuntu 24.04!**
2. 📚 **Ready for Sample Project** - Create PySpark tutorial notebooks
3. 🚀 **Start Learning** - Practice with Spark examples and transformations
4. 💡 **Explore Spark UI** - Learn to monitor jobs at `http://localhost:4040`
5. 🎯 **Future Goal** - Transition to Databricks (same PySpark API, easier cluster management)

### Recommended Learning Path
1. **Week 1:** Basic RDD operations and DataFrames
2. **Week 2:** Spark SQL and data transformations
3. **Week 3:** Working with different file formats (CSV, JSON, Parquet)
4. **Week 4:** Aggregations and window functions
5. **Week 5+:** Machine Learning with MLlib, then move to Databricks

---

## 📚 USEFUL RESOURCES FOR UBUNTU 24.04 + SPARK

### Official Documentation
- **Spark 4.0.1 Docs:** https://spark.apache.org/docs/4.0.1/
- **PySpark API Reference:** https://spark.apache.org/docs/4.0.1/api/python/
- **Spark Programming Guide:** https://spark.apache.org/docs/4.0.1/rdd-programming-guide.html
- **Spark SQL Guide:** https://spark.apache.org/docs/4.0.1/sql-programming-guide.html

### Code Examples & Tutorials
- **Spark Examples (GitHub):** https://github.com/apache/spark/tree/v4.0.1/examples/src/main/python
- **PySpark Tutorial:** https://spark.apache.org/docs/4.0.1/api/python/getting_started/index.html

### Databricks Learning (for later)
- **Databricks Learning:** https://www.databricks.com/learn
- **Databricks Community Edition:** https://community.cloud.databricks.com/ (Free tier)

### Ubuntu 24.04 Specific
- **Ubuntu Python Guide:** https://documentation.ubuntu.com/ubuntu-for-developers/reference/availability/python/
- **PEP 668 Explanation:** https://peps.python.org/pep-0668/

---

## 🔄 MAINTAINING YOUR SETUP

### Keep Your System Updated
```bash
# Update Ubuntu packages (monthly)
sudo apt update && sudo apt upgrade -y

# Update Python packages (as needed)
pip3 list --outdated
pip3 install --upgrade package-name

# Update Jupyter
pip3 install --upgrade jupyter jupyterlab
```

### Backup Your Configuration
```bash
# Backup your .bashrc
cp ~/.bashrc ~/.bashrc.backup

# Backup your Jupyter config
cp ~/.jupyter/jupyter_notebook_config.py ~/.jupyter/jupyter_notebook_config.py.backup
```

---

**Document Version:** 2.0 (Ubuntu 24.04 Optimized)  
**Last Updated:** December 26, 2024  
**Platform:** Ubuntu 24.04 LTS (Noble Numbat) + Apache Spark 4.0.1 + Python 3.12.3 + PySpark + Jupyter  
**Tested On:** Fresh Ubuntu 24.04 LTS installation
