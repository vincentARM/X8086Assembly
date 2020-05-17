; assembleur 32 bits Linux 
; programme : pgm1_0.asm
; programme simple

global  main               ; déclaration de main en global
main:

                           ; Fin standard du programme
    mov eax,1              ; signalement de fin de programme
    ;mov ebx,5              ; code retour du programme
    mov ebx,255            ; limité à 255 (1 octet)
    int 0x80               ; interruption : retour à Linux
