; assembleur 32 bits Linux 
; Systeme Ubuntu Compilateur nasm
; programme : pgm4.asm
; affichage des registres
; test premières macro 
bits 32

;************************************************************
;               Constantes 
;************************************************************
%define STDOUT 1
EXIT  equ 1
WRITE equ 4 
TAILLE equ 19 
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
%macro affregtit 1
    jmp %%endstr
%%str: db %1,10,0
%%endstr:
    push %%str
    call afficherMess
    push 1
    call afficherRegistres
%endmacro
;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
hello db "Hello world.",10,0
szRetourLigne db 10,0
titrereg:  db "vidage registre #"
numvid     db "      ",10,13,0
lgti  equ $ - titrereg -1
 textereg: db 'eax = ' 
 valr1:    db '00000000  '
           db 'ebx = '
 valr2       db '00000000  '
           db 'ecx = '
 valr3       db '00000000  '
           db 'edx = '
 valr4       db '00000000  '
           db 10,13  ;retour ligne pour les 4 suivants
           db 'esi = '
 valr5       db '00000000  '
           db 'edi = '
 valr6       db '00000000  '
           db 'ebp = '
 valr7       db '00000000  '
           db 'esp = '
 valr8       db '00000000  '
           db 10,13
           db ' cs = '
 valr9       db '00000000  '
           db ' ds = '
 valr10       db '00000000  '
           db ' ss = '
 valr11       db '00000000  '
           db ' es = '
 valr12       db '00000000  '
            db 10,13
            db 'eip = '
 valr13       db '00000000  '
           db 10,13, 0
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZoneConv:          resb 20
iLongZone:          resd 1
;************************************************************
; Code segment 
;************************************************************
section .text
global  main             ; déclaration de main en global
main:
    
    push hello
    call afficherMess
    ;jmp .fin
    afficherLib "Affichage d'un registre"
    mov eax,1000
    push eax
    call afficherReg
    mov eax,1000
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    call afficherMess
    
    push dword [iLongZone]
    push sZoneConv
    call conversion10
    push sZoneConv
    call afficherMess

    push szRetourLigne
    call afficherMess
    mov ebx,eax
    push 1
    call afficherRegistres

    affregtit "Fin"

.fin:                     ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    xor ebx,ebx          ; code retour du programme
    int 0x80             ; interruption : retour à Linux
;************************************************************
;               Affichage String
;************************************************************
; paramètre 1 contient l'adresse de la chaine
afficherMess:
    enter 0,0           ; prologue
    pusha               ; sauvegarde des registres
    mov eax, [ebp + 8]  ; recup de la valeur a afficher
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
    popa                ; restaur des registres
    leave               ; epilogue
    ret 4
;************************************************************
;           conversion registre en chaine hexadecimal
;************************************************************
; eax contient la valeur à convertir
afficherReg:
    enter 0,0           ; prologue
    push eax              ; save registre
    push ebx              ; save registre
    mov eax, [ebp + 8] ; recup de la valeur a afficher
    push eax
    push sZoneConv
    call conversion16
    push sZoneConv
    call afficherMess
    push szRetourLigne
    call afficherMess
    pop ebx               ; restaur des registres
    pop eax               ; restaur des registres
    leave               ; epilogue
    ret
;************************************************************
;       afficher tous les registres en hexa
;************************************************************
; parametre 1 identifiant de l'affichage
afficherRegistres:
    push ebp
    mov ebp, esp
    pusha
    pushf
    push eax              ; push du registre eax avant utilisation
    mov eax, [ebp + 8]    ; recup identifiant du vidage
    push eax
    push numvid
    call conversion10
    mov eax,[iLongZone]
    mov byte[numvid,eax],' '
    ;add   esp, 8          ; dépile les paramètres
    ; affichage
    push titrereg       ; adresse du message
    call afficherMess
    ;push    eax ; push du registre eax deja pusher
    push    valr1 ; push de l'adresse de la zone qui recuperera la conversion sans zero terminal
    call    conversion16
    mov byte[valr1,eax],' '
    push    ebx ; push du registre a convertir
    push    valr2 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16 
    mov byte[valr2,eax],' ' 
    push    ecx ; push du registre a convertir
    push    valr3 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr3,eax],' ' 
    push    edx ; push du registre a convertir
    push    valr4 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr4,eax],' ' 
    push    esi ; push du registre a convertir
    push    valr5 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr5,eax],' ' 
    push    edi ; push du registre a convertir
    push    valr6 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr6,eax],' ' 
    push    dword [ebp]     ; original EBP
    ; push    ebp ; push du registre a convertir
    push    valr7 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr7,eax],' ' 
    lea     eax, [ebp+12]
    push    eax             ; original ESP
     ;push    esp ; push du registre a convertir
    push    valr8 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr8,eax],' ' 
    push    cs ; push du registre a convertir
    push    valr9 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr9,eax],' ' 
    push    ds ; push du registre a convertir
    push    valr10 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr10,eax],' ' 
    push    ss ; push du registre a convertir
    push    valr11 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr11,eax],' ' 
    push    es ; push du registre a convertir
    push    valr12 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr12,eax],' ' 
    mov    eax, [ebp]
    add    eax, 16         ; EIP on stack is 0x10 bytes ahead of orig
    push    eax ; push du registre a convertir
    push    valr13 ; push de l'adresse de la zone qui recuperera la conversion
    call    conversion16
    mov byte[valr13,eax],' ' 
                                ; affichage
    push  textereg            ; adresse du message
    call  afficherMess
    ; et on termine    
    popf
    popa
    pop ebp
    ret
    
;************************************************************
;           conversion registre en chaine hexadecimal
;************************************************************
; eax contient la valeur à convertir
; ebx la zone destinataire
conversion16:
    enter 0,0           ; prologue
    push ecx               ; sauvegarde des registres
    push ebx
    push edx
    push edi
    mov eax, [ebp + 12] ; recup de la valeur à convertir
    mov ebx, [ebp + 8] ; recup de la zone receptrive
    mov edi,ebx
    mov ecx,8
deb: mov edx,0
    mov ebx ,16            ;on divise par 16
    div ebx
    cmp edx,9              ;si le reste est inferieur à 10 c'est un chiffre
    jg  lettre
    add edx,'0'            ;donc on ajoute '0'
    ;
    jmp    suite
lettre:                    ;sinon c'est une lettre
    add edx,'A'-10 
suite:   
    ;mov ebx,[edi + 7]       ;et on place le caractere en position debut + 8
    mov ebx,edi
    add ebx,ecx
    dec ebx    
    ;mov eax,hello
    ;call afficherMess
    mov byte  [ebx],dl
    dec ecx
    ;si pas taille atteinte on boucle
    cmp ecx,0
    jne    deb
    mov byte [edi + 8],0 ; ajout du 0 final
    mov eax,8           ; retour longueur
.fin:                   ; fin routine
    pop edi
    pop edx             ; restaur des registres
    pop ebx
    pop ecx
    leave               ; epilogue
    ret 8
;*******************************************
;conversion en base 10
;avec suppression des zeros inutiles
;*******************************************
;par 1 registre à convertir
;par 2 adresse de stockage
conversion10:
    enter 0,0
    pusha    ;sauvegarde des registres
    pushf
    mov eax, [ebp + 12] ; recup de la valeur a afficher
    cmp eax,0
    jl nega
    mov dl,'+'
    jmp suitesigne
nega:
    mov dl,'-'
    neg eax
suitesigne:
    mov ecx, [ebp+8]
    mov byte [ecx],dl
    mov ecx,TAILLE
deb_boucle_deco:
    mov edx,0
    mov ebx ,10
    div ebx              ;on divise par 10
    add edx,'0'
      ;et on place le caractere en position debut + 8
    ;mov ebx,[ebp + 8]
    mov ebx,sZoneConv
    add ebx,ecx
    mov byte  [ebx],dl
    dec ecx
    cmp eax,0                    ;si division encore a faire
    jne    deb_boucle_deco
    ; il faut recopier le resultat dans la zone de reception
    ; de ecx à tailled
    xor ebx,ebx
deb_boucle_dep:
    mov dl,[sZoneConv+ecx+1]
    mov eax,[ebp+8]
    add eax,1  ; on saute la position du signe
    add eax,ebx
    mov byte [eax],dl
    inc ecx
    inc ebx

    cmp ecx,TAILLE
    jl deb_boucle_dep
    mov byte [eax+1],0
    inc ebx
    mov [iLongZone],ebx
.fin:
    popf
    popa  ; restaur des registres
    leave
    ret 8
