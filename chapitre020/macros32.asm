; fichier des macros pour assembleur X86 32 bits Linux
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