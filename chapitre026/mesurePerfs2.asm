; assembleur 32 bits Linux 
; programme : mesurePerfs2.asm
; mesure performance avec regroupement des compteurs
; ATTENTION : dans cette version le regroupement ne fonctionne pas
; sur mon ordinateur : pb paramètrage ?
; les routines d'affichage sont déportées dans le fichier routines.asm
; les constantes sont déportées dans le fichier constantes32.asm
; les macros sont déportées dans le fichier macros32.asm
bits 32

;************************************************************
;               Constantes 
;************************************************************
;fichier des constantes générales
%include "../constantes32.asm"

PERF_EVENT_IOC_ENABLE  equ 0x2400      ; codes commande ioctl
PERF_EVENT_IOC_DISABLE equ 0x2401
PERF_EVENT_IOC_RESET   equ 0x2403

PERF_IOC_FLAG_GROUP    equ 1

PERF_TYPE_HARDWARE     equ 0
PERF_TYPE_SOFTWARE     equ 1
PERF_TYPE_TRACEPOINT   equ 2
PERF_TYPE_HW_CACHE     equ 3
PERF_TYPE_RAW          equ 4
PERF_TYPE_BREAKPOINT   equ 5

PERF_COUNT_HW_CPU_CYCLES              equ  0
PERF_COUNT_HW_INSTRUCTIONS            equ  1
PERF_COUNT_HW_CACHE_REFERENCES        equ  2
PERF_COUNT_HW_CACHE_MISSES            equ  3
PERF_COUNT_HW_BRANCH_INSTRUCTIONS     equ  4
PERF_COUNT_HW_BRANCH_MISSES           equ  5
PERF_COUNT_HW_BUS_CYCLES              equ  6
PERF_COUNT_HW_STALLED_CYCLES_FRONTEND equ  7
PERF_COUNT_HW_STALLED_CYCLES_BACKEND  equ  8
PERF_COUNT_HW_REF_CPU_CYCLES          equ  9

PERF_COUNT_SW_CPU_CLOCK               equ  0
PERF_COUNT_SW_TASK_CLOCK              equ  1
PERF_COUNT_SW_PAGE_FAULTS             equ  2
PERF_COUNT_SW_CONTEXT_SWITCHES        equ  3
PERF_COUNT_SW_CPU_MIGRATIONS          equ  4
PERF_COUNT_SW_PAGE_FAULTS_MIN         equ  5
PERF_COUNT_SW_PAGE_FAULTS_MAJ         equ  6
PERF_COUNT_SW_ALIGNMENT_FAULTS        equ  7
PERF_COUNT_SW_EMULATION_FAULTS        equ  8
PERF_COUNT_SW_DUMMY                   equ  9
PERF_COUNT_SW_BPF_OUTPUT              equ  10

PERF_FLAG_FD_NO_GROUP  equ    1 << 0
PERF_FLAG_FD_OUTPUT    equ    1 << 1
PERF_FLAG_PID_CGROUP   equ    1 << 2 ; pid=cgroup id, per-cpu mode only
PERF_FLAG_FD_CLOEXEC   equ    1 << 3  ; O_CLOEXEC 

PERF_FORMAT_TOTAL_TIME_ENABLED equ    1 << 0
PERF_FORMAT_TOTAL_TIME_RUNNING equ    1 << 1
PERF_FORMAT_ID                 equ    1 << 2
PERF_FORMAT_GROUP              equ    1 << 3
;************************************************************
;               Macros
;************************************************************
;fichier des macros générales
%include "../macros32.asm"

;*******************************************/
; structure de type perf_event_attr        */
;*******************************************/
struc   PerfEvent
.type:           resd 1                ; type
.size:           resd 1                ; taille
.config:         resq 1                ; configuration
.sample_period:  resq 1                ; ou sample_freq
.sample_type:    resq 1                ; type
.read_format:    resq 1                ; read format 
.param:          resq 1                ;  32 premiers bits voir la documentation
                                       ; bit disabled inherit pinned exclusive 
                                       ; exclude_user exclude_kernel exclude_hv exclude_idle etc 
.suite:          resb 100              ; voir documentation 
.fin:
endstruc
;************************************************************
; Variables initialisees segment 
;************************************************************
section .data
szMessDebPgm:    db "Début du programme.",10,0
szMessFinPgm:    db "Fin normale du programme.",10,0
szMessErrStats:  db "Erreur d'accès aux statistiques.",10,0
szRetourLigne:   db 10,0
szMessResult:    db "instructions: @ Cycles: @ temps en µs: @ temps1: @ ",10,0


;************************************************************
; Variables non initialisees segment 
;************************************************************
section .bss
sZoneConv:          resb 24
dFDLeader:          resd 1
stPerfLeader:       resb PerfEvent.fin
stPerfFils1:        resb PerfEvent.fin
stPerfFils2:        resb PerfEvent.fin
sCompteurs:         resb 100
;************************************************************
; Code segment 
;************************************************************
section .text
global  main
main:
    mov ebp,esp
    push szMessDebPgm
    call afficherMess
                                    ; préparation du leader
    mov edi,stPerfLeader            ; adresse structure
    mov dword[edi+PerfEvent.type],PERF_TYPE_HARDWARE
    mov dword[edi+PerfEvent.size],112   ; taille de la structure
    ;mov byte[edi+PerfEvent.param],0b11100111   ;Ok
    mov byte[edi+PerfEvent.param],0b11100111
    ;mov dword[edi+PerfEvent.param+4],0 
    mov dword[edi+PerfEvent.config],PERF_COUNT_HW_INSTRUCTIONS
    ;mov dword[edi+PerfEvent.config],PERF_COUNT_HW_CPU_CYCLES
    mov dword[edi+PerfEvent.read_format],PERF_FORMAT_GROUP|PERF_FORMAT_TOTAL_TIME_RUNNING
    push stPerfLeader
    push 5
    call afficherMemoire
    
    mov eax,336
    mov ebx,edi       ; adresse structure
    mov ecx,0         ; pid
    mov edx,-1        ; cpu 
    mov esi,-1
    mov edi,0
    int 0x80
    cmp eax,0
    jle erreurStats
    mov [dFDLeader],eax         ; save FD
    ;jmp suite
                                           ; préparation du fils 1
    mov edi,stPerfFils1
    ;mov edi,stPerfLeader
    mov dword[edi+PerfEvent.type],PERF_TYPE_HARDWARE
    mov dword[edi+PerfEvent.size],112
    mov byte[edi+PerfEvent.param],0b00000011  ; TODO: à revoir car <> du leader 
    ;mov dword[edi+PerfEvent.param+4],0 
    ;mov dword[edi+PerfEvent.config],PERF_COUNT_HW_CPU_CYCLES
    mov dword[edi+PerfEvent.config],PERF_COUNT_HW_INSTRUCTIONS
    mov dword[edi+PerfEvent.read_format],PERF_FORMAT_GROUP
    ;mov dword[edi+PerfEvent.read_format],PERF_FORMAT_GROUP|PERF_FORMAT_TOTAL_TIME_ENABLED
  
    mov eax,336
    mov ebx,edi               ; adresse structure
    mov ecx,0                 ; pid
    mov edx,-1                ; cpu 
    mov esi,[dFDLeader]
    mov edi,0
    ;mov edi,PERF_FLAG_FD_OUTPUT
    afficherRegs "fils1"
    int 0x80
    cmp eax,0
    jle erreurStats
    afficherRegs "fils1_1"
    ;jmp suite
    
                              ; préparation fils 2
    mov edi,stPerfFils2
    mov dword[edi+PerfEvent.type],PERF_TYPE_SOFTWARE
    mov dword[edi+PerfEvent.size],112
    mov byte[edi+PerfEvent.param],0b00000011  ; TODO: à revoir car <> du leader 
    mov dword[edi+PerfEvent.param+4],0 
    mov dword[edi+PerfEvent.config],PERF_COUNT_SW_CPU_CLOCK 
    mov dword[edi+PerfEvent.read_format],PERF_FORMAT_GROUP
    mov eax,336
    mov ebx,edi               ; adresse structure
    mov ecx,0                 ; pid
    mov edx,-1                ; cpu 
    mov esi,[dFDLeader]
    mov edi,0
    int 0x80
    cmp eax,0
    jle erreurStats
    
suite:
                              ; lancement des mesures
    mov eax,IOCTL             ; code appel systeme
    mov ebx,[dFDLeader]       ; recup du File Descriptor FD
    mov ecx,PERF_EVENT_IOC_RESET   ; code 
    ;mov edx,PERF_IOC_FLAG_GROUP     ; reset de tout le groupe
    mov edx,0
    int 0x80
    cmp eax,0                 ; erreur ?
    jl erreurStats
;suite:
    mov eax,IOCTL             ; code appel systeme
    mov ebx,[dFDLeader]       ; recup du File Descriptor FD
    mov ecx,PERF_EVENT_IOC_ENABLE   ; code 
    mov edx,2
    int 0x80
    cmp eax,0                 ; erreur ?
    jl erreurStats
suite1:
    ; ========================; début des instructions à mesurer
    mov ecx,10
.A1:
    mov eax,[dFDLeader]
    loop .A1
    ;=========================; fin des mesures
    mov eax,IOCTL             ; code appel systeme
    mov ebx,[dFDLeader]       ; recup du File Descriptor FD
    mov ecx,PERF_EVENT_IOC_DISABLE        ; code 
    ;mov edx,PERF_IOC_FLAG_GROUP    ; arrêt de tout le groupe
    mov edx,0
    int 0x80
    cmp eax,0                 ; erreur ?
    jl erreurStats
                              ;lecture des compteurs
    mov eax,READ              ; code appel systeme
    mov ebx,[dFDLeader]       ; recup du File Descriptor FD
    mov ecx,sCompteurs        ; adresse zone compteurs
    mov edx,48                ; taille zone compteurs
    int 0x80
    cmp eax,0                 ; erreur ?
    jl erreurStats
    
    push sCompteurs
    push 4
    call afficherMemoire
    
    afficherRegs "compteurs"
    
    mov esi,sCompteurs        ; adresse zone compteurs
    push dword[esi+16]        ; récup nombre d'instructions
    push sZoneConv            ; conversion décimale
    call conversion10
    push sZoneConv
    push szMessResult         ; et insertion dans message
    call insererChaine
    cmp eax,0
    je erreurStats
    mov edi,eax
    push dword[esi+24]
    push sZoneConv            ; conversion décimale
    call conversion10
    push sZoneConv
    push edi                  ; et insertion dans message précédent
    call insererChaine
    cmp eax,0
    je erreurStats
    mov edi,eax
    push dword[esi+8]         ; récupération du temps Leader
    push sZoneConv            ; conversion décimale
    call conversion10
    push sZoneConv
    push edi                  ; et insertion dans message précédent
    call insererChaine
    cmp eax,0
    je erreurStats
    mov edi,eax
    push dword[esi+32]        ; récupération du temps fils 2
    push sZoneConv            ; conversion décimale
    call conversion10
    push sZoneConv
    push edi                  ; et insertion dans message précédent
    call insererChaine
    cmp eax,0
    je erreurStats
    push eax
    call afficherMess
    
    push szMessFinPgm
    call afficherMess
    xor ebx,ebx              ; code retour Ok du programme
    jmp fin
    
erreurStats:                 ; affichage message d'erreur
    push szMessErrStats
    call afficherMess
    push eax
    call afficherReg10S
    mov ebx,1                ; code retour erreur du programme
    jmp fin

fin:
                             ; Fin standard du programme
    mov eax,EXIT             ; signalement de fin de programme
    int 0x80                 ; interruption : retour à Linux
