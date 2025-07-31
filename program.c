#include <stdlib.h>
#include <unistd.h>

int main() {
    char var[7];
    read(1, var, 7);
    write(1, var, 7);
    exit(0);
}