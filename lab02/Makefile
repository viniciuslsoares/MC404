lab02.o: lab02.s
	clang-15	--target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax lab02.s -c -o lab02.o

lab02.x: lab02.o
	ld.lld-15 lab02.o -o lab02.x

desmonte.txt: lab02.x
	llvm-objdump-15 -D lab02.x > desmonte.txt

all: desmonte.txt