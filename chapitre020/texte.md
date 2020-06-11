Pour analyser ce qui se passe dans un programme quand nous avons une anomalie, nous avons écrit les routines d’affichage d’un registre (suivant plusieurs formats) de la mémoire, des piles et des indicateurs. Mais il nous manque encore l’affichage simultané de tous les registres pour avoir une vision complète de l’exécution d’un programme. <br>
Dans le programme pgm20.asm, nous trouvons une routine qui affiche les 8 registres d’usage général. La routine est assez simple puisqu’elle convertit  en hexa les registres tels qu’ils sont à l’entrée de la routine. Il y a seulement une petite difficulté pour les registre ebp et esp. <br>
Pour le registre ebp, comme nous utilisons l’instruction enter en début de routine, nous savons qu’elle commence par sauvegarder le contenu de  ebp tel qu(il était avant l’appel puis qu’elle met le contenu de la pile dans ebp. Donc ebp contient l’adresse où se trouve son ancien contenu.<br>
Par ailleurs, le contenu de esp se trouve à 8 octets au dessus du contenu de epb puisque la plie à décrue de 4 octets au moment du call pour sauver l’adresse de retour et a encore décrue de 4 octets lors de la sauvegarde de ebp par l’instruction enter. <br>
Nous testons la routine après avoir alimenté tous les registres sauf ebp et esp puis nous l’intégrons dans une macro pour afficher un libellé et faciliter son utilisation. En effet il suffira de saisir afficherRegs « titre »   pour avoir le contenu de tous les registres. De plus comme nous sauvons tous les registres et les indicateurs, cette macro sera neutre par rapport au reste du programme. <br>
Nous la copions donc dans notre fichier annexes routines.asm et nous en profitons pour créer un fichier des macros et des constantes (et nous y ajoutons les déclarations externes). <br>
Le petit programme pgm20_1.asm teste ces modifications.<br> 
Rappel du rôle de chaque registre :<br>
Voir la documentation Intel Volume 1 paragraphe 3.4.1 <br>
Eax : accumulateur, sert à tout et est le seul possible pour les multiplications, divisions <br>
Ebx : sert à tout et est utilisé souvent pour les accès mémoire<br>
Ecx : sert à tout, est utilisé comme compteur ou indice. Il est le seul possible pour des instructions de boucle, de déplacement de bits.<br>
Edx : sert à tout et attention il est utilisé dans la multiplication et la division.<br>
Esi : sert pour désigner une adresse source de la mémoire.<br>
Edi : sert pour désigner une adresse destination de la mémoire.<br>
Ebp : pile de base ou pointeur de cadre (frame pointeur) est utilisé dans les routines<br>
Esp : la pile. Utilisée lors des call, push, pop ,ret pour sauver les registres, et les adresses de retour. <br>
