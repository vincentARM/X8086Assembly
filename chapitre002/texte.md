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
Hello world.vincent@vincent-Latitude-D610:~/assembleur32/projet2$ <br>
Tout ce qui est après le / est mon invite de commande de la console Linux. Il serait donc judicieux d'effectuer un saut de ligne. Pour cela il faut inserer le caractère saut de ligne en fin de message. Pour ceux qui pratique déjà un langage de programmation ils savent qu'il s'agit du caractère décimal 10 ou x0A décimal ou aussi \n.<br>
Bien que connu de nasm, le caractère \n ne semble pas reconnu et donc ne fonctionne pas ni dans la chaine ni en dehors.
L'ajout en fin de chaine du caractère 10 fonctionne comme le montre le programme pgm2_1.asm. <br>
Hello world.
vincent@vincent-Latitude-D610:~/assembleur32/projet2$ <br>

Nous pouvons aussi tester des longueurs d'affichage passées dans le registre edx. Par exemple 5, ce qui donne :
Hellovincent@vincent-Latitude-D610:~/assembleur32/projet2$ <br>
L'affichage est bien tronqué puisque l'on ne voit que hello.<br>
Et Monsieur si nous mettons une longueur plus grande que la taille de la chaine que se passe-t-il ? <br>
Restons modeste !! appelez moi simplement maitre !!   Voyons avec 20
L'affichage semble identique. Pourtant si on ajoute comme dans le programme pgm2_2 une autre chaine derrière la premiere, le programme affiche 6 caractères de la seconde. <br>
Hello world.
Bonjourvincent@vincent-Latitude-D610:~/assembleur32/projet2$ <br>

Mais maitre, nous n'allons pas compter à chaque fois les caractères de chaque message que nous voulons afficher ? Non bien sûr, nous allons voir une première methode pour calculer une chaine de caractères fixe. Il suffit d'ajouter la pseudo instruction 
LGHELLO    equ $ - hello <br>
derrière l'intruction de définition de la chaine hello. Cette pseudo instruction cacule la longueur entre sa propre adresse représentée par $ et le label hello en effectuant la soustraction et affecte le résultat à la constante LGHELLO. Je la met en majuscule pour indiquer qu'il s'agit d'une constante.<br>
Puis nous remplaçons le nombre 14 de l'instruction mov edx,14 par LGHELLO comme dans le programme pgm2_3.asm.
Et cela fonctionne.<br>
Et pour un message qui peut avoir une longueur variable ? Et bien, il faut calculer sa longueur et nous allons voir comment. Mais comme l'affichage d'un message va être utilisé frequement, nous allons écrire une routine (ou un sous programme ou une procèdure) qui pourra être executée plusieurs fois.




