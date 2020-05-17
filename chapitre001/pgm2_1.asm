; assembleur 32 bits Linux 
; programme : pgm2.asm
; routine d'affichage avec calcul de la longueur
; passage paramètre par la pile 
bits 32

;************************************************************
;               Constantes 
;************************************************************
STDOUT equ 1
EXIT  equ 1
WRITE equ 4 
;************************************************************
; Variables initialisées segment 
;************************************************************
section .data
szHello       db "Bonjour depuis l'assembleur 32 bits.",10,0
szMessDebPgm: db "Début du programme.",10,0
szMessFinPgm: db "Fin normale du programme.",10,0
szRetourLigne db 10,0
;************************************************************
; Variables non initialisées segment 
;************************************************************
section .bss
sZoneConv:          resb 20 ; exemple de réservation de 20 octets
;************************************************************
; Code segment 
;************************************************************
section .text
global  main               ; déclaration de main en global
main:
    push szMessDebPgm      ; adresse du message
    call afficherMess

    push szHello           ; adresse du message
    call afficherMess

    push szMessFinPgm      ; adresse du message
    call afficherMess
                           ; Fin standard du programme
    mov eax,EXIT           ; signalement de fin de programme
    xor ebx,ebx            ; code retour du programme
    int 0x80               ; interruption : retour à Linux
;************************************************************
;               Affichage chaine de caractères
;************************************************************
; le paramètre 1 contient l'adresse de la chaine
afficherMess:
    push ebp            ; sauvegarde le registre ebp
    mov ebp,esp         ; adresse de la pile dans ebp
    pusha               ; sauvegarde des registres
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
    popa                ; restaur des registres
    pop ebp             ; restaur du registre ebp
    ret 4               ; dépile 4 octets car un seul paramètre