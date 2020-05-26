Nos programmes deviennent de plus en plus importants avec l’insertion de nouvelles routines. De plus les routines d’affichages sont identiques d’un programme à l’autre.  Nous allons voir 3 manières de simplifier le programme maitre sans avoir à recopier chaque fois ces routines.<br>
La première méthode est de déplacer les routines dans un fichier source annexe et d’intégrer ce fichier avec la directive nasm : %include. Cette instruction va simplement recopier le fichier annexe pour l’iinsérer dans le corps du programme principal avant la compilation.<br>
Dans le programme pgm9.asm, nous supprimons donc toutes les routines d’affichage et de conversion pour les mettre dans le fichier includeFonction.asm . Nous ajoutons aussi dans ce fichier, la macro, les constantes et les libellés. Puis dans le programme principal, nous mettons la directive : 
<pre>
%include "includeFonction.asm"
</pre>
Vous voyez que le corps du programme est maintenant réduit à peu de choses. La compilation et l’exécution donnent des résultats corrects. <br>
Les inconvénients de cette méthode sont que le compilateur effectue à chaque nouveau programme, la compilation des routines et que vous ne pouvez pas utiliser les mêmes noms ou labels dans le programme principal puisqu’il s sont déjà définis dans le fichier annexe.<br>
Une deuxième méthode est de créer un fichier annexe contenant les routines et de le compiler séparément pour créer un fichier objet. Mais il ne sera pas possible d’appeler la macro instruction ni les constantes. De plus il faut déclarer chaque nom de routine comme global.<br>
Dans le programme pgm9_1, nous retrouvons donc les constantes, la macro d’affichage d’un libellé et nous devons déclarer avant l’appel les routines comme externes avec la directive :
<pre>
extern afficherMess,afficherReg
</pre>
pour éviter une erreur de compilation.
Ensuite nous devons modifier le script de compilation ou en écrire un nouveau pour y intégrer l’objet du programme annexe crée précédemment :

Les inconvénients : nous devons déclarer les routines externes, et surtout nous devons penser à chaque modification d’une routine de recompiler d’abord le fichier annexe  qui la contient puis de compiler (ou même simplement de linker) le programme principal.
Enfin la 3ième méthode, est plus complexe et peut s’appliquer à des programmes beaucoup plus gros. Il s’agit d’utiliser l’utilitaire make. Pour cela nous devons créer un fichier de commande nommé Makefile qui contiendra les règles de construction d’un exécutable (voir sur internet les nombreuses documentations de cet utilitaire). On y retrouver l’appel du compilateur nasm et l’appel du linker ld plus d’autres commandes pour générer tous les objets nécessaires à partir des sources et la construction de l’exécutable final.  La syntaxe n’est pas des plus simples à comprendre et il est possible de s’arracher les cheveux pour comprendre un dysfonctionnement.
Ensuite nous créons 2 sous répertoires : src qui contiendra le programme principal mais aussi le fichier annexe ou même plusieurs fichiers annexes chacun contenant une ou plusieurs routines regroupées suivant leur type, et un répertoire build qui recevra les objets et l’exécutable final.
Pour notre exemple nous créons le sous répertoire pgm9 puis les 2 soussous  répertoires src et build. Dans le répertoire pgm9, nous mettons le fichier Makefile et un petit script utilisé par le linker qui indiquera l’adresse de stockage des sections dans la mémoire. Pour l’instant je n’ai pas approfondit les possibilités de ce script, c’est à creuser !!.
Dans le répertoire src, nous mettons le programme pgm9_2.src et le fichier annexe contenant les routines : routines.asm
La construction s’effectue simplement en tapant make.
Si pas d’erreur, nous pouvons exécuter le programme pgm9_2 qui se trouve dans le répertoire build.
L’inconvénient c’est que c’est lourd à mettre en place car il faut recréer toute la structure pour chaque nouveau programme. L’avantage c’est qu’il suffit de modifier ou d’ajouter un fichier source et de relancer make pour que les compilations nécessaires soient lancées.
Je vous laisse le soin de choisir la méthode qui vous convient le mieux. Personnellement compte tenu de la taille limité des programmes exemples, je vais opter pour la 2ième solution car je vais compiler le programme annexe des routines et le placer dans le répertoire supérieur de mes programmes. Ainsi il n’est présent qu’une fois et il sera accessible par le script de compilation quelque soit le sous répertoire où on lance ce script.
