; assembleur 32 bits Linux 
; programme : pgm25.asm
; utilisation du framebuffer : dessin de droites
; les routines d'affichage sont déportées dans le fichier routines.asm
; les constantes sont déportées dans le fichier constantes32.asm
; les macros sont déportées dans le fichier macros32.asm
bits 32

;************************************************************
;               Constantes 
;************************************************************
;fichier des constantes générales
%include "../constantes32.asm"

MMAP                 equ 192
UNMMAP               equ 91
; codes fonction pour la récupération des données fixes et variables
FBIOGET_FSCREENINFO  equ 0x4602
FBIOGET_VSCREENINFO  equ 0x4600
FBIOPUT_VSCREENINFO  equ 0x4601   ; code pour l'écriture des données variables.

PROT_READ            equ    0x1     ; Page can be read.
PROT_WRITE           equ    0x2     ; Page can be written.
PROT_EXEC            equ    0x4     ; Page can be executed.
PROT_NONE            equ    0x0     ; Page can not be accessed.

MAP_SHARED           equ   0x01     ; Share changes.
MAP_PRIVATE          equ   0x02     ; Changes are private.


;************************************************************
;               Macros
;************************************************************
;fichier des macros générales
%include "../macros32.asm"

;************************************************************
;               Structures
;************************************************************

; structure informations fixes Framebuffer
; voir explication détaillée : https://www.kernel.org/doc/Documentation/fb/api.txt
struc  FBFIXSCinfo
.id:              resb 16        ; identification string
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
; structure informations variables Framebuffer
struc     FBVARSCinfo
.xres:                resd 1     ; visible resolution
.yres:                resd 1
.xres_virtual:        resd 1     ; virtual resolution
.yres_virtual:        resd 1
.xoffset:             resd 1     ; offset from virtual to visible resolution
.yoffset:             resd 1
.bits_per_pixel:      resd 1     ; bits par pixel
.grayscale:           resd 1     ; 0 = color, 1 = grayscale,  >1 = FOURCC
.red:                 resd 1     ; bitfield in fb mem if true color,
.green:               resd 1     ; else only length is significant
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
struc FRAMEBUFFER
.FD:                resd 1             ; FD framebuffer
.adresseInfoFixe:   resd 1
.adresseInfoVar:    resd 1
.adresseMap:        resd 1
.fin:
endstruc
;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
szMessDebPgm:     db "Début du programme.",10,0
szMessFinPgm:     db "Fin normale du programme.",10,0
szMessErrGen:     db "Erreur rencontrée. Fin anormale.",10,0
szMessErrOuv:     db "Erreur ouverture du fichier.",10,0
szMessErrAccesF:  db "Erreur acces données fixes.",10,0
szMessErrAccesV:  db "Erreur acces données variables.",10,0
szMessErrMmap:    db "Erreur mapping mémoire.",10,0 
szMessInfoFixe:   db "Adresse = @ taille = @",10,0 
szMessInfoVar:    db "Largeur = @ hauteur = @ bits par pixel = @",10,0 
szRetourLigne:    db 10,0

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZoneConv:          resb 24
sZone1:             resb 200
dFDFichier:         resd 1
align 4
stFramebuffer:      resb FRAMEBUFFER.fin
stInfosFixe:        resb FBFIXSCinfo.fin
stInfosVar:         resb FBVARSCinfo.fin
sZoneControle:      resb 200
;************************************************************
; Code segment 
;************************************************************
section .text
;extern conversion10
global  main                          ; déclaration de main en global
main:                                 ; INFO:main
    mov ebp,esp
    push szMessDebPgm
    call afficherMess
    ;mov eax,FRAMEBUFFER.fin
    ;mov ebx,FBVARSCinfo.fin
    mov ecx,stFramebuffer             ; préparation structure données 
    mov dword[ecx+FRAMEBUFFER.adresseInfoFixe],stInfosFixe
    mov dword[ecx+FRAMEBUFFER.adresseInfoVar],stInfosVar
    push stFramebuffer                ; paramètre = adresse de la structure
    call initFrameBuffer              ; initialisation
    jc .A99                           ; erreur ?
  
    push stFramebuffer                ; effacement écran
    call effacerEcran

    push stFramebuffer                ; traçage droite horizontale
    push 50                           ; X début
    push 200                          ; X fin
    push 200                          ; en Y
    push 0x00FF0000                   ; couleur rouge
    call tracerDroiteH
    
    push stFramebuffer                ; traçage droite verticale
    push 200                          ; Y debut
    push 500                          ; Y fin
    push 200                          ; position X
    push 0x0000FF00                   ; couleur vert
    call tracerDroiteV
    
    push stFramebuffer                ; traçage droite 
    push 200                          ; X debut
    push 200                          ; Y debut
    push 400                          ; X fin
    push 350                          ; Y fin
    push 0x000000FF                   ; couleur bleu
    call tracerDroite 
    
    push stFramebuffer                ; traçage droite 
    push 200                          ; X debut
    push 200                          ; Y debut
    push 300                          ; X fin
    push 50                           ; Y fin
    push 0x0000FFFF                   ; couleur bleu pale
    call tracerDroite 
    
    mov ecx,stFramebuffer         
    mov ebx,[ecx+FRAMEBUFFER.adresseMap]       ; adresse zone mapping
    mov ecx,[ecx+FRAMEBUFFER.adresseInfoFixe]
    mov ecx,[ecx+FBFIXSCinfo.smem_len]         ; longueur zone
    mov eax,UNMMAP                             ; desallocation zone mapping
    int 0x80
    cmp eax,0
    jl .A99
    
    mov ecx,stFramebuffer
    mov ebx,[ecx+FRAMEBUFFER.FD]         ;FD 
    mov eax,CLOSE                        ; fermeture du framebuffer
    int 0x80
    cmp eax,0
    jl .A99

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme
    jmp .A100

.A99:
    push szMessErrGen
    call afficherMess
    mov ebx,1                 ; code retour erreur du programme
.A100:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
;************************************************************
;     Ouverture framebuffer et mapping mémoire
;************************************************************
; paramètre1  : adresse de la structure de données
initFrameBuffer:                     ; INFO: initFrameBuffer
    enter 0,0
    pusha                            ; sauvegarde des registres
    mov eax,OPEN                     ; ouverture du framebuffer
    mov ebx,szNomFB                  ; nom du framebuffer
    mov ecx,O_RDWR                   ; flag
    mov edx,0                        ; mode
    int 0x80
    cmp eax,0                        ; erreur ?
    jle .A98
    mov edi,[ebp+8]                  ; récuperation adresse structure
    mov [edi+FRAMEBUFFER.FD],eax     ; stockage du File Descriptor FD
    mov ebx,eax
    mov eax,IOCTL                    ; lecture des infos fixes
    mov ecx,FBIOGET_FSCREENINFO
    mov edx,[edi+FRAMEBUFFER.adresseInfoFixe]
    int 0x80
    cmp eax,0                        ; erreur ?
    jl .A97
                                     ; lecture des infos variables
    mov eax,IOCTL
    mov ebx,[edi+FRAMEBUFFER.FD]     ; recup du File Descriptor FD
    mov ecx,FBIOGET_VSCREENINFO
    mov edx,[edi+FRAMEBUFFER.adresseInfoVar]
    int 0x80
    cmp eax,0                        ; erreur ?
    jl .A96

    mov eax,MMAP                     ; appel système mapping mémoire
    mov ebx,0
    mov ecx,[edi+FRAMEBUFFER.adresseInfoFixe]
    mov ecx,[ecx+FBFIXSCinfo.smem_len]
    mov edx,dFlagsMmap
    mov esi,MAP_SHARED
    mov edi,[edi+FRAMEBUFFER.FD]     ; recup du File Descriptor FD
    push ebp                         ; save ebp avant utilisation
    mov ebp, 0                       ; dernier paramétre = offset
    int 0x80
    pop ebp                          ; restaur ebp
    cmp eax,0                        ; erreur ?
    jg .A1
    cmp eax,-128                     ; car code erreur > -128 
    jg .A95
.A1:
    afficherRegs "Fin init :"   ;
    mov edi,[ebp+8]                ; récuperation adresse structure
    mov [edi+FRAMEBUFFER.adresseMap],eax
    clc                       ; ok carry à zéro
    jmp .A100
.A95:
    push szMessErrMmap
    call afficherMess
    push eax
    call afficherReg10S
    stc                      ; erreur carry à un 
    jmp .A100
.A96:
    push szMessErrAccesV
    call afficherMess
    push eax
    call afficherReg10S
    stc                      ; erreur carry à un 
    jmp .A100
.A97:
    push szMessErrAccesF
    call afficherMess
    push eax
    call afficherReg10S
    stc                      ; erreur carry à un 
    jmp .A100
.A98:
    push szMessErrOuv
    call afficherMess
    push eax
    call afficherReg10S
    stc                      ; erreur carry à un 
    jmp .A100
.A99:
    push szMessErrGen
    call afficherMess
    stc                      ; erreur carry à un 
.A100:
    popa                     ; restaur des registres
    leave
    ret 4                    ; 1 paramètre
dFlagsMmap:      dd PROT_READ|PROT_WRITE
szNomFB:         db "/dev/fb0",0
;************************************************************
;     Effacement écran
;************************************************************
; paramètre1  : adresse de la structure de données
effacerEcran:                ; INFO: effacerEcran
    enter 0,0
    pusha                    ;sauvegarde des registres
    mov ebx,[ebp+8]          ; récuperation structure
    mov edi,[ebx+FRAMEBUFFER.adresseInfoFixe] ; récup adresse infos fixes
    mov ecx,[edi+FBFIXSCinfo.smem_len]   ; récup taille mémoire écran
    ;shr ecx,2
    sub ecx,4                            ; commence à zéro
    mov esi,[ebx+FRAMEBUFFER.adresseMap] ; adresse mémoire écran
    ;afficherRegs "effacer"
    mov ebx,0
.A1:
    mov dword [esi+ebx],0xFFFFFFFF       ; code rgb noir
    ;afficherRegs "en cours effacer"
    add ebx,4                            ; pixel précédent
    cmp ebx,ecx
    jle .A1                              ; et boucle
    ;afficherRegs "fin effacer"
.A100:
    popa                                 ; restaur des registres
    leave
    ret 4                                ; 1 paramètre
;************************************************************
;     affichage d'une droite horizontale
;************************************************************
; paramètre1  : adresse de la structure de données
; paramètre2  : position X début
; paramètre3  : position X fin
; parametre4  : position Y
; parametre5  : couleur RGB
; ATTENTION : il n'est pas vérifié que X fin est > à X début
tracerDroiteH:              ; INFO: tracerDroiteH
    enter 0,0
    pusha                   ;sauvegarde des registres
    mov ebx,[ebp+24]        ; récuperation structure
    mov ecx,[ebp+20]        ; récupération position X
    mov edx,[ebp+16]        ; position Y
    ;afficherRegs "Droite H"
.A1:                        ; boucle d'affichage des pixels de la droite
    push ebx                ; adresse structure
    push ecx                ; position X
    push dword[ebp+12]      ; position Y
    push dword[ebp+8]       ; couleur
    call afficherPixel
    inc ecx                 ; pixel suivant
    cmp ecx,edx             ; fin ?
    jle .A1
.A100:
    popa                    ; restaur des registres
    leave
    ret 20                  ; 5 paramètres
;************************************************************
;     affichage d'une droite verticale
;************************************************************
; paramètre1  : adresse de la structure de données
; paramètre2  : position Y début
; paramètre3  : position Y fin
; parametre4  : position X
; parametre5  : couleur RGB
; ATTENTION : il n'est pas vérifié que Y fin est > à Y début
tracerDroiteV:              ; INFO: tracerDroiteH
    enter 0,0
    pusha                   ;sauvegarde des registres
    mov ebx,[ebp+24]        ; récuperation structure
    mov ecx,[ebp+20]        ; récupération position Y debut
    mov edx,[ebp+16]        ; position Y fin
    ;afficherRegs "DroiteV"
.A1:                        ; boucle d'affichage des pixels de la droite
    push ebx                ; adresse structure
    push dword[ebp+12]      ; position X
    push ecx                ; position Y
    push dword[ebp+8]       ; couleur
    call afficherPixel
    inc ecx                 ; pixel suivant
    cmp ecx,edx             ; fin ?
    jle .A1
.A100:
    popa                    ; restaur des registres
    leave
    ret 20                  ; 5 paramètres
    
;************************************************************
;     affichage d'une droite quelconque
;************************************************************
; algorithme trouvé sur le site http://betteros.org  mais ce site 
; ne semble plus fonctionner en 2020.
; sinon voir celui de bresenham sur wikipédia
; paramètre1  : adresse de la structure de données
; paramètre2  : position X début
; paramètre3  : position Y début
; parametre4  : position X fin
; paramètre5  : position Y fin
; parametre6  : couleur RGB
tracerDroite:              ; INFO: tracerDroite
    enter 16,0
%define indiceX [ebp-4]
%define ecartX  [ebp-8]
%define indiceY [ebp-12]
%define ecartY  [ebp-16]
    pusha                   ;sauvegarde des registres
    mov edi,[ebp+28]        ; récuperation structure
    mov ecx,[ebp+24]        ; récupération position X début
    mov edx,[ebp+16]        ; récupération position X fin  
   ; mov esi,[ebp+8]
    cmp ecx,edx             ; comparaison des X
    jg .A1
    mov eax,edx
    sub eax,ecx             ; calcul ecart X si debut < fin 
    mov ecartX,eax
    mov dword indiceX,1
    jmp .A2
.A1:                        ; calcul écart X si fin > debut
    mov eax,ecx
    sub eax,edx
    mov ecartX,eax
    mov dword indiceX,-1
.A2:                         
    mov ecx,[ebp+20]        ; récupération position Y début
    mov edx,[ebp+12]        ; récupération position Y fin  
    cmp ecx,edx             ; comparaison des Y
    jg .A3
    mov eax,edx             ; calcul ecart Y si debut < fin 
    sub eax,ecx
    mov ecartY,eax
    mov dword indiceY,1
    jmp .A4
.A3:                        ; calcul écart Y si fin > debut
    mov eax,ecx
    sub eax,edx
    mov ecartY,eax
    mov dword indiceY,-1
.A4:               
    mov eax,[ebp+24]        ; position X départ
    mov ebx,[ebp+20]        ; position Y départ
    mov edx,ecartX          ; comparaison des variations 
    cmp edx,ecartY
    jl .A10
    xor ecx,ecx             ; init compteur
    mov esi,ecartY          ; ecart des Y
    shr esi,1               ; diviser par 2
.A5:                        ; boucle  ecx = compteur edx = maxi
    add esi,ecartY
    cmp esi,edx
    jle .A6
    sub esi,edx
    add ebx,indiceY
.A6:
    add eax,indiceX
                            ; afficher pixel
    push edi                ; adresse structure données
    push eax                ; Position X
    push ebx                ; Position Y
    push dword[ebp+8]       ; couleur
    call afficherPixel
    inc ecx
    cmp ecx,edx             ; fin ?
    jl .A5                  ; et boucle
    jmp .A100
.A10:              ;variation Y > variation X      
    xor ecx,ecx       ; init compteur
    mov edx,ecartY
    mov esi,ecartX
    shr esi,1
.A11: 
    add esi,ecartX
    cmp esi,edx
    jle .A12
    sub esi,edx
    add eax,indiceX
.A12:
    add ebx,indiceY
               ; afficher pixel
    push edi    ; adresse structure données
    push eax    ; Position X
    push ebx    ; Position Y
    push dword[ebp+8]    ; couleur
    call afficherPixel
    inc ecx
    cmp ecx,edx
    jl .A11       ; TODO: a adapter

.A100:
    popa                    ; restaur des registres
    leave
    ret 24                  ; 6 paramètres 
;************************************************************
;     Affichage d'un pixel à l'écran
;************************************************************
; paramètre1  : adresse de la structure de données
; parametre2  : position X
; parametre3  : position Y
; parametre4  ; couleur du pixel code RGB xxRRVVBB
; ATTENTION : à adapter si le nombre de bits par pixel n'est pas 32
afficherPixel:             ; INFO: afficherPixel
    enter 0,0
    pusha                  ;sauvegarde des registres
    mov ebx,[ebp+20]          ; récuperation structure
    mov edi,[ebx+FRAMEBUFFER.adresseMap]
    mov esi,[ebx+FRAMEBUFFER.adresseInfoVar]
    mov ecx,[esi+FBVARSCinfo.xres]
    mov eax,[ebp+12]       ; position y
    mul ecx                ; * largeur écran
    add eax,[ebp+16]       ; + position X
    shl eax,2              ; * 4 car 4 octets par pixel
    mov edx,[ebp+8]        ; recup couleur rgb
    mov [edi+eax],edx      ; et stockage à l'adresse mémoire écran calculée
.A100:
    popa                   ; restaur des registres
    leave
    ret 16                 ; 4 paramètres
    
