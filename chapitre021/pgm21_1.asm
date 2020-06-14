; assembleur 32 bits Linux 
; programme : pgm21_1.asm
; nombres en virgule flottante  routine de saisie 
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
szMessSaisie:    db "Veuillez saisir un nombre avec virgule : ",10,0
szMessCarre:     db "Carré = %10.10e ",10,0
szMessRacine:    db "Racine carrée = %10.10e ",10,0
szMessAbs:       db "Valeur absolue = %10.10e ",10,0
szMessSigne:     db "Inversion signe = %10.10e ",10,0
szMessArrondi:   db "Arrondi = %10.10e ",10,0
szMessF2x:       db "Cosinus = %10.10e ",10,0
szMessGrand:     db "Plus grand que pi",10,0
szMessPetit:     db "Plus petit que pi",10,0

szFormat:        db "Nombre virgule flottante : %e",10,0
szFormat1:       db "Nombre virgule flottante : %10.15g",10,0

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
;sZone1:             resd 1
fqNombreAff:        resq 1

fqNbsaisie:         resq 1

;************************************************************
; Code segment 
;************************************************************
section .text
global  main             ; déclaration de main en global
extern printf,conversionAtoD
main:
    mov ebp,esp
    push szMessDebPgm
    call afficherMess
    finit                     ; initialise à vide tous les registres st0 à st7
    push szMessSaisie         ; message de saisie
    call afficherMess
    push fqNbsaisie           ; zone réceptrice après conversion en float
    call saisieFloat          ; saisie clavier
                              ; affichage pour controle
    push dword[fqNbsaisie+4]  ; 2ième partie du nombre
    push dword[fqNbsaisie]    ; 1ère partie du nombre
    push szFormat             ; format
    call printf
    add sp,12                 ; alignement piles 

    fld qword[fqNbsaisie]     ; charge la valeur saisie dans st0
    fld qword[fqNbsaisie]
    fmul
    ;fmul st0,st0
    ;fmul qword[fqNbsaisie]

    fstp qword[fqNombreAff]
    push dword[fqNombreAff+4]  ; 2ième partie du nombre
    push dword[fqNombreAff]    ; 1ère partie du nombre
    push szMessCarre           ; message
    call printf
    add sp,12                  ; alignement piles 

    fld qword[fqNbsaisie]      ; charge la valeur saisie dans st0
    fsqrt 

    fstp qword[fqNombreAff]
    push dword[fqNombreAff+4]  ; 2ième partie du nombre
    push dword[fqNombreAff]    ; 1ère partie du nombre
    push szMessRacine          ; message
    call printf
    add sp,12                  ; alignement piles


    fld qword[fqNbsaisie]      ; charge la valeur saisie dans st0
    fabs

    fstp qword[fqNombreAff]
    push dword[fqNombreAff+4]  ; 2ième partie du nombre
    push dword[fqNombreAff]    ; 1ère partie du nombre
    push szMessAbs             ; message
    call printf
    add sp,12                  ; alignement piles

    fld qword[fqNbsaisie]      ; charge la valeur saisie dans st0
    fchs

    fstp qword[fqNombreAff]
    push dword[fqNombreAff+4]  ; 2ième partie du nombre
    push dword[fqNombreAff]    ; 1ère partie du nombre
    push szMessSigne           ; message
    call printf
    add sp,12                  ; alignement piles

    fld qword[fqNbsaisie]      ; charge la valeur saisie dans st0
    frndint

    fstp qword[fqNombreAff]
    push dword[fqNombreAff+4]  ; 2ième partie du nombre
    push dword[fqNombreAff]    ; 1ère partie du nombre
    push szMessArrondi         ; message
    call printf
    add sp,12                  ; alignement piles

    fld qword[fqNbsaisie]      ; charge la valeur saisie dans st0
    fcos

    fstp qword[fqNombreAff]
    push dword[fqNombreAff+4]  ; 2ième partie du nombre
    push dword[fqNombreAff]    ; 1ère partie du nombre
    push szMessF2x             ; message
    call printf
    add sp,12                  ; alignement piles

    fldpi                      ; charge PI
    fst qword[fqNombreAff]     ; pour afficher pi
    push dword[fqNombreAff+4]  ; 2ième partie du nombre
    push dword[fqNombreAff]    ; 1ère partie du nombre
    push szFormat1             ; message
    call printf
    add sp,12                  ; alignement piles

    fld qword[fqNbsaisie]      ; charge la valeur saisie dans st0
    fcomi                      ; comparaison st0,st1 (qui contient PI)
    jc pluspetit               ; attention ne met à jour que les flags z p et c
                               ; si st0 = st1  z = 1
    push szMessGrand           ; si st0 < st1  c = 1
    call afficherMess
    jmp suite
pluspetit:
    push szMessPetit
    call afficherMess
suite:

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme

fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
;************************************************************
;         saisie d'un nombre en virgule flottante
;************************************************************
; le paramètre 1 contient la zone receptrice (8 octets)
saisieFloat:
    enter 88,0               ; prologue  reserve 88 octets
%define sZone ebp-80         ; nommage des zones réservées
%define dividende ebp-84
%define diviseur ebp-88
    pusha                    ; save registres généraux
    pushf                    ; save indicateurs
    mov eax,READ             ; lecture clavier
    mov ebx,STDIN
    lea ecx,[sZone]          ; stockage saisie dans zone pile
    mov edx,80
    int 0x80
                             ; chercher la virgule et la fin de chaine
    lea edi,[sZone]
    mov ecx,0                ; indice 
    mov ebx,0                ; position de la virgule
.A1:
    cmp byte [edi,ecx],','   ; virgule ?
    je .A2
    cmp byte [edi,ecx],0xA   ; fin de chaine ?
    jne .A3                  ; non 
    sub ecx,ebx              ; calcul nombre de chiffre après la virgule
    dec ecx
    jmp .A4
.A2:                         ; virgule trouvée
    mov ebx,ecx              ; save position virgule
.A3:
    inc ecx
    jmp .A1
.A4:                         ; calculer le diviseur le stocker en memoire
    cmp ebx,0                ; pas de virgule
    je .A6
    mov eax,1                ; diviseur
    mov ebx,10               ; multiplicateur
.A5:                         ; boucle de calcul du diviseur
    mul ebx                  ; eax = eax * 10
    dec ecx                  ; décremente le nombre de chiffres après la virgule
    jnz .A5                  ; jusquà zéro
    mov dword[diviseur],eax  ; stocke le diviseur calculé dans zone pile
    jmp .A7
.A6:                         ; si pas de virgule 
    mov dword[diviseur],1    ; diviseur = 1
.A7:                         ; convertir saisie en entier la stocker en mémoire
    lea ecx,[sZone]          ; adresse de la zone de saisie
    push ecx
    call conversionAtoD      ; conversion dans eax
    mov [dividende],eax      ; stocke la valeur saisie

    fild dword[dividende]    ; charger la valeur dans st0
    fild dword[diviseur]     ; charger le diviseur
    fdiv                     ; division
    mov ebx,[ebp + 8]        ; recup adresse zone réception
    fstp  qword[ebx]         ; stocke et dépile
                             ; retour resultat dans la zone receptrice
    popf                     ; restaur indicateurs
    popa                     ; restaur registres généraux
    leave                    ; epilogue
    ret 4                    ; car 1 paramètre en entrée