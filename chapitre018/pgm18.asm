; assembleur 32 bits Linux 
; programme : pgm18.asm
; variables locales dans routines
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
szMessDebPgm:   db "Début du programme.",10,0
szMessFinPgm:   db "Fin normale du programme.",10,0
szRetourLigne:   db 10,0

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
    mov ebp,esp
    call afficherPiles
    mov ebx,1
    mov ecx,2
    mov edx,3
    push 4
    call routine1
    afficherLib "Retour programme principal"
    call afficherPiles


    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme


fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
;************************************************************
;     routine 1
;************************************************************
; paramètre1  : 
routine1:
    enter 0,0
    sub esp,4                 ; réserve 4 octets sur la pile
    push ebx                  ;sauvegarde des registres
    push ecx
    push edx
    pushf
    afficherLib "Routine1"
    mov ecx, [ebp + 8]        ; recup parametre 1
    add ecx,5                 ; calcul quelconque
    mov [ebp-4],ecx           ; save
    call afficherPiles
    push 20
    call routine2
    mov ecx,[ebp-4]
    push ecx
    call afficherReg
    push 6
    call routine3
    popf
    pop edx
    pop ecx
    pop ebx                     ; restaur des registres
    add esp,4
    leave
    ret 4                       ; 1 paramètre
;************************************************************
;     routine 2
;************************************************************
; paramètre1  : 
routine2:
    enter 16,0                 ; réserve 16 octets sur la pile
    push ebx                  ;sauvegarde des registres
    push ecx
    push edx
    pushf
    afficherLib "Routine2"
    mov eax, [ebp + 8]        ; recup parametre 1
    add eax,25                 ; calcul quelconque
    mov ecx,2
    mov ebx,ebp
    sub ebx,16
    mov [ebx+(ecx * 4)],eax
    call afficherPiles
    popf
    pop edx
    pop ecx
    pop ebx                     ; restaur des registres
    leave
    ret 4                       ; 1 paramètre
;************************************************************
;     routine 3
;************************************************************
; paramètre1  : 
routine3:
%define var1 [ebp-4]          ; definit le nom de la zone 1
%define var2 ebp-8            ; definit le nom de la zone 2 (2ième façon)
    enter 8,0                 ; réserve 8 octets sur la pile pour les 2 zones
    push ebx                  ;sauvegarde des registres
    push ecx
    push edx
    pushf
    afficherLib "Routine3"
    mov eax, [ebp + 8]        ; recup parametre 1 passé à routine 3
    mov ebx,[ebp]             ; recup pile de base routine 1
    mov ecx,[ebx+8]           ; recup parametre 1 passé à routine 1
    add eax,ecx
    mov var1,eax              ; stocke eax dans la zone 1
    mov dword[var2],64        ; stocke 64 (0x40) dans la zone 2
    push eax
    call afficherReg
    call afficherPiles
    popf
    pop edx
    pop ecx
    pop ebx                     ; restaur des registres
    leave
    ret 4                       ; 1 paramètre