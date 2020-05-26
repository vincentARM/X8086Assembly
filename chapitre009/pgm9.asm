; assembleur 32 bits Linux 
; programme : pgm6_1.asm
; affichage d'un registre en base 10 
; verification des limites des instructions arithmètiques

bits 32
;************************************************************
;             fichier include 
;************************************************************
%include "includeFonction.asm"
;************************************************************
;               Constantes 
;************************************************************
 


;************************************************************
; Variables initialisees segment 
;************************************************************
section .data

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss

;************************************************************
; Code segment 
;************************************************************
section .text
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess
    afficherLib "Affichage registre."
    mov eax,1000
    push eax
    call afficherReg


    push szMessFinPgm
    call afficherMess
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    xor ebx,ebx          ; code retour du programme
    int 0x80             ; interruption : retour à Linux
