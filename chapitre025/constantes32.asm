; Fichier des constantes pour assembleur X86 32 bits Linux
;************************************************************
;               Constantes 
;************************************************************
CHARPOS  equ   '@'    ; caractère d'insertion

STDIN  equ 0
STDOUT equ 1

EXIT   equ 1            ; call system Linux
READ   equ 3
WRITE  equ 4 
OPEN     equ 5
CLOSE    equ 6
BRK      equ 45
IOCTL    equ 54

;  fichier
O_RDONLY  equ 0          ; lecture seule
O_WRONLY  equ 0x0001     ; écriture seule
O_RDWR    equ 0x0002     ; lecture-écriture

;************************************************************
;               Déclaration externe des fonctions appelées
;************************************************************

extern afficherMess,afficherBinaire,afficherReg10S,afficherReg,conversion16
extern afficherReg16,afficherMemoire,conversion10,conversion10S,afficherPiles,afficherFlags
extern afficherSegments,afficherRegistres,insererChaine