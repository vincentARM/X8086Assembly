echo Compilation 32 bits de $1 avec linker GCC
#appel nasm
nasm -f elf $1.asm
#appel linker GCC 
gcc  -Wall  -o $1 $1.o ../routines.o -e main
ls -l $1*
