Au chapitre précédent, nous avons vu que nous pouvons passer des paramètres à un programme en les saisissant dans la ligne de commande après le nom du programme. <br>
Dans le programme pgm15.asm, nous commençons par vérifier que la ligne de commande contient bien les 3 paramètres en nous servant de l’adresse de la pile mise dans le registre ebp. Si ce n’est pas le cas, nous affichons un message d’anomalie.<br>
Sinon nous récupérons le nom sous la forme d’une liste de caractères  à l’adresse ebp+8 (l’adresse ebp+4 contenant le nom du programme) ainsi qu’une valeur numérique.
 Le problème est que cette valeur est sous la forme d’une chaine de caractères et donc non utilisable pour des calculs. Il est nécessaire de la convertir en une valeur contenue dans un registre. C’est le but de la routine conversionAtoD. <br>
Dans cette routine, nous récupérons l’adresse de la chaine sur la pile ebp+8 puis nous commençons une boucle pour éliminer les blancs éventuels, et détecter le signe éventuel.<br>
Ensuite nous effectuons une deuxième boucle pour lire chaque caractère de la chaine, enlever 48 pour trouver sa valeur. Ensuite il suffit de multiplier le précédent résultat par 10, et d’ajouter la valeur calculée. La boucle s’arrête sur la fin de ligne (0x0A) ou la fin de la chaine (0x0). Si dépassement de capacité d’un montant maximum signé nous affichons un message d’erreur. <br>
Le résultat est retourné dans le registre eax. Attention : cette routine ne convertit que des valeurs entières et si l’utilisateur saisit un caractère qui n’est pas un chiffre, au milieu de la chaine, ce caractère est exclu et il est tenu compte des chiffres suivants. Par exemple si l’utilisateur a saisi 123abc456 le résultat dans eax sera 123456.<br>
Vous pouvez tester le programme en saisissant : pgm15 toto  -1000  par exemple. <br>
Maintenant nous allons voir comment lire les données saisies au clavier. Dans la liste des instructions, nous trouvons une instruction d’entrée in registre,N° de ports. Peut-on l’utiliser pour lire un caractères du clavier ? D’abord il nous faut trouver le port affecté au clavier grâce à la commande cat /proc/ioports qu’il faut lancer avec sudo. <br>
Un premier test de l’instruction in eax,0X0060-0060 donne l’erreur : Erreur de segmentation (core dumped)ce  qui n’est pas bon signe. <br>
Après une recherche sur Internet, il apparait qu’il faut des permissions spéciales pour accéder aux ports. Je creuserais cela plus tard. Je vais donc utiliser un appel système Linux pour lire une chaine de caractères saisie au clavier. <br>
Il existe l’appel système READ code 3 qui permet de lire dans un buffer la chaine saisie dans la console standard d’entrée (voir http://asm.sourceforge.net/syscall.html#p33). Dans le programme pgm15_1, nous ajoutons une petite routine pour utiliser cet appel en lui passant l’adresse d’une zone de lecture en section .bss szBuffer.
Dans la routine, nous alimentons le code appel READ dans eax, le code de la console d’entrée standard STDIN égal à Zéro dans ebx. Nous récupérons l’adresse de la zone de réception passée en paramètre en ebp+8 et nous la mettons dans ecx et nous mettons la longueur de la zone dans edx puis nous appelons l’interruption 0x80.<br>
La documentation nous précise que cet appel retourne le nombre de caractères saisis dans le registre eax. Donc nous laissons tel quel ce registre pour retourner sa valeur au programme appelant.<br>
Dans le programme principal, nous affichons un message d’invite à saisir un texte puis nous appelons la routine de lecture en lui passant l’adresse de la zone réceptrice. Puis nous appelons notre routine d’affichage de la mémoire pour regarder le contenu de la zone de lecture et la routine d’affichage d’un registre pour regarder le nombre de caractères saisis.
<pre>
Début du programme.
Veuillez saisir un texte :
ABCDEF
Vidage memoire adresse : 08049818
08049810 30 30 30 30 20 20 0A 00*41 42 43 44 45 46 0A 00  "0000  ??ABCDEF??"
08049820 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
Affichage décimal d'un registre : 7
</pre>
Petite surprise, la chaine saisie est transmise avec le caractère de fin de ligne x0A. Le nombre de caractère retourné compte aussi le caractère de fin de ligne.<br>
Maintenant demandons de saisir un nombre et après l’appel de la lecture appelons la routine de conversion de chaine en valeur numérique. 
<pre>Veuillez saisir un nombre :
400000
Vidage memoire adresse : 08049818
08049810 30 30 30 30 20 20 0A 00*34 30 30 30 30 30 0A 00  "0000  ??400000??"
08049820 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
Affichage décimal d'un registre : +400000
</pre>
Parfait !!  tout fonctionne normalement.<br>
Remarque : si vous saisissez des caractères accentués, ils sont stockès en mémoire sur 2 caractères et le comptage en tient compte.<br>
Il ne reste plus qu’à ajouter la routine de conversionAtoD dans le programme routines.asm pour l’utiliser dans d’autres programmes. La routine de lecture peut aussi être ajoutée à ce fichier.<br>
