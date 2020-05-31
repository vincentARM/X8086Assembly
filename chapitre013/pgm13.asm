; assembleur 32 bits Linux 
; programme : pgm12.asm
; copie d'une chaine
; gestion des tableaux
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
szChaine1       db "Le petit chat est mort !!",0
wZone1:         dw 0x1234           ; déclaration d'un mot de 16 bits
tabdExp:        dd 1,2,3,4,5,6,7,8,9,10
                NBPOSTE equ ($ - tabdExp) / 4



;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
szChaine2:           resb  100  ; réserve 100 octets
szChaine3:           resb  100  ; réserve 100 octets
szChaine4:           resb  100  ; réserve 100 octets
dZoneEcr2:           resd  1    ; réserve 1 double mot de 4 octets
;************************************************************
; Code segment 
;************************************************************
section .text
extern afficherMess,afficherBinaire,afficherReg10S,afficherReg,conversion16
extern afficherReg16,afficherMemoire
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess

    afficherLib "Copie d'une chaine "
    mov eax,szChaine1
    mov ebx,szChaine2
    mov ecx,0
boucleCopie:
    mov dl,[eax,ecx]
    mov [ebx,ecx],dl
    inc ecx
    cmp dl,0
    jne boucleCopie

    push szChaine2        ; adresse zone
    push 5                ; nombre de blocs à afficher
    call afficherMemoire
    mov esi,szChaine2
    mov edi,szChaine3
boucleCopie1:
    lodsb                 ; lit un octet et incremente esi
    stosb                 ; stocke un octet et incremente edi
    cmp al,0
    jne boucleCopie1

    push szChaine3        ; adresse zone
    push 5                ; nombre de blocs à afficher
    call afficherMemoire

    mov esi,szChaine3
    mov edi,szChaine4
    mov ecx,50
boucleCopie2:
    lodsb                 ; lit un octet et incremente esi
    stosb                 ; stocke un octet et incremente edi
    cmp al,0              ; pour tester la fin de la chaine
    loopne boucleCopie2   ; ou loopnz possible 
    push ecx
    call afficherReg

    push szChaine4        ; adresse zone
    push 5                ; nombre de blocs à afficher
    call afficherMemoire

    afficherLib "Nombre de poste : "
    mov eax,NBPOSTE
    push eax
    call afficherReg
 
    afficherLib "accès à un poste "
    mov edi,tabdExp
    mov eax,[edi+(2*4)]   ; accés au poste N°3  le premier poste commence à zero
    push eax
    call afficherReg
    afficherLib "accès à un poste N° de poste dans registre"
    mov esi,tabdExp
    mov ebx,5
    mov eax,[esi,ebx * 4]   ; accés au poste N°6  le premier poste commence à zero
    push eax
    call afficherReg
    afficherLib "Recherche dans un tableau."
    mov esi,tabdExp
    mov ebx,0
    mov ecx ,8
    ;mov ecx,11             ; pour tester non trouvée
DebRech:
    mov eax,[esi,ebx * 4]   ; lecture de chaque valeur en fonction de l'indice ebx
    cmp eax,ecx
    je trouve
    inc ebx
    cmp ebx,NBPOSTE
    jl DebRech
    afficherLib "Valeur non trouvee."
    jmp finRech
trouve:
    afficherLib "Valeur trouvee. indice :"
    push ebx
    call afficherReg
finRech:
    afficherLib "Autre Recherche dans un tableau."
    mov edi,tabdExp
    mov eax,11
    ;mov eax,11         ; pour tester non trouvée
    mov ecx,NBPOSTE
DebRech1:
    scasd             ; incremente edi de 4 et teste eax avec [edi]
    je trouve1
    loop DebRech1     ; decremente ecx et si différent de zero boucle
    afficherLib "Rech1 :Valeur non trouvee."
    jmp finRech1
trouve1:
    afficherLib "Rech1 :Valeur trouvee. indice :"
    push ecx
    call afficherReg
finRech1:
    push szMessFinPgm
    call afficherMess
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    xor ebx,ebx          ; code retour du programme
    int 0x80             ; interruption : retour à Linux


