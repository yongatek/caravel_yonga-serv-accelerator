#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

from sys import argv

# Use a binary file. 'example.bin'
binfile = '../c/matmul_bench_acc.bin'
nwords = 2560

with open(binfile, "rb") as f:
    bindata = f.read()

assert len(bindata) < 4*nwords                                # len() finds number of bytes
assert len(bindata) % 4 == 0
k = 0
kkk = 1
o_str = ''
o_str = o_str + ("static const uint8_t serv_code" + f"[{len(bindata)}]={{")
for i in range(nwords):
    if i < len(bindata) // 1:
        w = bindata[1*i : 1*i+1]
        if(k==15):
            o_str = o_str + ('0x'+"%02x" % (w[0]))
        else:
            o_str = o_str + ('0x'+"%02x," % (w[0]))
        k += 1
    if k == 16:
        k=0
        o_str = o_str + (",\n    ")

o_str = o_str[:-1]
o_str = o_str + "};"
print(o_str)