; assembleur 32 bits Linux 
; programme : pgm12.asm
; routine de lecture de la mémoire par bloc
; instructions d'accès à la mémoire
; les routines d'affichage sont déportées dans le fichier routines.asm

bits 32

;************************************************************
;               Constantes 
;************************************************************
STDOUT equ 1
EXIT  equ 1
WRITE equ 4 

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
szRetourLigne   db 10,0
bZone           db 0x33
wZone1:         dw 0x1234           ; déclaration d'un mot de 16 bits
dZone2:         dd 0x12345678       ; déclaration d'un double mot de 32 bits

car1:           db  "àéèê"

szMessAffMemTitre: db "Vidage memoire adresse : "
adr:               db "00000000 "
                   db 10,13,0

szMessAffMemBloc:  db "00000000 "
zmem:   times 16 db "00 "
        db " ",34   
zdec:   times 16 db"0"
        db 34,10,13,0

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
wZoneEcr1:           resw  1    ; réserve 1 mot de 2 octets
dZoneEcr2:           resd  1    ; réserve 1 double mot de 4 octets
;************************************************************
; Code segment 
;************************************************************
section .text
extern afficherMess,afficherBinaire,afficherReg10S,afficherReg,conversion16
extern afficherReg16
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess

    afficherLib "Affichage zone "
    push szMessDebPgm     ; adresse zone
    push 5                ; nombre de blocs à afficher
    call afficherMemoire

    ; lecture d'un double mot dans le registre eax
    mov eax,[dZone2]
    push eax
    call afficherReg16

    ; lecture d'un mot dans le registre bx
    mov bx,[wZone1]
    push ebx
    call afficherReg16

    ; lecture d'un byte dans le registre cl
    mov cl,[bZone]
    push ecx
    call afficherReg16
    ; lecture du 4 ième octet du double mot
    afficherLib "Lecture avec déplacement"
    mov  al,[dZone2+3]
    push eax
    call afficherReg16
    xor eax,eax
    mov  al,[dZone2+3]
    push eax
    call afficherReg16
    afficherLib "Lecture avec adresse dans registre"
    mov ebx,wZone1
    mov  ax, [ebx]
    push eax
    call afficherReg16
    afficherLib "Lecture avec adresse dans registre + deplacement"
    xor eax,eax
    mov ebx,wZone1
    mov  ah, [ebx+1]        ; et stockage dans ah donc partie haute
    push eax
    call afficherReg16

    ;mov eax,0               ; impossible d'afficher cette adresse
    ;mov ebx,[eax]
    mov eax,szMessDebPgm
    ; zones de la data routines
    push zdec
    push 5                ; nombre de blocs à afficher
    call afficherMemoire

    afficherLib "Ecriture mémoire d'un mot"
    mov eax,0x1234
    mov [wZoneEcr1],ax
    push wZoneEcr1
    push 2                ; nombre de blocs à afficher
    call afficherMemoire
    afficherLib "Ecriture mémoire d'un double mot"
    mov eax,0x12345678
    mov [dZoneEcr2],eax
    push wZoneEcr1
    push 2                ; nombre de blocs à afficher
    call afficherMemoire

    ; test de l'intruction xlat
    afficherLib "test instruction xlat."
    mov ebx,dZone2         ; adresse de la zone
    mov eax,3              ; déplacement demandé
    xlat                   ; met dans al l'octet de la zone dZone2 + deplacement de 3
    push eax
    call afficherReg16



    push szMessFinPgm
    call afficherMess
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    xor ebx,ebx          ; code retour du programme
    int 0x80             ; interruption : retour à Linux


;************************************************************
;               affichage de la mémoire
;************************************************************
; parametre 1  : adresse de debut
; parametre 2  : nombre de blocs de 16 octets à afficher
afficherMemoire:
    enter 0,0
    pusha                     ;sauvegarde des registres
    pushf                     ; sauvegarde des flags
    mov ebx, [ebp + 12]       ; recup de l'adresse memoire sur la pile
    mov ecx, [ebp + 8]        ; recup nombre de blocs
    
    push ebx                  ; conversion adresse en hexa
    push adr                  ; adresse zone réceptrice
    call conversion16
    mov dl,' '                ; pour effacer le zéro de fin de chaine
    mov byte [adr+8],dl       ; poitionné par la routine précédente
    push szMessAffMemTitre    ; affichage ligne titre
    call afficherMess
    mov    esi,ebx            ; copie de l'adresse mémoire
    and    esi, 0xFFFFFFF0    ; calcul de l'adresse début bloc de 16 octets
                              ;affichage * devant l'adresse 
    mov eax,ebx               ; copie de l'adresse mémoire
    sub eax,esi               ; calcul du déplacement
    mov edi,eax               ; sauvegarde pour l'effacement 
    mov  byte [zmem-1+(eax*3)],'*' ; mise en place * devant l'adresse

.A1:
    push ecx                  ; sauvegarde nb de bloc
    push esi                  ; conversion hexa du debut du bloc 
    push szMessAffMemBloc
    call conversion16
    mov dl,' '                ; pour effacer le zéro final
    mov byte [szMessAffMemBloc+8],dl
                              ;affichage d'un bloc
    xor    ecx,ecx            ;commencer la boucle de conversion des octets
.A2:
    xor eax,eax               ;raz registre
    mov al, [esi+ecx]         ;acquerir un caractere
    mov edx,eax
    and edx,0xF
    cmp edx,9                 ;si le reste est inferieur à 10 c'est un chiffre
    jg  .A21
    add edx,48                ; donc ajout de 48
    jmp    .A22
.A21:                         ;sinon c'est une lettre
    add edx,55                ; donc ajout de 55
.A22:   
    mov byte [zmem+1+(ecx*3)],dl ;et on place le caractere en position 1
    mov edx,eax               ; pour récuperer l'autre caractère
    and edx,0xF0              ; sur les bits 4 à 7
    shr edx,4                 ; puis déplacement du résultat sur la droite de 4 position
    cmp edx,9                 ;si le reste est inferieur à 10 c'est un chiffre
    jg  .A23
    add edx,48                ; donc ajout de 48
    jmp .A24
.A23:                         ;sinon c'est une lettre
    add edx,55                ; donc ajout de 55
.A24:   
    mov byte [zmem+(ecx*3)],dl ;et on place le caractere en position 0

    inc ecx                   ; increment le compteur de caractères
    cmp ecx, 16               ; fin du bloc ?
    jl .A2
    
    xor    ebx, ebx            ;commencer la boucle de conversion en Ascii
.A3:
    xor    eax, eax
    mov    al, [esi+ebx]       ;acquerir un caractere
    cmp    al, 32
    jl    .A31                 ; si inférieur il est non affichable
    cmp    al, 126
    jle    .A32                ; et si supérieur aussi 
.A31:
    mov    eax, '?'
.A32:
    mov byte [zdec+ebx],al     ;le mettre à la bonne place
    inc    ebx
    cmp    ebx, 16
    jl    .A3

    push szMessAffMemBloc     ; affiche la ligne d'un bloc
    call afficherMess
    pop ecx                   ; on recupere le nombre de bloc à afficher
    dec ecx                   ; decrementer de 1
    ;cmp ecx,0                ; egal à zero 
    ;je .fin_boucle_bloc
    jecxz  .A100
    mov eax,edi                   ; pour les autres blocs
    mov byte [zmem-1+(eax*3)],' ' ; il faut effacer l'étoile
    add esi,16                    ; ajout taille d'un bloc à l'adresse
    jmp .A1                       ; et boucle
 
.A100:                            ; fin de la routine
    popf
    popa                          ; restaur des registres
    leave
    ret 8                         ; car 2 paramètres