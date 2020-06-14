; assembleur 32 bits Linux 
; programme : pgm21.asm
; nombres en virgule flottante
; les routines d'affichage sont déportées dans le fichier routines.asm
; les constantes sont déportées dans le fichier constantes32.asm
; les macros sont déportées dans le fichier macros32.asm
bits 32

;************************************************************
;               Constantes 
;************************************************************
;fichier des constantes générales
%include "../constantes32.asm"
 
;************************************************************
;               Macros
;************************************************************
;fichier des macros générales
%include "../macros32.asm"

;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
szMessDebPgm:    db "Début du programme.",10,0
szMessFinPgm:    db "Fin normale du programme.",10,0
szRetourLigne:   db 10,0
szFin:           db "fin",10,0

fNombre1:        dd 1.234567e20 ; simple précision float
fqNombre2:       dq 1.2345678901234e20 ; double−precision float
fqNombre6:       dq 4.5         ; double−precision float

dUn:             dd 1           ; entier
fqnombre7:       dd 2.49        ; simple précision float

szFormat:        db "Nombre virgule flottante : %e",10,0
szFormat1:        db "Nombre virgule flottante : %10.15g",10,0

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZone1:             resd 1
fqNombre3:          resq 1
fqNombre4:          resq 1
fqNombre5:          resq 1

dRes1:              resd 1
;************************************************************
; Code segment 
;************************************************************
section .text
global  main             ; déclaration de main en global
extern printf
main:
    mov ebp,esp
    push szMessDebPgm
    call afficherMess
    afficherRegs "Registres début :"
    finit                    ; initialise à zéro tous les registres
    fld dword[fNombre1]      ; charge un nombre dans st0
    fstp qword[fqNombre3]    ; conversion en double précision

    push dword[fqNombre3+4]  ; 2ième partie du nombre
    push dword[fqNombre3]    ; 1ère partie du nombre
    push szFormat            ; format
    call printf
    add sp,12                ; alignement piles 

    push dword [fqNombre2+4] ; double précision
    push dword [fqNombre2]
    push szFormat1           ; test autre format
    call printf
    add sp,12

    push fNombre1            ; verif codage des nombres en mémoire
    push 2
    call afficherMemoire

    afficherRegs "Registres N° 1 :"

    
    fld qword [fqNombre6]    ; charge un nombre dans st0
    fild dword[dUn]          ; décale st0 dans st1 etcharge un entier dans st0
    fadd st0,st1             ; aditionne st1 à st0

    fstp qword[fqNombre3]    ; stocke st0 et le dépile donc st0 contient st1

    push dword[fqNombre3+4]  ; 2ième partie du nombre
    push dword[fqNombre3]    ; 1ère partie du nombre
    push szFormat            ; format
    call printf
    add sp,12                ; alignement piles 

    fstp qword[fqNombre3]    ; stocke st0 et le dépile  

    push dword[fqNombre3+4]  ; 2ième partie du nombre
    push dword[fqNombre3]    ; 1ére partie du nombre
    push szFormat            ; format
    call printf
    add sp,12                ; alignement piles 

    fstp qword[fqNombre3]    ; stocke st0 mais est égal à nan

    push dword[fqNombre3+4]  ; 2ième partie du nombre
    push dword[fqNombre3]    ; 1ére partie du nombre
    push szFormat            ; format
    call printf
    add sp,12                ; alignement piles 

    fld dword[fqnombre7]
    fild dword[dUn]          ; décale st0 dans st1 et charge un entier dans st0
    faddp st1,st0            ; aditionne st1 à st0 et depile donc st1 devient st0 

    fist dword[dRes1]        ; stocke un entier arrondi en mémoire sans depiler
    mov eax,[dRes1]
    afficherRegs "Registres apres fist :"

    fst qword[fqNombre3]    ; stocke st0 en mémoire sans le dépiler

    push dword[fqNombre3+4]  ; 2ième partie du nombre
    push dword[fqNombre3]    ; 1ére partie du nombre
    push szFormat            ; format
    call printf
    add sp,12                ; alignement piles 

    fstp qword[fqNombre3]    ; stocke st0 en mémoire et le dépile

    push dword[fqNombre3+4]  ; 2ième partie du nombre
    push dword[fqNombre3]    ; 1ére partie du nombre
    push szFormat            ; format
    call printf
    add sp,12                ; alignement piles 

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme

fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
;************************************************************
;           exemple de routine
;************************************************************
; le paramètre 1 contient une valeur
routine1:
    enter 0,0            ; prologue
    pusha                ; save registres généraux
    pushf                ; save indicateurs
    mov eax, [ebp + 8]   ; recup de la valeur à convertir
    afficherLib "Routine 1"
    call afficherPiles
    popf                 ; restaur indicateurs
    popa                 ; restaur registres généraux
    leave                ; epilogue
    ret 4                ; car 1 paramètre en entrée