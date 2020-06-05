; assembleur 32 bits Linux 
; programme : pgm15.asm
; lecture d'un fichier texte
; les routines d'affichage sont déportées dans le fichier routines.asm

bits 32

;************************************************************
;               Constantes 
;************************************************************
STDOUT  equ 1
EXIT    equ 1
READ    equ 3
WRITE   equ 4
OPEN    equ 5
CLOSE   equ 6

LGZONEBFIC  equ 100000

;  fichier
O_RDONLY  equ 0          ; lecture seule
O_WRONLY  equ 0x0001     ; écriture seule
O_RDWR    equ 0x0002     ; lecture-écriture


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
szRetourLigne:  db 10,0
szNomFic:       db  "test1.txt",0
;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
szBuffer:        resb LGZONEBFIC       ; zone réceptrice
dFDFichier       resd 1                ; FD du fichier
;************************************************************
; Code segment 
;************************************************************
section .text
extern afficherMess,afficherBinaire,afficherReg10S,afficherReg,conversion16
extern afficherReg16,afficherMemoire,conversion10S,afficherPiles,afficherFlags
global  main             ; déclaration de main en global
main:

    push szMessDebPgm
    call afficherMess

    mov eax,OPEN              ; ouverture du fichier
    mov ebx,szNomFic          ; nom du fichier
    mov ecx,O_RDWR            ; flag
    mov edx,0                 ; mode
    int 0x80
    cmp eax,0                 ; erreur ?
    jle erreur
    mov [dFDFichier],eax      ; stockage du File Descriptor FD
    push eax                  ; FD
    push szBuffer             ; zone receptrice
    call lireFichier          ; lecture
    cmp eax,0                 ; si erreur
    jl  close
    push szBuffer             ; affichage du buffer
    push 4
    call afficherMemoire
    push eax
    call afficherReg

close:
    mov eax,CLOSE             ; fermeture du fichier
    mov ebx,[dFDFichier]      ; FD
    int 0x80
    cmp eax,0
    jl erreurFerm

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx               ; code retour Ok du programme
    jmp fin
erreur:                       ; affichage message d'erreur
    push szMessErrOuv
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                 ; code retour erreur du programme
    jmp fin
erreurFerm:                   ; affichage message d'erreur
    push szMessErrFerm
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                 ; code retour erreur du programme
fin:
                              ; Fin standard du programme
    mov eax,EXIT              ; signalement de fin de programme
    int 0x80                  ; interruption : retour à Linux
szMessErrOuv:     db "Erreur ouverture du fichier.",10,0
szMessErrFerm:    db "Erreur fermeture du fichier.",10,0
;************************************************************
;     lecture d'un fichier
;************************************************************
; paramètre1  : File Descriptor du fichier
; paramètre2  : adresse de la zone receptrice
lireFichier:
    enter 0,0
    push ebx                  ;sauvegarde des registres
    push ecx
    push edx
    pushf
    mov eax,READ
    mov ebx,[ebp+12]          ; récuperation FD
    mov ecx,[ebp+8]           ; récuperation adresse zone réceptrice
    mov edx,LGZONEBFIC        ; longueur
    int 0x80
    cmp eax,0
    jge .A100                 ; si pas d'erreur
    push szMessErrLect        ; sinon affichage message d'erreur
    call afficherMess
    push eax                  ; et du code erreur
    call afficherReg10S 
    
.A100:
    popf
    pop edx
    pop ecx
    pop ebx                     ; restaur des registres
    leave
    ret 8                       ; 2 paramètres
szMessErrLect:     db "Erreur lecture du fichier.",10,0

