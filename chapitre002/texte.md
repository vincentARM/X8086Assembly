Dans ce deuxième chapitre, nous allons écrire un programme assembleur qui affiche un message : voir dans la partie code le programme pgm2.asm. <br>
Par rapport au 1er programme vu au chapitre précédent, j'ai ajouté les sections pour définir des parties de la mémoire de notre programme; La section (ou segment) .data sert à definir dans la mémoire les données que nous allons utiliser dans ce programme. <br>
Nous définissons le label hello: et nous lui affectons la chaine de caractères "Hello world" grâce à la pseudo instruction db (pour data byte). Pour nasm, la chaine doit être encadrée par des ". Il est possible de lire et d'écrire des données dans cette section.
Ensuite nous trouvons une section .bss qui est vide et dans laquelle nous définirons dans des programmes ultèrieurs, les données qui seront initialisées à zéro par le système. Il est aussi possible de lire et d'écrire des données dans cette section.<br>
Puis nous avons les instructions qui seront stockées dans une section code qui curieusement s'appelle .text. <br>
Pour afficher un message sous forme d'une chaine de caractères, nous sommes obligés de faire appel à une fonction du système d'exploitation. En effet il est ineavisageable d'écrire en assembleur des routines capables d'écrire directement dans les multitudes d'écrans différents des ordinateurs. <br>
Nous allons donc utiliser la fonction write de Linux. En fait il s'agit plutot d'un appel système par l'utilisation de l'interruption x80 comme pour l'appel EXIT que nous avons vu au chapitre précédent. <br>
La liste des appels système linux (linux calls system) se trouve sur de nombreux sites sur internet (par exemple : https://web.archive.org/web/20051024081539/http://docs.cs.up.ac.za/programming/asm/derick_tut/syscalls.html) ou dans linux (pour ubuntu voir le fichier /usr/include/asm-generic/unistd.h.<br>
Remarque : sur internet il faut faire attention car les codes 64 bits sont différents des codes 32 bits. <br>
Sur internet, en plus du code, nous trouvons le type des données à mettre dans les differents registres pour transmettre des paramètres à Linux mais aussi des descriptions de chaque fonction. Il est aussi possible de consulter les manuels de linux avec la commande man par exemple man write.<br>
Ici, nous allons mettre le code 4 dans le registre eax pour l'appel WRITE, le code 1 dans le registre ebx pour indiquer que nous voulons écrire sur la console standard de sortie Linux (STDOUT), le label du message dans le registre ecx (donc l'adresse en mémoire de notre chaine de caractères) puis la longueur de la chaine soit 14 dans le registre edx. Nous appelons l'interruption x80 pour afficher notre chaine puis comme pour le précédent programme pour appelons la fonction EXIT pour terminer correctement le programme.<br>
Après avoir corrigé les éventuelles erreurs de saisie, l'execution du programme donne ceci : <br>
Hello world.vincent@vincent-Latitude-D610: <br>
Tout ce qui est après le / est mon invite de commande de la console Linux. Il serait donc judicieux d'effectuer un saut de ligne. Pour cela il faut inserer le caractère saut de ligne en fin de message. Pour ceux qui pratique déjà un langage de programmation ils savent qu'il s'agit du caractère décimal 10 ou x0A décimal ou aussi \n.<br>
Bien que connu de nasm, le caractère \n ne semble pas reconnu et donc ne fonctionne pas ni dans la chaine ni en dehors.
L'ajout en fin de chaine du caractère 10 fonctionne comme le montre le programme pgm2_1.asm. <br>
Hello world.
vincent@vincent-Latitude-D610: <br>

Nous pouvons aussi tester des longueurs d'affichage passées dans le registre edx. Par exemple 5, ce qui donne :
Hellovincent@vincent-Latitude-D610:~/assembleur32/projet2$ <br>
L'affichage est bien tronqué puisque l'on ne voit que hello.<br>
Et Monsieur si nous mettons une longueur plus grande que la taille de la chaine que se passe-t-il ? <br>
Restons modeste !! appelez moi simplement maitre !!   Voyons avec 20
L'affichage semble identique. Pourtant si on ajoute comme dans le programme pgm2_2 une autre chaine derrière la premiere, le programme affiche 6 caractères de la seconde. <br>
Hello world.
Bonjourvincent@vincent-Latitude-D610: <br>

Mais maitre, nous n'allons pas compter à chaque fois les caractères de chaque message que nous voulons afficher ? Non bien sûr, nous allons voir une première methode pour calculer une chaine de caractères fixe. Il suffit d'ajouter la pseudo instruction 
LGHELLO    equ $ - hello <br>
derrière l'intruction de définition de la chaine hello. Cette pseudo instruction cacule la longueur entre sa propre adresse représentée par $ et le label hello en effectuant la soustraction et affecte le résultat à la constante LGHELLO. Je la met en majuscule pour indiquer qu'il s'agit d'une constante.<br>
Puis nous remplaçons le nombre 14 de l'instruction mov edx,14 par LGHELLO comme dans le programme pgm2_3.asm.
Et cela fonctionne.<br>
Et pour un message qui peut avoir une longueur variable ? Et bien, il faut calculer sa longueur et nous allons voir comment. Mais comme l'affichage d'un message va être utilisé frequement, nous allons écrire une routine (ou un sous programme ou une procèdure) qui pourra être executée plusieurs fois.

Dans le programme pgm2_4, j'ai rajouté une partie Constantes dans laquelle j'ai défini les constantes déjà utilisées : STDOUT, EXIT et WRITE. Nasm accepte 2 façons des les définir soit avec la pseudo instruction %define soit avec equ (pour equal ou equivalent). Ces définitions indiquent que ces noms sont équivalents aux valeurs qui suivent. STDOUT aura dons la valeur 1 et le compilateur remplacera STDOUT par cette valeur.<br>
Ensuite j'ai modifié le label de la chaine hello pour l'appeler szHello, sz pour string terminée par zero. C'est une bonne façon de procéder pour savoir dans la suite du code quelle est la nature du label manipulé.<br>
J'ai ajouté une nouvelle chaine szMessFinPgm que le programme affichera à la fin de son execution. Cela permet de savoir si un programme s'est terminé correctement !!<br>
Dans le code du programme , nous mettons toujours dans le registre eax l'adresse de la chaine à afficher puis nous appelons la nouvelle routine par call afficherMess. <br>
Plus loin nous trouvons la description de cette routine. Son nom est une simple étiquette afficherMess puis nous trouvons les instructions pour calculer la longueur de la chaine dont l'adresse est contenue dans le registre eax. <br>
Comment calculer en assembleur la longueur de cette chaine. Il nous faut compter le nombre de caractères qui la composent en lisant chaque caractère jusqu'à la fin. Mais qu'est la fin d'une chaine ? Les informaticiens ont pris l'habitude de l'indiquer en mettant la valeur zéro binaire après les caractères ASCII de la chaine. C'est pourquoi la chaine "hello world" se termine par les caractères 10 (pour le retour ligne) et 0 pour indiquer la fin.<br>
Donc nous devons comparer chaque caractère avec la valeur zero. Si le caractère est different, nous devons incrementer un compteur et s'il est egal à zéro, nous arreterons le comptage et le compteur contiendra la longueur de la chaine. <br>
Comme la longueur doit être passée à la fonction système WRITE dans le registre edx, c'est ce registre qui nous servira de compteur. Nous le mettons donc à zéro en début de routine : remarque importante : il faut toujours initialiser un registre avant de l'utiliser car il peut contenir n'importe quoi !!
Ensuite il nous faut comparer chaque caractère de la chaine avec zéro. C'est le role de l'instruction cmp byte [eax,edx],0
cmp pour comparaison byte car nous nous ne voulons qu'un seul caractère ASCII dont la longueur est un octet (8 bits ou byte) et qui se trouve à l'adresse contenue dans eax et à la position donnée par le compteur edx. Notez bien que tout cela est indiqué entre les crochets. En effet il faut bien comprendre cela : cmp eax,0   compare la valeur contenue dans le registre eax avec la valeur zéro alors que cmp [eax],0 compare la valeur se trouvant en mémoire à l'adresse contenue dans le registre eax.<br>
Puis nous trouvons l'instruction je .A2 qui est une instruction de saut (jump) à l'étiquette locale .A2. Ce saut n'est effectué que si la comparaison précédente est égale à zéro et c'est le e qui signifie égal. Si on avait voulu sauter si la comparaison n'etait pas égale, nous aurions utiliser jne  (jump not equal).<br>
Si le caractère n'est pas égal à 0, il faut incrementer le compteur avec l'instruction add edx,1 qui ajoute 1 au compteur (ça c'est facile à comprendre). <br> 
Puis nous bouclons à nouveau à la comparaison du caractère suivant avec l'instruction jmp .A1 : qui est un saut inconditionnel à l'étiquette .A1. <br>
Enfin nous terminons la routine par l'appel systeme linux Write comme précedement. <br> 
Mais il y a encore une nouvelle instruction tout à fait à la fin : ret. En effet il faut dire que notre routine est terminé et que le processeur doit revenir au programme principal pour executer les instructions suivantes. C'est le rôle de cette instruction qui ne doit jamais être oubliée sinon votre programme ira executer n'importe quoi ou la routine suivante si elle existe.








