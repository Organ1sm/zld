#!/bin/bash

test_name=$(basename "$0" .sh)
t="out/tests/$test_name"

mkdir -p "$t"

cat <<EOF | zig cc -target riscv64-linux-gnu -o "$t/a.o" -c -xc -
#include <stdio.h>
int main(void) {
    printf("Hello, World\n");
    return 0;
}
EOF

