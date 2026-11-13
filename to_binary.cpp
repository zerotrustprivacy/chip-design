// to_binary.cpp -- converts numbers from decimal to binary
// Chips store everything in binary (1s and 0s), so this comes up constantly
// in the chip design half of the course.

#include <iostream>
#include <string>

// Turns a number like 5 into its binary form "101"
std::string to_binary(int number) {
    if (number == 0) {
        return "0";
    }
    std::string result = "";
    while (number > 0) {
        int bit = number % 2;                  // remainder: 0 or 1
        result = std::to_string(bit) + result; // add it to the front
        number = number / 2;                   // move to the next bit
    }
    return result;
}

int main() {
    for (int n = 0; n <= 10; n++) {
        std::cout << n << " in binary is " << to_binary(n) << std::endl;
    }
    return 0;
}
