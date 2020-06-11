; assembleur 32 bits Linux 
; programme : routines.asm
; routines d'affichage et de conversion
; 

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
szMessRegistre: db "Affichage décimal d'un registre : ",0
szMessBinaire:  db "Affichage registre en binaire : ",0
szMessHexa:     db "Affichage registre en hexa : ",0
szRetourLigne   db 10,0
szMessAffFlags: db "Affichage des indicateurs : ",10,"Zéro : "
sZero           db "  "
                db "Signe : "
sSigne          db "  "
                db "Carry : "
sCarry          db "  "
                db "Overflow : "
sOver           db "  "
                db "Parité : "
sPari           db "  "
                db "Direction : "
sDir            db "  "
                db 10,0
szMessAffMemTitre: db "Vidage memoire adresse : "
adr:               db "00000000 "
                   db 10,13,0

szMessAffMemBloc:  db "00000000 "
zmem:   times 16 db "00 "
        db " ",34   
zdec:   times 16 db"0"
        db 34,10,13,0

;lignes d'affichage pour le vidage des piles
szMessTitRep:  db "Affichage piles : ",10,
               db "    pile ESP: "
sAdrESP:       db "00000000       pile EBP: "
sAdrEBP:       db "00000000  ",10,0

szMessDetail:  db "00  "
sAdrDetESP:    db "00000000  "
sValDetESP:    db "00000000       "
sAdrDetEBP:    db "00000000  "
sValDetEBP:    db "00000000  ",10,0
;zones pour affichage des selecteurs de segments
szMessAffExtra:          db "cs: "
sCS              times 8 db ' '
                 db " ds: "
sDS              times 8 db ' '
                 db " ss: "
sSS              times 8 db ' '
                 db " es: "
sES              times 8 db ' '
                 db " fs: "
sFS              times 8 db ' '
                 db " gs: "
sGS              times 9 db ' '
                 db 10,0
;zones pour affichage des registres
szTextereg:  db 'eax = ' 
 valr1       db '00000000  '
             db 'ebx = '
 valr2       db '00000000  '
             db 'ecx = '
 valr3       db '00000000  '
             db 'edx = '
 valr4       db '00000000  '
             db 10              ;retour ligne pour les 4 suivants
             db 'esi = '
 valr5       db '00000000  '
             db 'edi = '
 valr6       db '00000000  '
             db 'ebp = '
 valr7       db '00000000  '
             db 'esp = '
 valr8       db '00000000  '
             db 10, 0
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZoneConv:          resb 12
sZoneBinaire:       resb 33
;************************************************************
; Code segment 
;************************************************************
section .text
 ; déclaration des routines en global
global  afficherMess,afficherReg,afficherReg10S,afficherBinaire,conversion10
global conversion10S,conversion2,conversion16,afficherReg16,afficherFlags
global afficherMemoire,afficherPiles,conversionAtoD,afficherSegments
global afficherRegistres
;************************************************************
;               Affichage chaine de caractères
;************************************************************
; paramètre 1 contient l'adresse de la chaine
afficherMess:
    enter 0,0           ; prologue
    push eax               ; sauvegarde des registres
    push ecx
    push ebx
    push edx
    pushf               ; sauvegarde des indicateurs
    mov eax, [ebp + 8]  ; recup de la valeur a afficher
    mov ecx,eax         ; save adresse string
    mov edx,0           ; init compteur longueur
.A1:                    ; boucle comptage caractères
    cmp byte [eax,edx],0; compare l'octet à l'adresse contenue dans eax + edx
    je .A2              ; si egal à zero, saute à l'etiquette .A2
    add edx,1           ; sinon ajout de 1 au compteur de longueur
    jmp .A1             ; et boucle 
.A2:                    ; etiquette locale
    mov eax,WRITE       ; appel système write
    mov ebx,STDOUT      ; console sortie
    int 0x80
    popf                ; restaur des indicateurs
    pop edx             ; restaur des registres
    pop ebx
    pop ecx
    pop eax
    leave               ; epilogue
    ret 4
;************************************************************
;           affichage d'un registre en décimal
;************************************************************
; le paramètre 1 contient la valeur à convertir
afficherReg:
    enter 0,0            ; prologue
    push eax             ; save registre
    mov eax, [ebp + 8]   ; recup de la valeur à convertir
    push szMessRegistre  ; affichage du debut du message 
    call afficherMess
    push eax             ; puis conversion décimale de la valeur 
    push sZoneConv
    call conversion10
    push sZoneConv       ; puis affichage de la zone de conversion
    call afficherMess
    push szRetourLigne   ; et affichage d'un retour ligne
    call afficherMess
    pop eax              ; restaur registre
    leave                ; epilogue
    ret 4
;************************************************************
;           affichage d'un registre en décimal signé
;************************************************************
; le paramètre 1 contient la valeur à convertir
afficherReg10S:
    enter 0,0            ; prologue
    push eax             ; save registre
    mov eax, [ebp + 8]   ; recup de la valeur à convertir
    push szMessRegistre  ; affichage du debut du message 
    call afficherMess
    push eax             ; puis conversion décimale de la valeur 
    push sZoneConv
    call conversion10S
    push sZoneConv       ; puis affichage de la zone de conversion
    call afficherMess
    push szRetourLigne   ; et affichage d'un retour ligne
    call afficherMess
    pop eax              ; restaur du registre
    leave                ; epilogue
    ret 4
;************************************************************
;           affichage d'un registre en binaire
;************************************************************
; le paramètre 1 contient la valeur à convertir
afficherBinaire:
    enter 0,0            ; prologue
    push eax             ; save registre
    mov eax, [ebp + 8]   ; recup de la valeur à convertir
    push szMessBinaire  ; affichage du debut du message 
    call afficherMess
    push eax             ; puis conversion binaire de la valeur 
    push sZoneBinaire
    call conversion2
    push sZoneBinaire    ; puis affichage de la zone de conversion
    call afficherMess
    push szRetourLigne   ; et affichage d'un retour ligne
    call afficherMess
    pop eax              ; restaur registre
    leave                ; epilogue
    ret 4
;************************************************************
;           conversion registre en chaine décimale
;************************************************************
; parametre 1 contient la valeur à convertir
; parametre 2 contient l'adresse de la zone destinataire
conversion10:
    enter 0,0              ; prologue
    push ebx               ; sauvegarde des registres
    push ecx               ; sauvegarde des registres
    push edx               ; sauvegarde des registres
    push edi               ; sauvegarde des registres
    pushf                  ; sauvegarde des indicateurs
    mov eax,[ebp + 12]     ; recup de la valeur à convertir
    mov edi,[ebp + 8]      ; recup de l'adresse 
    mov ecx,11             ; compteur de caractères 
    mov byte [edi + ecx],0 ; ajout du 0 final
.deb: 
    dec ecx                ; position précédente
    mov edx,0
    mov ebx ,10            ; division de eax par 10
    div ebx
    add edx,48             ; et ajout de 48 (x30) pour avoir un caractère ASCII
     ; mov [edi,ecx],edx    N'est pas autorisé !!!
    mov [edi,ecx],dl       ; stockage du caractère dans la zone de reception
    cmp eax,0              ; boucle au début si le quotient est different de zéro
    jne .deb
    mov ebx,0              ; compteur début
.boucle:                   ; il faut recopier le résultat en début de zone
    mov dl,[edi,ecx]       ; charge un octet
    mov [edi,ebx],dl       ; et le stocke au début de la zone
    cmp dl,0               ; est-ce la fin ?
    je .finboucle          ; oui
    inc ecx                ; sinon on incremente le compteur 
    inc ebx                ; et le compteur début
    jmp .boucle            ; et on boucle 
.finboucle:
    mov eax,ebx            ; retour longueur
.fin:                      ; fin routine
    popf                   ; restau des indicateurs
    pop edi                ; et de chaque registre
    pop edx
    pop ecx
    pop ebx
    leave                  ; epilogue
    ret  8                 ; car 2 paramètres en entrée
;************************************************************
;           conversion registre  décimal signé
;************************************************************
; parametre 1 contient la valeur à convertir
; parametre 2 contient l'adresse de la zone destinataire
conversion10S:
    enter 0,0              ; prologue
    push ebx               ; sauvegarde des registres
    push ecx               ; sauvegarde des registres
    push edx               ; sauvegarde des registres
    push edi               ; sauvegarde des registres
    push esi               ; sauvegarde des registres
    pushf                  ; sauvegarde des indicateurs
    mov eax,[ebp + 12]     ; recup de la valeur à convertir
    mov edi,[ebp + 8]      ; recup de l'adresse 
    mov ecx,11             ; compteur de caractères 
    mov byte [edi + ecx],0 ; ajout du 0 final
    mov esi,'+'            ; par defaut signe + dans esi
    cmp eax,0
    jns .deb               ; si valeur positive saut au début conversion
    mov esi,'-'            ; sinon positionne signe -  dans esi
    neg eax                ; et on inverse la valeur
.deb: 
    dec ecx                ; position précédente
    mov edx,0
    mov ebx ,10            ; division de eax par 10
    div ebx
    add edx,48             ; et ajout de 48 (x30) pour avoir un caractère ASCII
     ; mov [edi,ecx],edx    N'est pas autorisé !!!
    mov [edi,ecx],dl       ; stockage du caractère dans la zone de reception
    cmp eax,0              ; boucle au début si le quotient est different de zéro
    jne .deb
                           ; conversion terminée il faut stocker le signe
    mov edx,esi
    dec ecx                ; devant les chiffres
    mov [edi,ecx],dl
    mov ebx,0              ; compteur début
.boucle:                   ; il faut recopier le résultat en début de zone
    mov dl,[edi,ecx]       ; charge un octet
    mov [edi,ebx],dl       ; et le stocke au début de la zone
    cmp dl,0               ; est-ce la fin ?
    je .finboucle          ; oui
    inc ecx                ; sinon on incremente le compteur 
    inc ebx                ; et le compteur début
    jmp .boucle            ; et on boucle 
.finboucle:
    mov eax,ebx            ; retour longueur
.fin:                      ; fin routine
    popf                   ; restau des indicateurs
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx
    leave                  ; epilogue
    ret  8                 ; car 2 paramètres en entrée
;************************************************************
;           conversion registre en binaire
;************************************************************
; parametre 1 contient la valeur à convertir
; parametre 2 contient l'adresse de la zone destinataire
conversion2:
    enter 0,0              ; prologue
    push eax
    push ebx               ; sauvegarde des registres
    push ecx               ; sauvegarde des registres
    push edx               ; sauvegarde des registres
    push edi               ; sauvegarde des registres
    pushf                  ; sauvegarde des indicateurs
    mov eax,[ebp + 12]     ; recup de la valeur à convertir
    mov edi,[ebp + 8]      ; recup de l'adresse 
    mov ecx,32             ; compteur de caractères 
    mov byte [edi + ecx],0 ; ajout du 0 final
.deb: 
    dec ecx                ; position précédente
    mov edx,0
    mov ebx ,2            ; division de eax par 10
    div ebx
    add edx,48             ; et ajout de 48 (x30) pour avoir un caractère ASCII
     ; mov [edi,ecx],edx    N'est pas autorisé !!!
    mov [edi,ecx],dl       ; stockage du caractère dans la zone de reception
    cmp ecx,0              ; boucle au début si nombre de bits non atteint
    jne .deb

.fin:                      ; fin routine
    popf                   ; restau des indicateurs
    pop edi                ; et de chaque registre
    pop edx
    pop ecx
    pop ebx
    pop eax
    leave                  ; epilogue
    ret  8                 ; car 2 paramètres en entrée
;************************************************************
;           affichage d'un registre en hexadecimal
;************************************************************
; le paramètre 1 contient la valeur à convertir
afficherReg16:          ; INFO:  afficherReg16
    enter 0,0           ; prologue
    push eax            ; save registre
    mov eax, [ebp + 8]  ; recup de la valeur à convertir
    push szMessHexa     ; affichage du debut du message 
    call afficherMess
    push eax
    push sZoneConv
    call conversion16
    push sZoneConv
    call afficherMess
    push szRetourLigne
    call afficherMess
    pop eax             ; restaur des registres
    leave               ; epilogue
    ret 4
;************************************************************
;           conversion registre en chaine hexadecimal
;************************************************************
; parametre 1 contient la valeur à convertir
; parametre 2 contient l'adresse de la zone destinataire
conversion16:              ; INFO: conversion16
    enter 0,0              ; prologue
    pusha                  ; sauvegarde des registres
    pushf
    mov eax,[ebp + 12]     ; recup de la valeur à convertir
    mov edi,[ebp + 8]      ; recup de l'adresse 
    mov ecx,7              ; compteur de caractères 
.deb: 
    mov edx,0
    mov ebx ,16            ;division de eax par 16
    div ebx
    cmp edx,9              ;si le reste est inferieur à 10 c'est un chiffre
    jg  .lettre
    add edx,'0'            ;donc on ajoute '0'
    ;
    jmp  .suite
.lettre:                    ;sinon c'est une lettre
    add edx,'A'-10 
.suite:   
    mov byte  [edi,ecx],dl
    dec ecx
    cmp ecx,0            ; boucle au début si pas taille atteinte
    jge .deb
    mov byte [edi + 8],0 ; ajout du 0 final
    mov eax,8            ; retour longueur
.fin:                    ; fin routine
    popf
    popa
    leave                ; epilogue
    ret 8                ; car 2 paramètres en entrée
;************************************************************
;               affichage des indicateurs
;************************************************************
; aucun parametre 
afficherFlags:                ; INFO: afficherFlags
    push eax
    jz .zero
    mov al,'0'
    mov [sZero],al
    jmp .suite
.zero:
    mov al,'1'
    mov [sZero],al
.suite:
    js .signe
    mov al,'0'
    mov [sSigne],al
    jmp .suite1
.signe:
    mov al,'1'
    mov [sSigne],al
.suite1:
    jc .carry
    mov al,'0'
    mov [sCarry],al
    jmp .suite2
.carry:
    mov al,'1'
    mov [sCarry],al
.suite2:
    jo .over
    mov al,'0'
    mov [sOver],al
    jmp .suite3
.over:
    mov al,'1'
    mov [sOver],al
.suite3:
    jp .pair
    mov al,'0'
    mov [sPari],al
    jmp .suite4
.pair:
    mov al,'1'
    mov [sPari],al
.suite4:
    pushf
    pop eax
    test eax,1<<10
    jz .incre
    mov al,'D'          ; décroissant
    mov [sDir],al
    jmp .suite5
.incre:
    mov al,'C'          ; croissant
    mov [sDir],al
.suite5:
.fin:
    push szMessAffFlags
    call afficherMess
    pop eax
    ret
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
;************************************************************
;          Affichage des piles
;************************************************************
; affiche 10 adresses
NBADRAFF  equ 10
afficherPiles:
    enter 0,0
    pusha                    ;sauvegarde des registres
    pushf                    ; sauvegarde des flags
    mov edi,ebp
    add edi,8                ; l'adresse de esp est dans ebp + 8
    push edi
    push sAdrESP             ; conversion en hexa
    call conversion16
    mov byte [sAdrESP+8],' ' ; effacement du zéro final
    mov esi,[ebp]            ; contient l'adresse de ebp
    push esi
    push sAdrEBP
    call conversion16        ; conversion en hexa
    mov byte [sAdrEBP+8],' '
    push szMessTitRep        ; affiche le titre 
    call afficherMess

    mov  ecx,NBADRAFF        ; nombre d'adresses à afficher
    shl  ecx,2               ; * 4 octets   = déplacement des adresses
.A1:
    push ecx                 ; sauvegarde du compteur
    push ecx                 ; deplacement d'adresses
    push szMessDetail
    call conversion10S
    mov byte [szMessDetail,eax],' '
    mov  edx,esi             ; adresse ebp
    add  edx,ecx             ; ajout du deplacement
    mov  ebx,[edx]           ; contenu de ebp
    push edx                 ; adresse de ebp
    push sAdrDetEBP
    call conversion16
    mov byte [sAdrDetEBP+8],' '
    push ebx                 ; contenu de ebp
    push sValDetEBP
    call conversion16
    mov byte [sValDetEBP+8],' '
    mov  edx,edi             ;adresse de esp
    add  edx,ecx
    mov  ebx,[edx]         ; contenu de esp
    push edx               ; adresse de esp 
    push sAdrDetESP
    call conversion16
    mov byte [sAdrDetESP+8],' '
    push ebx                ; contenu de esp 
    push sValDetESP
    call conversion16
    mov byte [sValDetESP+8],' '
                             ; affichage ligne détail
    push szMessDetail
    call afficherMess

    pop ecx                  ; restaur du déplacement d'adresse
    sub ecx,4                ; adresse précédente

    cmp ecx,(-2 * NBADRAFF)  ; pour afficher 2 fois mois d'adresses négatives
    jge .A1
                             ; fin de la routine
    popf             
    popa                     ; restaur des registres
    leave
    ret
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
    ret
szMessDep:       db "Dépassement de capacité !!!",10,0
;************************************************************
;               affichage des registres de segments
;************************************************************
; pas de parametres
afficherSegments:
    enter 0,0
    pusha                     ;sauvegarde des registres
    pushf                     ; sauvegarde des flags
    push cs
    push sCS
    call conversion16
    mov byte [sCS+8],' '
    push ds
    push sDS
    call conversion16
    mov byte [sDS+8],' '
    push ss
    push sSS
    call conversion16
    mov byte [sSS+8],' '
    push es
    push sES
    call conversion16
    mov byte [sES+8],' '
    push fs
    push sFS
    call conversion16
    mov byte [sFS+8],' '
    push gs
    push sGS
    call conversion16
    mov byte [sGS+8],' '

    push szMessAffExtra
    call afficherMess

.A100:                            ; fin de la routine
    popf
    popa                          ; restaur des registres
    leave
    ret
;************************************************************
;               affichage des registres généraux
;************************************************************
; pas de parametres
afficherRegistres:
    enter 0,0
    pusha                     ;sauvegarde des registres
    pushf                     ; sauvegarde des flags
    push eax                  ; parametre 1
    push valr1                ; parametre 2 zone de réception
    call conversion16
    mov byte [valr1+8],' '    ; pour enlever le 0 final
    push ebx                  ; idem pour les autres registres
    push valr2
    call conversion16
    mov byte [valr2+8],' '
    push ecx
    push valr3
    call conversion16
    mov byte [valr3+8],' '
    push edx
    push valr4
    call conversion16
    mov byte [valr4+8],' '
    push esi
    push valr5
    call conversion16
    mov byte [valr5+8],' '
    push edi
    push valr6
    call conversion16
    mov byte [valr6+8],' '
    mov eax,ebp               ; l'adresse de epb avant l'appel est 
    push dword[eax]           ; dans ebp actuelle
    push valr7
    call conversion16
    mov byte [valr7+8],' '
    add eax,8                 ; l'adresse de la pile est 8 octets avant ebp
    push eax
    push valr8
    call conversion16
    mov byte [valr8+8],' '

    push szTextereg
    call afficherMess

.A100:                            ; fin de la routine
    popf
    popa                          ; restaur des registres
    leave
    ret