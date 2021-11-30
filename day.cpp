#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

int main(void) {
    std::ifstream inputfile("input.txt");

    int product = 1;
    std::string line;
    std::getline(inputfile, line); // discard first line

    while (std::getline(inputfile, line)) {
        std::stringstream ss(line);
        int sum = 0;
        while (ss.good()) {
            std::string substr;
            std::getline(ss, substr, ',');
            sum += std::stoi(substr);
        }
        product *= sum;
    }
    std::cout << product << std::endl;
    return 0;
}
