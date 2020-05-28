; assembleur 32 bits Linux 
; programme : pgm11.asm
; le registre d'état, les indicateurs ou flags
; les instructions de saut conditionnels
; les routines d'affichage sont déportées dans le fichier routines.asm

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
szMessDebPgm:   db "Début du programme.",10,0
szMessFinPgm:   db "Fin normale du programme.",10,0
szRetourLigne   db 10,0
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
                db 10,0
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
;sZoneConv:          resb 12
;sZoneBinaire:       resb 33
;************************************************************
; Code segment 
;************************************************************
section .text
extern afficherMess,afficherBinaire,afficherReg10S,afficherReg
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess

    afficherLib "Affichage du registre eflag"
    pushf
    call afficherBinaire
    xor eax,eax
    lahf 
    push eax
    call afficherBinaire
    call testerCarry
    call testerSigne
    call testerZero
    afficherLib "Routine Flags"
    call afficherFlags   ; affichage des indicateurs
    afficherLib "Valeur nulle "
    xor eax,eax
    call afficherFlags   ; affichage des indicateurs
    afficherLib "Valeur négative"
    sub eax,1
    call afficherFlags   ; affichage des indicateurs
    afficherLib "Multiplication non signee "
    mul eax
    call afficherFlags   ; affichage des indicateurs
    push eax
    call afficherBinaire  ; pour vérification
    push edx
    call afficherBinaire  ; pour vérification
    afficherLib "Comparaison non signee."
    mov eax,5
    mov ebx,2
    cmp eax,ebx
    call afficherFlags   ; affichage des indicateurs
    cmp ebx,eax
    call afficherFlags   ; affichage des indicateurs
    afficherLib "Comparaison signee ."
    mov eax,5
    mov ebx,-1
    cmp eax,ebx
    call afficherFlags   ; affichage des indicateurs
    cmp ebx,eax
    call afficherFlags   ; affichage des indicateurs

    afficherLib "Comparaison eax=-1,ebx=1"
    mov eax,-1
    mov ebx,1
    cmp eax,ebx
    ja plusgrand
    afficherLib "eax plus petit"
    jmp suite
plusgrand:
    afficherLib "eax plus grand"
suite:
    mov eax,-1
    mov ebx,1
    cmp eax,ebx
    jg plusgrand
    afficherLib "eax plus petit"
    jmp suite1
plusgrand1:
    afficherLib "eax plus grand"
suite1:

                           ; vérification test sur cx
    mov ecx,-1             ; pour mettre tous les bits à 1
    xor cx,cx              ; pour mettre les 16 premiers bits à zéro
    jcxz cxaZero           ; et vérifier le saut
    afficherLib "le registre cx est différent de zéro"
    jmp suite2
cxaZero:
    afficherLib "le registre cx est égal à zéro"
suite2:

    push szMessFinPgm
    call afficherMess
                         ; Fin standard du programme
    mov eax,EXIT         ; signalement de fin de programme
    xor ebx,ebx          ; code retour du programme
    int 0x80             ; interruption : retour à Linux

;************************************************************
;               test de l'indicateur carry
;************************************************************
; aucun parametre 
testerCarry:
    jc .carry
    afficherLib "carry à zéro"
    jmp .suite
.carry:
    afficherLib "carry à un"
.suite:
    ret
;************************************************************
;               test de l'indicateur signe
;************************************************************
; aucun parametre 
testerSigne:
    jns .positif
    afficherLib "Signe négatif"
    jmp .suite
.positif:
    afficherLib "Signe positif"
.suite:
    ret
;************************************************************
;               test de l'indicateur zéro
;************************************************************
; aucun parametre 
testerZero:
    jz .zero
    afficherLib "Indicateur Z différent de zéro"
    jmp .suite
.zero:
    afficherLib "Indicateur Z = zéro"
.suite:
    ret
;************************************************************
;               affichage des indicateurs
;************************************************************
; aucun parametre 
afficherFlags:
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
.fin:
    push szMessAffFlags
    call afficherMess
    pop eax
    ret