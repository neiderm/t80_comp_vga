#!/bin/bash

TEST_ASM="./test.asm"
echo z80asm $TEST_ASM

#z80asm  ./basys3_multicomp_z80.srcs/sources_1/imports/mem/test.asm  a.bin
z80asm $TEST_ASM


od -v  -t x1 a.bin | cut -c 9- | tr '\ ' '\n' > ./z80test_hex.dat

z80dasm  -t a.bin | head -n10
