; assembleur 32 bits Linux 
; programme : squel_1.asm
; informations d'un fichier. Utilisation du tas
; les routines d'affichage sont déportées dans le fichier routines.asm
; les constantes sont déportées dans le fichier constantes32.asm
; les macros sont déportées dans le fichier macros32.asm
bits 32

;************************************************************
;               Constantes 
;************************************************************
;fichier des constantes générales
%include "../constantes32.asm"
OPEN    equ 5
CLOSE   equ 6
BRK     equ 45
FSTAT   equ 108

;  fichier
O_RDONLY  equ 0          ; lecture seule
O_WRONLY  equ 0x0001     ; écriture seule
O_RDWR    equ 0x0002     ; lecture-écriture
 
;************************************************************
;               Macros
;************************************************************
;fichier des macros générales
%include "../macros32.asm"

;************************************************************
;               Structures
;************************************************************

; structure de type   stat  : infos fichier
struc  Stat
   .dev_t:     resd 1        ; ID of device containing file
   .ino_t:     resw 1        ; inode
   .mode_t:    resw 1        ; File type and mode
   .nlink_t:   resw 1        ; Number of hard links
   .uid_t:     resw 1        ; User ID of owner
   .gid_t:     resw 1        ; Group ID of owner  
   .rdev_t:    resw 1        ; Device ID (if special file)
   .size_deb:  resd 1        ; la taille est sur 8 octets si gros fichiers
   .size_t:    resd 1        ; Total size, in bytes  
   .blksize_t: resd 1        ; Block size for filesystem I/O 
   .blkcnt_t:  resd 1        ; Number of 512B blocks allocated  
   .atime:     resq 1        ; date et heure fichier   
   .mtime:     resq 1        ; date et heure modif fichier
   .ctime:     resq 1        ; date et heure creation fichier   
   .Fin:       resb 0
endstruc 

;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
szMessDebPgm:    db "Début du programme.",10,0
szMessFinPgm:    db "Fin normale du programme.",10,0
szMessErrOuv:    db "Erreur ouverture du fichier.",10,0
szMessErrFerm:   db "Erreur fermeture du fichier.",10,0
szMessErrStats:  db "Erreur d'accès aux statistiques.",10,0
szMessErrBRK:    db "Erreur acces au tas.",10,0
szMessErrAlloc:  db "Erreur d'allocation.",10,0
szRetourLigne:   db 10,0
;szFin:           db "fin",10,0
szNomFic:        db "testSt1.txt",0

;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
;sZone1:             resd 1
dFDFichier:         resd 1         ; FD du fichier
dAdrsBuffer:        resd 1         ; adresse du buffer de lecture
stStats:            resb Stat.Fin  ; zone de réception des informations Fichier
;************************************************************
; Code segment 
;************************************************************
section .text
global  main                          ; déclaration de main en global
main:
    mov ebp,esp
    push szMessDebPgm
    call afficherMess
	
	mov eax,OPEN                      ; ouverture du fichier
    mov ebx,szNomFic                  ; nom du fichier
    mov ecx,O_RDWR                    ; flag
    mov edx,0                         ; mode
    int 0x80
    cmp eax,0                         ; erreur ?
    jle erreur
    mov [dFDFichier],eax              ; stockage du File Descriptor FD
	
	mov ebx,eax                       ; FD du fichier
	mov eax,FSTAT                     ; statistiques fichier
    mov ecx,stStats                   ; structure de reception des stats
    int 0x80
    cmp eax,0                         ; erreur ?
    jl erreurStats
	
    push stStats
    push 4
    call afficherMemoire
    mov esi,stStats
	mov eax,[esi+Stat.size_t]
    afficherRegs "Verif taille :"     ; macro
	
	mov eax,BRK                       ; 1er appel pour récupèrer l'adresse du tas
	mov ebx,0                         ; avec zéro
	int 0x80
    cmp eax,0                         ; erreur ?
    jle erreurBRK
	afficherRegs "Adresse du tas :"   ; macro
	mov [dAdrsBuffer],eax             ; save adresse début du tas
	mov ebx,eax
	add ebx,[esi+Stat.size_t]         ; ajout taille du fichier
    mov eax,BRK                       ; 2ième appel pour réserver la place
    int 0x80
    cmp eax,0                         ; erreur ?
    jle erreurAlloc
	afficherRegs "Nouvelle adresse du tas :"   ;  macro
	
	push dword [esi+Stat.size_t]         ; taille du fichier
	push dword [dFDFichier]              ; FD
    push dword [dAdrsBuffer]             ; adresse zone receptrice sur le tas
    call lireFichier                     ; lecture
    cmp eax,0                            ; erreur ?
    jl  close
    push dword[dAdrsBuffer]              ; affichage du buffer
    push 4
    call afficherMemoire
	
close:
    mov eax,CLOSE                        ; fermeture du fichier
    mov ebx,[dFDFichier]                 ; FD
    int 0x80
    cmp eax,0
    jl erreurFerm

    push szMessFinPgm
    call afficherMess
    xor ebx,ebx                          ; code retour Ok du programme
	jmp fin
erreurAlloc:                             ; affichage message d'erreur
    push szMessErrAlloc
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                            ; code retour erreur du programme
    jmp fin
erreurBRK:                               ; affichage message d'erreur
    push szMessErrBRK
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                            ; code retour erreur du programme
    jmp fin
erreurStats:                             ; affichage message d'erreur
    push szMessErrStats
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                            ; code retour erreur du programme
    jmp fin
erreur:                                  ; affichage message d'erreur
    push szMessErrOuv
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                            ; code retour erreur du programme
    jmp fin
erreurFerm:                              ; affichage message d'erreur
    push szMessErrFerm
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                            ; code retour erreur du programme	

fin:
                                         ; Fin standard du programme
    mov eax,EXIT                         ; signalement de fin de programme
    int 0x80                             ; interruption : retour à Linux
;************************************************************
;     lecture d'un fichier
;************************************************************
; paramètre1  : File Descriptor du fichier
; paramètre2  : adresse de la zone receptrice
; parametre3  : longueur de la zone receptrice
lireFichier:
    enter 0,0
    push ebx                  ;sauvegarde des registres
    push ecx
    push edx
    pushf
    mov eax,READ
    mov ebx,[ebp+12]          ; récuperation FD
    mov ecx,[ebp+8]           ; récuperation adresse zone réceptrice
    mov edx,[ebp+16]          ; longueur
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
