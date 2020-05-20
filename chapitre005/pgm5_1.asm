; assembleur 32 bits Linux 
; programme : pgm5_1.asm
; affichage d'un registre 
; verification de la valeur de retour 
; et ce n'est pas le cas, voir le programme suivant

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
szMessDebPgm:   db "Début du programme.",10,0
szMessFinPgm:   db "Fin normale du programme.",10,0
szRetourLigne   db 10,0
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZoneConv:          resb 12
;************************************************************
; Code segment 
;************************************************************
section .text
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess

    mov eax,1234
    push eax
    call afficherReg
    push eax
    call afficherReg

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
    push eax               ; sauvegarde des registres
    push ecx
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
    pop eax              ; restaur des registres
    leave                ; epilogue
    ret
;************************************************************
;           conversion registre en chaine décimale
;************************************************************
; parametre 1 contient la valeur à convertir
; parametre 2 contient l'adresse de la zone destinataire
conversion10:
    enter 0,0              ; prologue
    pusha                  ; sauvegarde des registres
    mov eax,[ebp + 12]     ; recup de la valeur à convertir
    mov edi,[ebp + 8]      ; recup de l'adresse 
    mov ecx,11             ; compteur de caractères 
    mov byte [edi + ecx],0 ; ajout du 0 final
.deb: 
    sub ecx,1              ; position précédente
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
    add ecx,1              ; sinon on incremente le compteur 
    add ebx,1              ; et le compteur début
    jmp .boucle            ; et on boucle 
.finboucle:
    mov eax,ebx            ; retour longueur
.fin:                      ; fin routine
    popa
    leave                  ; epilogue
    ret  8                 ; car 2 paramètres en entrée