# OOP Cheat Sheet

<img src="../img/oop/oop.png">

## 📑 Table of Contents

<div style="display: flex; flex-wrap: wrap;">

<div style="flex: 1; min-width: 250px; margin-right: 20px;">
<ul>
<li><strong>📦 The Core: Classes & Encapsulation</strong></li>
<ul>
<li><a href="#🧱-the-class-keyword">🧱 The <code>class</code> Keyword</a></li>
<li><a href="#🔑-encapsulation-public-private-protected">🔑 Encapsulation (public, private, protected)</a></li>
<li><a href="#scope-resolution-operator">:: Scope Resolution Operator</a></li>
</ul>
<li><strong> lifecycle: Constructors & Destructors</strong></li>
<ul>
<li><a href="#🚀-constructors--destructors">🚀 Constructors & Destructors</a></li>
<li><a href="# overloaded-constructors">Overloaded Constructors</a></li>
<li><a href="#📋-member-initializer-lists">📋 Member Initializer Lists</a></li>
<li><a href="#©%EF%B8%8F-copy-constructor">©️ Copy Constructor</a></li>
<li><a href="#🔑-explicit-keyword">🔑 explicit Keyword</a></li>
</ul>
<li><strong>Special Class Features</strong></li>
<ul>
<li><a href="#⚙️-inline-member-functions">⚙️ inline Member Functions</a></li>
<li><a href="#🤝-friend-keyword-functions--classes">🤝 <code>friend</code> Keyword (Functions & Classes)</a></li>
<li><a href="#🔧-operator-overloading">🔧 Operator Overloading</a></li>
<li><a href="#🏠-local-classes">🏠 Local Classes</a></li>
</ul>
</ul>
</div>

<div style="flex: 1; min-width: 250px;">
<ul>
<li><strong>🧬 Inheritance: The "Is-A" Relationship</strong></li>
<ul>
<li><a href="#🌳-inheritance-public-protected-private">🌳 Inheritance (public, protected, private)</a></li>
<li><a href="#🔗-multiple-inheritance">🔗 Multiple Inheritance</a></li>
<li><a href="#💎-virtual-inheritance">💎 Virtual Inheritance (The Diamond Problem)</a></li>
<li><a href="#🧩-aggregation-the-has-a-relationship">🧩 Aggregation (The "Has-A" Relationship)</a></li>
</ul>
<li><strong>🎭 Polymorphism & Abstraction</strong></li>
<ul>
<li><a href="#🎭-polymorphism--virtual-functions">🎭 Polymorphism & <code>virtual</code> Functions</a></li>
<li><a href="#🕊%EF%B8%8F-abstraction--pure-virtual-functions">🕊️ Abstraction & Pure Virtual Functions</a></li>
<li><a href="#🆚-interfaces-vs-abstract-classes">🆚 Interfaces vs. Abstract Classes</a></li>
<li><a href="#casting-upcasting--downcasting">Casting (Upcasting & Downcasting)</a></li>
<li><a href="#ℹ%EF%B8%8F-rtti-run-time-type-information">ℹ️ RTTI (Run-Time Type Information)</a></li>
</ul>
<li><strong>📐 Design Patterns</strong></li>
<ul>
<li><a href="#📐-design-patterns">📐 Design Patterns</a></li>
</ul>
</ul>
</div>

</div>

---

## 📦 The Core: Classes & Encapsulation

---

### 🧱 The `class` Keyword

A **class** is the fundamental unit of OOP. It's a blueprint for creating objects, bundling data (member variables) and functions (member methods) that operate on that data.

- `class`: Members are **private** by default.
- `struct`: Members are **public** by default. (Otherwise identical to `class` in C++).

<!-- end list -->

```cpp
class Dog {
    // Members are private by default
    std::string name;
    int age;

public:
    // Methods (and members) in 'public' are accessible
    void bark() {
        std::cout << name << " says Woof!\n";
    }

    // Constructor to initialize the object
    Dog(std::string n, int a) {
        name = n;
        age = a;
    }
};

// Create an instance (object)
Dog my_dog("Rex", 3);
my_dog.bark(); // "Rex says Woof!"
// my_dog.name = "Sam"; // COMPILE ERROR! 'name' is private
```

---

### 🔑 Encapsulation (public, private, protected)

**Encapsulation** (or "information hiding") is the bundling of data and methods into a class, and restricting direct access to an object's internal state.

| Specifier   | Access from...                   | Description                                                        |
| :---------- | :------------------------------- | :----------------------------------------------------------------- |
| `public`    | **Anywhere**                     | The "public interface." Accessible from outside the class.         |
| `protected` | **This class & derived classes** | Accessible by this class and any class that inherits from it.      |
| `private`   | **This class only**              | Accessible _only_ by other member functions of this _exact_ class. |

---

### :: Scope Resolution Operator

The `::` operator is used to define a member function _outside_ of the class declaration. This keeps the class definition clean (like a header file).

```cpp
// In Dog.h (The declaration)
class Dog {
public:
    void bark(); // Declare the method
private:
    std::string name;
};

// In Dog.cpp (The definition)
#include "Dog.h"

void Dog::bark() { // Use :: to specify this 'bark' belongs to 'Dog'
    std::cout << name << " says Woof!\n";
}
```

---

## lifecycle: Constructors & Destructors

---

### 🚀 Constructors & Destructors

- **Constructor:** A special method called _automatically_ when an object is created. Its job is to **initialize** the object's members. It has the same name as the class and no return type.
- **Destructor:** A special method called _automatically_ when an object is destroyed (e.g., goes out of scope, is `delete`d). Its job is to **clean up** resources (e.g., free memory, close files). It has the class name prefixed with `~`.

<!-- end list -->

```cpp
class Resource {
public:
    Resource() {
        std::cout << "Resource Acquired!\n";
        data = new int[100]; // e.g., allocate memory
    }

    ~Resource() {
        std::cout << "Resource Released!\n";
        delete[] data; // Clean up memory
    }
private:
    int* data;
};

void func() {
    Resource r; // Constructor called here
} // Destructor called here when 'r' goes out of scope
```

This automatic cleanup is the basis for **RAII** (Resource Acquisition Is Initialization), a core C++ concept.

---

### Overloaded Constructors

A class can have multiple constructors, as long as they have different parameter lists (different types or number of arguments). This is **constructor overloading** (it is _not_ polymorphism).

```cpp
class Point {
public:
    Point() { x = 0; y = 0; } // Default constructor
    Point(int val) { x = val; y = val; } // Constructor from one int
    Point(int x_val, int y_val) { x = x_val; y = y_val; } // Constructor from two ints
private:
    int x, y;
};

Point p1; // p1 = {0, 0}
Point p2(10); // p2 = {10, 10}
Point p3(5, 7); // p3 = {5, 7}
```

---

### 📋 Member Initializer Lists

This is the **preferred** way to initialize members in a constructor. It initializes members _before_ the constructor body runs.

**Syntax:** `Constructor() : member1(value1), member2(value2) { ... }`

**Why use it?**

1.  **Efficiency:** It performs _initialization_, not _assignment_. For complex objects, this avoids a default-construction followed by an assignment.
2.  **Required:** It is the _only_ way to initialize:
    - `const` members
    - Reference (`&`) members
    - Members that don't have a default constructor

<!-- end list -->

```cpp
class MyClass {
public:
    // BAD: Assignment
    MyClass(std::string s, int i) {
        name = s; // 1. name is default-constructed, 2. then assigned
        id = i;
    }

    // GOOD: Initialization List
    MyClass(std::string s, int i) : name(s), id(i), ref_id(id) {
        // 'name' is copy-constructed directly
        // 'id' is initialized
        // 'ref_id' (reference) is initialized
    }
private:
    std::string name;
    int id;
    const int& ref_id;
};
```

---

### ©️ Copy Constructor

A special constructor that creates a new object as a **copy of an existing object**.

**Syntax:** `ClassName(const ClassName& other)`

It's called automatically in these cases:

1.  `MyClass obj2 = obj1;` (Initialization, not assignment)
2.  Passing an object **by value** to a function.
3.  Returning an object **by value** from a function.

**Shallow vs. Deep Copy:**

- **Shallow Copy (Default):** The compiler-generated copy constructor just copies all members bit-by-bit. If you have a pointer, _only the pointer is copied_, not the data it points to. Both objects now point to the same memory, leading to a "double free" error when they are destroyed.
- **Deep Copy (Manual):** You must write a custom copy constructor to allocate _new_ memory and copy the _data_ from the original object.

<!-- end list -->

```cpp
class Buffer {
public:
    Buffer(int size) : size(size), data(new int[size]) {}

    // 1. Destructor
    ~Buffer() { delete[] data; }

    // 2. Custom Copy Constructor (Deep Copy)
    Buffer(const Buffer& other) : size(other.size) {
        data = new int[size]; // Allocate NEW memory
        std::memcpy(data, other.data, size * sizeof(int)); // Copy data
    }

    // 3. (Also need Copy Assignment Operator, 'Rule of Three')

private:
    int* data;
    size_t size;
};

Buffer b1(10);
Buffer b2 = b1; // Calls copy constructor. b2 has its OWN data.
```

_(This leads to the **Rule of Three/Five**: If you write any of a destructor, copy constructor, or copy assignment operator, you almost always need to write all three. With move semantics (C++11), this expands to the **Rule of Five** to include the move constructor and move assignment operator.)_

---

### 🔑 `explicit` Keyword

Use `explicit` on single-argument constructors to **prevent implicit conversions**.

```cpp
class MyInt {
public:
    // This constructor can be used for implicit conversion
    // MyInt(int v) : val(v) {}

    // This one cannot
    explicit MyInt(int v) : val(v) {}
private:
    int val;
};

void func(MyInt m) {}

// func(10); // COMPILE ERROR! 'explicit' prevents implicit (int) -> MyInt
MyInt m(10); // OK (Direct initialization)
func(m);     // OK
```

---

## Special Class Features

---

### ⚙️ `inline` Member Functions

- **Implicitly `inline`:** Any function defined _inside_ the class declaration is automatically treated as `inline`.
- **Explicitly `inline`:** You can use the `inline` keyword when defining a function outside the class body (in a `.h` file) to hint to the compiler to paste the code in-place.

<!-- end list -->

```cpp
class MyClass {
public:
    // Implicitly inline
    void func1() { /* ... */ }

    // Declared, defined elsewhere
    void func2();
};

// Explicitly inline (e.g., in the header file)
inline void MyClass::func2() {
    /* ... */
}
```

---

### 🤝 `friend` Keyword (Functions & Classes)

The `friend` keyword allows an external function or class to **access the `private` and `protected` members** of a class. It _breaks encapsulation_ and should be used sparingly.

```cpp
class MyClass {
private:
    int secret = 42;

    // Grant friendship
    friend void global_func(const MyClass& m);
    friend class FriendClass;
};

// A global function that is now a 'friend'
void global_func(const MyClass& m) {
    // Can access private members
    std::cout << "The secret is: " << m.secret << "\n";
}

// A class that is now a 'friend'
class FriendClass {
public:
    void show_secret(const MyClass& m) {
        // Can access private members
        std::cout << "The secret is: " << m.secret << "\n";
    }
};
```

---

### 🔧 Operator Overloading

Allows you to define custom behavior for C++ operators (like `+`, `-`, `==`, `<<`, `[]`) for your class. This makes your class behave more intuitively, like a built-in type.

```cpp
struct Point {
    int x, y;

    // Overload the '+' operator
    Point operator+(const Point& other) const {
        Point result;
        result.x = this->x + other.x;
        result.y = this->y + other.y;
        return result;
    }
};

// Overload the '<<' operator for std::cout (as a friend function)
std::ostream& operator<<(std::ostream& os, const Point& p) {
    os << "(" << p.x << ", " << p.y << ")";
    return os;
}

Point p1 {1, 2};
Point p2 {3, 4};
Point p3 = p1 + p2; // p3 is {4, 6}
std::cout << p3;    // Prints (4, 6)
```

---

### 🏠 Local Classes

You can define a class _inside_ a function. This class is local to the function's scope.

- It can _only_ be used inside that function.
- It _cannot_ have `static` member variables.
- It can _only_ access `static` local variables (or `typedef`s) from the enclosing function.

<!-- end list -->

```cpp
void func() {
    class LocalClass { // Defined inside func()
    public:
        void say_hi() { std::cout << "Hi from local class!\n"; }
    };

    LocalClass l;
    l.say_hi();
}

// LocalClass l2; // COMPILE ERROR! LocalClass is not visible here
```

---

## 🧬 Inheritance: The "Is-A" Relationship

---

### 🌳 Inheritance (public, protected, private)

**Inheritance** allows one class (the **derived** class) to acquire the properties and methods of another class (the **base** class). This forms an "Is-A" relationship (e.g., a `Dog` "Is-A" `Animal`).

**Syntax:** `class Derived : [access_specifier] Base`

The **inheritance access specifier** (`public`, `protected`, `private`) controls how the base class members' access levels are _changed_ in the derived class.

| Inheritance Type | `public` Base Members become... | `protected` Base Members become... | `private` Base Members become... |
| :--------------- | :------------------------------ | :--------------------------------- | :------------------------------- |
| `public`         | `public`                        | `protected`                        | **Inaccessible**                 |
| `protected`      | `protected`                     | `protected`                        | **Inaccessible**                 |
| `private`        | `private`                       | `private`                          | **Inaccessible**                 |

- **Rule:** You almost _always_ want **`public` inheritance**. This is the only type that models a true "Is-A" relationship.
- `private` inheritance is a way to implement a "Has-A" relationship (composition).

---

### 🔗 Multiple Inheritance

A C++ class can inherit from **more than one** base class.

**Syntax:** `class Child : public Parent1, public Parent2`

```cpp
class Logger {
public:
    void log(std::string msg) { /* ... */ }
};
class Serializable {
public:
    void save() { /* ... */ }
};

// 'MyObject' inherits capabilities from both
class MyObject : public Logger, public Serializable {
    // ...
};

MyObject obj;
obj.log("Hello");
obj.save();
```

**Warning:** This can lead to the "Dreaded Diamond Problem" if both base classes inherit from a common grandparent.

---

### 💎 Virtual Inheritance (The Diamond Problem)

**The Problem:**

1.  Class `A` is a base class.
2.  Classes `B` and `C` both inherit from `A`.
3.  Class `D` inherits from _both_ `B` and `C`.
4.  **Result:** `D` has _two copies_ of `A`'s members, leading to ambiguity. Which `A::member` do you mean?

**The Solution: `virtual` Inheritance**
By using the `virtual` keyword, you tell the compiler to only include _one copy_ of the common base class (`A`).

```cpp
class A { public: int data; };
class B : virtual public A {}; // Use virtual
class C : virtual public A {}; // Use virtual
class D : public B, public C {};

D d;
d.data = 10; // OK! No ambiguity. There is only one 'data'.
```

---

### 🧩 Aggregation (The "Has-A" Relationship)

This is an alternative to inheritance. Instead of _being_ another class, the object _contains_ an instance of another class. This is also called **composition** and is often **preferred over inheritance**.

```cpp
// Inheritance ("Is-A")
// class Car : public Engine {}; // A Car "Is-A" Engine? Bad design.

// Aggregation/Composition ("Has-A")
class Engine {
public:
    void start() {}
};

class Car {
private:
    Engine e; // A Car "Has-A" Engine. Good design.
public:
    void start() {
        e.start(); // Delegate the call
    }
};
```

**Rule of Thumb:** "Prefer composition over inheritance."

---

## 🎭 Polymorphism & Abstraction

---

### 🎭 Polymorphism & `virtual` Functions

**Polymorphism** ("many forms") is the ability to treat an object of a derived class as if it were an object of its base class, but still have it execute the _derived class's_ version of a method.

This is achieved using **`virtual` functions** and **dynamic dispatch** (or "late binding").

- `virtual`: A keyword in the **base class** that tells C++ to look up the correct function to call at _runtime_ (via a **v-table**) based on the object's _actual type_, not the pointer's type.

<!-- end list -->

```cpp
class Animal {
public:
    // 'virtual' allows this to be overridden
    virtual void speak() { std::cout << "Animal sound\n"; }
};

class Dog : public Animal {
public:
    // 'override' is optional but good practice (C++11)
    void speak() override { std::cout << "Woof!\n"; }
};

class Cat : public Animal {
public:
    void speak() override { std::cout << "Meow!\n"; }
};

// --- Polymorphism in action ---
Animal* a1 = new Dog();
Animal* a2 = new Cat();

a1->speak(); // Prints "Woof!" (Dog's version)
a2->speak(); // Prints "Meow!" (Cat's version)
// Without 'virtual', both would print "Animal sound"
```

---

### 🕊️ Abstraction & Pure Virtual Functions

**Abstraction** is the concept of hiding complex implementation details and exposing only the essential features.

A **pure virtual function** is the C++ mechanism for this. It's a `virtual` function that the base class _declares_ but does not _define_. It _must_ be implemented by any concrete derived class.

**Syntax:** `virtual void func() = 0;`

An **abstract class** is any class that has one or more pure virtual functions. **You cannot create an instance of an abstract class.**

```cpp
// 'Shape' is an abstract class
class Shape {
public:
    // A pure virtual function
    virtual double get_area() = 0;
};

class Square : public Shape {
public:
    Square(double s) : side(s) {}

    // Must implement the pure virtual function
    double get_area() override {
        return side * side;
    }
private:
    double side;
};

// Shape s; // COMPILE ERROR! Cannot instantiate abstract class
Shape* s = new Square(5);
std::cout << s->get_area(); // 25
```

---

### 🆚 Interfaces vs. Abstract Classes

C++ does not have a built-in `interface` keyword like Java or C#.

- **Abstract Class:** A class that _can_ have data members, normal methods, and pure virtual functions. It's a mix of implementation and specification.
- **Interface (C++ pattern):** A class that contains _only_ pure virtual functions (and perhaps a virtual destructor). It defines a _pure contract_ with no implementation.

| Feature     | Abstract Class                             | Interface (C++ Pattern)                                 |
| :---------- | :----------------------------------------- | :------------------------------------------------------ |
| **Purpose** | Provide a base implementation, share code. | Define a 100% pure contract.                            |
| **Methods** | Can have normal and pure virtual methods.  | **Only** pure virtual methods.                          |
| **Data**    | Can have data members.                     | **No** data members.                                    |
| **Example** | `Shape` (all shapes share `get_area()`)    | `ISerializable` (many _different_ objects can `save()`) |

---

### Casting (Upcasting & Downcasting)

- **Upcasting (Implicit):** Converting a derived-class pointer to a base-class pointer. This is **always safe** and is done implicitly.

  ```cpp
  Dog* d = new Dog();
  Animal* a = d; // Implicit upcast. Safe.
  ```

- **Downcasting (Explicit):** Converting a base-class pointer to a derived-class pointer. This is **unsafe** because the base pointer might not _actually_ point to that derived type.

  - **`static_cast` (Unsafe, Fast):**
    - Performs the cast at compile time.
    - If the pointer is the wrong type, this results in _undefined behavior_.
    - Use it _only_ when you are 100% certain the cast is valid.
    <!-- end list -->
    ```cpp
    Animal* a = new Dog();
    Dog* d = static_cast<Dog*>(a); // OK (we know it's a Dog)
    ```
  - **`dynamic_cast` (Safe, Slower):**
    - Uses **RTTI** to check the type at _runtime_.
    - If the cast is invalid, it returns `nullptr` (for pointers) or throws `std::bad_cast` (for references).
    - **Requires** the base class to have at least one `virtual` function (to have a v-table).
    <!-- end list -->
    ```cpp
    Animal* a = new Cat();
    Dog* d = dynamic_cast<Dog*>(a); // 'd' will be nullptr
    if (d) { /* ... */ } // Check is necessary
    ```

---

### ℹ️ RTTI (Run-Time Type Information)

RTTI is the mechanism that allows C++ to determine an object's type at runtime. It's what powers `dynamic_cast` and `typeid`.

- **`dynamic_cast`:** (See above) Safely casts based on runtime type.
- **`typeid`:** An operator that returns an object (`std::type_info`) containing information about a type.
  ```cpp
  #include <typeinfo>
  Animal* a = new Dog();
  if (typeid(*a) == typeid(Dog)) {
      std::cout << "It's a Dog!\n";
  }
  std::cout << typeid(*a).name(); // Prints a "mangled" name, e.g., "3Dog"
  ```

---

## 📐 Design Patterns

**Design Patterns** are well-documented, reusable solutions to common software design problems in an OOP context. They are templates for how to solve a problem, not finished code.

| Category       | Description                            | Examples                                                                                                                                                      |
| :------------- | :------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Creational** | About object _creation_ mechanisms.    | **Singleton:** Ensure a class has only one instance. <br> **Factory:** Use a central function to create objects without specifying the exact class.           |
| **Structural** | About _composing_ classes and objects. | **Adapter:** Make two incompatible interfaces work together. <br> **Decorator:** Add new functionality to an object dynamically (at runtime).                 |
| **Behavioral** | About _communication_ between objects. | **Observer:** When one object changes state, all its dependents are notified. <br> **Strategy:** Define a family of algorithms and make them interchangeable. |
