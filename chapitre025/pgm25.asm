; assembleur 32 bits Linux 
; programme : pgm25.asm
; utilisation du framebuffer : affichage informations
; les routines d'affichage sont déportées dans le fichier routines.asm
; les constantes sont déportées dans le fichier constantes32.asm
; les macros sont déportées dans le fichier macros32.asm
bits 32

;************************************************************
;               Constantes 
;************************************************************
;fichier des constantes générales
%include "../constantes32.asm"
CHARPOS               equ '@'        ; caractère d'insertion

OPEN                  equ 5          ; call system Linux
CLOSE                 equ 6
BRK                   equ 45
IOCTL                 equ 54
;  fichier
O_RDONLY              equ 0          ; lecture seule
O_WRONLY              equ 0x0001     ; écriture seule
O_RDWR                equ 0x0002     ; lecture-écriture

FBIOGET_FSCREENINFO   equ 0x4602
FBIOGET_VSCREENINFO   equ 0x4600
FBIOPUT_VSCREENINFO   equ 0x4601     ; code pour l'écriture des données variables.

;************************************************************
;               Macros
;************************************************************
;fichier des macros générales
%include "../macros32.asm"

;************************************************************
;               Structures
;************************************************************

; structure FSCREENINFO
; voir explication détaillée : https://www.kernel.org/doc/Documentation/fb/api.txt
struc  FBFIXSCinfo
.id:              resb 16        ; identification string eg "TT Builtin"
.smem_start:      resd 1         ; Start of frame buffer mem 
.smem_len:        resd 1         ; Length of frame buffer mem 
.type:            resd 1         ; see FB_TYPE_*
.type_aux:        resd 1         ; Interleave for interleaved Planes
.visual:          resd 1         ; see FB_VISUAL_*
.xpanstep:        resw 1         ; zero if no hardware panning
.ypanstep:        resw 1         ; zero if no hardware panning
.ywrapstep:       resd 1         ; zero if no hardware ywrap
.line_length:     resd 1         ; length of a line in bytes
.mmio_start:      resd 1         ; Start of Memory Mapped I/O
.mmio_len:        resd 1         ; Length of Memory Mapped I/O
.accel:           resd 1         ; Indicate to driver which    specific chip/card we have
.capabilities:    resd 1         ; see FB_CAP_*
.reserved:        resq 1         ; Reserved for future compatibility
.fin:
endstruc
; structure VSCREENINFO */    
struc     FBVARSCinfo
.xres:                resd 1           ; visible resolution
.yres:                resd 1            
.xres_virtual:        resd 1           ; virtual resolution
.yres_virtual:        resd 1           
.xoffset:             resd 1           ; offset from virtual to visible resolution
.yoffset:             resd 1          
.bits_per_pixel:      resd 1           ; bits par pixel
.grayscale:           resd 1           ; 0 = color, 1 = grayscale,  >1 = FOURCC
.red:                 resd 1           ; bitfield in fb mem if true color,
.green:               resd 1           ; else only length is significant
.blue:                resd 1        
.transp:              resd 1           ; transparency
.nonstd:              resd 1           ; != 0 Non standard pixel format
.activate:            resd 1           ; see FB_ACTIVATE_*
.height:              resd 1           ; height of picture in mm
.width:               resd 1           ; width of picture in mm
.accel_flags:         resd 1           ; (OBSOLETE) see fb_info.flags
; Timing: All values in pixclocks, except pixclock (of course)
.pixclock:            resd 1           ; pixel clock in ps (pico seconds)
.left_margin:         resd 1           
.right_margin:        resd 1           
.upper_margin:        resd 1         
.lower_margin:        resd 1        
.hsync_len:           resd 1           ; length of horizontal sync
.vsync_len:           resd 1           ; length of vertical sync
.sync:                resd 1           ; see FB_SYNC_*
.vmode:               resd 1           ; see FB_VMODE_*
.rotate:              resd 1           ; angle we rotate counter clockwise
.colorspace:          resd 1           ; colorspace for FOURCC-based modes
.reserved:            resb 16          ; Reserved for future compatibility
.fin:    
endstruc
;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
szMessDebPgm:    db "Début du programme.",10,0
szMessFinPgm:    db "Fin normale du programme.",10,0
szMessErrGen:    db "Erreur rencontrée. Fin anormale.",10,0
szMessErrOuv:    db "Erreur ouverture du fichier.",10,0
szMessErrAccesF:  db "Erreur acces données fixes.",10,0
szMessErrAccesV:  db "Erreur acces données variables.",10,0
szMessInfoFixe:  db "Adresse = @ taille = @",10,0 
szMessInfoVar:   db "Largeur = @ hauteur = @ bits par pixel = @ ",10,0 
szRetourLigne:   db 10,0

szNomFic         db "/dev/fb0",0

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZoneConv:          resb 24
sZone1:             resb 200
dFDFichier:         resd 1
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
    
    mov eax,OPEN              ; ouverture du fichier
    mov ebx,szNomFic          ; nom du fichier
    mov ecx,O_RDWR            ; flag
    mov edx,0                 ; mode
    int 0x80
    cmp eax,0                 ; erreur ?
    jle .A98
    mov [dFDFichier],eax      ; stockage du File Descriptor FD
    mov ebx,eax               ; puis dans paramètre 2
    mov eax,IOCTL             ; code call sysyem
    mov ecx,FBIOGET_FSCREENINFO ; code lecture infos fixes
    mov edx,sZone1            ; adresse de la structure de reception
    int 0x80
    cmp eax,0                 ; erreur ?
    jl .A97

    push sZone1               ; affichage mémoire du résultat
    push 4
    call afficherMemoire
    
    mov ebx,sZone1            ; affichage en clair de 2 zones
    mov eax,[ebx+FBFIXSCinfo.smem_start] ; recup valeur dans structure
    push eax
    push sZoneConv                       ; conversion hexa
    call conversion16
    push sZoneConv
    push szMessInfoFixe                  ; et insertion dans message
    call insererChaine
    mov edx,eax                          ; save adresse message sur le tas
    mov eax,[ebx+FBFIXSCinfo.smem_len]   ; recup taille dans structure
    push eax
    push sZoneConv                       ; conversion décimale
    call conversion10
    push sZoneConv
    push edx                             ; et insertion dans message précedent
    call insererChaine
    cmp eax,0
    je .A99
    push eax                             ; affichage de la ligne
    call afficherMess
    
    mov eax,IOCTL                        ; code appel systeme
    mov ebx,[dFDFichier]                 ; recup du File Descriptor FD
    mov ecx,FBIOGET_VSCREENINFO          ; code pour lecture infos variables
    mov edx,sZone1                       ; zone de reception
    int 0x80
    cmp eax,0                            ; erreur ?
    jl .A96

    push sZone1                          ; affichage mémoire du résultat
    push 4
    call afficherMemoire
    
                                         ;affichage des informations variables
    mov ebx,sZone1
    mov eax,[ebx+FBVARSCinfo.xres]       ; largeur écran
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push szMessInfoVar
    call insererChaine
    cmp eax,0
    je .A99
    mov edx,eax
    mov eax,[ebx+FBVARSCinfo.yres]       ; hauteur écran
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edx
    call insererChaine
    cmp eax,0
    je .A99
    mov edx,eax
    mov eax,[ebx+FBVARSCinfo.bits_per_pixel] ; bits par pixel
    push eax
    push sZoneConv
    call conversion10
    push sZoneConv
    push edx
    call insererChaine
    cmp eax,0
    je .A99
    push eax
    call afficherMess

    mov eax,CLOSE                        ; fermeture du framebuffer
    mov ebx,[dFDFichier]                 ; FD
    int 0x80
    cmp eax,0
    jl .A99

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx                          ; code retour Ok du programme
    jmp .A100
.A96:
    push szMessErrAccesV
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                           ; code retour erreur du programme
    jmp .A100
.A97:
    push szMessErrAccesF
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                           ; code retour erreur du programme
    jmp .A100
.A98:
    push szMessErrOuv
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                           ; code retour erreur du programme
    jmp .A100
.A99:
    push szMessErrGen
    call afficherMess
    mov ebx,1                           ; code retour erreur du programme
.A100:
                                        ; Fin standard du programme
    mov eax,EXIT                        ; signalement de fin de programme
    int 0x80                            ; interruption : retour à Linux

    
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