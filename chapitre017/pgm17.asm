; assembleur 32 bits Linux 
; programme : pgm15.asm
; test diverses instructions accès mémoire
; les routines d'affichage sont déportées dans le fichier routines.asm

bits 32

;************************************************************
;               Constantes 
;************************************************************
STDOUT equ 1
EXIT  equ 1
WRITE equ 4 
;************************************************************
;               Structures 
;************************************************************
struc  enreg1
    .valeur1    resb 1
    .valeur2    resd 1
    .valeur3    resb 40
    .fin        resd 0
endstruc

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
szRetourLigne:   db 10,0
dTabVal:        dd  1,2,0x12345678,4,5
szChaine1:      db "Chaine 1 "
       times 10 db '*'               ; génére 10 caractères *
                db 0

;message d'affichage des flags
szMessAffFlags: db "Affichage des indicateurs : ",10,"Zéro : "
sZero           db "  "
                db "Signe : "
sSigne          db "  "
                db "Carry : "
sCarry          db "  "
                db "Overflow : "
sOver           db "  "
                db "Parité : "
sPari           db "  "
                db "Direction : "
sDir            db "  "
                db 10,0

;zone pour test structure
stZone1:        db 5
                dd 10
                db "TOTO",0
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sBuffer:             resb 100
;************************************************************
; Code segment 
;************************************************************
section .text
extern afficherMess,afficherBinaire,afficherReg10S,afficherReg,conversion16
extern afficherReg16,afficherMemoire,conversion10S,afficherPiles
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess
    afficherLib "Lecture 2ième octet de l'entier N° 3"
    mov ecx,2             ; entier N° 3
    mov ebx,dTabVal       ; adresse début tableau
    xor eax,eax           ; init eax
    mov al,[ebx+(ecx * 4)+1] ; lecture octet
    push eax                ; et verification
    call afficherReg16

    afficherLib "Copie et flag direction"
    call afficherFlags      ; verification du flag de direction
    std                     ; forçage à 1  : décroissant
    call afficherFlags
    mov ecx,5               ; nombre de cractères à copier
    mov edi,sBuffer+10      ; destination
    mov esi,szChaine1+10    ; source
    rep movsb               ; copie 5 caractères
    push sBuffer
    push 2
    call afficherMemoire
    cld                     ; forçage à 0  : croissant
    call afficherFlags
    mov esi,dTabVal         ; source
    mov edi,sBuffer         ;destination
    mov ecx,3               ; nombre de double mots à copier
    rep movsd               ; copie 3 double mots (soit 4 * 3 = 12 octets)
    push sBuffer
    push 2
    call afficherMemoire

    afficherLib "Opérations arithmétique direct mémoire"
    mov eax,5
    add eax,[dTabVal+4]     ; addition avec un nombre en mémoire
    push eax
    call afficherReg10S
    mov dword[sBuffer+4],10 ; stockage nombre 1 en mémoire
    add dword[sBuffer+4],20 ; addition directe en mémoire
    push sBuffer            ; resultat 0x1E  = 30 Ok
    push 2
    call afficherMemoire
    mov eax,2
    xchg eax,[sBuffer+4]    ; echange les 2 valeurs
    push eax                ; on récupère bien 30
    call afficherReg10S
    ;xchg [sBuffer+4],[sBuffer+8]  ; pas possible

    afficherLib "Structures"
    xor eax,eax
    mov esi,stZone1
    mov al,[esi+enreg1.valeur1]
    push eax                ; on récupère bien 5
    call afficherReg10S

    mov eax,[esi+enreg1.valeur2]
    push eax                ; on récupère bien 10
    call afficherReg10S
    mov eax,enreg1.fin      ; pour vérif longueur totale zone
    push eax                ; on récupère bien 45 (1 + 4 + 40)
    call afficherReg10S
    
    mov eax,stZone1         ; adresse zone
    add eax,enreg1.valeur3  ; pour acceder à la 3ième zone
    push eax                ; et comme c'est une chaine, affichage
    call afficherMess
    push szRetourLigne
    call afficherMess

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx          ; code retour Ok du programme

fin:
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    int 0x80             ; interruption : retour à Linux

;************************************************************
;               affichage des indicateurs
;************************************************************
; aucun parametre 
afficherFlags:                ; INFO: afficherFlags
    push eax
    jz .zero
    mov al,'0'
    mov [sZero],al
    jmp .suite
.zero:
    mov al,'1'
    mov [sZero],al
.suite:
    js .signe
    mov al,'0'
    mov [sSigne],al
    jmp .suite1
.signe:
    mov al,'1'
    mov [sSigne],al
.suite1:
    jc .carry
    mov al,'0'
    mov [sCarry],al
    jmp .suite2
.carry:
    mov al,'1'
    mov [sCarry],al
.suite2:
    jo .over
    mov al,'0'
    mov [sOver],al
    jmp .suite3
.over:
    mov al,'1'
    mov [sOver],al
.suite3:
    jp .pair
    mov al,'0'
    mov [sPari],al
    jmp .suite4
.pair:
    mov al,'1'
    mov [sPari],al
.suite4:
    pushf
    pop eax
    test eax,1<<10
    jz .incre
    mov al,'D'          ; décroissant
    mov [sDir],al
    jmp .suite5
.incre:
    mov al,'C'          ; croissant
    mov [sDir],al
.suite5:
.fin:
    push szMessAffFlags
    call afficherMess
    pop eax
    ret
