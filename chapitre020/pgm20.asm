; assembleur 32 bits Linux 
; programme : pgm20.asm
; Affichage de tous les registres
; les routines d'affichage sont déportées dans le fichier routines.asm

bits 32

;************************************************************
;               Constantes 
;************************************************************
STDIN  equ 0
STDOUT equ 1
EXIT   equ 1
READ   equ 3
WRITE  equ 4 

;************************************************************
;               Macros
;************************************************************
; affichage d'un libellé
%macro afficherLib 1        
    jmp %%endstr
%%str: db %1,10,0
%%endstr:
    push %%str
    call afficherMess
%endmacro
;affichage des registres
%macro afficherRegs 1
    jmp %%endstr
%%str: db %1,10,0
%%endstr:
    push %%str
    call afficherMess
    call afficherRegistres
%endmacro
;affichage des selecteurs de segments
%macro afficherSeg 1
    jmp %%endstr
%%str: db %1,10,0
%%endstr:
    push %%str
    call afficherMess
    call afficherSegments
%endmacro
;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
szMessDebPgm:    db "Début du programme.",10,0
szMessFinPgm:    db "Fin normale du programme.",10,0
szRetourLigne:   db 10,0
szFin:           db "fin",10,0

szTextereg:  db 'eax = ' 
 valr1       db '00000000  '
             db 'ebx = '
 valr2       db '00000000  '
             db 'ecx = '
 valr3       db '00000000  '
             db 'edx = '
 valr4       db '00000000  '
             db 10              ;retour ligne pour les 4 suivants
             db 'esi = '
 valr5       db '00000000  '
             db 'edi = '
 valr6       db '00000000  '
             db 'ebp = '
 valr7       db '00000000  '
             db 'esp = '
 valr8       db '00000000  '
             db 10, 0
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss

;************************************************************
; Code segment 
;************************************************************
section .text
extern afficherMess,afficherBinaire,afficherReg10S,afficherReg,conversion16
extern afficherReg16,afficherMemoire,conversion10S,afficherPiles,afficherFlags
extern afficherSegments
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess
    mov ebp,esp

    call afficherPiles

    mov eax,1                ; pour verifier les contenus de chaque registres
    mov ebx,2
    mov ecx,3
    mov edx,4
    mov esi,5
    mov edi,6
    call afficherRegistres   ; affichage de tous les registres


    afficherRegs "Registres N° 1 :"   ; utilisation de la macro

    sub esp,4
    afficherRegs "Registres N° 2 :"   ; utilisation de la macro
    add esp,4

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme


fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
;************************************************************
;               affichage des registres généraux
;************************************************************
; pas de parametres
afficherRegistres:
    enter 0,0
    pusha                     ;sauvegarde des registres
    pushf                     ; sauvegarde des flags
    push eax                  ; parametre 1
    push valr1                ; parametre 2 zone de réception
    call conversion16
    mov byte [valr1+8],' '    ; pour enlever le 0 final
    push ebx                  ; idem pour les autres registres
    push valr2
    call conversion16
    mov byte [valr2+8],' '
    push ecx
    push valr3
    call conversion16
    mov byte [valr3+8],' '
    push edx
    push valr4
    call conversion16
    mov byte [valr4+8],' '
    push esi
    push valr5
    call conversion16
    mov byte [valr5+8],' '
    push edi
    push valr6
    call conversion16
    mov byte [valr6+8],' '
    mov eax,ebp               ; l'adresse de epb avant l'appel est 
    push dword[eax]           ; dans ebp actuelle
    push valr7
    call conversion16
    mov byte [valr7+8],' '
    add eax,8                 ; l'adresse de la pile est 8 octets avant ebp
    push eax
    push valr8
    call conversion16
    mov byte [valr8+8],' '

    push szTextereg
    call afficherMess

.A100:                            ; fin de la routine
    popf
    popa                          ; restaur des registres
    leave
    ret