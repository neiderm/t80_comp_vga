#!/bin/bash

z80asm  ./test.asm

#pasmo --bin  ./basys3_multicomp_z80.srcs/sources_1/imports/mem/test.asm  a.bin

od -v  -t x1 a.bin | cut -c 9- | tr '\ ' '\n' > ./z80test_hex.dat

z80dasm  -t a.bin
