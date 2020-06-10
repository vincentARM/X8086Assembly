; assembleur 32 bits Linux 
; programme : pgm18_1.asm
; Appel d'une fonction du C
; les routines d'affichage sont déportées dans le fichier routines.asm

bits 32

;************************************************************
;               Constantes 
;************************************************************
STDIN  equ 0
STDOUT equ 1
EXIT   equ 1
READ   equ 3
WRITE  equ 4 

;************************************************************
;               Macros
;************************************************************
%macro afficherLib 1
    jmp %%endstr
%%str: db %1,10,0
%%endstr:
    push %%str
    call afficherMess
%endmacro
%macro afficherSeg 1
    jmp %%endstr
%%str: db %1,10,0
%%endstr:
    push %%str
    call afficherMess
    call afficherSegments
%endmacro
;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
szMessDebPgm:    db "Début du programme.",10,0
szMessFinPgm:    db "Fin normale du programme.",10,0
szRetourLigne:   db 10,0
szFin:           db "fin",10,0

szMessAffExtra:          db "cs: "
sCS              times 8 db ' '
                 db " ds: "
sDS              times 8 db ' '
                 db " ss: "
sSS              times 8 db ' '
                 db " es: "
sES              times 8 db ' '
                 db " fs: "
sFS              times 8 db ' '
                 db " gs: "
sGS              times 9 db ' '
                 db 10,0

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss

;************************************************************
; Code segment 
;************************************************************
section .text
extern afficherMess,afficherBinaire,afficherReg10S,afficherReg,conversion16
extern afficherReg16,afficherMemoire,conversion10S,afficherPiles,afficherFlags
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess

    mov eax,cs              ; copie segment cs
    push eax                ; et affichage
    call afficherReg16

    call afficherSegments   ; affichage de tous les segments

    mov eax,[ds:szMessDebPgm] ; accés à la mémoire avec un segment
    push eax 
    call afficherReg16
    lea eax,[ds:szMessDebPgm] ; récup de l'adresse
    push eax                  ; et affichage
    push 2
    call afficherMemoire

    afficherSeg "Test macro Affichage segments"

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme


fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
;************************************************************
;               affichage des registres de segments
;************************************************************
; pas de parametres
afficherSegments:
    enter 0,0
    pusha                     ;sauvegarde des registres
    pushf                     ; sauvegarde des flags
    push cs
    push sCS
    call conversion16
    mov byte [sCS+8],' '
    push ds
    push sDS
    call conversion16
    mov byte [sDS+8],' '
    push ss
    push sSS
    call conversion16
    mov byte [sSS+8],' '
    push es
    push sES
    call conversion16
    mov byte [sES+8],' '
    push fs
    push sFS
    call conversion16
    mov byte [sFS+8],' '
    push gs
    push sGS
    call conversion16
    mov byte [sGS+8],' '

    push szMessAffExtra
    call afficherMess

.A100:                            ; fin de la routine
    popf
    popa                          ; restaur des registres
    leave
    ret