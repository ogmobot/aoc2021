#include <stdio.h>

int main(void) {
    FILE *input = fopen("input.txt", "r");
    char line[1024];
    /* discard first line */
    fgets(line, 1024, input);

    int product = 1;
    int a = 0, b = 0, c = 0;
    while (fgets(line, 1024, input)) {
        sscanf(line, "%d, %d, %d", &a, &b, &c);
        product *= (a+b+c);
    }
    printf("%d\n", product);
    fclose(input);
    return 0;
}
