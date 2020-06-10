Nous avons déjà vu au chapitre 14, l’affichage des piles et l’utilisation de la pile pour le passage des arguments à des routines. Mais la pile peut aussi servir à stocker des données locales à une routine et qui ne sont donc conservées que le temps de l’exécution de la routine.
Dans le programme pgm18.asm, nous commençons par afficher les piles une première fois après avoir initialisé la pile de base avec la pile pour éviter une erreur d’affichage. Nous mettons des valeurs dans les registres pour vérifier leur endroit de sauvegarde sur la pile et nous passons en paramètre la valeur 4 à la routine1.<br>
Dans la routine1, après l’instruction leave, nous réservons une zone de 4 octets avec l’instruction sub esp,4 car les adresses de la pile vont décroissantes. Cette réservation est faite là car nous savons qu’à ce moment les adresses de esp et bsp sont égales et donc que cette nouvelle zone sera accessible par l’adresse ebp-4 . Après la sauvegarde des registres, nous récupérons le paramètre d’entrée comme déjà vu et nous effectuons un exemple de calcul pour sauvegarder le résultat dans cette nouvelle zone par l’instruction :
<pre>    mov [ebp-4],ecx           ; save</pre>
Nous affichons les piles pour examiner la situation :
<pre>
Routine1
Affichage piles :
    pile ESP: BFF3A0A0       pile EBP: BFF3A0B4
+40 BFF3A0C8  00000000       BFF3A0DC  BFF3A81B
+36 BFF3A0C4  BFF3A7C8       BFF3A0D8  BFF3A7FA
+32 BFF3A0C0  00000001       BFF3A0D4  BFF3A7EA
+28 BFF3A0BC  00000004       BFF3A0D0  BFF3A7DF
+24 BFF3A0B8  080480A7       BFF3A0CC  BFF3A7CE
+20 BFF3A0B4  BFF3A0C0       BFF3A0C8  00000000
+16 BFF3A0B0  00000009       BFF3A0C4  BFF3A7C8
+12 BFF3A0AC  00000001       BFF3A0C0  00000001
+8  BFF3A0A8  00000002       BFF3A0BC  00000004
+4  BFF3A0A4  00000003       BFF3A0B8  080480A7
+0  BFF3A0A0  00000282       BFF3A0B4  BFF3A0C0
-4  BFF3A09C  08048116       BFF3A0B0  00000009
-8  BFF3A098  BFF3A0B4       BFF3A0AC  00000001
-12 BFF3A094  00000000       BFF3A0A8  00000002
-16 BFF3A090  00000009       BFF3A0A4  00000003
-20 BFF3A08C  00000003       BFF3A0A0  00000282 </pre>
Pour la pile ebp, nous trouvons en 0 l’adresse de la pile ebp précédente en + 4 l’adresse de retour en +8 le paramètre passé à la routine. En -4 nous trouvons bien le résultat du calcul précédent  puis la sauvegarde des registres ebx, ecx et edx.<br>
Pour la pile esp, nous trouvons dans les adresses positives la sauvegarde des registres. Vous pouvez vous demander à quoi correspond la valeur 282 au déplacement 0 ? alors !! c’est la sauvegarde du registre des indicateurs eflag (faite par le pushf).<br>
Puis nous appelons une deuxième routine à laquelle nous passons  la valeur 20 et au retour de cette routine, nous remettons dans le registre ecx la valeur de la zone réservée et nous l’affichons. Il y a bien toujours 9.<br>
Ensuite nous appelons une 3 ième routine en lui passant la valeur 6 et nous terminons la routine 2 en restaurant les registres et en libérant la place de 4 octets avec l’instruction <pre> add esp,4 </pre> avant l’instruction leave.<br>
Il existe une deuxième méthode pour réserver la place pour des variables locales : c’est d’utiliser le premier argument de l’instruction enter. C’est je que j’ai fait dans la routine N°2, en réservant 16 octets pour un tableau de 4 valeurs avec l’instruction <pre> enter 16,0 </pre>
Ensuite nous pouvons stocker des valeurs dans ce tableau mais nous penser qu’il faut commencer par l’adresse ebp -16. Ici je stocke la valeur 20 + 25 = 45 soit 0x2D dans le 2ième poste du tableau donc à l’adresse ebp – 16 + 8 soit ebp -8. <br>
L’affichage des piles donne ceci : <pre>
Routine2
Affichage piles :
    pile ESP: BFF3A074       pile EBP: BFF3A094
+40 BFF3A09C  00000014       BFF3A0BC  00000004
+36 BFF3A098  0804811D       BFF3A0B8  080480A7
+32 BFF3A094  BFF3A0B4       BFF3A0B4  BFF3A0C0
+28 BFF3A090  00000009       BFF3A0B0  00000009
+24 BFF3A08C  0000002D       BFF3A0AC  00000001
+20 BFF3A088  00000001       BFF3A0A8  00000002
+16 BFF3A084  BFF3A098       BFF3A0A4  00000003
+12 BFF3A080  00000001       BFF3A0A0  00000282
+8  BFF3A07C  00000009       BFF3A09C  00000014
+4  BFF3A078  00000003       BFF3A098  0804811D
+0  BFF3A074  00000206       BFF3A094  BFF3A0B4
-4  BFF3A070  0804816E       BFF3A090  00000009
-8  BFF3A06C  BFF3A094       BFF3A08C  0000002D
-12 BFF3A068  0000002D       BFF3A088  00000001
-16 BFF3A064  00000002       BFF3A084  BFF3A098
-20 BFF3A060  00000003       BFF3A080  00000001
</pre>
Nous trouvons bien la valeur 2D au déplacement -8 de ebp. Mais il y a des valeurs aussi avant et après !! pourquoi ?  Et bien nous n’avons pas initialisé les 16 octets que nous avons réservé sur la pile et donc il y a n’importe quoi !!.
0 la fin de la routine, il est inutile de libérer la place réservée par une instruction add, l’instruction leave fera le nécessaire. <br>
Dans la 3ième routine, nous récupérons le paramètre passée à la routine mais nous récupérons aussi le paramètre passé à la routine 1. En effet nous avons déjà vue que le déplacement 0 de ebp contient l’adresse de ebp avant l’appel de la routine. Donc il nous suffit de charger le contenu de ebp dans un registre puis de lire le contenu de ce registre +8 pour récupérer le paramètre passé à la routine 1. Ceci permet de récupérer des paramètres principaux dans des sous routines  sans avoir à les remettre sur la pile.<br>
Nous pouvons aussi utiliser des noms pour identifier les zones réservées sur la pile. Le nom est attribué avec l'instruction %define. Dans cette routine nous avons 2 zones appelées var1 et var2. <br>
De retour dans le programme principal, nous réaffichons les piles pour vérifier que nous sommes bien revenus à leur adresse d’origine. <br>
Une dernière question : à quoi sert le 2ième argument de l’instruction enter. Vous pouvez regarder le chapitre 5 du volume 1 de la documentation INTEL qui explique bien le pourquoi de ce paramètre. Il est possible d’exprimer le niveau d’imbrication de chaque routine par un chiffre dans ce deuxième argument (1 pour le programme principal, 2 pour la routine 1, 2 pour les routines 2 et 3 etc ). Ceci à pour effet de sauvegarder sur la pile des informations complémentaires qui permettent de retrouver les paramètres passés aux routines. Je n’ai pas beaucoup approfondi le déroulement de ces codes car cela semble peu utilisé par des programmes assembleurs. Cela semble plutôt utile pour des programmes de plus haut niveau comme le C. <br>

Nous avons vu que la pile sert à passer des paramètres à nos routines, mais elle sert aussi à passer des paramètres lorsque l’on veut utiliser des fonctions d’autres libraires ( par exemple librairie graphique comme X11). Pour cela il y a lieu de respecter des normes pour que la fonction appelée récupère les paramètres dans le bon ordre. Il est aussi nécessaire de savoir dans quel état  vont se retrouver nos registres après l’appel. <br>
Dans le programme pgm18_1, nous allons simplement appeler la fonction printf du C avec  un ou plusieurs paramètres. Mais il nous faut modifier le linker qui effectue l’édition de liens, pour que celui appelle les librairies du langage C. Pour cela nous remplaçons ld par le compilateur C gcc qui effectue aussi l’édition des liens. Voici la commande à effectuer ou copier le script compil32GCC.sh ; <br>
<pre>
#appel linker GCC 
gcc  -Wall  -o $1 $1.o ../routines.o -e main
</pre>
 Nous effectuons pour afficher un petit message pour vérifier la compilation et le linker. Dans la programme il ne faut pas oublier de déclarer la fonction printf comme extern.  Nous remarquons que l’ordre des paramètres est inversé d’abord la chaine à afficher puis le format.  Un contrôle de la pile avant et après montre que c’est le programme appelant qui doit réaligner la pile. Nous ajoutons donc l’instruction <pre>add esp,8 </pre> car il y a 2 paramètres mis sur la pile<br> 
Un deuxième test sur 3 valeurs contenues dans les registres ebx, ecx, edx montre que les registres ecx et edx sont écrasés par le premier printf. Le registre ebx est conservé. <br>
Le 3ième test montre que le registre eax contient au retour de l’appel de la fonction, le nombre de caractères affichés. <br>
Une consigne indique que la pile doit être alignée sur une frontière de 16 octets. Le 4ième test effectué sur le passage de 3 paramètres ne montre pas de différence. Je teste aussi en ajoutant l’instruction sub esp,4 avant les autres push pour aligner la pile.<br>
La recherche sur Internet pour connaitre les registres sauvegardés ne donne pas grand-chose donc j’effectue un test avec des valeurs sur tous les paramètres. Nous constatons que seuls les registres eax, ecx et edx sont perdus. <br>
