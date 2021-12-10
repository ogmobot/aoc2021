#include <fstream>
#include <iostream>
#include <string>
#include <stack>
#include <vector>
#include <algorithm>

enum status_code {
    STATUS_OK,
    STATUS_CORRUPT,
    STATUS_INCOMPLETE
};

struct lineresult {
    status_code code;
    long score;
};

int getscore (char b) {
    switch (b) {
    case ')': return 3;
    case ']': return 57;
    case '}': return 1197;
    case '>': return 25137;
    case '(': return 1;
    case '[': return 2;
    case '{': return 3;
    case '<': return 4;
    default:  return 0;
    }
}

long stackscore (std::stack<char> brackets) {
    long score = 0;
    while (!brackets.empty()) {
        score *= 5;
        score += getscore(brackets.top());
        brackets.pop();
    }
    return score;
}

lineresult syntaxcheck(std::string line) {
    std::stack<char> brackets;
    for (int i = 0; i < line.length(); i++) {
        switch (line[i]) {
        case '(':
        case '[':
        case '{':
        case '<':
            brackets.push(line[i]);
            break;
        case ')':
            if (brackets.top() != '(') goto corrupt;
            brackets.pop();
            break;
        case ']':
            if (brackets.top() != '[') goto corrupt;
            brackets.pop();
            break;
        case '}':
            if (brackets.top() != '{') goto corrupt;
            brackets.pop();
            break;
        case '>':
            if (brackets.top() != '<') goto corrupt;
            brackets.pop();
            break;
        corrupt:
        default:
            return {STATUS_CORRUPT, getscore(line[i])};
        }
    }
    //if (brackets.empty()) return {STATUS_OK, 0};
    return {STATUS_INCOMPLETE, stackscore(brackets)};
}

int main(void) {
    std::ifstream inputfile("input10.txt");

    std::string line;
    lineresult res;

    long corrupt_total = 0;
    std::vector<long> auto_scores;
    while (std::getline(inputfile, line)) {
        res = syntaxcheck(line);
        if (res.code == STATUS_CORRUPT)
            corrupt_total += res.score;
        else if (res.code == STATUS_INCOMPLETE)
            auto_scores.push_back(res.score);
        else
            std::cout << "ERROR: line without errors encountered!" << std::endl;
    }
    // part 1
    std::cout << corrupt_total << std::endl;
    // part 2
    std::sort (auto_scores.begin(), auto_scores.end());
    std::cout << auto_scores.at(auto_scores.size()/2) << std::endl;
    return 0;
}
