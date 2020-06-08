Maintenant, nous avons pratiquement vu tout ce qui nous permet de programmer de petits programmes complets. Il nous reste encore à voir des notions importantes comme les calculs en virgule flottante mais nous allons revenir sur des chapitres précédents pour apporter des précisions. <br>
En effet, en parallèle de l’écriture de ces chapitres, j’ai lu la documentation Intel et donc découvert quelques aspects qui m’avaient échappés.<br>
Tout d’abord, pour accéder à une zone mémoire, la figure 3-11 de la documentation Intel Volume 1 résume bien toute les possibilités d’adressage sous la forme :
[base+(index * type) + déplacement]  avec  des registres pour base et index, les valeurs 1, 2 ,4,8 pour le type et une valeur immédiate comme déplacement : par exemple :
<pre> mov al,[ebx+(ecx * 4)+1]</pre>
Ensuite au chapitre 13, j’avais abordé les instructions lodsd et stosd  qui permettent de lire et de stocker des entiers en mémoire en décrémentant automatiquement les registres edi et esi. Mais il est possible aussi d’utiliser ces instructions en incrémentant les registres edi et esi à l’aide d’un indicateur de direction (DF) se trouvant à la position 10 du registre eflags.<br>
Dans le programme pgm17.asm, nous allons tester cette particularité et adapter la routine d’affichage des indicateurs pour ajouter ce nouveau flag. <br>
Dans la routine nous nous contentons d’effectuer un pushf et un pop eax pour récupérer tout le contenu du registre eflag. Ensuite nous testons la position 10 en utilisant l’astuce 1<<10 qui positionne le bit 10 à 1 et nous affichons le code D pour décroissant et C si les adresses des chaines croissent.<br>
Dans le programme principal, nous vérifions quel est la valeur de l’indicateur puis nous le forçons à 1 avec l’instruction std pour tester le cas décroissant. Nous allons copier 5 caractères en partant de la position 10 de la chaine origine szChaine1 dans la zone sBuffer à partir de la position 10 mais en ordre décroissant.<br>
 J’ai découvert l’instruction movsb qui effectue la copie d’un caractère et décrémente les adresses de edi et esi et l’instruction rep qui répète l’instruction précédente tant que le registre ecx n’est pas nul.<br>
Plus besoin d’étiquettes de boucle ni d’instruction jmp pour effectuer les 5 copies. Le résultat est OK.<br>
<pre>
Affichage des indicateurs :
Zéro : 1 Signe : 0 Carry : 0 Overflow : 0 Parité : 1 Direction : D
Vidage memoire adresse : 08049A14
08049A10 20 20 0A 00*00 00 00 00 00 00 20 31 20 2A 2A 00  "  ???????? 1 **?"
08049A20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
</pre>
Remettons l’indicateur à zéro avec l’instruction cld mais cette fois ci nous allons effectuer la copie de 3 double mots  avec l’instruction movsd .
<pre>
Affichage des indicateurs :
Zéro : 0 Signe : 0 Carry : 0 Overflow : 0 Parité : 1 Direction : C
Vidage memoire adresse : 08049A14
08049A10 20 20 0A 00*01 00 00 00 02 00 00 00 78 56 34 12  "  ??????????xV4?"
08049A20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
</pre>
Là aussi tout est OK.
Ensuite j’ai vérifié que l’on pouvait effectuer des opérations arithmétiques directement avec des valeurs en mémoire par exemple échanger une valeur mémoire et une valeur registre :
<pre>
    mov eax,2
    xchg eax,[sBuffer+4]    ; echange les 2 valeurs</pre>

Pour des structures de données plus complexes que des octets, des mots ou des doubles mots, nous pouvons utiliser avec nasm un descriptif de structures. En début de programme j’ai ajouté un paragraphe structures qui décrit les structures utilisées par le programme. Ici nous avons une seule structure enreg1 définie par le mot clé struc et se terminant par le mot clé endstruc. <br>
A l’intérieur nous définissons chaque zone avec un label commençant par un point et leur longueur avec les mots clés resb resd etc. Pour vérifier un usage ultérieur, je termine avec la zone .fin qui n’a pas de longueur resb 0. Attention, cette définition ne reserve aucun octet en mémoire, elle ne sert qu’à définir des noms et des positions. <br>
Pour l’utiliser nous créons dans la .data une zone de données qui contient 5 dans un octet puis 10 dans un double mot et la chaine toto.<br>
Dans le code pour accéder à la valeur 5 avec la définition de la structure enreg1, il nous suffit de mette dans le registre esi l’adresse de la zone mémoire de la .data puis d’accéder à la première zone avec l’instruction :
<pre>
mov esi,stZone1
    mov al,[esi+enreg1.valeur1]
</pre>
Et pour l’accès à la deuxième zone  qui est un double mot 
<pre>
    mov eax,[esi+enreg1.valeur2]
    </pre>
Et nous pouvons afficher la 3ième zone 
Les définitions de structures peuvent être utilisées pour passer en paramètre plusieurs zones de nature différentes à une routine. <br><br>

Dans le programme pgm17_1.asm, nous allons voir l’ utilisation d’ un tableau de chaines de caractères.Le programme est un peu plus complexe que les routines précédentes car nous allons effectuer une boucle de saisie de chains au clavier en utilisant la routine lireClavier. Les chaines saisies sont stockèes dans une zone unique à la queue-leu-leu et chacune séparée par le 0 final. Nous conservons l’adresse du début de chaque chaine dans un pointeur qui sera stocké dans un tableau.<br>
Mais la chaine saisie sera comparée aux autres chaines déjà saisies pour que son pointeur soit inséré au bon endroit dans le tableau. Si la chaine s’avère être plus petite (plus exactement inférieure du point de vue lexical) son pointeur sera inséré avant le pointeur de la chaine lue. Et pour effectuer cette insertion, il faudra déplacer tous les pointeurs suivants d’une position vers le haut du tableau.<br>
Pour comparer 2 chaines nous sommes obligés d’écrire une petite routine qui effectue la comparaison caractère par caractère jusqu’à rencontrer un caractère différent ou le caractère 0 de fin de chaine. C’est le rôle de la routine comparerChaines. <br>
Cette routine servira aussi à comparer chaque chaine saisie avec la chaine « fin » pour arrêter la saisie. Et dans ce cas, le programme effectue une nouvelle boucle pour balayer tous les pointeurs de la table et afficher chaque chaine.<br>
Voici un résultat possible :

<pre>Début du programme.
Veuillez saisir une chaine (fin pour terminer) :
toto
Veuillez saisir une chaine (fin pour terminer) :
trucmuche
Veuillez saisir une chaine (fin pour terminer) :
poule
Veuillez saisir une chaine (fin pour terminer) :
renard
Veuillez saisir une chaine (fin pour terminer) :
xyz
Veuillez saisir une chaine (fin pour terminer) :
abc
Veuillez saisir une chaine (fin pour terminer) :
fin
Affichage des chaines :
abc
poule
renard
toto
trucmuche
xyz
Fin normale du programme.</pre>
Vous remarquerez que les chaines sont bien affichées dans l’ordre alphabétique (tant qu’il n-y a pas de caractères accentués !!).<br>
Les commentaires du programmes sont suffisants pour comprendre son fonctionnement.<br>
La mise au point de ce petit programme m’a révélé que l’affichage d’un seul registre n’est pas satisfaisant pour trouver une erreur. Nous verrons donc dans un prochain chapitre une routine pour afficher les 8 registres simultanément ce qui permettra de suivre plus facilement l’exécution.  Bon il y a aussi pour ceux qui le connaisse l’utilitaire dbg pour analyser un programme récalcitrant. <br>
