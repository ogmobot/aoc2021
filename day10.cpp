#include <algorithm>
#include <fstream>
#include <iostream>
#include <map>
#include <stack>
#include <string>
#include <vector>

struct checkresult {
    enum {
        STATUS_OK,
        STATUS_CORRUPT,
        STATUS_INCOMPLETE
    } code;
    long score;
};

const std::map<char, long> bracketscore {
    {')',     3},
    {']',    57},
    {'}',  1197},
    {'>', 25137},
    {'(',     1},
    {'[',     2},
    {'{',     3},
    {'<',     4}
};

const std::map<char, char> bracketpairs {
    {'(', ')'},
    {'[', ']'},
    {'{', '}'},
    {'<', '>'}
};

long stackscore (std::stack<char> brackets) {
    long score = 0;
    while (!brackets.empty()) {
        score *= 5;
        score += bracketscore.at(brackets.top());
        brackets.pop();
    }
    return score;
}

checkresult syntaxcheck(std::string line) {
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
        case ']':
        case '}':
        case '>':
            if (bracketpairs.at(brackets.top()) != line[i])
                return {checkresult::STATUS_CORRUPT, bracketscore.at(line[i])};
            brackets.pop();
            break;
        }
    }
    //if (brackets.empty()) return {checkresult::STATUS_OK, 0};
    return {checkresult::STATUS_INCOMPLETE, stackscore(brackets)};
}

int main(void) {
    std::ifstream inputfile("input10.txt");

    std::string line;
    checkresult res;

    long corrupt_total = 0;
    std::vector<long> auto_scores;
    while (std::getline(inputfile, line)) {
        res = syntaxcheck(line);
        switch (res.code) {
        case checkresult::STATUS_CORRUPT:
            corrupt_total += res.score;
            break;
        case checkresult::STATUS_INCOMPLETE:
            auto_scores.push_back(res.score);
            break;
        case checkresult::STATUS_OK:
        default:
            std::cout << "ERROR: line without errors encountered!" << std::endl;
            break;
        }
    }
    // part 1
    std::cout << corrupt_total << std::endl;
    // part 2
    std::sort (auto_scores.begin(), auto_scores.end());
    std::cout << auto_scores.at(auto_scores.size()/2) << std::endl;
    return 0;
}

/* The C++ standard library has a lot of useful stuff in it, and my familiarity
   with C makes it relatively easy to use. (That said, I'm only using a tiny
   part of the language in this solution.)
   C++'s biggest flaw is probably its backwards compatibility with C. The
   original version of this program used `goto` in the syntaxcheck function.
   (I later refactored the function to use maps instead, which I didn't know
   about when I wrote the original solution.)
*/
