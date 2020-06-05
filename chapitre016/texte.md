Dans le programme pgm16.asm, nous allons lire le contenu d’un fichier. Ici ce sera un fichier texte qui contient quelques lignes. Vous pouvez le créer avec l’éditeur nano directement dans le répertoire où vous allez stocker votre exécutable. Le fichier s’appellera test1.txt . <br>
Dans la .data du programme, nous ajoutons une chaine de caractères qui contiendra le nom du programme soit « tst1.txt. Dans la section .bss nous ajoutons une zone qui servira à recevoir les données lues et nous lui réservons 100000 octets ,ce qui devrait être suffisant. Nous ajoutons aussi une zone de 4 octets qui contiendra le descripteur de fichier (File Descriptor). Il s’agit d’une identification qui fait le lien entre Linux et notre programme.<br>
Dans le code, nous commençons par ouvrir le fichier en utilisant l’appel système OPEN (code 5) et en lui passant comme paramètre l’adresse de la chaine contenant le nom du fichier, une constante standard LINUX indiquant que le fichier pourra être lu ou écrit (O_RDWR) et un mode qui indique la codification des droits pour le fichier qui est à zéro ici car le fichier ne sera que lu.<br>
A propos des constantes standards linux qui doivent être utilisées, nous trouvons leur noms dans la description des appels système soit sur internet soit avec la commande Man. Trouver ensuite leur valeur est une autre paire de manches !! Il est possible de trouver ces valeurs sur Internet, dans les sources Linux, ou alors dans les fichiers .h du langage C. <br>
Au retour de l’appel, il est nécessaire de tester s’il y a une anomalie (absence du fichier, problème de droits etc) et afficher un message d’erreur avec le code. En règle générale, Linux retourne un code négatif dans le registre eax ou zéro dans le cas où il devait retourner une entité. <br>
Si l’ouverture est ok, nous récupérons dans le registre eax, le File Descriptor (FD) que nous allons passer à une petite routine de lecture avec l’adresse de la zone réceptrice des données qui vont être lues.<br>
Dans la routine lireFichier, nous utilisons l’appel système READ exactement pareil que dans le chapitre précédent : seul le registre ebx est différent car il contiendra le FD du fichier à la place de la constante STDIN. Là aussi nous testons le code retour de l’appel pour afficher les erreurs éventuelles. <br>
Au retour de la routine, nous nous contentons d’afficher la zone de lecture et le contenu du registre eax et nous terminons par la fermeture du fichier à l’aide de l’appel système CLOSE et le FD comme paramètre.
L’affichage de la zone de lecture donne ceci :
<pre>
Début du programme.
Vidage memoire adresse : 08049880
08049880 6C 69 67 6E 65 31 0A 6C 69 67 6E 65 32 0A 6C 69  "ligne1?ligne2?li"
08049890 67 6E 65 33 0A 0A 00 00 00 00 00 00 00 00 00 00  "gne3????????????"
080498A0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
080498B0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
Affichage décimal d'un registre : 22
</pre>
Je retrouve bien les lignes saisies dans mon fichier. Chaque fin de ligne est indiquée par le caractère 0xA. A la fin il y a 2 caractères 0xA qui se suivent car j’ai terminé le fichier avec une ligne vide. Donc là, nous ne voyons pas très bien s’il y a un zéro final. (remarque : j'ai vérifié et il n'y a pas de zéro final!!)<br>
Le registre eax contient exactement le nombre de caractères lus, ce qui sera bien utilie quand il faudra exploiter cette lecture. <br>
Maintenant voyons l’écriture dans un fichier dans le programme pgm16_1.asm. Nous décrivons dans la section .data une zone szBuffer qui contient les lignes à écrire et terminée par 0 binaire. <br>
Dans le code, nous pouvons pour créer le fichier procéder de 2 façons : utiliser l’appel système CREAT (code 8) ou l’appel système OPEN avec une option particulière. Ici nous allons utiliser CREAT et dans le programme pgm16_2.asm nous utiliserons OPEN.<br>
L’appel système CREAT nécessite le passage en paramètre du nom du fichier et du mode qui représente les droits à attribuer au fichier. Ici nous mettons le code 664 qui autorisera la lecture et l’écriture pour l’utilisateur et son groupe et seulement la lecture pour tous les autres. Vous remarquerez que ce code est en octal (petit o placé devant les chiffres) et il m’a fallu un petit bout de temps pour le trouver (car je le mettais en hexa au début et les droits étaient vraiment bizarres).<br>
Nous vérifions si la création se passe bien et nous appelons la routine ecrireFichier qui va utiliser l’appel système WRITE exactement comme dans la routine afficherMess à part le code STDOUT remplacé par le FD du fichier. Et il nous faut calculer la longueur des données à ecrire ce que nous faisons dans une boucle avant d’appeler le WRITE.<br>
Après l’écriture, un ls –l nous permet de vérifier la bonne exécution du programme :
<pre>
-rw-rw-r--  1 vincent vincent   50 juin   4 21:25 test2.txt
</pre>
Le fichier est bien crée avec les bons droits d’accès.
Dans le programme pgm16_2.asm, nous utilisons l’appel système OPEN en lui passant comme options les codes O_CREAT O_EXCL O_WRONLY  qui forment une seule constante grâce au caractère | (OU logique). Ces constantes indiquent que le fichier doit être crée, produit une erreur s’il existe déjà, et le crée en écriture.<br>
Le reste du programme est identique au pgm16_1.asm.<br>
Si vous relancez l’exécution, une erreur code -17 se produit car le fichier existe déjà. Il faut donc le supprimer pour que l’écriture soit de nouveau OK. <br>
