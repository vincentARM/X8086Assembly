; assembleur 32 bits Linux 
; programme : pgm2_3.asm
; affichage d'un message avec calcul statique de la longueur

;************************************************************
; Variables initialisées segment 
;************************************************************
section .data
hello:      db "Hello world.",10
LGHELLO    equ $ - hello
       db "Bonjour.",10
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
    mov eax,4              ; appel système write
    mov ebx,1              ; console sortie
    mov ecx,hello          ; adresse du message
    mov edx,LGHELLO        ; longueur 
    int 0x80

                           ; Fin standard du programme
    mov eax,1              ; signalement de fin de programme
    mov ebx,0              ; code retour du programme
    int 0x80               ; interruption : retour à Linux
