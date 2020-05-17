; assembleur 32 bits Linux 
; programme : pgm3.asm
; affichage d'un registre 

bits 32

;************************************************************
;               Constantes 
;************************************************************
%define STDOUT 1
EXIT  equ 1
WRITE equ 4 
;************************************************************
;               Structures
;************************************************************
struc tBIOSDA         ; its structure
.COM1addr RESW 1
.COM2addr RESD 1
.COM2fin:             ; donne la taille de la structure
endstruc
;************************************************************
;               Macros
;************************************************************
%macro afficherLib 1
    jmp %%endstr
%%str: db %1,10,0
%%endstr:
    mov eax, %%str
    call afficherMess
%endmacro
;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
hello db "Hello world.",10,0
szRetourLigne db 10,0
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

    mov eax,hello
    call afficherMess
    mov eax,1000
    call afficherReg
    mov eax,tBIOSDA.COM2fin
    call afficherReg
    afficherLib "toto"
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    xor ebx,ebx          ; code retour du programme
    int 0x80             ; interruption : retour à Linux
;************************************************************
;               Affichage String
;************************************************************
; eax contient l'adresse de la chaine
afficherMess:
    enter 0,0           ; prologue
    push ecx               ; sauvegarde des registres
    push ebx
    push edx
    mov ecx,eax         ; save adresse string
    mov edx,0           ; init compteur longueur
.A1:                     ; boucle comptage caractères
    cmp byte [eax],0
    je .A2
    add edx,1
    add eax,1
    jmp .A1
.A2:
    mov eax,WRITE       ; appel système write
    mov ebx,STDOUT      ; console sortie
    int 0x80
    pop edx             ; restaur des registres
    pop ebx
    pop ecx
    leave               ; epilogue
    ret
;************************************************************
;           affichage d'un registre en chaine hexadecimal
;************************************************************
; eax contient la valeur à convertir
afficherReg:
    ;enter 0,0           ; prologue
    push ebx              ; save registre
    mov ebx,sZoneConv
    call conversion16
    mov eax,sZoneConv
    call afficherMess
    mov eax,szRetourLigne
    call afficherMess
    pop ebx               ; restaur des registres
    ;leave               ; epilogue
    ret
;************************************************************
;           conversion registre en chaine hexadecimal
;************************************************************
; eax contient la valeur à convertir
; ebx la zone destinataire
conversion16:
    enter 0,0             ; prologue
    push ecx              ; sauvegarde des registres
    push ebx
    push edx
    push edi
    mov edi,ebx
    mov ecx,8
.deb: mov edx,0
    mov ebx ,16            ;on divise par 16
    div ebx
    cmp edx,9              ;si le reste est inferieur à 10 c'est un chiffre
    jg  .lettre
    add edx,'0'            ;donc on ajoute '0'
    ;
    jmp  .suite
.lettre:                    ;sinon c'est une lettre
    add edx,'A'-10 
.suite:   
    ;mov ebx,[edi + 7]       ;et on place le caractere en position debut + 8
    mov ebx,edi
    add ebx,ecx
    dec ebx    
    mov byte  [ebx],dl
    dec ecx
    cmp ecx,0            ;si pas taille atteinte on boucle
    jne .deb
    mov byte [edi + 8],0 ; ajout du 0 final
    mov eax,8           ; retour longueur
.fin:                   ; fin routine
    pop edi
    pop edx             ; restaur des registres
    pop ebx
    pop ecx
    leave               ; epilogue
    ret