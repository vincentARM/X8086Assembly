; assembleur 32 bits Linux 
; programme : squel_1.asm
; informations sur le processeur : instruction cpuid
; les routines d'affichage sont déportées dans le fichier routines.asm
; les constantes sont déportées dans le fichier constantes32.asm
; les macros sont déportées dans le fichier macros32.asm
bits 32

;************************************************************
;               Constantes 
;************************************************************
;fichier des constantes générales
%include "../constantes32.asm"
BRK      equ 45
CHARPOS  equ   '@'
 
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
szRetourLigne:   db 10,0
szMessErreurGen: db "Erreur rencontrée.",10,0
szMessInfo1:     db "Famille ex : @ Modèle ex : @ type : @ "
                 db "Famille : @ Modèle : @ Stepping : @ ",10,0
szMessInfo1A:    db "Brand index : @ CLFLUSH line size : @ "
                 db "Maximun ID : @ Initial Apic ID : @ ",10,0                 

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZone1:             resb 24
sZoneConv:          resb 24
;************************************************************
; Code segment 
;************************************************************
section .text
extern conversion10
global  main             ; déclaration de main en global
main:
    mov ebp,esp
    push szMessDebPgm
    call afficherMess

    cpuid                 ;
    afficherRegs "Registres :" 
    mov [sZone1],ebx      ; stockage libellé contenu dans les 3 registres
    mov [sZone1+4],edx
    mov [sZone1+8],ecx

    push sZone1           ; et affichage du libellé trouvé
    push 2
    call afficherMemoire
    
    mov ebx,eax           ; save nombre d'infos disponibles
    cmp eax,1
    jl finok
    call information01
    cmp eax,-1
    je erreurgen
    
    cmp ebx,2
    jl finok
    call information02
    cmp eax,-1
    je erreurgen
    
    cmp ebx,3
    jl finok
    afficherLib "Autres Infos : à compléter"

finok:
    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme
    jmp fin

erreurgen:
    push szMessErreurGen
    call afficherMess
    mov ebx,1

fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
;************************************************************
;           CPUID informations 01
;************************************************************
information01:
    enter 0,0            ; prologue
    push ebx               ; save registres généraux
    push ecx
    push edx
    push edi
    push esi
    pushf                ; save indicateurs
    mov eax,1
    cpuid                 ; 
    afficherLib "01 Informations EAX"
    push eax
    call afficherBinaire
    mov ebx,eax
    and eax,0b1111111100000000000000000000
    shr eax,20
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push szMessInfo1
    call insererChaine
    cmp eax,0
    je .A99
    
    mov edi,eax
    mov eax,ebx
    and eax,0b11110000000000000000
    shr eax,16
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edi
    call insererChaine
    cmp eax,0
    je .A99
    
    mov edi,eax
    mov eax,ebx
    and eax,0b11000000000000
    shr eax,12
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edi
    call insererChaine
    cmp eax,0
    je .A99
    
    mov edi,eax
    mov eax,ebx
    and eax,0b111100000000
    shr eax,8
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edi
    call insererChaine
    cmp eax,0
    je .A99
    
    mov edi,eax
    mov eax,ebx
    and eax,0b11110000
    shr eax,4
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edi
    call insererChaine
    cmp eax,0
    je .A99

    mov edi,eax
    mov eax,ebx
    and eax,0b1111
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edi
    call insererChaine
    cmp eax,0
    je .A99
    push eax
    call afficherMess
                          ; information 1 registre ebx
    afficherLib "Informations EBX"
    mov eax,1
    cpuid                 ; 
    push ebx
    call afficherBinaire
    mov eax,ebx
    and eax,0xFF
    ;shr eax,20
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push szMessInfo1A
    call insererChaine
    cmp eax,0
    je .A99
    
    mov edi,eax
    mov eax,ebx
    and eax,0xFF00
    shr eax,8
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edi
    call insererChaine
    cmp eax,0
    je .A99
    mov edi,eax
    mov eax,ebx
    and eax,0xFF0000
    shr eax,16
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edi
    call insererChaine
    cmp eax,0
    je .A99
    mov edi,eax
    mov eax,ebx
    and eax,0xFF000000
    shr eax,24
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edi
    call insererChaine
    cmp eax,0
    je .A99
    push eax
    call afficherMess
    
                              ; information 1 registres
    afficherLib "Informations ECX"
    mov eax,1
    cpuid                 ; 
    push ecx
    call afficherBinaire
    afficherLib "Informations EDX"
    mov eax,1
    cpuid                 ; 
    push edx
    call afficherBinaire
    
    mov eax,0            ; ok
    jmp .A100
.A99:
    mov eax,-1           ; erreur
.A100:
    popf                 ; restaur indicateurs
    pop esi              ; restaur registres généraux
    pop edi  
    pop edx
    pop ecx
    pop ebx
    leave                ; epilogue
    ret
;************************************************************
;           CPUID Informations 2 
;************************************************************
information02:
    enter 0,0            ; prologue
    push ebx               ; save registres généraux
    push ecx
    push edx
    push edi
    push esi
    pushf                ; save indicateurs
    mov eax,2
    cpuid                 ; 
    afficherRegs "INFORMATIONS 02 "
    afficherLib "02 Informations EAX"
    push eax
    call afficherBinaire
    
    
    jmp .A100
.A99:
    mov eax,-1           ; erreur
.A100:
    popf                 ; restaur indicateurs
    pop esi              ; restaur registres généraux
    pop edi  
    pop edx
    pop ecx
    pop ebx
    leave                ; epilogue
    ret
;************************************************************
;      insertion chaine dans autre chaine au délimiteur @
;************************************************************
; le paramètre 1 contient l'adresse de la zone à inserer
; le parametre 2 contient l'adresse de la chaine réceptrice
; retourne dans eax l'adresse de la nouvelle chaine (sur le tas)
insererChaine:
    enter 4,0              ; prologue
%define pos1 [ebp-4]       ; position d'insertion
    push ebx               ; save registres généraux
    push ecx
    push edx
    push edi
    push esi
    pushf                  ; save indicateurs
    mov eax,BRK            ; 1er appel pour récupèrer l'adresse du tas
    mov ebx,0              ; avec zéro
    int 0x80
    cmp eax,0              ; erreur ?
    jle .A99
    mov edi,eax            ; adresse du tas pour stockage chaine finale
    mov eax,[ebp + 12]     ; recup adresse de la chaine 1
    mov ecx,0
.A1:                       ; boucle de calcul de la longueur
    cmp byte[eax+ecx],0
    je .A2                 ; zéro final ?
    inc ecx
    jmp .A1
.A2:
    mov ebx,ecx            ; save longueur chaine 1
    mov eax,[ebp + 8]      ; recup de l'adresse chaine 2
    mov ecx,0
.A3:                       ; boucle de calcul de la longueur chaine 2
    cmp byte[eax+ecx],0
    je .A4                 ; zéro final ?
    inc ecx
    jmp .A3
.A4:
    add ebx,ecx           ; + longueur chaine 2
    add ebx,edi           ; + adresse début tas
    inc ebx               ; pour le zéro final
    mov eax,BRK           ; 2ième appel pour récupèrer l'adresse du tas
    int 0x80
    cmp eax,0             ; erreur ?
    jle .A99
                         ; copie début chaine jusqu'au caractère insertion
    mov esi,[ebp + 8]    ; recup de l'adresse chaine 2    
    mov ecx,0
.A5:                     ; boucle de copie
    mov al,[esi+ecx]
    cmp al,0             ; zéro final ?
    je .A98              ; si oui -> erreur
    cmp al,CHARPOS       ; caractère d'insertion ?
    je .A6               ; oui -> suite
    mov [edi+ecx],al     ; sinon copie
    inc ecx
    jmp .A5              ; et boucle
.A6:
    mov ebx,ecx          ; position départ insertion
    mov pos1,ecx         ; et on garde la position pour copie de la fin
    mov ecx,0
    mov esi,[ebp + 12]   ; recup de l'adresse chaine 1
.A7:                     ; boucle de copie de la chaine à inserer 
    mov al,[esi+ecx]
    cmp al,0             ; zero final ?
    je .A8
    mov [edi+ebx],al     ; copie caractère
    inc ebx
    inc ecx
    jmp .A7              ; et boucle
.A8:                     ; insertion fin chaine 2
    mov ecx,pos1         ; récupération position 
    inc ecx              ; pour sauter le caractère d'insertion
    mov esi,[ebp + 8]    ; recup de l'adresse chaine 2     
.A9:                     ; boucle de copie
    mov al,[esi+ecx]
    mov [edi+ebx],al
    cmp al,0             ; zero final ?
    je .A10
    inc ebx
    inc ecx
    jmp .A9              ; et boucle
.A10:
    mov eax,edi          ; retourne l'adresse début de zone du tas
    jmp .A100
.A98:                    ; caractère d'insertion non trouvé
    push szMessPBCarIns
    call afficherMess
    mov eax,0
    jmp .A100
.A99:                    ; erreur d'allocation
    push szMessPBAlloc
    call afficherMess
    mov eax,0
.A100:    
    popf                 ; restaur indicateurs
    pop esi              ; restaur registres généraux
    pop edi  
    pop edx
    pop ecx
    pop ebx
    leave                ; epilogue
    ret 8                ; car 2 paramètres en entrée
szMessPBCarIns:  db "Caractère d'insertion non trouvé !!",10,0
szMessPBAlloc:   db "Problème d'allocation !!",10,0
