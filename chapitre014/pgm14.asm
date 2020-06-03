; assembleur 32 bits Linux 
; programme : pgm14.asm
; affichage des contenus des piles esp et ebp
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



;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss

;************************************************************
; Code segment 
;************************************************************
section .text
extern afficherMess,afficherBinaire,afficherReg10S,afficherReg,conversion16
extern afficherReg16,afficherMemoire,conversion10S
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess

    mov eax,-1           ; pour vérifier la sauvegarde du registre eax
    push 5               ; pour vérifier le passage d'un paramètre à une routine
    call routine1

    push szMessFinPgm
    call afficherMess
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    xor ebx,ebx          ; code retour du programme
    int 0x80             ; interruption : retour à Linux
;************************************************************
;          petite routine
;************************************************************
; test affichage pile
routine1:
    enter 0,0
    pusha                ;sauvegarde des registres
    mov ebx,[ebp+8]
    push ebx             ; pour vérifier la bonne récupération du paramètre
    call afficherReg16
 
    call afficherPiles   ; affichage du contenu des piles

    popa                 ; restaur des registres
    leave
    ret 4                ; car un seul paramètre
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

