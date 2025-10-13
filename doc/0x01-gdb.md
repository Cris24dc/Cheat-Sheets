# pwndbg Cheat Sheet

<img src="../img/gdb/gdb.png">

## 📑 Table of Contents

<div style="display: flex; flex-wrap: wrap;">

  <!-- Column 1 -->
  <div style="flex: 1; min-width: 250px; margin-right: 20px;">
    <ul>
      <li><strong>🎯 Core Debugging</strong></li>
      <ul>
        <li><a href="#📋-interface-structure">📋 Interface Structure</a></li>
        <li><a href="#🎯-basic-navigation-commands">🎯 Basic Navigation Commands</a></li>
        <li><a href="#🔁-stepping--single-stepping-detailed">🔁 Stepping / Single-Stepping</a></li>
        <li><a href="#🔍-breakpoint-management">🔍 Breakpoint Management</a></li>
        <li><a href="#📊-register-inspection">📊 Register Inspection</a></li>
        <li><a href="#🧠-memory-examination">🧠 Memory Examination</a></li>
      </ul>

  <li><strong>📋 Stack & Execution</strong></li>
  <ul>
    <li><a href="#📋-stack-analysis">📋 Stack Analysis</a></li>
    <li><a href="#✅-stack-trace">✅ Stack Trace</a></li>
    <li><a href="#🔧-code-analysis">🔧 Code Analysis</a></li>
    <li><a href="#🔄-process-control">🔄 Process Control</a></li>
  </ul>

  <li><strong>🔍 Search & Memory</strong></li>
  <ul>
    <li><a href="#🔍-search-and-find">🔍 Search and Find</a></li>
    <li><a href="#📊-advanced-memory-operations">📊 Advanced Memory Operations</a></li>
    <li><a href="#🔍-memory-layout-analysis">🔍 Memory Layout Analysis</a></li>
  </ul>
</ul>
  </div>

  <!-- Column 2 -->
  <div style="flex: 1; min-width: 250px;">
    <ul>
      <li><strong>🏗️ Heap & Dynamic Analysis</strong></li>
      <ul>
        <li><a href="#🏗️-heap-analysis">🏗️ Heap Analysis</a></li>
        <li><a href="#🔗-dynamic-analysis">🔗 Dynamic Analysis</a></li>
      </ul>

  <li><strong>🎮 Exploitation & Security</strong></li>
  <ul>
    <li><a href="#🎮-exploitation-helpers">🎮 Exploitation Helpers</a></li>
    <li><a href="#🛡️-security-analysis">🛡️ Security Analysis</a></li>
  </ul>

  <li><strong>🧠 Information & Configuration</strong></li>
  <ul>
    <li><a href="#📝-information-gathering">📝 Information Gathering</a></li>
    <li><a href="#🎨-customization--configuration">🎨 Customization & Configuration</a></li>
    <li><a href="#🖨️-print--examine--display">🖨️ Print / Examine / Display</a></li>
  </ul>

  <li><strong>🔍 Debugging Techniques</strong></li>
  <ul>
    <li><a href="#🔍-debugging-techniques">🔍 General Debugging Techniques</a></li>
    <li><a href="#🧱-buffer-overflow-analysis">🧱 Buffer Overflow Analysis</a></li>
    <li><a href="#🧾-format-string-analysis">🧾 Format String Analysis</a></li>
    <li><a href="#🏗️-return-to-libc-analysis">🏗️ Return-to-libc Analysis</a></li>
  </ul>

  <li><strong>⚡ Essentials</strong></li>
  <ul>
    <li><a href="#⚡-essential-pwndbg-commands">⚡ Essential pwndbg Commands</a></li>
    <li><a href="#📚-help--docs">📚 Help & Docs</a></li>
  </ul>
</ul>
  </div>
</div>

## 📋 Interface Structure

```yaml
┌─────────────────────────────────────────────────────────────────────────────┐
│ Registers                                         │ Assembly / Machine Code │
│                                                   │ 0x401000: mov rdi, rax  │
│  RAX = 0x7fffffffe0a0                             │ 0x401005: call 0x400f00 │
│  RBX = 0x0                                        │ 0x40100A: nop           │
│ *RSP = 0x7fffffffe0b0 (* = newly modified)        │                         |
│  RBP = 0x7fffffffe120                             │_________________________│
│  RIP = 0x401000 -> mov rdi, rax (instruction at RIP shown)                  │
│  RDI = 0x601050 -> 0x601050: 0x2f2f62696e2f7368 (points to "/bin/sh")       │
└─────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────┐
│ Source (if available)     │ Stack (growing down)                            |
│                           │ 0x7fffffffe0b0 : 0x00000000004010FF (ret addr)  │
│ 1 int main() {            │ 0x7fffffffe0b8 : 0x0000000000601050 (arg ptr)   │
│ 2 char *s = "/bin/sh";    │ 0x7fffffffe0c0 : 0x0000000000000000 (saved rbp) │
│ 3 system(s);              │                                                 │
│ 4 }                       │                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────────────┐
│ Stack Frames / Backtrace                                                    │
│ 0 0x401005 in main (s=0x601050) at main.c:3                                 │
│ 1 0x400f00 in __libc_start_main (args...)                                   │
│ 2 0x400e90 in _start                                                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 🎯 Basic Navigation Commands

```bash
(gdb) b main           # Set breakpoint at main
(gdb) b *0x401000      # Set breakpoint at address
(gdb) b function+10    # Set breakpoint at offset
(gdb) b +2             # Set breakpoint 2 lines forward from current source line
(gdb) b myfunc         # Break at start of function `myfunc` (alias: b fn)
(gdb) r                # Run program
(gdb) r arg1 arg2      # Run with arguments
(gdb) c                # Continue execution
(gdb) s                # Step into (source-level)
(gdb) si               # Step one instruction (alias: stepi, si)
(gdb) n                # Next (step over)
(gdb) ni               # Next instruction (alias: nexti, ni)
(gdb) finish           # Run until current function returns
(gdb) q                # Quit gdb
```

## 🔁 Stepping / Single-Stepping (detailed)

Use these to control execution one source line or one instruction at a time.

```bash
# Source-level stepping
step, s              # Step into next source line (steps into function calls)
step N               # Repeat step N times

# Instruction-level stepping
stepi, si            # Step a single machine instruction
stepi N              # Step N instructions

# Step-over variants
next, n              # Step over (do not enter functions)
nexti, ni            # Step over a single instruction (on some gdb builds it's alias 'ni')
next N               # Repeat next N times

# Other useful step-style commands
finish               # Run until current function returns
until                # Run until a source location past the current one is reached
return               # Make current function return (optionally supply value)
```

> Tip: `si`/`stepi` are for instruction-level debugging (useful when debugging assembly); `s`/`step` are for source-level.

## 🔍 Breakpoint Management

```bash
# Setting breakpoints
b main                 # Break at function
b *0x401234            # Break at address
b file.c:42            # Break at line number
tb main                # Temporary breakpoint
b +N                   # Break N lines down from current source line (relative line offset)
b -N                   # Break N lines up from current source line
b func+10              # Break at function+offset (bytes/instructions)
b myfunc               # Break at function `myfunc` (also shown as b fn)
watch variable         # Break when variable changes
rwatch variable        # Break when variable is read
awatch variable        # Break on read/write access

# Managing breakpoints
info breakpoints       # List all breakpoints
delete 1               # Delete breakpoint 1
delete                 # Delete all breakpoints
disable 1              # Disable breakpoint 1
enable 1               # Enable breakpoint 1
clear                  # Clear breakpoint at current location
ignore 1 N             # Ignore breakpoint 1 the next N times
commands 1             # Set commands to run when breakpoint 1 is hit
```

## 📊 Register Inspection

```bash
# pwndbg enhanced register views
regs                  # Show all registers (pwndbg style)
i r                   # Info registers (standard gdb)
i r eax               # Show specific register
i r eax ebx ecx       # Show multiple registers

# Register modification
set $eax = 0x41414141 # Set register value
set $rsp = $rsp + 8   # Modify stack pointer
```

## 🧠 Memory Examination

### Basic Memory Commands

```bash
# Examine memory (x command)
x/10x $esp            # 10 hex values from ESP
x/10i $eip            # 10 instructions from EIP
x/s 0x401000          # String at address
x/10c $rax            # 10 characters from RAX

# Format specifiers (x uses format + size):
x/x   # Hexadecimal
x/d   # Decimal
x/u   # Unsigned decimal
x/o   # Octal
x/t   # Binary
x/c   # Character
x/s   # String
x/i   # Instruction
#  size modifiers:  b (byte), h (halfword 2B), w (word 4B), g (giant word 8B)

# Examples including the requested x/g (hex view with 64-bit units):
# Print 4 giant words (8-byte units) in hex from $rsp
x/4xg $rsp            # 4 hex 8-byte values from RSP
# Print 8 floats as 8-byte (double) units
x/8fg 0x601000        # format f (float/double) with g-size (64-bit units)
```

> Note: the `g` after the format is a size modifier meaning a giant word (64-bit) — e.g. `x/4xg` = 4 × hex × 8-byte units. See `help x` in gdb for details.

### pwndbg Enhanced Memory Commands

```bash
# pwndbg memory visualization
hexdump $esp          # Hex dump from ESP
hexdump $esp 64       # 64 bytes from ESP
telescope $esp        # Smart memory view with references
telescope $esp 20     # 20 entries from ESP
vmmap                 # Show memory mappings
nearpc                # Show instructions near PC
```

## 📋 Stack Analysis

```bash
# Stack inspection
stack                 # pwndbg stack view
stack 20              # Show 20 stack entries
backtrace             # Show call stack
bt                    # Show call stack (short)
bt full               # Show full backtrace with locals/args
frame                 # Show current frame
frame 1               # Switch to frame 1
up, u                 # Move up one frame (alias: u)
down, d               # Move down one frame (alias: d)
up N                  # Move up N frames (alias: u N)
down N                # Move down N frames (alias: d N)

# Stack manipulation
set $esp = $esp + 4   # Adjust stack pointer
```

> Note: `u` and `d` are common short aliases for `up` and `down` and accept a numeric argument, e.g. `u 2` moves two frames up.

## 🔧 Code Analysis

```bash
# Disassembly
disass main           # Disassemble function
disass main,+20       # Disassemble 20 bytes from main
disass $eip,+10       # 10 instructions from current
u $eip                # pwndbg disassemble at EIP
u $eip 20             # 20 instructions from EIP
nearpc                # Instructions around PC
context               # Show full context (pwndbg) — this refreshes the pwndbg interface
```

> Tip: `context` (or `ctx`) will refresh pwndbg's contextual UI (registers, code, stack) after stops — handy to redraw the interface after running commands that change state.

## 🔍 Search and Find

```bash
# Search in memory
search "string"       # Search for string
search 0x41414141      # Search for value
search -t string "hello"  # Search for string type
find &system           # Find system function

# Pattern search
pattern create 100    # Create cyclic pattern
pattern offset 0x41414141  # Find offset in pattern
cyclic 100            # Generate cyclic pattern
cyclic -l 0x61616161  # Find offset of pattern
```

## 🏗️ Heap Analysis

```bash
# Heap inspection
heap                  # Show heap information
bins                  # Show heap bins
fastbins              # Show fastbins
tcache                # Show tcache bins
vis                   # Visualize heap chunks
malloc_chunk addr     # Show chunk information
```

## 🔗 Dynamic Analysis

```bash
# Process information
pmap                  # Show memory mappings
vmmap                 # pwndbg memory map
got                   # Show GOT table
plt                   # Show PLT entries
checksec              # Security mitigations check

# Library functions
plt                   # Show PLT entries
got printf            # Show GOT entry for printf
```

## 🎮 Exploitation Helpers

```bash
# ROP gadgets
rop                   # Find ROP gadgets
rop --grep "pop rdi"  # Find specific gadgets
ropper                # External ROP tool integration

# Shellcode
shellcraft            # Generate shellcode
asm "mov eax, 1"      # Assemble instruction
disasm "\x31\xc0"     # Disassemble bytes
```

## 📝 Information Gathering

```bash
# Binary information
info functions        # List all functions
info variables        # List all variables
info files            # Show loaded files
info proc mappings    # Process memory mappings
checksec              # Security features
elfheader             # ELF header information
sections              # Show sections
segments              # Show segments

# Symbol information
info address main     # Address of symbol
whatis variable       # Type information
ptype structure       # Show structure definition
```

## 🔄 Process Control

```bash
# Process management
attach PID            # Attach to running process
detach                # Detach from process
kill                  # Kill current process
core-file core        # Load core dump
generate-core-file    # Generate core dump

# Multi-threading
info threads          # Show all threads
thread 2              # Switch to thread 2
thread apply all bt   # Backtrace all threads
```

## 🎨 Customization & Configuration

```bash
# pwndbg configuration
config                # Show all configuration
set context-sections "regs code stack"  # Customize context
set telescope-limit 10    # Set telescope entries
theme                 # Show available themes

# Context control
context               # Show full context
ctx                   # Show context (short)
context code          # Show only code context
context regs          # Show only registers
context stack         # Show only stack
```

## 📊 Advanced Memory Operations

```bash
# Memory operations
dump memory file.bin $esp $esp+100  # Dump memory to file
restore file.bin binary $esp        # Restore memory from file
compare-sections                     # Compare memory sections

# Memory protection
vmmap addr            # Check memory protection at address
mprotect addr size prot  # Change memory protection
```

## 🔍 Debugging Techniques

### Buffer Overflow Analysis

```bash
# Set up environment
set environment COLUMNS=200
set environment LINES=50
b main
r $(python -c "print 'A'*100")

# Analyze crash
info registers
x/10x $esp
bt
```

### Format String Analysis

```bash
# Test format string
r %x.%x.%x.%x.%x
telescope $esp
# Look for stack values
```

### Return-to-libc Analysis

```bash
# Find system function
p system
# Find "/bin/sh" string
search "/bin/sh"
# Check stack layout
telescope $esp 20
```

## 🛡️ Security Analysis

```bash
# Check binary protections
checksec              # All protections
checksec --file=binary # File-specific check

# ASLR status
cat /proc/sys/kernel/randomize_va_space

# Stack canary detection
info functions __stack_chk_fail
```

## ⚡ Essential pwndbg Commands

```bash
start                 # Start and break at entry
init                  # Initialize/restart
ctx                   # Show context
telescope $esp        # Smart stack view
vmmap                 # Memory layout
checksec              # Security check
search "string"       # Find string
pattern create 100    # Create pattern
cyclic 100            # Generate cyclic
disass main           # Disassemble
```

## 🔍 Memory Layout Analysis

```bash
# Understand the stack
info proc mappings    # Full memory map
vmmap stack           # Stack region only
vmmap heap            # Heap region only
vmmap libc            # libc mapping

# Library analysis
ldd binary            # Show linked libraries
info shared           # Loaded shared libraries
```

## 🖨️ Print / Examine / Display

```bash
# Print values (expressions)
print expr            # Print expression (alias: p expr)
p/x var               # Print var in hex
p/t var               # Print var in binary
p/a var               # Print as address
print &var            # Print address of var

# Use output-format with print
print /x var          # Print value in hex using format-suffix
print /f var          # Print floating point

# Examine memory at address (x) vs print
x/g $rsp              # Examine memory with unit size 'g' (64-bit)
```

## ✅ Stack Trace

```bash
bt                    # Backtrace (stack trace)
bt full               # Backtrace with local variables and args
backtrace             # Synonym for bt
frame                 # Show current frame info
```

## 📚 Help & Docs

```bash
help                  # GDB help
help x                # Help for x command
help break            # Help for break command
help print            # Help for print command
```
