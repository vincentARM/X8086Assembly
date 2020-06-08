; assembleur 32 bits Linux 
; programme : pgm15.asm
; tableau de chaine de caractères insertion dans un tableau
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

NBMAXCHAIN equ 100
LGZONEREC  equ 100
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
szMessSaisie:    db "Veuillez saisir une chaine (fin pour terminer) : ",10,0
szFin:           db "fin",0
szMessErrSai:    db "Erreur de saisie !!!",10,0

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sBuffer:             resb LGZONEREC
sChaines:            resb 80 * NBMAXCHAIN
tbAdrChaine:         resd 4 * NBMAXCHAIN
dNbChaine            resd 1

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
    mov ebx,sChaines         ; zone de stockage des chaines
boucleSaisie:
    push szMessSaisie        ; affichage message de saisie
    call afficherMess
    push ebx                 ; zone de saisie
    call lireClavier
    dec eax                  ; pour position du 0xA
    mov byte [ebx+eax],0     ; remplace 0xA final par 0
    mov edx,eax              ; save de la longueur saisie
    push ebx
    push szFin               ; compare chaine avec "fin"
    call comparerChaines
    cmp eax,0
    je finSaisie             ; chaine saisie = "fin" -> fin de saisie
    push ebx                 ; adresse chaine saisie
    call insererChaine       ; pour insertion dans tableau des pointeurs

    add ebx,edx              ; adresse zone saisie + longueur
    inc ebx                  ; + 1 pour stocker la suivante
    jmp boucleSaisie         ; et boucle

finSaisie:
    afficherLib "Affichage des chaines : "
    mov ecx,0                ; indice
boucleAff:                   ; boucle d'affichage
    push dword[tbAdrChaine+(ecx * 4)] ; lecture d'un pointeur chaine
    call afficherMess        ; affichage de la chaine
    push szRetourLigne       ; et retour ligne
    call afficherMess
    inc ecx                  ; incremente l'indice
    cmp ecx,[dNbChaine]      ; nombre de chaines saisies atteint ?
    jl boucleAff             ; non -> boucle

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme
    jmp fin
erreur:
    push szMessErrSai
    call afficherMess
    mov ebx,1                ; code retour erreur du programme

fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
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
;     inserer l'adresse de la chaine dans la table en ordre croissant
;************************************************************
; paramètre1  : adresse de la chaine à inserer
insererChaine:
    enter 0,0
    push ebx                  ;sauvegarde des registres
    push ecx
    push edx
    push edi
    push esi
    pushf
    mov ebx,[ebp+8]           ; récuperation adresse chaine   
    cmp dword[dNbChaine],0    ; nombre de chaine d&ja saisie = 0 ?
    jne .A1
                              ; première saisie
    mov [tbAdrChaine],ebx     ; stocke l'adresse dans le tableau des pointeurs
    inc dword[dNbChaine]      ; incremente le nombre de chaine
    jmp .A100
.A1:
    mov ecx,0                 ; indice de recherche
.A2:
    mov eax,[tbAdrChaine+(ecx * 4)]  ; lecture d'un pointeur chaine
    push ebx                   ; pointeur chaine à inserer
    push eax                   ; pointeur chaine lu
    call comparerChaines       ; comparaison
    cmp eax,-1                 ; chaine à inserer inférieure à chaine déjà stockee
    je .A3                     ; insertion à effectuer
    inc ecx                    ; incrente indice
    cmp ecx,[dNbChaine]        ; nb de chaine déjà stocké atteint ?
    jl .A2                     ; non boucle
    mov [tbAdrChaine+(ecx * 4)],ebx  ; stocke l'adresse dans le tableau des pointeurs
    inc dword[dNbChaine]        ; incremente le nombre de chaine
    cmp dword[dNbChaine],NBMAXCHAIN      ; maxi possible ?
    je .A99                      ; non -> erreur
    xor eax,eax                 ; sinon insertion ok
    jmp .A100
.A3:
    inc dword[dNbChaine]             ; incremente le nombre de chaine
    cmp dword[dNbChaine],NBMAXCHAIN  ; maxi possible ?
    je .A99                          ; non erreur
    mov edx,[dNbChaine]              ; déplacement des pointeurs
    lea edi,[tbAdrChaine+(edx * 4)]  ; d'une position vers le haut
    mov esi,edi                      ; position maxi
    sub esi,4                        ; position précédente
    sub edx,ecx                      ; nombre de pointeurs à déplacer
    mov eax,ecx                      ; save de la position d'insertion
    xchg edx,ecx                     ; echange car ecx va servir de compteur
    std                              ; indic direction passe à croissant
    repnz movsd                      ; déplacement des pointeurs de ecx positions

    mov [tbAdrChaine+(eax * 4)],ebx  ; stocke l'adresse dans le tableau des pointeurs
    cld                              ; raz indicateur de direction
    xor eax,eax                      ; insertion ok
    jmp .A100
.A99:                                ; erreur car plus de place dans le tableau
    push szMessErrSai
    call afficherMess
    mov eax,1                        ; code retour erreur routine
.A100:
    popf
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx                          ; restaur des registres
    leave
    ret 4                            ; 1 paramètre
;************************************************************
;     comparaison de 2 chaines
;************************************************************
; paramètre1  : adresse chaine 1
; paramètre2  : adresse chaine 2
; retourne 0 dans eax si égalité -1 si chaine 1 inferieure ou +1 
comparerChaines:
    enter 0,0
    push edi                  ;sauvegarde des registres
    push ecx
    push esi
    pushf
    mov edi,[ebp+12]          ; récuperation adresse chaine 1
    mov esi,[ebp+8]           ; récuperation adresse chaine 2
    xor ecx,ecx               ; raz indice
    xor eax,eax               ; raz retour
.A1:
    mov al,[edi,ecx]          ; lecture 1 caractère chaine1
    cmp byte al,[esi,ecx]     ; comparaison avec caractère chaine 2
    jl .A2                    ; plus petit ?
    jg .A3                    ; plus grand ?
    cmp al,0                  ; fin de chaine
    je .A100                  ; oui égalité eax = 0
    inc ecx                   ; caractère suivant
    jmp .A1                   ; et boucle
.A2:
    mov eax,-1                ; plus petit
    jmp .A100
.A3:
    mov eax,1                 ; plus grand
.A100:
    popf
    pop esi
    pop ecx
    pop edi                   ; restaur des registres
    leave
    ret 8                     ; 2 paramètres
