# Apache Spark 4.1.0 Quick Setup Guide
## Ubuntu 24.04 | Python Virtual Environment | PySpark | Jupyter

**Platform:** Ubuntu 24.04 LTS  
**Components:** Java 17, Apache Spark 4.1.0, PySpark 4.1.0, Jupyter  
**Approach:** Virtual Environment (Best Practice)

---

## 📋 PREREQUISITES CHECK

```bash
# Verify Ubuntu version
lsb_release -a  # Should show 24.04

# Check Python (comes pre-installed)
python3 --version  # Should show 3.12.x

# Check available disk space (need 10GB+)
df -h ~

# Check RAM (need 4GB+)
free -h
```

---

## ⚡ QUICK INSTALLATION

### STEP 1: Install Java 17

```bash
# Update system
sudo apt update

# Install Java 17
sudo apt install openjdk-17-jdk openjdk-17-jre -y

# Set as default (if you have Java 25)
sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Verify
java -version  # Should show Java 17
```

---

### STEP 2: Install Apache Spark 4.1.0

```bash
# Download Spark 4.1.0
cd ~
wget https://dlcdn.apache.org/spark/spark-4.1.0/spark-4.1.0-bin-hadoop3.tgz

# Extract and install
tar -xzf spark-4.1.0-bin-hadoop3.tgz
sudo mv spark-4.1.0-bin-hadoop3 /opt/spark
sudo chown -R $USER:$USER /opt/spark

# Set environment variables
cat >> ~/.bashrc << 'EOF'
export SPARK_HOME=/opt/spark
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
export PYSPARK_PYTHON=python3
EOF
source ~/.bashrc

# Verify
spark-shell --version  # Should show 4.1.0
```

---

### STEP 3: Setup Python Virtual Environment

```bash
# Install required packages
sudo apt install python3-pip python3-venv python3-dev build-essential -y

# Create project directory
mkdir -p ~/spark-project
cd ~/spark-project

# Create virtual environment
python3 -m venv spark-env

# Create activation alias
echo "alias spark-activate='source ~/spark-project/spark-env/bin/activate'" >> ~/.bashrc
source ~/.bashrc

# Activate virtual environment
spark-activate

# Verify
echo $VIRTUAL_ENV  # Should show ~/spark-project/spark-env
```

---

### STEP 4: Install PySpark & Libraries

**Make sure virtual environment is activated!**

```bash
# Activate if not already active
spark-activate

# Install PySpark 4.1.0 (matching Spark version)
pip3 install pyspark==4.1.0

# Install data science libraries
pip3 install numpy pandas pyarrow matplotlib seaborn

# Install Jupyter
pip3 install jupyter jupyterlab ipython ipywidgets

# Save requirements
pip3 freeze > ~/spark-project/requirements.txt

# Verify
python3 -c "import pyspark; print(f'PySpark: {pyspark.__version__}')"
```

---

### STEP 5: Setup Jupyter Notebooks

```bash
# Create notebooks directory
mkdir -p ~/spark-project/notebooks

# Create startup script
cat > ~/spark-project/start-jupyter.sh << 'EOF'
#!/bin/bash
source ~/spark-project/spark-env/bin/activate
cd ~/spark-project/notebooks
jupyter lab
EOF

chmod +x ~/spark-project/start-jupyter.sh
```

---

## ✅ VERIFICATION TEST

```bash
# Activate environment
spark-activate

# Run comprehensive test
python3 << 'EOF'
from pyspark.sql import SparkSession

print("\n" + "="*50)
print("TESTING SPARK SETUP")
print("="*50)

# Create Spark session
spark = SparkSession.builder \
    .appName("QuickTest") \
    .master("local[*]") \
    .getOrCreate()

print(f"✓ Spark Version: {spark.version}")

# Test DataFrame
data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
df = spark.createDataFrame(data, ["Name", "Age"])
df.show()

print(f"✓ Test passed! Spark is working.")
print(f"✓ Spark UI: http://localhost:4040")
print("="*50 + "\n")

spark.stop()
EOF
```

**Expected output:**
```
==================================================
TESTING SPARK SETUP
==================================================
✓ Spark Version: 4.1.0

+-------+---+
|   Name|Age|
+-------+---+
|  Alice| 25|
|    Bob| 30|
|Charlie| 35|
+-------+---+

✓ Test passed! Spark is working.
✓ Spark UI: http://localhost:4040
==================================================
```

---

## 🚀 DAILY USAGE

### Start Working

```bash
# Method 1: Manual
spark-activate
cd ~/spark-project/notebooks
jupyter lab

# Method 2: Startup script
~/spark-project/start-jupyter.sh
```

### Test in Jupyter Notebook

**Create new notebook, run these cells:**

```python
# Cell 1: Import and verify
from pyspark.sql import SparkSession
import pyspark

print(f"PySpark: {pyspark.__version__}")

# Cell 2: Create Spark session
spark = SparkSession.builder \
    .appName("MyNotebook") \
    .master("local[*]") \
    .getOrCreate()

print(f"Spark Version: {spark.version}")

# Cell 3: Create DataFrame
data = [("Alice", 25), ("Bob", 30)]
df = spark.createDataFrame(data, ["Name", "Age"])
df.show()
```

### Stop Working

```bash
# In terminal: Ctrl+C to stop Jupyter
# Then: deactivate (to exit virtual environment)
deactivate
```

---

## 📁 PROJECT STRUCTURE

```
~/spark-project/
├── spark-env/              # Virtual environment (all packages here)
├── notebooks/              # Your Jupyter notebooks
├── requirements.txt        # Package list
└── start-jupyter.sh        # Startup script
```

---

## 🔧 QUICK TROUBLESHOOTING

### Issue: "ModuleNotFoundError: No module named 'pyspark'"
```bash
spark-activate  # Activate virtual environment first!
pip3 install pyspark==4.1.0
```

### Issue: Jupyter can't find PySpark
```bash
spark-activate
pip3 install jupyter jupyterlab
# Restart Jupyter
```

### Issue: Wrong Java version
```bash
java -version  # Check current version
sudo update-alternatives --config java  # Select Java 17
```

### Issue: Command 'spark-shell' not found
```bash
echo $SPARK_HOME  # Should show /opt/spark
source ~/.bashrc  # Reload environment
```

---

## 📦 ENVIRONMENT VARIABLES SUMMARY

Add to `~/.bashrc`:

```bash
# Java
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Spark
export SPARK_HOME=/opt/spark
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
export PYSPARK_PYTHON=python3

# Virtual environment alias
alias spark-activate='source ~/spark-project/spark-env/bin/activate'
```

---

## ✅ INSTALLATION CHECKLIST

- [ ] Java 17 installed and active (`java -version`)
- [ ] JAVA_HOME set (`echo $JAVA_HOME`)
- [ ] Spark 4.1.0 installed (`spark-shell --version`)
- [ ] SPARK_HOME set (`echo $SPARK_HOME`)
- [ ] Virtual environment created (`ls ~/spark-project/spark-env`)
- [ ] Can activate venv (`spark-activate`)
- [ ] PySpark 4.1.0 installed in venv (`pip3 show pyspark`)
- [ ] Jupyter installed in venv (`which jupyter`)
- [ ] Test script passes (see Verification Test above)
- [ ] Can create DataFrames in Jupyter

---

## 🎯 NEXT STEPS

1. **Practice basics:** Create DataFrames, filters, transformations
2. **Learn Spark SQL:** Query data with SQL syntax
3. **Work with files:** Read CSV, JSON, Parquet
4. **Explore Spark UI:** Monitor jobs at http://localhost:4040
5. **Move to Databricks:** Same PySpark API, managed clusters

---

## 📚 QUICK REFERENCE

**Activate environment:**
```bash
spark-activate
```

**Start Jupyter:**
```bash
~/spark-project/start-jupyter.sh
```

**Install new package (in venv):**
```bash
spark-activate
pip3 install package-name
pip3 freeze > ~/spark-project/requirements.txt
```

**Check installed packages:**
```bash
spark-activate
pip3 list
```

**Recreate environment:**
```bash
python3 -m venv ~/spark-project/new-env
source ~/spark-project/new-env/bin/activate
pip3 install -r ~/spark-project/requirements.txt
```

---

## 🌐 RESOURCES

- **Spark Docs:** https://spark.apache.org/docs/4.1.0/
- **PySpark API:** https://spark.apache.org/docs/4.1.0/api/python/
- **Examples:** https://github.com/apache/spark/tree/v4.1.0/examples/src/main/python
- **Databricks:** https://www.databricks.com/learn

---

**Quick Setup Guide v1.0**  
**Updated:** December 26, 2024  
**For:** Ubuntu 24.04 LTS + Spark 4.1.0 + Python 3.12 + Virtual Environment
