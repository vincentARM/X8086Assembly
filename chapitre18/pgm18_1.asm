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
;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
szMessDebPgm:    db "Début du programme.",10,0
szMessFinPgm:    db "Fin normale du programme.",10,0
szRetourLigne:   db 10,0
szFin:           db "fin",10,0
szFormat1:       db "Message : %s ",0
szFormat2:       db "Valeur : %d %d %d ",10,0
szFormat3:       db "Valeur : %d %d  ",10,0

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
extern printf
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess
    mov ebp,esp
    mov ebx,1
    mov ecx,2
    mov edx,3
    push esp
    call afficherReg16
    push szFin               ; affichage d'un message
    push szFormat1           ; format d'affichage
    call printf              ; appel fonction C
    add esp,8                ; la pile doit être alignée
    push esp
    call afficherReg16

    push ebx                 ; affichage de valeurs
    push ecx
    push edx
    push szFormat2
    call printf
    add esp,16               ; la pile doit être alignée

    mov eax,22               ; affichage de valeurs
    push 3
    push 2
    push 1
    push szFormat2
    call printf
    push eax                 ; pour vérifier le retour
    call afficherReg
    add esp,16               ; la pile doit être alignée
                             ; pour test non alignement pile
    sub esp,4                ; utile ou pas ?
    push 2
    push 1
    push szFormat3
    call printf
    add esp,16               ; réalignement pile
    push esp
    call afficherReg16

    afficherLib "Vérification registres."
    mov ebx,1
    mov ecx,2
    mov edx,3
    mov ebp,4
    mov edi,5
    mov esi,6
    push szFin               ; affichage d'un message
    push szFormat1           ; format d'affichage
    call printf              ; appel fonction C
    add esp,8                ; la pile doit être alignée
    push ebx
    call afficherReg
    push ecx
    call afficherReg
    push edx
    call afficherReg
    push ebp
    call afficherReg
    push edi
    call afficherReg
    push esi
    call afficherReg

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme


fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
