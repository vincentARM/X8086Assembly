; assembleur 32 bits Linux 
; programme : pgm20_1.asm
; Affichage de tous les registres
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
    mov ebp,esp

    call afficherPiles

    mov eax,1                ; pour verifier les contenus de chaque registres
    mov ebx,2
    mov ecx,3
    mov edx,4
    mov esi,5
    mov edi,6
    call afficherRegistres   ; affichage de tous les registres


    afficherRegs "Registres N° 1 :"   ; utilisation de la macro

    sub esp,4
    afficherRegs "Registres N° 2 :"   ; utilisation de la macro
    add esp,4

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme


fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
