; assembleur 32 bits Linux 
; programme : calculInvRac.asm
; routine de calcul de l'inverse d'une racine carrée
; voir https://fr.wikipedia.org/wiki/Racine_carr%C3%A9e_inverse_rapide

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

szFormat:        db "Nombre virgule flottante : %e",10,0

fNombre1:        dd 0.15625    ; simple précision float
fNombre2:        dd 4.0        ; 
fConst1:         dd 0.5        ; constante
fConst2:         dd 1.5        ; constante 

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZone1:             resd 1      ; zone stockage résultat en 32 bits
sZone2:             resq 1      ; zone conversion en 64 bits
;************************************************************
; Code segment 
;************************************************************
section .text
global  main              ; déclaration de main en global
extern printf
main:
    mov ebp,esp
    push szMessDebPgm
    call afficherMess

    push dword[fNombre1]   ; valeur à calculer
    push sZone1            ; adresse du résultat
    call racineCarInv      ; appel routine

    fld dword[sZone1]      ; charge le résultat dans st0
    fstp qword[sZone2]     ; conversion en double précision

    push dword[sZone2+4]   ; 2ième partie du nombre
    push dword[sZone2]     ; 1ère partie du nombre
    push szFormat          ; format
    call printf
    add sp,12              ; alignement piles 


    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme

fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
;************************************************************
;          Calcul inverse racine carrée
;************************************************************
; le paramètre 1 contient une valeur en virgule flottante
; le parametre 2 contient l'adresse de stockage du résultat (en 32 bits)
racineCarInv:
    enter 4,0               ; prologue
    push eax
    push ebx                ; save registres généraux
    pushf                   ; save indicateurs
    fld dword [fConst2]     ; charge la constante 1.5 utilisée en fin de calcul
    fld dword[ebp + 12]     ; charge le nombre
    fmul dword [fConst1]    ; multiplié  par constante 0.5 dans st0 = X
    mov eax, [ebp + 12]     ; charge le nombre comme un entier
    shr eax,1               ; décale une position à droite
    ;mov ebx,0x5f3759df      ; charge le nombre magique original
    mov ebx,0x5f375a86      ; charge un nombre plus précis : voir wikipedia
    sub ebx,eax             ; enleve le résultat précédent
    mov [ebp-4],ebx         ; et stockage sur la pile
    fld dword[ebp-4]        ; puis rechargement en float
    fmul                    ; multiplié par X (qui était passé en st1)
    fld dword[ebp-4]        ; puis nouveau rechargement
    fmul                    ; et nouvelle multiplication
    fsub                    ; et soustraction avec la constante 1.5 chargée au début
    fld dword[ebp-4]        ; puis nouveau rechargement
    fmul                    ; et multiplication
    mov eax,[ebp+8]         ; récup adresse de stockage sur la pile
    fst dword [eax]         ; et stockage du dernier résultat
    popf                    ; restaur indicateurs
    pop ebx                 ; restaur registres généraux
    pop eax
    leave                   ; epilogue
    ret 8                   ; car 2 paramètres en entrée