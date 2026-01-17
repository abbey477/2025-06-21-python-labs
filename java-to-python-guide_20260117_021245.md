# Java to Python Quick Reference Guide

## Core Syntax Differences

### Hello World
```java
// Java
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello World");
    }
}
```
```python
# Python
print("Hello World")
```

### Variables & Types
```java
// Java - explicit typing
int age = 25;
String name = "John";
final double PI = 3.14;
```
```python
# Python - dynamic typing
age = 25
name = "John"
PI = 3.14  # convention: UPPERCASE for constants
```

### Conditionals
```java
// Java
if (x > 0) {
    System.out.println("Positive");
} else if (x < 0) {
    System.out.println("Negative");
} else {
    System.out.println("Zero");
}
```
```python
# Python - no parentheses, no braces, use colon and indentation
if x > 0:
    print("Positive")
elif x < 0:
    print("Negative")
else:
    print("Zero")
```

### Loops
```java
// Java - for loop
for (int i = 0; i < 5; i++) {
    System.out.println(i);
}

// Java - enhanced for
for (String item : items) {
    System.out.println(item);
}
```
```python
# Python - for loop (more like Java's enhanced for)
for i in range(5):
    print(i)

# Python - iterating over collection
for item in items:
    print(item)
```

```java
// Java - while loop
while (condition) {
    // do something
}
```
```python
# Python - while loop
while condition:
    # do something
```

### Functions/Methods
```java
// Java
public int add(int a, int b) {
    return a + b;
}

public static void greet(String name) {
    System.out.println("Hello " + name);
}
```
```python
# Python - no access modifiers needed
def add(a, b):
    return a + b

def greet(name):
    print(f"Hello {name}")
```

### Classes
```java
// Java
public class Person {
    private String name;
    private int age;
    
    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
}
```
```python
# Python - simpler, no getters/setters needed
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    
    # Methods automatically public
    def greet(self):
        print(f"Hi, I'm {self.name}")

# Usage
person = Person("John", 25)  # No 'new' keyword
print(person.name)  # Direct access (or use @property for encapsulation)
```

### Data Structures

#### Arrays/Lists
```java
// Java - arrays
int[] numbers = {1, 2, 3, 4, 5};
String[] names = new String[10];
```
```python
# Python - lists (dynamic, no size needed)
numbers = [1, 2, 3, 4, 5]
names = []  # empty list
names.append("John")  # add element
```

#### HashMap/Dictionary
```java
// Java
HashMap<String, Integer> map = new HashMap<>();
map.put("age", 25);
int age = map.get("age");
```
```python
# Python - dict
my_dict = {"age": 25, "name": "John"}
age = my_dict["age"]
# or
age = my_dict.get("age")  # safer, returns None if key missing
```

### String Operations
```java
// Java
String text = "Hello";
text = text + " World";
text = text.toUpperCase();
boolean contains = text.contains("World");
String[] parts = text.split(" ");
```
```python
# Python
text = "Hello"
text = text + " World"  # or use f-strings
text = text.upper()
contains = "World" in text
parts = text.split(" ")
```

### Exception Handling
```java
// Java
try {
    int result = divide(10, 0);
} catch (ArithmeticException e) {
    System.out.println("Error: " + e.getMessage());
} finally {
    // cleanup
}
```
```python
# Python
try:
    result = divide(10, 0)
except ZeroDivisionError as e:
    print(f"Error: {e}")
finally:
    # cleanup
    pass
```

### File I/O
```java
// Java
try (BufferedReader br = new BufferedReader(new FileReader("file.txt"))) {
    String line;
    while ((line = br.readLine()) != null) {
        System.out.println(line);
    }
} catch (IOException e) {
    e.printStackTrace();
}
```
```python
# Python - much simpler!
with open("file.txt", "r") as file:
    for line in file:
        print(line.strip())
```

## Key Mental Shifts

### 1. **Indentation = Curly Braces** ⚠️ IMPORTANT

**The Challenge:**
Coming from Java, the lack of curly braces feels "invisible" and error-prone. Your muscle memory wants to type `{` and `}`.

**How Indentation Works:**
```java
// Java - braces define scope
if (x > 0) {
    System.out.println("Positive");
    doSomething();
}
```
```python
# Python - indentation defines scope (4 spaces = 1 level)
if x > 0:
    print("Positive")
    do_something()
```

**Coping Strategies:**

1. **Configure Your IDE Properly** (CRITICAL!)
   - Set Tab key to insert **4 spaces** (not actual tab character)
   - Enable "Show whitespace" or "Show indentation guides"
   - PyCharm: Settings → Editor → Code Style → Python → Use spaces
   - VS Code: `"editor.insertSpaces": true`, `"editor.tabSize": 4`

2. **Use Auto-Formatters** (Your Safety Net!)
   - Install **Black** - fixes indentation automatically
   - Run on save: catches mistakes before you see them
   - PyCharm: Enable Black as file watcher
   - VS Code: `"editor.formatOnSave": true`

3. **Visual Aids** (Make the Invisible Visible!)
   
   **Indentation Guides:**
   - Enable vertical lines that show each indentation level
   - PyCharm: Settings → Editor → General → Appearance → Show indent guides
   - VS Code: `"editor.guides.indentation": true` (enabled by default)
   - These lines act like visual "braces" showing scope boundaries
   
   **Show Whitespace Characters:**
   - Display dots for spaces, arrows for tabs
   - PyCharm: View → Active Editor → Show Whitespaces
   - VS Code: View → Render Whitespace (or `"editor.renderWhitespace": "all"`)
   - Helps you catch mixing tabs/spaces immediately
   
   **Recommended Plugins:**
   - **Rainbow Brackets** (PyCharm) - Colors matching brackets/parentheses
   - **Indent Rainbow** (VS Code) - Colors each indentation level differently
   - **Bracket Pair Colorizer** (VS Code) - Helps you see matching parentheses
   - **Error Lens** (VS Code) - Shows errors inline, catches indentation issues fast
   
   **Visual Example of What You'll See:**
   ```
   def calculate(x, y):           │ ← Indentation guide (vertical line)
   ····if x > 0:                  │ ← Dots show spaces
   ········result = x + y         │ ← Two levels deep
   ········return result          │ 
   ····else:                      │
   ········return 0               │
   ```
   
   **Color-Coded Indentation (with Indent Rainbow):**
   ```python
   def process_data(items):
   │   for item in items:              # Level 1 - Blue
   │   │   if item.is_valid():         # Level 2 - Yellow  
   │   │   │   result = item.process() # Level 3 - Pink
   │   │   │   save(result)            # Level 3 - Pink
   │   │   else:                       # Level 2 - Yellow
   │   │   │   skip(item)              # Level 3 - Pink
   ```
   
   **Pro Tip:** Start with ALL visual aids enabled. As you get comfortable (week 2-3), you can gradually turn them off. But there's no shame in keeping them permanently!

4. **Common Mistakes & How to Avoid Them**
   ```python
   # WRONG - mixing tabs and spaces (will cause IndentationError)
   if condition:
   →   print("tab")
       print("4 spaces")  # Error!
   
   # WRONG - inconsistent indentation
   if condition:
       print("4 spaces")
     print("2 spaces")  # Error!
   
   # CORRECT - consistent 4 spaces
   if condition:
       print("Correct")
       print("Also correct")
   ```

5. **Mental Model Shift**
   - Think: "Each indent level = one scope deeper"
   - Python forces you to write readable code (no messy brace placement debates!)
   - After 1-2 weeks, you'll stop missing braces

6. **Don't Forget the Colon!**
   ```python
   # WRONG - missing colon
   if x > 0
       print("Oops")
   
   # CORRECT - colon required
   if x > 0:
       print("Good")
   ```

7. **When You Get IndentationError**
   - Check: Are you using spaces everywhere (not tabs)?
   - Check: Is each level exactly 4 spaces?
   - Run Black formatter - it will fix it instantly
   - Use `cat -A filename.py` in terminal to see invisible characters

**Pro Tip:** Think of indentation as **Python's curly braces that you can't mess up**. In Java, you can have mismatched braces. In Python, proper indentation is enforced, leading to more consistent code.

**Adjustment Timeline:**
- Day 1-3: Frustrating, lots of IndentationErrors
- Week 1: Still thinking about it, but fewer errors
- Week 2: Muscle memory adapting, formatter helps
- Week 3+: Natural, you'll wonder why Java needs braces!

---

### 2. **Python Uses Spaces, Not Tabs**
- **Always use 4 spaces** for indentation (PEP 8 standard)
- NEVER mix tabs and spaces (causes hard-to-debug errors)
- Configure your editor to convert Tab key to spaces

### 3. **No Access Modifiers**
- Everything is "public" by default
- Convention: prefix with `_` for "internal use" (e.g., `_private_method`)
- Prefix with `__` for name mangling (pseudo-private)

### 4. **Dynamic Typing**
- No need to declare types
- Can use type hints for clarity: `def add(a: int, b: int) -> int:`
- Variables can change type (but don't abuse this)

### 5. **No 'new' Keyword**
- Create objects directly: `person = Person()` not `Person person = new Person()`

### 6. **Everything is an Object**
- Even primitives like integers are objects
- Methods exist on everything: `"hello".upper()`, `[1,2,3].append(4)`

### 7. **Boolean Values**
- `True` and `False` (capitalized!) not `true` and `false`
- `None` instead of `null`

### 8. **Comparison Operators**
- `==` for equality (same as Java)
- `is` for identity (like Java's `==` for objects)
- `and`, `or`, `not` instead of `&&`, `||`, `!`

### 9. **Multiple Return Values**
```python
def get_user():
    return "John", 25  # returns tuple

name, age = get_user()  # unpacking
```

## Common Python Idioms

### List Comprehensions (powerful!)
```python
# Instead of:
squares = []
for i in range(10):
    squares.append(i ** 2)

# Write:
squares = [i ** 2 for i in range(10)]
```

### F-strings (modern string formatting)
```python
name = "John"
age = 25
message = f"My name is {name} and I'm {age} years old"
```

### Enumerate (instead of index tracking)
```python
# Instead of:
for i in range(len(items)):
    print(i, items[i])

# Write:
for i, item in enumerate(items):
    print(i, item)
```

### The 'with' Statement (resource management)
```python
# Automatically closes file
with open("file.txt") as f:
    data = f.read()
```

## Quick Tips

- **Configure your editor for 4 spaces** - this is the #1 thing to do first!
- **Install Black formatter** - it handles indentation for you automatically
- **Enable indentation guides** - makes invisible whitespace visible
- **Use snake_case** for variables and functions, not camelCase
- **Use PascalCase** for class names
- **UPPER_CASE** for constants
- **Read PEP 8** - Python's style guide
- **Use `dir()` and `help()`** in the interpreter to explore objects
- **Type hints are optional** but helpful for complex code

## Practice Exercises

1. Rewrite a simple Java class (with fields, constructor, methods) in Python
2. Convert a Java for-loop to Python list comprehension
3. Replace Java's try-with-resources with Python's `with` statement
4. Use f-strings instead of string concatenation

## Resources

- [Official Python Tutorial](https://docs.python.org/3/tutorial/)
- [PEP 8 Style Guide](https://pep8.org/)
- [Real Python](https://realpython.com/) - excellent tutorials
- [Python for Java Programmers](https://lobster1234.github.io/2017/05/25/python-java-primer/)

---

**Remember:** Python is designed to be readable and concise. Embrace "The Zen of Python" - type `import this` in Python interpreter!
