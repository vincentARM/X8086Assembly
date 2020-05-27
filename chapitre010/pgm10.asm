; assembleur 32 bits Linux 
; programme : pgm10.asm
; suite instructions de manipulation des bits
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
szMessRegistre: db "Affichage décimal d'un registre : ",0
szMessBinaire:  db "Affichage registre en binaire : ",0
szMessDebPgm:   db "Début du programme.",10,0
szMessFinPgm:   db "Fin normale du programme.",10,0
szRetourLigne   db 10,0
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

    afficherLib "Instruction deplacement gauche"
    mov eax,0b0011
    mov ecx,5
    shl eax,cl             ; registre cl uniquement 
    push eax
    call afficherBinaire
    afficherLib "Instruction deplacement droite valeur immédiate"
    mov eax,0b110000
    shr eax,2             ;
    push eax
    call afficherBinaire
    afficherLib "Instruction deplacement gauche = multiplication par 2"
    mov eax,5
    push eax
    call afficherBinaire
    ;mov ecx,2
    shl eax,1            ; déplacement
    push eax
    call afficherBinaire
    push eax
    call afficherReg10S
    afficherLib "Instruction deplacement droite de 3 = division par 8"
    mov eax,1000
    shr eax,3
    push eax
    call afficherReg10S
    afficherLib "Instruction déplacement droite pour nombres signés"
    mov eax,-1000
    sar eax,3
    push eax
    call afficherReg10S


    afficherLib "Instruction deplacement droite verif du carry"
    mov eax,0b10
    shr eax,1               ; premier déplacement à droite
    call testerCarry        ; le bit doit être zéro
    shr eax,1               ; deuxieme déplacement à droite
    call testerCarry        ; le bit doit être un

    afficherLib "Instruction rotation droite"
    mov eax,0b0011
    mov ecx,10
    ror eax,cl             ; registre cl uniquement 
    push eax
    call afficherBinaire
    afficherLib "Instruction rotation gauche"
    mov ecx,9
    rol eax,cl             ; registre cl uniquement 
    push eax
    call afficherBinaire
    afficherLib "Instruction rotation gauche avec deplacement retenue"
    mov ecx,9
    rcl eax,cl             ; registre cl uniquement 
    push eax
    call afficherBinaire
    afficherLib "Instruction rotation droite avec deplacement retenue"
    stc                   ;  positionne l'indicateur carry à un
    rcr eax,3             ;  exemple avec valeur immédiate
    push eax
    call afficherBinaire
                          ; tests de bits
    afficherLib "Test d'un bit "
    mov eax,0b10
    bt eax,1              ; les positions commencent à zéro
    call testerCarry
    push eax
    call afficherBinaire
    btc eax,1             ; et complément du bit du registre
    call testerCarry
    push eax
    call afficherBinaire
    bts eax,1             ; et mise à 1 du bit du registre
    call testerCarry
    push eax
    call afficherBinaire
    btr eax,1             ; et mise à 0 du bit du registre
    call testerCarry
    push eax
    call afficherBinaire
    afficherLib "Instruction bsf"
    mov eax,0b10010000
    bsf ebx,eax             ; met dans ebx la position du premier 1 à droite
    push eax
    call afficherBinaire
    push ebx
    call afficherReg
    mov eax,0b10010000
    bsr ebx,eax             ; met dans ebx la position du premier 1 à gauche
    push eax
    call afficherBinaire
    push ebx
    call afficherReg
                            ; instruction test
    mov eax,0b1100
    push eax
    call afficherBinaire
    test eax,1               ; effectue un ET entre 0b1100 ET 0b0001
    call testerSigne
    call testerZero
    test eax,0b100          ; effectue un ET entre 0b1100 ET 0b0100
    call testerSigne
    call testerZero
    test eax,0b1100          ; effectue un ET entre 0b1100 ET 0b1100
    call testerSigne
    call testerZero
    afficherLib "Test nombre négatif"
    bts eax,31             ; et mise à 1 du 31 ième bit du registre
    push eax
    call afficherBinaire
    test eax,1<<31          ;  test 31 bit
    call testerSigne
    call testerZero

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