; assembleur 32 bits Linux 
; programme : pgm3.asm
; affichage d'un registre 

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
szMessRegistre: db "Affichage hexa d'un registre : ",0
szMessDebPgm:   db "Début du programme.",10,0
szMessFinPgm:   db "Fin normale du programme.",10,0
szRetourLigne   db 10,0
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZoneConv:          resb 20
;************************************************************
; Code segment 
;************************************************************
section .text
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess
    push szMessRegistre
    call afficherMess
    mov eax,1000
    push eax
    call afficherReg

    afficherLib "toto"

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
    push ecx               ; sauvegarde des registres
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
;************************************************************
;           affichage d'un registre en chaine hexadecimal
;************************************************************
; le paramètre 1 contient la valeur à convertir
afficherReg:
    enter 0,0           ; prologue
    push eax              ; save registre
    mov eax, [ebp + 8]  ; recup de la valeur à convertir
    push eax
    push sZoneConv
    call conversion16
    push sZoneConv
    call afficherMess
    push szRetourLigne
    call afficherMess
    pop eax               ; restaur des registres
    leave               ; epilogue
    ret
;************************************************************
;           conversion registre en chaine hexadecimal
;************************************************************
; parametre 1 contient la valeur à convertir
; parametre 2 contient l'adresse de la zone destinataire
conversion16:
    enter 0,0              ; prologue
    pusha                  ; sauvegarde des registres
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
    popa
    leave                ; epilogue
    ret 8                ; car 2 paramètres en entrée