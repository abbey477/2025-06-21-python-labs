#!/bin/bash


# Simple Python virtual environment setup
# Usage: ./setup_env.sh <project_name> <directory>
# Example: ./setup_env.sh my-project ~/projects


# Make executable => chmod +x setup_env.sh

# Default (~/spark-project)  => ./setup_env.sh

# Custom project name  => ./setup_env.sh my-project

# Custom project and directory  => ./setup_env.sh data-pipeline ~/workspace

PROJECT_NAME=${1:-spark-project2}
BASE_DIR=${2:-$HOME}
PROJECT_DIR="$BASE_DIR/dev/python/$PROJECT_NAME"


echo "Setting up: $PROJECT_DIR"

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "Current working directory is : $PWD"

# Create virtual environment
python3 -m venv venv

# Activate virtual environment FIRST
source "$PROJECT_DIR/venv/bin/activate"


# Now pip commands will work inside the virtual environment
pip install --upgrade pip
pip install pyspark jupyter pandas numpy

# Save requirements
pip freeze > requirements.txt

# Deactivate
deactivate

echo ""
echo "========================================="
echo "Setup Complete!"
echo "Project: $PROJECT_DIR"
echo "Activate: source $PROJECT_DIR/venv/bin/activate"
echo "========================================="