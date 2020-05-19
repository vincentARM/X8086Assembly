; assembleur 32 bits Linux 
; programme : pgm4.asm
; affichage d'un message
; utilisation d'une macro instruction

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
szMessRegistre: db "Affichage hexa d'un registre : ",0
szMessDebPgm:   db "Début du programme.",10,0
szMessFinPgm:   db "Fin normale du programme.",10,0
szRetourLigne   db 10,0
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
;************************************************************
; Code segment 
;************************************************************
section .text
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess

    afficherLib "toto"

    afficherLib "Très bien l'assembleur sous linux !!"

    push szMessFinPgm
    call afficherMess
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    xor ebx,ebx          ; code retour du programme
    int 0x80             ; interruption : retour à Linux
;************************************************************
;               Affichage chaine de caractères
;************************************************************
; paramètre 1 contient l'adresse de la chaine
afficherMess:
    enter 0,0           ; prologue
    push ecx            ; sauvegarde des registres
    push ebx
    push edx
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
    pop edx             ; restaur des registres
    pop ebx
    pop ecx
    leave               ; epilogue
    ret 4
