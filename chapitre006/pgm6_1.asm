; assembleur 32 bits Linux 
; programme : pgm6_1.asm
; affichage d'un registre en base 10 
; verification des limites des instructions arithmètiques

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

    mov eax,4000             ; pas d'overflow
    ; mov eax,4000000001     ; pour tester l'overflow
    mov ebx,1000             ; multiplicateur
    mul ebx
    jo over
    afficherLib "Pas d'overflow"
    jmp suite
over:
    afficherLib "Overflow."
suite:
                                  ; cas de l'addition
    afficherLib "Addition"
    mov eax,4294967290
    mov ebx,10
    add eax,ebx
    jo over1
    afficherLib "Pas d'overflow"
    jmp suite1
over1:
    afficherLib "Overflow."
    push eax
    call afficherReg
suite1:
    afficherLib "Controle eax après addition"
    push eax
    call afficherReg
    afficherLib "Addition avec retenue"
    mov eax,4294967290
    mov ebx,10
    add eax,ebx
    jc over2
    afficherLib "Pas de retenue"
    jmp suite2
over2:
    afficherLib "Retenue."
    push eax
    call afficherReg
suite2:
                         ; cas de la soustraction
    mov eax, 5
    mov ebx, 15
    sub eax,ebx
    jo over3
    afficherLib "Soustraction. Pas d'overflow"
    jmp suite3
over3:
    afficherLib "Soustraction Overflow."
suite3:
    sub eax,ebx               ; soustraction refaite car afficherLib change les flags
    jc over4
    afficherLib "Soustraction. Pas de retenue"
    jmp suite4
over4:
    afficherLib "Soustraction. Retenue."
suite4:
    sub eax,ebx
    js over5
    afficherLib "Soustraction. Positif"
    jmp suite5
over5:
    afficherLib "Soustraction. Negatif."
suite5:
    afficherLib "Controle eax aprés soustraction"
    push eax
    call afficherReg


    push szMessFinPgm
    call afficherMess
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    mov ebx,0          ; code retour du programme
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
    ;push eax             ; save registre
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
    ;pop eax              ; restaur des registres
    leave                ; epilogue
    ret
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
    pop edi
    pop edx
    pop ecx
    pop ebx
    leave                  ; epilogue
    ret  8                 ; car 2 paramètres en entrée
