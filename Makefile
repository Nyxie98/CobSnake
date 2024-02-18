main: main.cbl
	cobc -x main.cbl raylib.c -O3 -L./raylib/ -lraylib -Iraylib -lc -lm