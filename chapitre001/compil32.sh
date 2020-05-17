echo Compilation 32 bits de $1
#appel nasm
nasm -f elf $1.asm
#appel linker
ld -m elf_i386 $1.o -o $1  -e main
ls -l $1.*
