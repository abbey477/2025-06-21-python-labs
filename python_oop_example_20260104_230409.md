# Python OOP Example for Java Developers - Enhanced Edition

This comprehensive example demonstrates Python's object-oriented programming with advanced features, structured for Java developers.

## Project Structure

```
project/
├── person.py
├── department.py
├── company.py
├── salary_calculator.py
└── main.py
```

## person.py

```python
class Person:
    """Represents a person with basic information"""
    
    def __init__(self, name, age, email):
        self.name = name
        self.age = age
        self.email = email
    
    def greet(self):
        return f"Hi, I'm {self.name} and I'm {self.age} years old"
    
    def __str__(self):
        """String representation - like Java's toString()"""
        return f"Person(name={self.name}, age={self.age}, email={self.email})"
    
    def __repr__(self):
        """Developer-friendly representation"""
        return self.__str__()


class Employee(Person):
    """Employee extends Person - demonstrates inheritance"""
    
    def __init__(self, name, age, email, employee_id, salary, department=None):
        super().__init__(name, age, email)  # Call parent constructor
        self.employee_id = employee_id
        self.salary = salary
        self.department = department
    
    def greet(self):
        """Override parent method - like @Override in Java"""
        base_greeting = super().greet()
        return f"{base_greeting}. I work as Employee #{self.employee_id}"
    
    def get_annual_salary(self):
        return self.salary * 12
    
    def assign_department(self, department):
        self.department = department
        department.add_employee(self)
    
    def __str__(self):
        return f"Employee(id={self.employee_id}, name={self.name}, salary=${self.salary})"
```

## department.py

```python
class Department:
    """Represents a company department"""
    
    def __init__(self, name, department_code):
        self.name = name
        self.department_code = department_code
        self.employees = []
        self._budget = 0  # Private-like attribute (convention with underscore)
    
    def add_employee(self, employee):
        if employee not in self.employees:
            self.employees.append(employee)
            print(f"✓ Added {employee.name} to {self.name}")
    
    def remove_employee(self, employee):
        if employee in self.employees:
            self.employees.remove(employee)
            print(f"✗ Removed {employee.name} from {self.name}")
    
    def get_employee_count(self):
        return len(self.employees)
    
    def list_employees(self):
        print(f"\n{self.name} Department ({self.department_code}):")
        print("-" * 50)
        if not self.employees:
            print("  No employees")
        else:
            for emp in self.employees:
                print(f"  • {emp.name} - ID: {emp.employee_id} - ${emp.salary:,}/month")
    
    def get_total_monthly_cost(self):
        return sum(emp.salary for emp in self.employees)
    
    def set_budget(self, budget):
        """Setter method - like Java's setBudget()"""
        self._budget = budget
    
    def get_budget(self):
        """Getter method - like Java's getBudget()"""
        return self._budget
    
    def __str__(self):
        return f"Department(name={self.name}, employees={len(self.employees)})"
```

## company.py

```python
class Company:
    """Represents a company with departments and employees"""
    
    # Class variable - shared across all instances (like static in Java)
    company_count = 0
    
    def __init__(self, company_name, industry):
        self.company_name = company_name
        self.industry = industry
        self.departments = []
        self.employees = []
        Company.company_count += 1
    
    def add_department(self, department):
        if department not in self.departments:
            self.departments.append(department)
            print(f"✓ Created department: {department.name}")
    
    def add_employee(self, employee):
        if employee not in self.employees:
            self.employees.append(employee)
    
    def show_company_structure(self):
        print(f"\n{'=' * 60}")
        print(f"  {self.company_name} - {self.industry}")
        print(f"{'=' * 60}")
        print(f"Total Departments: {len(self.departments)}")
        print(f"Total Employees: {len(self.employees)}")
        
        for dept in self.departments:
            dept.list_employees()
    
    def get_total_payroll(self):
        total = sum(emp.salary for emp in self.employees)
        return total
    
    def find_employee_by_id(self, employee_id):
        """Find employee - demonstrates search/filter"""
        for emp in self.employees:
            if emp.employee_id == employee_id:
                return emp
        return None
    
    def get_high_earners(self, threshold):
        """Filter employees - like Java streams"""
        return [emp for emp in self.employees if emp.salary >= threshold]
    
    @staticmethod
    def get_company_count():
        """Static method - like Java's static method"""
        return Company.company_count
    
    def __str__(self):
        return f"Company(name={self.company_name}, employees={len(self.employees)})"
```

## salary_calculator.py

```python
class SalaryCalculator:
    """Utility class for salary calculations - like a Java utility class"""
    
    TAX_RATE = 0.20  # Class constant - like public static final
    
    @staticmethod
    def calculate_net_salary(gross_salary):
        """Calculate salary after tax"""
        tax = gross_salary * SalaryCalculator.TAX_RATE
        return gross_salary - tax
    
    @staticmethod
    def calculate_annual_net(monthly_salary):
        """Calculate annual net salary"""
        monthly_net = SalaryCalculator.calculate_net_salary(monthly_salary)
        return monthly_net * 12
    
    @staticmethod
    def compare_salaries(emp1, emp2):
        """Compare two employee salaries"""
        diff = abs(emp1.salary - emp2.salary)
        higher = emp1 if emp1.salary > emp2.salary else emp2
        return higher, diff
```

## main.py

```python
from person import Person, Employee
from department import Department
from company import Company
from salary_calculator import SalaryCalculator


class Application:
    """Main application class - entry point"""
    
    @staticmethod
    def main():
        print("🚀 Starting Company Management System\n")
        
        # Create company
        company = Company("TechCorp", "Software Development")
        
        # Create departments
        engineering = Department("Engineering", "ENG-001")
        engineering.set_budget(500000)
        
        sales = Department("Sales", "SAL-001")
        sales.set_budget(300000)
        
        hr = Department("Human Resources", "HR-001")
        hr.set_budget(200000)
        
        company.add_department(engineering)
        company.add_department(sales)
        company.add_department(hr)
        
        print()
        
        # Create employees
        emp1 = Employee("Alice Johnson", 30, "alice@techcorp.com", "E001", 8000)
        emp2 = Employee("Bob Smith", 28, "bob@techcorp.com", "E002", 7500)
        emp3 = Employee("Carol White", 35, "carol@techcorp.com", "E003", 9000)
        emp4 = Employee("David Brown", 26, "david@techcorp.com", "E004", 6000)
        emp5 = Employee("Eve Davis", 32, "eve@techcorp.com", "E005", 7000)
        
        # Assign employees to departments
        print()
        emp1.assign_department(engineering)
        emp2.assign_department(engineering)
        emp3.assign_department(sales)
        emp4.assign_department(sales)
        emp5.assign_department(hr)
        
        # Add all employees to company
        for emp in [emp1, emp2, emp3, emp4, emp5]:
            company.add_employee(emp)
        
        # Display company structure
        company.show_company_structure()
        
        # Salary calculations
        print(f"\n{'=' * 60}")
        print("  SALARY ANALYSIS")
        print(f"{'=' * 60}")
        
        print(f"\nTotal Monthly Payroll: ${company.get_total_payroll():,}")
        print(f"Total Annual Payroll: ${company.get_total_payroll() * 12:,}")
        
        # High earners
        print(f"\nHigh Earners (>= $7,500/month):")
        high_earners = company.get_high_earners(7500)
        for emp in high_earners:
            net_annual = SalaryCalculator.calculate_annual_net(emp.salary)
            print(f"  • {emp.name}: ${emp.salary:,}/month (${net_annual:,.2f}/year net)")
        
        # Compare salaries
        print(f"\nSalary Comparison:")
        higher_emp, diff = SalaryCalculator.compare_salaries(emp1, emp3)
        print(f"  {higher_emp.name} earns ${diff:,} more than the other")
        
        # Find specific employee
        print(f"\nEmployee Lookup:")
        found = company.find_employee_by_id("E003")
        if found:
            print(f"  Found: {found}")
            print(f"  Annual Salary: ${found.get_annual_salary():,}")
        
        # Department budgets
        print(f"\n{'=' * 60}")
        print("  DEPARTMENT BUDGETS")
        print(f"{'=' * 60}")
        for dept in company.departments:
            monthly_cost = dept.get_total_monthly_cost()
            budget = dept.get_budget()
            remaining = budget - (monthly_cost * 12)
            print(f"\n{dept.name}:")
            print(f"  Budget: ${budget:,}")
            print(f"  Annual Cost: ${monthly_cost * 12:,}")
            print(f"  Remaining: ${remaining:,}")
        
        # Static method demo
        print(f"\n{'=' * 60}")
        print(f"Total Companies Created: {Company.get_company_count()}")
        print(f"{'=' * 60}\n")


if __name__ == "__main__":
    Application.main()
```

## How to Run

```bash
# Run the main application
python main.py

# Or make it executable (Linux/Mac)
chmod +x main.py
./main.py
```

## Expected Output

```
🚀 Starting Company Management System

✓ Created department: Engineering
✓ Created department: Sales
✓ Created department: Human Resources

✓ Added Alice Johnson to Engineering
✓ Added Bob Smith to Engineering
✓ Added Carol White to Sales
✓ Added David Brown to Sales
✓ Added Eve Davis to Human Resources

============================================================
  TechCorp - Software Development
============================================================
Total Departments: 3
Total Employees: 5

Engineering Department (ENG-001):
--------------------------------------------------
  • Alice Johnson - ID: E001 - $8,000/month
  • Bob Smith - ID: E002 - $7,500/month

Sales Department (SAL-001):
--------------------------------------------------
  • Carol White - ID: E003 - $9,000/month
  • David Brown - ID: E004 - $6,000/month

Human Resources Department (HR-001):
--------------------------------------------------
  • Eve Davis - ID: E005 - $7,000/month

============================================================
  SALARY ANALYSIS
============================================================

Total Monthly Payroll: $37,500
Total Annual Payroll: $450,000

High Earners (>= $7,500/month):
  • Alice Johnson: $8,000/month ($76,800.00/year net)
  • Bob Smith: $7,500/month ($72,000.00/year net)
  • Carol White: $9,000/month ($86,400.00/year net)

Salary Comparison:
  Carol White earns $1,000 more than the other

Employee Lookup:
  Found: Employee(id=E003, name=Carol White, salary=$9,000)
  Annual Salary: $108,000

============================================================
  DEPARTMENT BUDGETS
============================================================

Engineering:
  Budget: $500,000
  Annual Cost: $186,000
  Remaining: $314,000

Sales:
  Budget: $300,000
  Annual Cost: $180,000
  Remaining: $120,000

Human Resources:
  Budget: $200,000
  Annual Cost: $84,000
  Remaining: $116,000

============================================================
Total Companies Created: 1
============================================================
```

## Advanced Python Concepts Demonstrated

### 1. Inheritance
```python
class Employee(Person):  # Employee inherits from Person
    def __init__(self, ...):
        super().__init__(name, age, email)  # Call parent constructor
```

### 2. Method Overriding
```python
def greet(self):  # Override parent's greet() method
    base_greeting = super().greet()  # Can still call parent method
    return f"{base_greeting}. I work as Employee #{self.employee_id}"
```

### 3. List Comprehension (like Java Streams)
```python
# Filter high earners
high_earners = [emp for emp in self.employees if emp.salary >= threshold]

# Equivalent Java:
// employees.stream()
//     .filter(emp -> emp.getSalary() >= threshold)
//     .collect(Collectors.toList());
```

### 4. Private-like Attributes
```python
self._budget = 0  # Convention: underscore means "private" (not enforced)
```

### 5. String Methods
```python
def __str__(self):  # Like Java's toString()
    return f"Person(name={self.name})"

def __repr__(self):  # Developer representation
    return self.__str__()
```

### 6. Class Variables and Methods
```python
class Company:
    company_count = 0  # Class variable (like static in Java)
    
    @staticmethod
    def get_company_count():  # Static method
        return Company.company_count
```

## Python vs Java Comparison Table

| Feature | Python | Java |
|---------|--------|------|
| Constructor | `__init__(self, ...)` | `public ClassName(...)` |
| Instance reference | `self` | `this` |
| Inheritance | `class Child(Parent):` | `class Child extends Parent` |
| Call parent constructor | `super().__init__(...)` | `super(...)` |
| Method override | Just redefine method | Use `@Override` annotation |
| toString | `__str__(self)` | `toString()` |
| Static method | `@staticmethod` | `static` keyword |
| Static variable | Class variable | `static` keyword |
| Private members | `_variable` (convention) | `private` keyword |
| List operations | List comprehensions | Stream API |
| No value | `None` | `null` |
| Boolean | `True`/`False` | `true`/`false` |

## Key Python Features for Java Developers

### 1. No Explicit Interface Declaration
Python uses "duck typing" - if it walks like a duck and quacks like a duck, it's a duck.

### 2. Multiple Return Values
```python
def get_stats(employees):
    return len(employees), sum(e.salary for e in employees)

count, total = get_stats(employees)
```

### 3. Default Parameters
```python
def __init__(self, name, age, department=None):  # department is optional
    self.department = department
```

### 4. F-Strings (Modern String Formatting)
```python
name = "Alice"
age = 30
message = f"Hi, I'm {name} and I'm {age} years old"
```

### 5. List Comprehensions
```python
# Create a list of employee names
names = [emp.name for emp in employees]

# Filter and transform
high_salaries = [emp.salary * 12 for emp in employees if emp.salary > 7000]
```

## Best Practices

1. **Use meaningful names** - Python emphasizes readability
2. **Follow PEP 8** - Python's style guide (snake_case for functions/variables)
3. **Add docstrings** - Document your classes and methods
4. **Use type hints** (optional but helpful):
   ```python
   def calculate_salary(amount: float) -> float:
       return amount * 0.8
   ```
5. **Keep it simple** - "Simple is better than complex" (The Zen of Python)

## Running Tests (Bonus)

Create a `test_company.py`:

```python
import unittest
from company import Company
from employee import Employee

class TestCompany(unittest.TestCase):
    def test_add_employee(self):
        company = Company("TestCorp", "Tech")
        emp = Employee("John", 25, "john@test.com", "E001", 5000)
        company.add_employee(emp)
        self.assertEqual(len(company.employees), 1)

if __name__ == "__main__":
    unittest.main()
```

Run with: `python -m unittest test_company.py`

## Next Steps

1. Add error handling with try/except (like try/catch in Java)
2. Implement data persistence (save to file/database)
3. Add logging instead of print statements
4. Create a command-line interface (CLI)
5. Build a REST API with Flask or FastAPI

---

**Created**: 2026-01-04 23:04:09  
**Author**: Claude (Anthropic)  
**Purpose**: Educational example for Java developers learning Python
