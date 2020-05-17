; assembleur 32 bits Linux 
; programme : pgm3.asm
; affichage d'un registre 

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
hello db "Hello world.",10,0
szMessDebPgm: db "Fin normale du programme.",10,0
szRetourLigne db 10,0
;************************************************************
; Variables non initialisées segment 
;************************************************************
section .bss
sZoneConv:          resb 20 ; exemple de réservation de 20 octets
;************************************************************
; Code segment 
;************************************************************
section .text
global  main               ; déclaration de main en global
main:

    mov eax,WRITE          ; appel système write
    mov ebx,STDOUT         ; console sortie
    mov ecx,hello          ; adresse du message
    mov edx,14             ; longueur 
    int 0x80
    mov eax,WRITE          ; appel système write
    mov ebx,STDOUT         ; console sortie
    mov ecx,szMessDebPgm   ; adresse du message
    mov edx,26             ; longueur 
    int 0x80
                           ; Fin standard du programme
    mov eax,EXIT           ; signalement de fin de programme
    xor ebx,ebx            ; code retour du programme
    int 0x80               ; interruption : retour à Linux
