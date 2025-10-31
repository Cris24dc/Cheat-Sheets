# C++ Cheat Sheet

<img src="../img/cpp/cpp.jpg">

## 📑 Table of Contents

<div style="display: flex; flex-wrap: wrap;">

<div style="flex: 1; min-width: 250px; margin-right: 20px;">
<ul>
<li><strong>🧠 Core Language Differences (vs. C)</strong></li>
<ul>
<li><a href="#🔗-pointers--references">🔗 Pointers & References</a></li>
<li><a href="#💾-memory-allocation">💾 Memory Allocation (new/delete)</a></li>
<li><a href="#🎯-null-vs-nullptr">🎯 NULL vs nullptr</a></li>
<li><a href="#🧩-struct-enum-union">🧩 struct, enum, union</a></li>
<li><a href="#🔒-static-keyword">🔒 static Keyword</a></li>
<li><a href="#📚-namespaces">📚 Namespaces</a></li>
<li><a href="#⚙️-macros">⚙️ Macros (and alternatives)</a></li>
</ul>
<li><strong>📦 Type System & Initialization</strong></li>
<ul>
<li><a href="#🔄-c-style-casting">🔄 C++ Style Casting</a></li>
<li><a href="https://www.google.com/search?q=%23%F0%9F%8E%AF-type-punning">🎯 Type Punning</a></li>
<li><a href="#⚙️-the-auto-keyword--type-inference">⚙️ The `auto` Keyword & Type Inference</a></li>
<li><a href="#📋-initializer-lists--uniform-initialization">📋 Initializer Lists & Uniform Initialization</a></li>
</ul>
<li><strong>🔐 Const & Mutability</strong></li>
<ul>
<li><a href="#🔐-const-keyword">🔐 const Keyword</a></li>
<li><a href="#🔧-mutable-keyword">🔧 mutable Keyword</a></li>
</ul>
<li><strong>Functions & Callables</strong></li>
<ul>
<li><a href="#🎯-function-pointers--lambdas">🎯 Function Pointers & Lambdas</a></li>
</ul>
</ul>
</div>

<div style="flex: 1; min-width: 250px;">
<ul>
<li><strong>Templates</strong></li>
<ul>
<li><a href="#🛠️-template-functions">🛠️ Template Functions</a></li>
<li><a href="#🛠️-template-structs">🛠️ Template Structs (Classes)</a></li>
</ul>
<li><strong>Memory & Concurrency</strong></li>
<ul>
<li><a href="#🧠-smart-pointers">🧠 Smart Pointers</a></li>
<li><a href="#🚚-lvalues-rvalues--move-semantics">🚚 lvalues, rvalues, & Move Semantics</a></li>
<li><a href="#🧵-threads--concurrency">🧵 Threads & Concurrency</a></li>
</ul>
<li><strong>🔤 Strings & Regex</strong></li>
<ul>
<li><a href="#🔤-stdstring--manipulation">🔤 std::string & Manipulation</a></li>
<li><a href="#🌊-stdstringstream">🌊 std::stringstream</a></li>
<li><a href="#🔍-stdregex">🔍 std::regex</a></li>
</ul>
<li><strong>Miscellaneous</strong></li>
<ul>
<li><a href="#❓-ternary-operator">❓ Ternary Operator</a></li>
<li><a href="#🚶-iterators">🚶 Iterators</a></li>
</ul>
</ul>
</div>

</div>

---

## 🔗 Pointers & References

### Pointers

Pointers in C++ function identically to C, holding a memory address.

```cpp
int x = 10;
int* ptr = &x; // 'ptr' stores the address of 'x'
*ptr = 20;     // 'x' is now 20
```

### References (C++ Only)

A **reference** is an _alias_ for an existing variable. It must be initialized upon declaration and cannot be changed to refer to another variable. It also cannot be `nullptr`.

```cpp
int x = 10;
int& ref = x; // 'ref' is now an alias for 'x'

ref = 30; // This changes 'x' to 30.
int y = 50;
// ref = y; (ILLEGAL! Cannot reseat a reference. This assigns 'y' (50) to 'x')
```

| Feature                   | Pointer (`int* p`)                          | Reference (`int& r`)                              |
| ------------------------- | ------------------------------------------- | ------------------------------------------------- |
| **Can be NULL?**          | **Yes** (`p = nullptr;`)                    | **No**. Must be initialized.                      |
| **Can be Reseated?**      | **Yes** (`p = &another_var;`)               | **No**. Always refers to the same variable.       |
| **Needs Initialization?** | No (`int* p;` is valid)                     | **Yes** (`int& r = var;`)                         |
| **Syntax**                | Dereference (`*p`)                          | Direct access (`r`)                               |
| **Primary Use**           | Optional values, C-style APIs, heap memory. | Function parameters (pass-by-reference), aliases. |

**Pass-by-Reference:** Using references for function parameters is cleaner than using pointers as it avoids `*` and `&` syntax at the call site and guarantees the value is not null.

```cpp
// C-style (pass-by-pointer)
void increment_c(int* p) {
    if (p != NULL) {
        (*p)++;
    }
}
increment_c(&x);

// C++ style (pass-by-reference)
void increment_cpp(int& r) {
    r++; // No null check needed
}
increment_cpp(x);
```

---

## 💾 Memory Allocation (new/delete)

C++ replaces `malloc()`/`free()` with the `new` and `delete` operators. These operators are type-aware (they call constructors/destructors, which is crucial for OOP).

| C (`<stdlib.h>`)                                | C++ (Modern)                                 |
| ----------------------------------------------- | -------------------------------------------- |
| `int* p = (int*)malloc(sizeof(int));`           | `int* p = new int;`                          |
| `int* arr = (int*)callalloca(10, sizeof(int));` | `int* arr = new int[10];` (Zero-initializes) |
| `free(p);`                                      | `delete p;`                                  |
| `free(arr);`                                    | `delete[] arr;`                              |

**Critial:** You **must** use `delete[]` for memory allocated with `new[]`. Mismatching `delete` and `delete[]` (or mixing `malloc`/`delete`) is undefined behavior.

**Modern Practice:** Avoid `new`/`delete` entirely. Use **Smart Pointers**.

---

## 🎯 NULL vs nullptr

| Macro / Keyword | C          | C++              | Why?                                                                                                                                                                              |
| --------------- | ---------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `NULL`          | `(void*)0` | `0` (an `int`)   | In C, `(void*)0` is a null pointer.                                                                                                                                               |
| `nullptr`       | N/A        | `std::nullptr_t` | `NULL` in C++ is just the integer `0`, which leads to ambiguity in function overloading (e.g., `foo(int)` vs. `foo(char*)`). `nullptr` is a true, type-safe null pointer keyword. |

**Rule:** In C++, **always** use `nullptr` instead of `NULL` or `0` for pointers.

```cpp
void func(int x) { /*...*/ }
void func(char* s) { /*...*/ }

func(NULL); // Calls func(int) in C++! (NULL is 0)
func(nullptr); // Correctly calls func(char*)
```

---

## 🧩 struct, enum, union

### `struct`

In C, `struct` creates a type, but you must use the `struct` keyword (or a `typedef`) to declare a variable. In C++, the `struct` name _is_ the type name.

```c
// C
struct Point { int x, y; };
struct Point p; // 'struct' keyword required
typedef struct Point Point_t;
Point_t p2;
```

```cpp
// C++
struct Point { int x, y; };
Point p; // 'Point' is now a type name
```

_(Note: In C++, `struct` is identical to `class` except `struct` members are `public` by default.)_

### `enum` (Scoped Enums)

C-style enums "pollute" the surrounding namespace with their enumerator names. C++11 introduced **`enum class`** (or `enum struct`) to fix this.

```cpp
// C-style enum
enum Color { RED, GREEN, BLUE };
Color c = RED;
int x = GREEN; // Implicitly converts to int
// Color other = RED; // Error if another enum has 'RED'

// C++ Scoped enum (Preferred)
enum class ScopedColor { RED, GREEN, BLUE };
ScopedColor c = ScopedColor::RED; // Must use scope
// int x = ScopedColor::GREEN; // ILLEGAL! No implicit conversion to int
if (c == ScopedColor::RED) { /* ... */ }
```

### `union`

Unions work largely the same as in C. However, they are less common in C++ for type punning (see [Type Punning](https://www.google.com/search?q=%23%F0%9F%8E%AF-type-punning)).

---

## 🔒 `static` Keyword

The `static` keyword has multiple meanings based on its context, similar to C, but with a C++ nuance.

| Context                          | C                                                        | C++                                                       |
| -------------------------------- | -------------------------------------------------------- | --------------------------------------------------------- |
| **Local Variable** (in function) | Preserves value between calls. Initialized once.         | Same.                                                     |
| **Global Variable**              | **Internal Linkage**. Visible only within its `.c` file. | Same. **Deprecated**. Use _anonymous namespaces_ instead. |
| **Global Function**              | **Internal Linkage**. Visible only within its `.c` file. | Same. **Deprecated**. Use _anonymous namespaces_ instead. |
| **Class Member** (OOP)           | N/A                                                      | Shared variable/function for all instances of a class.    |

```cpp
// C++ alternative to 'static global'
namespace {
  int g_internal_var = 10; // Only visible in this .cpp file
  void internal_func() { /* ... */ } // Only visible in this .cpp file
}
```

---

## 📚 Namespaces

Namespaces are a C++ feature to prevent naming conflicts by grouping code under a specific name.

```cpp
namespace MyMath {
  const double PI = 3.14159;
  int add(int a, int b) { return a + b; }
}

// Access using scope resolution operator ::
double pi = MyMath::PI;
int sum = MyMath::add(5, 3);

// 'using' directive
using namespace MyMath;
double pi_2 = PI; // Now accessible directly

// 'using' declaration
using MyMath::add;
int sum_2 = add(1, 2); // 'add' is now accessible
```

**Best Practice:** Avoid `using namespace ...` in header files as it pollutes the global namespace for everyone who includes it. `using` declarations are safer.

---

## ⚙️ Macros

C-style macros (`#define`) are still available but **strongly discouraged** in C++.

| C Macro                                     | C++ Alternative                                                      | Why?                                                                                |
| ------------------------------------------- | -------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
| `#define PI 3.14`                           | `const double PI = 3.14;` <br> `constexpr double PI = 3.14;` (C++11) | Macros are not type-safe and have no scope. `const`/`constexpr` are real variables. |
| `#define MAX(a, b) ((a) > (b) ? (a) : (b))` | `template<typename T> T max(T a, T b) { return a > b ? a : b; }`     | Macros can have side effects (e.g., `MAX(++x, y)`). Templates are type-safe.        |
| `#define LOG(msg) printf("%s\n", msg)`      | `inline void LOG(const char* msg) { std::cout << msg << "\n"; }`     | `inline` functions are type-safe and respect namespaces.                            |

---

## 📦 Type System & Initialization

---

### 🔄 C++ Style Casting

C++ replaces C-style casts (`(type)value`) with four specific, safer casting operators.

1.  **`static_cast<T>(expr)`**

    - The "normal" cast for compatible types.
    - Used for conversions like `int` to `float`, or pointer-to-base to pointer-to-derived (OOP).
    - Fails at compile-time if types are incompatible (e.g., `int*` to `float*`).

    <!-- end list -->

    ```cpp
    float f = 9.5f;
    int i = static_cast<int>(f); // OK (value is 9)
    ```

2.  **`reinterpret_cast<T>(expr)`**

    - The most dangerous cast. Re-interprets the underlying bit pattern.
    - Used for low-level, non-portable tasks, like casting a pointer to an integer or to a completely different pointer type.
    - This is the C++ equivalent of a C-style "force-cast."

    <!-- end list -->

    ```cpp
    int i = 0x41424344; // "ABCD" in ASCII
    char* c = reinterpret_cast<char*>(&i);
    // 'c' now points to the bytes of 'i'
    ```

3.  **`const_cast<T>(expr)`**

    - Used _only_ to add or remove `const` (or `volatile`).
    - Its only legitimate use is to interface with old C APIs that don't use `const` correctly. Modifying a truly `const` object is undefined behavior.

    <!-- end list -->

    ```cpp
    void legacy_c_func(char* s); // Doesn't modify 's', but missing 'const'
    const char* my_str = "hello";
    legacy_c_func(const_cast<char*>(my_str)); // OK, as long as func doesn't write
    ```

4.  **`dynamic_cast<T>(expr)`**

    - Used _only_ for polymorphic OOP types (requires virtual functions).
    - Safely casts a base-class pointer to a derived-class pointer, returning `nullptr` (for pointers) or throwing an exception (for references) if the cast is invalid.
    - _(You will cover this in your OOP document.)_

**Rule:** **Always** prefer C++ casts over C-style casts. They are safer and easier to search for.

---

### 🎯 Type Punning

Type punning is accessing a piece of memory as a different type.

- **C Method (via `union` or `reinterpret_cast`):** Accessing an inactive `union` member is _undefined behavior (UB)_ in C++.
  ```cpp
  // UB in C++!
  union Pun { int i; float f; };
  Pun p;
  p.f = 3.14f;
  int x = p.i; // Undefined Behavior
  ```
- **C++ Method (via `reinterpret_cast`):** Also technically UB if you violate _strict aliasing_ rules.
  ```cpp
  float f = 3.14f;
  int* p_i = reinterpret_cast<int*>(&f);
  int x = *p_i; // Undefined Behavior
  ```
- **The Safe C++20 Method (`std::bit_cast`)**:
  ```cpp
  #include <bit>
  float f = 3.14f;
  int x = std::bit_cast<int>(f); // OK!
  ```
- **The Safe Pre-C++20 Method (`memcpy`)**: This is optimized away by compilers and is the standard, safe way to do type punning.
  ```cpp
  #include <cstring>
  float f = 3.14f;
  int x;
  std::memcpy(&x, &f, sizeof(int)); // OK!
  ```

---

### ⚙️ The `auto` Keyword & Type Inference

The `auto` keyword (C++11) directs the compiler to deduce the type of a variable from its initializer. This process is called **type inference**.

It works using the same rules as **template argument deduction**. The compiler looks at the initializer and determines the simplest type that can hold it.

```cpp
int x = 5;
auto y = 10; // y is deduced as 'int'
auto z = 3.14; // z is 'double'
auto s = "hello"; // s is 'const char*'

// 'auto' strips const/volatile and references
const int& x_ref = x;
auto y = x_ref; // y is 'int' (const and & are stripped)

// To preserve them, add them back:
auto& ref_x = x; // ref_x is 'int&'
const auto& const_ref_x = x; // const_ref_x is 'const int&'
const auto* ptr_x = &x; // ptr_x is 'const int*'
```

**Benefit:** Simplifies code, especially with complex types (like iterators or lambdas) and makes refactoring easier.

---

### 📋 Initializer Lists & Uniform Initialization

C++11 introduced a "uniform initialization" syntax using curly braces `{}`. It's intended to be a more consistent and safer way to initialize variables.

```cpp
// C-style initialization
int x = 10;
int arr[3] = {1, 2, 3};
struct Point { int x, y; };
Point p = {5, 6};

// C++11 Uniform Initialization
int y {10}; // Preferred over int y = 10;
int arr2[3] {1, 2, 3};
Point p2 {5, 6};
std::string s {"hello"};
```

**Key Feature: Disallows "Narrowing" Conversions**
This is its main safety benefit. It prevents accidental data loss.

```cpp
int i = 3.14; // OK in C/C++. 'i' becomes 3 (data loss)
// int j {3.14}; // COMPILE ERROR! Narrowing conversion disallowed.
```

**`std::initializer_list`**
This is a lightweight object that represents a list of values in braces. It's what allows `struct`s (and STL containers) to be initialized with `{...}`.

```cpp
#include <initializer_list>
#include <vector>

void print_list(std::initializer_list<int> list) {
    for (int x : list) { // Can be iterated
        std::cout << x << " ";
    }
}

print_list({1, 2, 3, 4, 5}); // Compiler creates a std::initializer_list
```

---

## 🔐 Const & Mutability

---

### 🔐 `const` Keyword

`const` in C++ is much stronger than in C.

- In C, `const` variables are read-only but are _not_ compile-time constants.
- In C++, `const` global or namespace-level variables have **internal linkage** by default (unlike C, where they have external linkage) and can be used as compile-time constants (e.g., `const int SIZE = 10; int arr[SIZE];` is valid C++, invalid C).

**`constexpr` (C++11):**
For values that _must_ be known at compile-time, use `constexpr`. This guarantees compile-time evaluation.

```cpp
const int x = 5; // C++: compile-time constant
int arr[x]; // OK

constexpr int get_size() { return 10; }
int arr_2[get_size()]; // OK, get_size() is evaluated at compile time
```

**`const` in Functions**
`const` can appear in three places in a function declaration:

`const int func(const int param) const;`

1.  **`const int ...` (Return Value):**

    - `const int func(...)`
    - Returns a `const` value. For simple types like `int`, this is mostly useless. For complex types, it prevents the caller from modifying the returned temporary.
    - `func() = 5; // ILLEGAL`

2.  **`... (const int param)` (Parameter):**

    - The function promises not to change the value of `param` inside its body.
    - This is critical when passing by reference or pointer to avoid copies and guarantee safety.
    - `void func(const std::string& s)` (Pass by const reference)

3.  **`... () const` (Member Function):**

    - This _only_ applies to member functions of a `struct` or `class` (OOP).
    - It promises that the function will _not modify any member variables_ of the object it's called on.
    - It's a key part of `const`-correctness in OOP.

**Pointer `const` (same as C):**
Read from right to left.

```cpp
const int* p1;      // Pointer to a const int (value can't change)
int const* p2;      // Same as p1
int* const p3;      // Const pointer to an int (pointer can't change)
const int* const p4; // Const pointer to a const int
```

---

### 🔧 `mutable` Keyword

The `mutable` keyword is an exception to `const`. It allows a member of a `struct` (or `class`) to be modified, even if the `struct` instance is `const` (or inside a `const` member function).

Its use outside of OOP is rare, but it can be used in `const` lambdas.

```cpp
struct Data {
    int normal_val;
    mutable int access_count; // e.g., for logging/caching
};

void process(const Data& d) {
    // d.normal_val = 15; // ILLEGAL! 'd' is const
    d.access_count++; // OK! 'access_count' is mutable
}
```

---

## Functions & Callables

---

### 🎯 Function Pointers & Lambdas

#### Function Pointers

Syntax is identical to C, but `typedef` (or `using`) is still recommended for clarity.

```cpp
// C-style typedef
typedef int (*BinOp_C)(int, int);

// C++ 'using' alias
using BinOp_CPP = int(*)(int, int);

int add(int a, int b) { return a + b; }
BinOp_CPP my_op = add;
int result = my_op(5, 3);
```

**Common Use Cases:**

- **Callbacks:** Passing a function to another function to be called later (e.g., C-style APIs, event handlers).
- **Strategy Pattern:** Implementing interchangeable algorithms.
- **Dynamic Libraries:** Loading functions by name from `.dll` or `.so` files (e.g., `dlsym()`).

---

#### Lambda Expressions (C++11)

A **lambda** is a convenient, inline, anonymous function. It's one of the most powerful features of modern C++.

**Syntax:** `[capture_list](parameter_list) -> return_type { function_body }`

- `[]`: An empty capture. The lambda can't see any local variables.
- `[=]`: Capture by **value**. The lambda gets a _copy_ of all local variables.
- `[&]`: Capture by **reference**. The lambda gets a _reference_ to all local variables.
- `[x, &y]`: Capture `x` by value and `y` by reference.

The `-> return_type` is often optional; the compiler can deduce it.

```cpp
int x = 10;
int y = 20;

// A simple lambda that adds two numbers
auto my_add = [](int a, int b) -> int {
    return a + b;
};
int result = my_add(5, 3); // 8

// A lambda that captures local state
auto add_x_and_y = [=]() { // Captures x and y by value
    return x + y;
};
int result2 = add_x_and_y(); // 30

// A lambda that modifies local state
auto increment_x = [&x]() { // Captures x by reference
    x++;
};
increment_x(); // 'x' is now 11
```

Lambdas are the preferred C++ way to handle "callbacks" and are fundamental to the STL algorithms.

---

## Templates

Templates are the C++ mechanism for **generic programming**. They allow you to write functions and `struct`s/`class`es that can operate on any data type. The type is specified as a parameter _at compile time_.

---

### 🛠️ Template Functions

A single function definition that can be instantiated by the compiler for many different types.

```cpp
// A template function 'T' is the template parameter
template <typename T>
T add(T a, T b) {
    return a + b;
}

// Compiler auto-generates versions of 'add'
int i = add(5, 10); // Instantiates add<int>(int, int)
double d = add(3.14, 2.71); // Instantiates add<double>(double, double)
std::string s = add(std::string("Hello"), std::string(" World")); // Instantiates add<std::string>(...)
```

---

### 🛠️ Template Structs (Classes)

A single `struct` definition that can be instantiated for different types. This is the basis for all STL containers (like `std::vector<T>`).

```cpp
template <typename T1, typename T2>
struct Pair {
    T1 first;
    T2 second;
};

// Instantiate a Pair of int and double
Pair<int, double> p1;
p1.first = 10;
p1.second = 3.14;

// Instantiate a Pair of string and int
Pair<std::string, int> p2;
p2.first = "age";
p2.second = 30;

// C++17 Class Template Argument Deduction (CTAD)
Pair p3 {"hello", 5}; // Compiler deduces Pair<const char*, int>
```

---

## Memory & Concurrency

---

### 🧠 Smart Pointers

Found in `<memory>`. They manage memory automatically using a principle called **RAII** (Resource Acquisition Is Initialization). They replace `new` and `delete`.

1.  **`std::unique_ptr<T>` (C++11)**

    - **Exclusive ownership.** Only one `unique_ptr` can point to an object.
    - When the `unique_ptr` goes out of scope, it automatically `delete`s the object.
    - It's lightweight (zero-cost abstraction, same size as a raw pointer).
    - It **cannot** be copied. It can only be **moved**.

    <!-- end list -->

    ```cpp
    #include <memory>

    void use_smart_ptr() {
        // Create (use std::make_unique, C++14)
        auto u_ptr = std::make_unique<int>(42);

        // Access
        *u_ptr = 100;

        // Pass ownership (move)
        std::unique_ptr<int> other_ptr = std::move(u_ptr);
        // 'u_ptr' is now nullptr

    } // 'other_ptr' goes out of scope, 'int' is automatically deleted
    ```

2.  **`std::shared_ptr<T>` (C++11)**

    - **Shared ownership.** Multiple `shared_ptr`s can point to the same object.
    - Keeps an internal _reference count_.
    - When the _last_ `shared_ptr` is destroyed, the object is `delete`d.
    - Has a small overhead (for the control block/ref count).

    <!-- end list -->

    ```cpp
    void use_shared_ptr() {
        // Create (use std::make_shared, C++11)
        auto s_ptr = std::make_shared<int>(50);
        // Ref count is 1

        {
            auto s_ptr_copy = s_ptr; // Copy. Ref count is now 2
            *s_ptr_copy = 100;
        } // 's_ptr_copy' destroyed. Ref count is 1

    } // 's_ptr' destroyed. Ref count is 0. Object is deleted.
    ```

3.  **`std::weak_ptr<T>` (C++11)**

    - A non-owning, "weak" observer of a `shared_ptr`.
    - It **does not** increase the reference count.
    - Used to break circular references (e.g., two objects with `shared_ptr`s to each other).
    - You must `lock()` it to get a temporary `shared_ptr` to safely access the object.

    <!-- end list -->

    ```cpp
    std::weak_ptr<int> w_ptr;
    {
        auto s_ptr = std::make_shared<int>(99);
        w_ptr = s_ptr; // w_ptr observes s_ptr. Ref count is 1.

        if (auto temp_shared = w_ptr.lock()) { // Try to get a valid shared_ptr
            std::cout << *temp_shared << "\n"; // Prints 99
        }
    } // s_ptr destroyed. Object deleted.

    if (auto temp_shared = w_ptr.lock()) {
        // Fails. w_ptr.lock() returns empty shared_ptr
    } else {
        std::cout << "Object expired.\n";
    }
    ```

---

### 🚚 lvalues, rvalues, & Move Semantics

This is a C++11 concept for optimizing away expensive copies.

- **lvalue (locator value):** An expression that has an identity (a name, an address). You can take its address.
  - `int x = 10;` (`x` is an lvalue)
  - `std::string s = "hi";` (`s` is an lvalue)
- **rvalue (right value):** A temporary expression that has no identity and "expires" at the end of the statement. You cannot take its address.
  - `10` is an rvalue
  - `x + 5` is an rvalue
  - `std::string("hi")` is an rvalue

**Rvalue References (`&&`)**
A reference that can _only_ bind to a temporary (an rvalue). This is the key to "stealing" resources.

```cpp
void func(int& x) { /* lvalue ref */ }
void func(int&& x) { /* rvalue ref */ }

int y = 10;
func(y); // Calls func(int& x)
func(5); // Calls func(int&& x)
```

**`std::move`**
`std::move` doesn't move anything. It's a cast. It casts an lvalue into an rvalue, "promising" the compiler you are done with the lvalue and its resources can be stolen.

**Move Constructor (OOP Concept)**
This is what makes `std::move` useful. A **move constructor** is a special constructor (in a `struct`/`class`) that "steals" the resources from an rvalue, leaving the original empty.

```cpp
#include <utility> // for std::move

struct Buffer {
    char* data_ = nullptr;
    size_t size_ = 0;

    // Copy Constructor (deep copy)
    Buffer(const Buffer& other) {
        data_ = new char[other.size_];
        std::memcpy(data_, other.data_, other.size_);
        size_ = other.size_;
    }

    // Move Constructor (shallow copy + "steal")
    Buffer(Buffer&& other) noexcept { // Takes an rvalue reference (&&)
        data_ = other.data_; // Steal pointer
        size_ = other.size_;

        other.data_ = nullptr; // Leave old object empty
        other.size_ = 0;
    }
    // ... destructor, assignment operators, etc.
};

Buffer b1; // Assume b1 holds a large 10MB buffer
Buffer b2 = b1; // Calls COPY constructor. We now have 20MB in use.
Buffer b3 = std::move(b1); // Calls MOVE constructor. Still 10MB in use.
                           // b3 now owns the buffer, b1 is empty.
```

This is how `std::unique_ptr` and `std::string` transfer ownership efficiently.

---

### 🧵 Threads & Concurrency

C++11 introduced a standard thread library (`<thread>`, `<mutex>`, `<atomic>`).

**`std::thread`**

- Represents a single thread of execution.
- It takes a function (or lambda) to run.
- Execution begins immediately upon construction.
- You **must** `join()` (wait for it to finish) or `detach()` (let it run independently) before the `std::thread` object is destroyed.

<!-- end list -->

```cpp
#include <thread>
#include <iostream>

void thread_func(int id) {
    std::cout << "Hello from thread " << id << "\n";
}
std::thread t1(thread_func, 1); // Create and run thread
t1.join(); // Wait for t1 to finish
```

---

#### `std::mutex` (Mutual Exclusion)

A **mutex** is a lock used to protect shared data from being accessed by multiple threads at the same time (a "race condition").

```cpp
#include <mutex>

int g_counter = 0;
std::mutex g_mutex; // A mutex to protect g_counter

void safe_increment() {
    g_mutex.lock(); // Lock the mutex (wait if another thread has it)
    g_counter++;
    g_mutex.unlock(); // Unlock the mutex
}
```

**RAII Lock (Preferred): `std::lock_guard`**
Manually calling `lock()` and `unlock()` is error-prone (e.g., if an exception happens, it never unlocks). `std::lock_guard` handles this automatically.

```cpp
void safer_increment() {
    // Lock is acquired on construction
    std::lock_guard<std::mutex> lock(g_mutex);
    g_counter++;
} // 'lock' goes out of scope, mutex is automatically unlocked
```

_(Other lock types exist, like `std::unique_lock` which is more flexible but heavier.)_

---

#### `std::atomic`

For simple types (like `int`, `bool`, pointers), a **mutex** is often overkill. `std::atomic` provides **lock-free** atomic operations, which are much faster.

```cpp
#include <atomic>

std::atomic<int> g_atomic_counter = 0;

void atomic_increment() {
    g_atomic_counter++; // This is now a thread-safe atomic operation
}
```

Use `std::atomic` for simple flags and counters. Use `std::mutex` to protect larger or more complex data structures.

---

## 🔤 Strings & Regex

---

### 🔤 `std::string` & Manipulation

Found in `<string>`. `std::string` is the C++ replacement for C-style `char*` strings. It handles its own memory management.

```cpp
#include <string>
#include <iostream>

std::string s1 = "Hello";
std::string s2 = "World";

// Concatenation
std::string s3 = s1 + ", " + s2 + "!"; // "Hello, World!"
s3.append(" Welcome."); // "Hello, World! Welcome."
```

**Common Manipulation Methods:**

| Method                     | Example                     | Description                                                    |
| -------------------------- | --------------------------- | -------------------------------------------------------------- |
| `s.substr(pos, len)`       | `s3.substr(0, 5)`           | Returns `"Hello"` (substring).                                 |
| `s.find(str)`              | `s3.find("World")`          | Returns `7` (index). Returns `std::string::npos` if not found. |
| `s.find_first_of(chars)`   | `s3.find_first_of("abcde")` | Returns `1` ('e'). Finds first char from the set.              |
| `s.find_last_of(chars)`    | `s3.find_last_of("abcde")`  | Returns `20` ('e' in Welcome). Finds last char from the set.   |
| `s.replace(pos, len, str)` | `s3.replace(0, 5, "Hi")`    | Changes `s3` to `"Hi, World! Welcome."`                        |
| `s.insert(pos, str)`       | `s3.insert(0, "Well, ")`    | Changes `s3` to `"Well, Hi, World!..."`                        |
| `s.erase(pos, len)`        | `s3.erase(0, 6)`            | Changes `s3` to `"Hi, World!..."` (removes "Well, ")           |
| `s.c_str()`                | `printf("%s", s3.c_str())`  | Returns a `const char*` for C-style APIs.                      |
| `s.length()` / `s.size()`  | `s3.length()`               | Returns the number of characters.                              |
| `s.empty()`                | `s1.empty()`                | Returns `false`.                                               |

---

### 🌊 `std::stringstream`

Found in `<sstream>`. An in-memory stream used for converting between strings and other data types. Replaces `sprintf` and `sscanf`.

```cpp
#include <sstream>
#include <string>

// --- Convert numbers TO string (replaces sprintf) ---
std::stringstream ss;
int i = 123;
double d = 45.6;
ss << "Int: " << i << " Double: " << d;

std::string result_str = ss.str(); // "Int: 123 Double: 45.6"


// --- Convert string TO numbers (replaces sscanf) ---
std::stringstream ss_in("10 20.5");
int val_i;
double val_d;
ss_in >> val_i >> val_d; // val_i is 10, val_d is 20.5
```

---

### 🔍 `std::regex`

Found in `<regex>`. C++11 added a standard library for **regular expressions** (Perl-compatible syntax by default).

```cpp
#include <regex>

std::string log_line = "ERROR 123: File not found.";

// 1. Create the regex object
std::regex r("(\\w+)\\s(\\d+)"); // Find a word, then a space, then digits

// 2. Create a match object
std::smatch match; // 's' for string

// 3. Search the string
if (std::regex_search(log_line, match, r)) {
    // match[0] is the full match ("ERROR 123")
    // match[1] is the first capture group ("ERROR")
    // match[2] is the second capture group ("123")
    std::cout << "Type: " << match[1] << "\n";
    std::cout << "Code: " << match[2] << "\n";
}
```

- **`std::regex_search`**: Checks if a pattern _exists_ anywhere in the string.
- **`std::regex_match`**: Checks if the _entire string_ matches the pattern.
- **`std::regex_replace`**: Replaces matches with new text.

---

## Miscellaneous

---

### ❓ Ternary Operator

Identical to C.
`condition ? expression_if_true : expression_if_false`

```cpp
int x = 10;
int y = 20;
int max_val = (x > y) ? x : y; // max_val is 20
```

---

### 🚶 Iterators

An **iterator** is an object that acts like a "generalized pointer." It's the core concept that connects STL algorithms to STL containers. It provides a uniform API for traversing a sequence of elements, regardless of how that sequence is stored (e.g., in an array, a list, etc.).

Since you are not covering STL containers, think of them as an abstraction over pointers.

```cpp
#include <vector> // (Included just for a C++ style example)

int C_array[] = {10, 20, 30, 40, 50};

// C-style "iteration" using pointers
for (int* ptr = C_array; ptr != C_array + 5; ++ptr) {
    std::cout << *ptr << " "; // 10 20 30 40 50
}

// C++ style "iteration" using iterators
std::vector<int> vec = {10, 20, 30, 40, 50};

for (std::vector<int>::iterator it = vec.begin(); it != vec.end(); ++it) {
    std::cout << *it << " "; // 10 20 30 40 50
}

// C++11 "range-based for loop" (syntactic sugar for iterators)
for (int val : vec) {
    std::cout << val << " "; // 10 20 30 40 50
}
```

| Iterator "Pointer" | `vec.begin()` | Returns an iterator to the _first_ element.         |
| ------------------ | ------------- | --------------------------------------------------- |
| Iterator "Null"    | `vec.end()`   | Returns an iterator to _one-past-the-last_ element. |
| Dereference        | `*it`         | Accesses the element's value.                       |
| Increment          | `++it`        | Moves the iterator to the next element.             |
