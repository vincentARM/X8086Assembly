; assembleur 32 bits Linux 
; programme : pgm2.asm
; routine d'affichage avec calcul de la longueur
; passage paramètre par un registre 

bits 32

;************************************************************
;               Constantes 
;************************************************************
%define STDOUT 1
EXIT  equ 1
WRITE equ 4 
;************************************************************
; Variables initialisées segment 
;************************************************************
section .data
szHello db "Bonjour le monde.",10,0
szMessFinPgm: db "Fin normale du programme.",10,0

;************************************************************
; Variables non initialisées segment 
;************************************************************
section .bss
;************************************************************
; Code segment 
;************************************************************
section .text
global  main               ; déclaration de main en global
main:

    mov eax,szHello        ; adresse du message
    call afficherMess

    mov eax,szMessFinPgm   ; adresse du message de fin
    call afficherMess
                           ; Fin standard du programme
    mov eax,EXIT           ; signalement de fin de programme
    xor ebx,ebx            ; code retour du programme
    int 0x80               ; interruption : retour à Linux
;************************************************************
;               Affichage chaine de caractères
;************************************************************
; le registre eax contient l'adresse de la chaine
afficherMess:
    mov ecx,eax         ; save adresse string
    mov edx,0           ; init compteur longueur
.A1:                    ; boucle comptage caractères
    cmp byte [eax,edx],0
    je .A2
    add edx,1
    jmp .A1
.A2:
    mov eax,WRITE       ; appel système write
    mov ebx,STDOUT      ; console sortie
    int 0x80
    ret                 ; retour programme principal