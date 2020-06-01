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
global conversion10S,conversion2,conversion16

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
afficherReg16:
    enter 0,0           ; prologue
    push eax            ; save registre
    mov eax, [ebp + 8]  ; recup de la valeur à convertir
    push szMessHexa  ; affichage du debut du message 
    call afficherMess
    push eax
    push sZoneConv
    call conversion16
    push sZoneConv
    call afficherMess
    push szRetourLigne
    call afficherMess
    pop eax               ; restaur des registres
    leave               ; epilogue
    ret 4
;************************************************************
;           conversion registre en chaine hexadecimal
;************************************************************
; parametre 1 contient la valeur à convertir
; parametre 2 contient l'adresse de la zone destinataire
conversion16:
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
