; Fichier des constantes pour assembleur X86 32 bits Linux
;************************************************************
;               Constantes 
;************************************************************
STDIN  equ 0
STDOUT equ 1
EXIT   equ 1
READ   equ 3
WRITE  equ 4 


;************************************************************
;               Déclaration externe des fonctions appelées
;************************************************************

extern afficherMess,afficherBinaire,afficherReg10S,afficherReg,conversion16
extern afficherReg16,afficherMemoire,conversion10S,afficherPiles,afficherFlags
extern afficherSegments,afficherRegistres