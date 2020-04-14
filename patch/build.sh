#!/usr/bin/env bash

echo Building Super Metroid + Zelda 3 Vanilla Patch

cd build
python3 create_canvas.py 00.sfc ff.sfc
./asar --no-title-check --symbols=wla --symbols-path=../build/zsm.sym ../src/main.asm 00.sfc
./asar --no-title-check --symbols=wla --symbols-path=../build/zsm.sym ../src/main.asm ff.sfc
python3 create_diff.py -f bin 00.sfc ff.sfc ../dist/vanilla-zsm.bin
rm 00.sfc ff.sfc

gzip ../dist/vanilla-zsm.bin

cd ..
echo Done
