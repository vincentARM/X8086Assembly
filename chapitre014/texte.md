Il ne nous reste plus qu’à voir l’affichage des données contenues dans la pile (esp) et dans la pile de base (ebp). Pour cela dans le programme pgm14.asm, nous trouvons une nouvelle routine afficherPiles.<br>
Tout d’abord, rappelons que l’opération push est équivalente à une décrémentation de l’ adresse de contenue dans le registre de la pile esp  de 4 octets puis  un stockage en mémoire à l’adresse contenue dans le registre de la pile esp . Par exemple push eax correspond à
<pre>sub esp,4
mov [esp],eax</pre>
L’instruction pop fait l’inverse par exemple pop ebx correspond à 
<pre>mov ebx[esp]
add esp,4</pre>

La routine afficherPiles  va afficher l’adresse actuelle de la pile et de la pile de base puis va afficher les n adresses supérieures de chaque pile et le contenu de chaque adresse et elle va afficher les n/2 adresses inférieures de chaque pile.<br>
J’ai limité les adresses inférieures car il y a moins d’intérêt à consulter leur contenu. Mais vous pouvez le modifier ainsi que le nombre des adresses supérieures (voir constante NBADRAFF) <br>
Le petit problème de cette routine est de récupérer les adresses des piles telles qu’elles sont avant l’appel de la routine. En effet, nous voulons afficher les contenus tels qu'ils sont au moment de l’appel et non pas les contenus qu’ils ont dans la routine. Je vous rappelle que l’instruction call empile l’instruction de retour sur la pile donc son adresse a diminuée de 4 octets. <br>
Ensuite au début de la routine, nous avons l’instruction enter qui commence par sauvegarder la pile de base (ebp) ce qui fait encore descendre l’adresse de la pile de 4 octets. Puis elle copie l’adresse de la pile dans la pile de base donc à ce moment-là, l’adresse de la pile avant l’appel est égale à l’adresse contenue dans ebp + 8 octets. <br>
 Et comme nous avons sauvegardé l’adresse de la pile de base juste avant, l’adresse de la pile de base avant l’appel se trouve à l’adresse de la pile de base actuelle : évident non !!!!!<br>
Ensuite nous nous contentons de partir de ces adresses + le nombre d’adresses à afficher * 4 octets pour afficher adresses et contenus  avec des adresses décroissantes.<br>
Voyons un exemple, dans le programme pgm14, j’ai écrit une petite routine qui prend en entrée le paramètre  de valeur 5. Dans la routine, je me contente d’afficher cette valeur et j’appelle la routine de vidage de piles : voici le résultat :
<pre> 
Début du programme.
Affichage registre en hexa : 00000005
Routine1
Affichage piles :
    pile ESP: BF834FE4       pile EBP: BF835004
+40 BF83500C  00000005       BF83502C  BF83681B
+36 BF835008  08048096       BF835028  BF8367FA
+32 BF835004  00000000       BF835024  BF8367EA
+28 BF835000  FFFFFFFF       BF835020  BF8367DF
+24 BF834FFC  00000000       BF83501C  BF8367CE
+20 BF834FF8  00000000       BF835018  00000000
+16 BF834FF4  00000000       BF835014  BF8367C8
+12 BF834FF0  BF835004       BF835010  00000001
+8  BF834FEC  BF835004       BF83500C  00000005
+4  BF834FE8  00000000       BF835008  08048096
+0  BF834FE4  00000000       BF835004  00000000
-4  BF834FE0  080480D3       BF835000  FFFFFFFF
-8  BF834FDC  BF835004       BF834FFC  00000000
-12 BF834FD8  00000005       BF834FF8  00000000
-16 BF834FD4  00000000       BF834FF4  00000000
-20 BF834FD0  00000000       BF834FF0  BF835004
Fin normale du programme.
</pre>
Analysons les adresses de la pile esp. En début nous trouvons l’adresse courante de la pile : BF834FE4 que nous retrouvons au niveau du déplacement +0. Le contenu des adresses négatives correspond soit à des opérations push et pop précédentes soit à un appel de routine. Ici nous avons un appel à la routine afficherReg16. <br>
Donc le contenu de l'adresse -4 donne l’adresse de retour de la routine, l’adresse -8 correspond au pop ebp de l’instruction leave (et ce contenu correspond bien à l’adresse ebp) et l’adresse -12 correspond au pop eax etc.<br>
Les adresses positives de la pile correspondent aux opérations de début de la routine  donc nous trouvons l’instruction pusha de sauvegarde des registres. Donc l’adresse +0 correspond au contenu du registre edi, +4 au registre esi, +8 à ebp, +12 à esp,  + 16 à edx, + 20 à ecx, +24 à ebx, et +28 à eax (on peut vérifier que la valeur est -1 (0xFFFFFFFF) ). <br>
Ensuite nous trouvons en +32 le contenu de l’instruction push ebp (cachée à l’intérieur de l’instruction enter)  contenu qui est à zéro car à cet instant le registre ebp n’a jamais été alimenté. (ce qui semble suggérer que Linux initialise tous les registres à zéro avant d’exécuter notre programme : à vérifier).<br>
Et nous terminons avec le contenu en +36 qui est l’adresse de retour au programme principal et en +40, le contenu du paramètre passé à la routine(5).<br>
En ce qui concerne les adresses et les contenus de la pile de base ebp, nous trouvons au déplacement +0  l’adresse de la pile esp qu’elle avait après l’instruction push ebp (cachée à l’intérieur de l’instruction enter) puisque la deuxième instruction cachée à l’intérieur du enter est mov ebp,esp.<br>
Les déplacements négatifs correspondnt donc aux contenus de la pile esp que nous avons vus à partir du déplacement +28 et les déplacement positifs correspondent à tous les contenus de la pile esp avant l’appel de la routine ce qui permet comme nous l’avons déjà vu de récupérer tous les paramètres passés par des push.<br>
Ouf !! cela parait compliqué mais il faut s’y habituer pour récupérer le bon paramètre ou la bonne adresse dans des sous routines.<br>
Dans le programme pgm14_1, l’affichage des piles s’effectue directement dans le programme principal après avoir initialisé la pile de base ebp avec l’adresse de la pile esp. L’affichage des 2 piles est identique ce qui est normal. Il y a des contenus dans les déplacements négatifs, ce qui est normal aussi puisqu’il y a l’appel à la routine afficherMess juste avant et qui a laissé des traces.<br>
Mais il y a aussi des contenus dans les déplacements positifs. Il s’avère que le déplacement +0 contient le nombre de paramètres de la ligne de commande. Ici nous avons 1 car nous n’avons lancé le programme qu’avec son nom. Le déplacement +4 correspond à l’adresse contenant le nom du programme que nous pouvons afficher.<br>
Ecrivons une boucle qui à partir du nombre de paramètres, extrait chaque adresse du contenu du paramètre et la passe à la routine d’affichage. Nous utilisons l’instruction loop pour boucler car elle décrémente le registre ecx. <br>
Le programme affiche tous les paramètres saisis dans la ligne de commande (et dans l’ordre inverse) . Lancer le programme avec pgm14_1 para1 para2 para3. Vous verrez l’affichage des 4 paramètres. C’est très bien pour récupérer des paramètres dans un programme !!<br>
Ensuite dans la pile nous trouvons au déplacement +8 la valeur 0 qui normalement correspond à l’adresse de retour d’une routine. Ici comme il s’agit du programme principal cette adresse est à zéro. Ceci explique que le retour au système d’exploitation s’effectue à faisant appel à un appel système EXIT et non pas avec la simple instruction ret qui produirait une anomalie.<br>
Mais au-delà de ces déplacements il reste encore des contenus dans la pile. Un simple affichage de la première adresse trouvée montre qu’il s’agit du contenu d’une variable d’environnement. Et donc une simple boucle de récupération de ces adresses pour afficher la chaine correspondante jusqu’à trouver une adresse à zéro affiche toutes les variables d’environnement comme le USER, le nom du répertoire HOME etc. Super !! En découpant ces chaines, il est possible de récupérer des données intéressantes dans un programme assembleur.
