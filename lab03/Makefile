lab03.s: lab03.c
	clang-15	--target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax lab03.c -S -o lab03.s

lab03.o: lab03.s
	clang-15	--target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax lab03.s -c -o lab03.o

lab03.x: lab03.o
	ld.lld-15 lab03.o -o lab03.x

desmonte.txt: lab03.x
	llvm-objdump-15 -D lab03.x > desmonte.txt

all: lab03.x