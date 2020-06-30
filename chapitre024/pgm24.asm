; assembleur 32 bits Linux 
; programme : squel_1.asm
; Calculs avec les nombres BCD
; les routines d'affichage sont déportées dans le fichier routines.asm
; les constantes sont déportées dans le fichier constantes32.asm
; les macros sont déportées dans le fichier macros32.asm
bits 32

;************************************************************
;               Constantes 
;************************************************************
;fichier des constantes générales
%include "../constantes32.asm"
NBCHIFFRES equ 9
 
;************************************************************
;               Macros
;************************************************************
;fichier des macros générales
%include "../macros32.asm"

;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
szMessDebPgm:    db "Début du programme.",10,0
szMessFinPgm:    db "Fin normale du programme.",10,0
szMessErreurGen: db "Erreur rencontrée.",10,0
szRetourLigne:   db 10,0
szFin:           db "fin",10,0
bcdNombre1:      dd 0x8
bcdNombre2:      dd 0x9
bcdNombre3:      db 1,2,3,4,5,6,7,8,7          ; nombres de 9 chiffres
bcdNombre4:      db 7,0,0,0,5,6,7,8,9
bcdNombre5:      db 1,2,3,4,5,6,7,8,9

bcdNombre6:      db 9,9,9,9,9,9,9,9,9
bcdNombre7:      db 9,9,9,9,9,9,9,9,9

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZone1:             resb NBCHIFFRES         ; zone de résultat
sZoneMult:          resb NBCHIFFRES * 2     ; résultat pour la multiplication

;************************************************************
; Code segment 
;************************************************************
section .text
global  main             ; déclaration de main en global
main:
    mov ebp,esp
    push szMessDebPgm
    call afficherMess
                              ; test addition simple
    mov eax,[bcdNombre1]   
    add eax,[bcdNombre2]
    daa                       ; ajustement décimal
    afficherRegs "Addition et ajustement :"  

    mov eax,[bcdNombre1]
    add eax,[bcdNombre2]
    aaa                       ; ajustement ascii
    afficherRegs "Ajustement ascii :"  
    or eax,0x3030             ; et conversion ascii
    afficherRegs "Conversion ascii :"  
    
                              ; addition grands nombres
    push bcdNombre3
    push bcdNombre4
    push sZone1               ; zone résultat
    push NBCHIFFRES
    call additionBCD
    jc .A99                   ; si carry  -> erreur
    push sZone1               ; affichage mémoire du résultat
    push 2
    call afficherMemoire
    push sZone1               ; conversion et affichage ascii
    push NBCHIFFRES
    call afficherBCD    
    
                              ; soustraction
    afficherLib "Soustraction BCD."
    push bcdNombre5
    push bcdNombre3
    push sZone1
    push NBCHIFFRES
    call soustractionBCD
    jc .A99
    push sZone1
    push NBCHIFFRES
    call afficherBCD
                           ;  multiplication simple 
    afficherLib "Multiplication simple"                       
    mov eax,[bcdNombre1]
    mov ebx,[bcdNombre2]
    mul ebx
    aam
    afficherRegs "Verif multiplication simple"  
    
    
    afficherLib "Multiplication 1 chiffre"
    push bcdNombre5
    push 9
    push sZone1
    push NBCHIFFRES
    call multiplicationBCD1C
    jc .A99
    push sZone1
    push NBCHIFFRES * 2
    call afficherBCD
    
                              ; multiplication
    afficherLib "Multiplication 9 chiffres"
    push bcdNombre6
    push bcdNombre7
    push sZoneMult
    push NBCHIFFRES
    call multiplicationBCD
    jc .A99
    push sZoneMult
    push NBCHIFFRES * 2
    call afficherBCD
    
    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme
    jmp .A100
.A99:
    push szMessErreurGen
    call afficherMess
    mov ebx,1
.A100:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
;************************************************************
;           addition de 2 nombres mémoire format BCD
;************************************************************
; le paramètre 1 contient l'adresse du nombre 1
; le paramètre 2 contient l'adresse du nombre 2
; le parametre 3 contient l'adresse de la zone receptrice
; le parametre 4 contient le nombre de chiffres
additionBCD:
    enter 0,0            ; prologue
    pusha                ; save registres généraux
    mov ecx, [ebp + 8]   ; recup du nombre de chiffres
    dec ecx              ; car 1ére position est zéro
    mov edi,[ebp+12]     ; recup adresse résultat
    mov esi,[ebp+16]     ; recup adresse nombre 2
    mov ebx,[ebp+20]     ; recup adresse nombre 1
    xor edx,edx          ; raz retenue

.A1:                     ; début de boucle d'addition des chiffres
    xor eax,eax          ;raz zone calcul
    mov al,[esi+ecx]     ; charge un chiffre
    add al,[ebx+ecx]     ; addition au deuxieme
    aaa                  ; ajustement ascii
    add al,dl            ; ajout retenue
    aaa                  ; ajustement ascii

    mov [edi+ecx],al     ; stockage résultat
    mov dl,ah            ; et conservation retenue
    dec ecx              ; décrement indice
    jge .A1              ; et boucle
    cmp dl,0             ; si dl contient quelque chose, il y a dépassement
    jne .A99             ; de capacité donc erreur
    clc                  ; ok donc carry à 0
    jmp .A100
.A99:                    ; erreur overflow
    push szMessDepCap
    call afficherMess
    stc                  ; erreur donc carry à 1
.A100:
    popa                 ; restaur registres généraux
    leave                ; epilogue
    ret 16               ; car 4 paramètres en entrée
szMessDepCap:      db "Addition bcd : overflow !!",10,0
;************************************************************
;           soustraction de 2 nombres mémoire format BCD
;************************************************************
; le paramètre 1 contient l'adresse du nombre 1
; le paramètre 2 contient l'adresse du nombre 2
; le parametre 3 contient l'adresse de la zone receptrice
; le parametre 4 contient le nombre de chiffres
soustractionBCD:
    enter 0,0            ; prologue
    pusha                ; save registres généraux
    mov ecx, [ebp + 8]   ; recup du nombre de chiffres
    dec ecx
    mov edi,[ebp+12]     ; recup adresse résultat
    mov esi,[ebp+16]     ; recup adresse nombre 2
    mov ebx,[ebp+20]     ; recup adresse nombre 1
    xor edx,edx          ; raz retenue
.A1:
    xor eax,eax          ;raz zone calcul
    mov al,[ebx+ecx]     ; charge un chiffre
    sub al,[esi+ecx]     ; soustrait chiffre
    aas                  ; ajustement
    sub al,dl
    aas
    mov [edi+ecx],al     ; stockage résultat
    mov dl,ah
    dec ecx
    jge .A1
    cmp dl,0             ; si dl <> de zéro -> erreur
    jne .A99
    clc                  ; ok donc carry à 0
    jmp .A100
.A99:
    push szMessDepCapSous
    call afficherMess
    stc                  ; erreur donc carry à 1
.A100:
    popa                 ; restaur registres généraux
    leave                ; epilogue
    ret 16               ; car 4 paramètres en entrée
szMessDepCapSous:      db "Soustraction bcd : overflow !!",10,0
;************************************************************
;           multiplication de 2 nombres mémoire format BCD
;************************************************************
; le paramètre 1 contient l'adresse du nombre 1
; le paramètre 2 contient l'adresse du nombre 2
; le parametre 3 contient l'adresse de la zone receptrice
; le parametre 4 contient le nombre de chiffres
multiplicationBCD:
    enter 120,0            ; prologue
%define saveInd [ebp-4]
%define cptChif [ebp-8]
%define zonecal [ebp-40]
%define zoneRes [ebp-120]
    pusha                ; save registres généraux
    lea edi,zoneRes      ; adresse dernière zone
    mov ecx,119
.A1:                     ; boucle init 
    mov BYTE[edi+ecx],0
    ;mov BYTE[esi+ecx],0
    dec ecx
    jge .A1
    mov edi,[ebp+12]     ; recup adresse résultat
    mov esi,[ebp+16]     ; recup adresse nombre 2
    mov ebx,[ebp+20]     ; recup adresse nombre 1
    mov ecx,[ebp + 8]    ; recup du nombre de chiffres
    dec ecx
.A2:                     ; début de boucle de multiplication
    xor eax,eax          ;raz zone calcul
    mov al,[ebx+ecx]     ; charge un chiffre du nombre 1
    push esi             ; nombre 2
    push eax             ; chiffre nombre 1
    
    lea eax,zonecal
    push eax             ; adresse zone reception produit
    mov edx, [ebp + 8]   ; recup du nombre de chiffres
    push edx             ; nombre de chiffres
    call multiplicationBCD1C
                         ; décalage du produit intermèdiaire pour addition
    sub eax,ecx          ; soustraction indice
    add eax,edx          ; ajout nb de chiffre
    dec eax  
    push eax            ; adresse zone reception produit
    lea eax,zoneRes
    push eax            ; resultat courant
    push edi            ; zone resultat final
    mov edx, [ebp + 8]  ; recup du nombre de chiffres
    shl edx,1           ; multiplié par 2
    push edx            ; nombre de chiffres
    call additionBCD

    ; il faut recopier la zone finale dans zone de calcul
    mov saveInd,ecx       ; save indice courant
    mov ecx, [ebp + 8]    ; recup du nombre de chiffres
    shl ecx,1             ; multiplié par 2
    dec ecx
    lea edx,zoneRes       ; zone resultat courant
.A3:
    mov al,[edi+ecx]      ; resultat de l'addition
    mov [edx+ecx],al      ; copie dans zone resultat courant
    dec ecx
    jge .A3               ; et boucle
    mov ecx,saveInd       ; restaur indice

    dec ecx               ; chiffre précédent
    jge .A2               ; et boucle 

    clc                  ; ok donc carry à 0
.A100:
    popa                 ; restaur registres généraux
    leave                ; epilogue
    ret 16               ; car 4 paramètres en entrée
szMessDepCapMul:      db "Multiplication bcd : overflow !!",10,0
;************************************************************
;           multiplication d'un nombre mémoire format BCD
;           le nombre 2 ne contient qu'un chiffre BCD
;************************************************************
; le paramètre 1 contient l'adresse du nombre 1
; le paramètre 2 contient le nombre 2
; le parametre 3 contient l'adresse de la zone receptrice
; le parametre 4 contient le nombre de chiffres
multiplicationBCD1C:
    enter 0,0            ; prologue
    pusha                ; save registres généraux
    mov edi,[ebp+12]     ; recup adresse résultat
    mov ebx,[ebp+16]     ; recup nombre 2
    mov esi,[ebp+20]     ; recup adresse nombre 1
                         ; initialiser la zone de reception avec des zéros
    mov ecx, [ebp + 8]   ; recup du nombre de chiffres
    shl ecx,1            ; * par 2
    dec ecx
    mov edx,ecx          ; save pour usage dans boucle produit
.A1:                     ; boucle init 
    mov BYTE[edi+ecx],0
    dec ecx
    jge .A1
    
    mov ecx, [ebp + 8]   ; recup du nombre de chiffres
    dec ecx              ; car la 1ére position est zéro
.A2:
    xor eax,eax          ; raz zone calcul
    mov al,[esi+ecx]     ; charge un chiffre du nombre 1
    mul bl               ; multiplier
    aam                  ; ajustement ascii
    add al,[edi+edx]     ; addition retenue
    aaa                  ; ajustement ascii
    mov [edi+edx],al     ; stockage produit
    mov [edi+edx-1],ah   ; stockage retenue
    dec edx              ; décremente la position de stockage
    dec ecx              ; decrementer le compteur ecx
    jge .A2              ; et boucler

    clc                  ; ok donc carry à 0

.A100:
    popa                 ; restaur registres généraux
    leave                ; epilogue
    ret 16               ; car 4 paramètres en entrée
    
;************************************************************
;           affichage d'un nombre bcd
;************************************************************
; le paramètre 1 contient l'adresse du nombre 1
; le parametre 2 contient le nombre de chiffres
afficherBCD:
    enter 80,0           ; prologue
%define affi  ebp-75
    pusha                ; save registres généraux
    pushf                ; save indicateurs
    mov ecx, [ebp + 8]   ; recup du nombre de chiffres
    dec ecx
    mov esi,[ebp+12]     ; recup adresse du nombre
    lea ebx,[affi]
    add ebx,ecx
    mov dword[ebx+1],0x0A ; 0 final + retour ligne
.A1:
    mov al,[esi+ecx]      ; charge un chiffre
    xor al,0x30           ; conversion en ascii
    mov [ebx],al          ; stockage
    dec ebx
    dec ecx
    jge .A1
    inc ebx
                         ; et affichage du résultat
    push ebx
    call afficherMess
    
    popf                 ; restaur indicateurs
    popa                 ; restaur registres généraux
    leave                ; epilogue
    ret 8                ; car 2 paramètres en entrée
    