; assembleur 32 bits Linux 
; programme : pgm6.asm
; affichage d'un registre en base 10 
; verification des instructions arithmètiques

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

    mov eax,100
    mov ebx,10
    mov eax,ebx            ; verif mov
    push eax
    call afficherReg
    afficherLib "Controle ebx après mov"
    push ebx
    call afficherReg
    mov eax,100
    add eax,ebx             ; addition
    afficherLib "Controle eax après add"
    push eax
    call afficherReg
    mov eax,100
    sub eax,ebx             ; soustraction
    afficherLib "Controle eax après sub"
    push eax
    call afficherReg
    mov eax,100
    ;mul 10           non autorisé
    mul ebx                 ; multiplication
    afficherLib "Controle eax après mul"
    push eax
    call afficherReg
    mov eax,100
    mov edi,50              ; calculs possibles avec edi
    add eax,edi
    afficherLib "Controle eax après add eax,edi"
    push eax
    call afficherReg

    mov eax,100
    mul esi                 ; ou avec esi
    afficherLib "Controle eax après mul esi"
    push eax
    call afficherReg
    mov eax,100
    inc eax                 ; increment
    afficherLib "Controle eax après inc eax"
    push eax
    call afficherReg
    mov eax,100
    dec eax                  ; decrement
    afficherLib "Controle eax après dec eax"
    push eax
    call afficherReg
    mov eax,100
    xchg eax,ebx             ; echange 
    afficherLib "Controle eax après xchg eax,ebx"
    push eax
    call afficherReg
    afficherLib "Controle ebx après xchg eax,ebx"
    push ebx
    call afficherReg

    mov eax,101
    ;mov ebx,0                 ; pour tester la division par zéro
    mov ebx,20
    ;mov edx,0                 ; à remettre si pb dans le résultat
    div ebx
    afficherLib "Controle eax après div ebx"
    push eax
    call afficherReg
    afficherLib "Controle ebx après div ebx"
    push ebx
    call afficherReg
    afficherLib "Controle edx après div ebx"
    push edx
    call afficherReg
    push ebx
    call afficherReg
    mov eax,101
    mov ecx,15
    mov edx,0              ; indispensable
    div ecx
    afficherLib "Controle eax après div ecx"
    push eax
    call afficherReg
    push edx
    call afficherReg
    mov eax,1002
    mov ebx,20
    mov edx,0
    div ebx
    afficherLib "Controle eax après div ebx  2ième"
    push eax
    call afficherReg
    push edx
    call afficherReg
    ;division 2 registres  edx:eax
    mov eax,100
    mov edx,1                ; correspond à 2 puissance 32 soit 4 294 967 296
    mov ebx,1000             ; diviseur
    div ebx
    afficherLib "Controle eax aprés div edx:eax"
    push eax
    call afficherReg
    afficherLib "Controle edx aprés div edx:eax"
    push edx
    call afficherReg
    mov eax,4000000001
    mov ebx,1000             ; multiplicateur
    mul ebx
    afficherLib "Controle eax aprés mul eax par ebx"
    push eax
    call afficherReg
    afficherLib "Controle edx aprés mul eax par ebx"
    push edx
    call afficherReg


    ;affichage autres registres
    ; push eip               non valide
    ; mov eax,eip            non valide
    push eax
    call afficherReg
    afficherLib "Affichage registre de pile esp"
    push esp
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