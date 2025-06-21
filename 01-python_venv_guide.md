# Python Virtual Environments Guide for Java Developers (Linux)

## Overview: Java vs Python Dependency Management

In Java, you're used to having one JVM installation and managing dependencies per project using Maven or Gradle. Python works differently by default - it uses a single global interpreter where all packages are installed system-wide, leading to version conflicts between projects.

**Virtual environments solve this by creating isolated Python environments** - essentially giving each project its own Python interpreter with its own set of packages.

## The Problem Virtual Environments Solve

```bash
# Without venv - BAD
sudo pip install django==3.2    # Project A needs Django 3.2
sudo pip install django==4.1    # Project B needs Django 4.1 - CONFLICT!
```

This is like trying to use different versions of the same JAR in the same JVM classpath - it doesn't work.

## Basic Virtual Environment Workflow

### 1. Create a Virtual Environment

```bash
# Navigate to your project directory
cd /home/username/myproject

# Create virtual environment (like initializing a new Maven project)
python3 -m venv venv

# This creates a 'venv' directory with isolated Python installation
```

**What happens**: Creates a `venv/` folder containing:
- `bin/` - Python executable and activation scripts
- `lib/` - Isolated package installation directory
- `include/` - Header files
- `pyvenv.cfg` - Configuration file

### 2. Activate the Virtual Environment

```bash
# Activate (like switching to project context)
source venv/bin/activate

# Your prompt changes to show active environment
(venv) username@hostname:~/myproject$
```

**Key point**: This modifies your `PATH` so `python` and `pip` commands now point to the virtual environment versions.

### 3. Install Packages

```bash
# Now pip installs only affect this environment
pip install django requests pandas

# Check what's installed in this environment
pip list
```

### 4. Working with Requirements

```bash
# Export current environment packages (like pom.xml dependencies)
pip freeze > requirements.txt

# Install from requirements file (like mvn install)
pip install -r requirements.txt
```

## Managing Dependencies with requirements.txt

The `requirements.txt` file is Python's equivalent to Maven's `pom.xml` - it lists all your project dependencies.

### Creating requirements.txt

```bash
# After installing packages in your venv
pip install django requests pandas numpy

# Export all installed packages and versions
pip freeze > requirements.txt

# Contents of requirements.txt will look like:
# Django==4.1.7
# requests==2.28.2
# pandas==1.5.3
# numpy==1.24.2
```

### Different Ways to Specify Dependencies

```bash
# Exact version (recommended for production)
Django==4.1.7

# Minimum version
Django>=4.1.0

# Compatible release (allows patch updates)
Django~=4.1.0

# Version range
Django>=4.0.0,<5.0.0

# Latest version (not recommended for production)
Django
```

### Best Practices for requirements.txt

#### 1. Separate Requirements Files
```bash
# Base dependencies
requirements.txt

# Development-only dependencies
requirements-dev.txt

# Production-specific dependencies
requirements-prod.txt
```

Example `requirements-dev.txt`:
```bash
# Include base requirements
-r requirements.txt

# Development tools
pytest==7.2.1
black==23.1.0
flake8==6.0.0
```

#### 2. Installing from Different Requirements Files
```bash
# Install production dependencies
pip install -r requirements.txt

# Install development dependencies (includes base requirements)
pip install -r requirements-dev.txt

# Install multiple files
pip install -r requirements.txt -r requirements-dev.txt
```

### Complete Workflow with requirements.txt

```bash
# 1. Start new project
mkdir myproject && cd myproject
python3 -m venv venv
source venv/bin/activate

# 2. Install initial packages
pip install django requests

# 3. Create requirements.txt
pip freeze > requirements.txt

# 4. Later, when setting up project on another machine
git clone myproject
cd myproject
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt  # Installs exact same versions

# 5. Adding new dependencies
pip install pandas
pip freeze > requirements.txt  # Update requirements.txt

# 6. Upgrading dependencies
pip install --upgrade django
pip freeze > requirements.txt  # Update with new versions
```

### Team Development Workflow

```bash
# Developer A adds a new dependency
pip install matplotlib
pip freeze > requirements.txt
git add requirements.txt
git commit -m "Add matplotlib dependency"
git push

# Developer B pulls changes
git pull
pip install -r requirements.txt  # Gets matplotlib automatically
```

### 5. Deactivate When Done

```bash
# Return to global Python environment
deactivate

# Prompt returns to normal
username@hostname:~/myproject$
```

## Common Commands Reference

```bash
# Virtual Environment Management
python3 -m venv <environment_name>    # Create venv
source <environment_name>/bin/activate # Activate
deactivate                            # Deactivate
rm -rf <environment_name>             # Remove venv

# Package Management
pip install package_name              # Install latest version
pip install package_name==1.2.3      # Install specific version
pip install --upgrade package_name   # Upgrade package
pip uninstall package_name           # Remove package
pip list                             # List installed packages
pip show package_name                # Show package details

# Requirements Management
pip freeze > requirements.txt        # Export current packages
pip install -r requirements.txt      # Install from requirements
pip freeze --local > requirements.txt # Export only venv packages (not global)

# Environment Information
which python                         # Check Python location
which pip                           # Check pip location
python --version                    # Check Python version
pip --version                       # Check pip version
```

## Best Practices for Java Developers

### 1. Naming Convention
```bash
# Common patterns
python3 -m venv venv          # Simple 'venv' (like target/ in Maven)
python3 -m venv .venv         # Hidden directory
python3 -m venv myproject-env # Project-specific name
```

### 2. Project Structure
```
myproject/
├── venv/                 # Virtual environment (like target/)
├── src/                  # Source code
├── requirements.txt      # Dependencies (like pom.xml)
├── README.md
└── .gitignore           # Should include venv/
```

### 3. .gitignore
Always exclude virtual environments from version control:
```gitignore
venv/
.venv/
env/
```

### 4. Development Workflow with requirements.txt
```bash
# Project setup workflow
cd myproject
source venv/bin/activate           # Activate environment
pip install -r requirements.txt    # Install all dependencies
python main.py                     # Run your code

# Adding new dependencies
pip install new_package            # Install new package
pip freeze > requirements.txt     # Update requirements file
git add requirements.txt           # Commit changes
git commit -m "Add new_package dependency"

# Daily development
source venv/bin/activate           # Start work
# ... do development work ...
deactivate                        # End work session
```

## Troubleshooting

### Virtual Environment Not Activating
```bash
# Make sure you're using source, not just running the script
source venv/bin/activate  # ✓ Correct
./venv/bin/activate       # ✗ Wrong - won't modify current shell
```

### Wrong Python Version
```bash
# Specify Python version when creating venv
python3.9 -m venv venv    # Use specific Python version
python3 -m venv venv      # Use default Python 3
```

### Permission Issues
```bash
# Never use sudo with pip in virtual environments
sudo pip install package  # ✗ Wrong - breaks venv isolation
pip install package       # ✓ Correct - installs in venv
```

## Advanced: Multiple Python Versions

If you need different Python versions (like managing different JDK versions):

```bash
# Install specific Python version first
sudo apt install python3.9 python3.9-venv

# Create venv with specific version
python3.9 -m venv myproject-py39
source myproject-py39/bin/activate
python --version  # Should show Python 3.9.x
```

## Summary for Java Developers

| Java Concept | Python Equivalent |
|--------------|-------------------|
| JVM | Python Interpreter |
| Maven/Gradle | pip + requirements.txt |
| Local Repository | Virtual Environment |
| `mvn install` | `pip install -r requirements.txt` |
| `pom.xml` | `requirements.txt` |
| Project Scope | Activated venv |

**Remember**: Always activate your virtual environment before working on a Python project, just like you'd navigate to your Maven project directory before running `mvn` commands.