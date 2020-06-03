; assembleur 32 bits Linux 
; programme : pgm15_1.asm
; saisie de chaines de caractères au clavier.
; les routines d'affichage sont déportées dans le fichier routines.asm

bits 32

;************************************************************
;               Constantes 
;************************************************************
STDIN    equ 0
STDOUT   equ 1
EXIT     equ 1
READ     equ 3
WRITE    equ 4 
LGZONEREC   equ 100
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
szMessInviteSai:   db  "Veuillez saisir un texte :",10,0 
szMessInviteSaiVal:   db  "Veuillez saisir un nombre :",10,0 
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
szBuffer:        resb LGZONEREC

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
    push szMessInviteSai
    call afficherMess
    push szBuffer
    call lireClavier
    push szBuffer
    push 2
    call afficherMemoire
    push eax
    call afficherReg

    push szMessInviteSaiVal
    call afficherMess
    push szBuffer
    call lireClavier
    push szBuffer
    push 2
    call afficherMemoire

    push szBuffer
    call conversionAtoD
    push eax
    call afficherReg10S

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx          ; code retour Ok du programme
    jmp fin

fin:
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    int 0x80             ; interruption : retour à Linux
;************************************************************
;     lecture chaine au clavier
;************************************************************
; paramètre1  : adresse de la zone receptrice
lireClavier:
    enter 0,0
    push ebx                  ;sauvegarde des registres
    push ecx
    push edx
    pushf
    mov eax,READ
    mov ebx,STDIN
    mov ecx,[ebp+8]           ; récuperation adresse chaine
    mov edx,LGZONEREC
    int 0x80

    popf
    pop edx
    pop ecx
    pop ebx                     ; restaur des registres
    leave
    ret 4                       ; 1 paramètre

;************************************************************
;     conversion chaine ASCII en entier signé dans registre eax
;************************************************************
; paramètre1  : adresse de la chaine
; retourne la valeur dans eax
conversionAtoD:
    enter 0,0
    push ebx                  ;sauvegarde des registres
    push ecx
    push edx
    push esi
    push edi
    pushf
    mov esi,[ebp+8]           ; récuperation adresse chaine
    mov ecx,0                 ; indice caractère
    xor edi,edi               ; signe positif
    xor eax,eax               ; resultat = 0
    xor ebx,ebx               ; raz registre reception
.A1:                          ; debut de boucle début de chaine
    mov bl,[esi,ecx]          ; lire un caractère
    cmp bl,0                  ; fin de chaine
    je .A100
    cmp bl,0xA                ; fin de ligne
    je .A100
    cmp bl,'-'                ; signe moins
    je .A2
    cmp bl,'+'                ; signe plus éventuel
    je .A3
    cmp bl,' '                ; blanc
    je .A3
    jmp .A4                   ; chiffre
.A2:
    mov edi,1                 ; signe negatif
.A3:
    inc ecx                   ; caractère suivant
    jmp .A1                   ; et boucle
                              ; traitement des chiffres
.A4:                          ; chiffre
    sub bl,48                 ; caractère ASCII -> chiffre 0 à 9
    cmp bl,10                 ; mais est ce bien un chiffre ?
    jge .A5                   ; non
    mov edx,10
    mul edx                   ; multiplie eax par 10
    jo .A99                   ; overflow ?
    add eax,ebx               ; et ajout du nouveau chiffre
    js  .A99                  ; overflow ?
.A5:
    inc ecx                   ; caractère suivant
    mov bl,[esi,ecx]
    cmp bl,0                  ; fin de chaine
    je .A8
    cmp bl,0xA                ; fin de ligne
    je .A8
    jmp .A4
.A8:
    cmp edi,0                 ; signe ?
    je .A100
    neg eax                   ; negatif 
    jmp .A100
.A99:                         ; overflow
    push szMessDep
    call afficherMess
    mov eax,0
.A100:
    popf
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx                     ; restaur des registres
    leave
    ret 4                       ; un paramètre
szMessDep:       db "Dépassement de capacité !!!",10,0

