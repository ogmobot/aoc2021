//Run wtih dmd -run .
import std.stdio;

void main() {
    File inputfile = File("input.txt", "r");
    inputfile.readln(); // discard first line

    auto product = 1;
    auto a = 0, b = 0, c = 0;
    while (inputfile.readf!"%d, %d, %d\n"(a, b, c)) {
        product *= (a+b+c);
    }
    writef("%d\n", product);
    inputfile.close();
}
