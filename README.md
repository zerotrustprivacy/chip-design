# Chip Design

My practice code as I learn chip design: C++ programming fundamentals first, then Verilog and FPGA. Coursework is from the NYU Tandon BASICS program.

Every time I push code, GitHub automatically compiles and runs every C++ program here. Check the **Actions** tab: ✅ means everything built and ran.

## Part 1: Programming fundamentals (C++)

| Folder | Topic | Status |
|---|---|---|
| `01-hello-world` | First program | ✅ |
| `02-number-systems` | Converting decimal to binary | ✅ |
|  | Data types and expressions | ⬜ |
|  | Branching (if / else) | ⬜ |
|  | Loops | ⬜ |
|  | Functions | ⬜ |
|  | Arrays and strings | ⬜ |

## Part 2: Chip design (Verilog)

Coming in the second half of the course: logic gates, Verilog, testing, FPGA prototyping, and a capstone chip design.

---

## Adding a new program

1. Make a new folder, numbered in order, like `03-data-types`.
2. Put your `.cpp` file inside. Each program needs its own `main()`.
3. Commit, and GitHub builds and runs it automatically.

Use dashes instead of spaces in file and folder names.

## Run a program on your own computer

```
g++ -std=c++17 -Wall -o program 02-number-systems/to_binary.cpp
./program
```
