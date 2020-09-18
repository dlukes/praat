#!/bin/sh

# eopkg info -f luajit

# get symbols in binary
# nm -an libluapraa.a | c++filt

# might possibly also need -ldl -lm
gcc -Wl,--trace -I/usr/include/luajit-2.0 -L/usr/lib64 -lluajit-5.1 embed.c -o embed  && ./embed
