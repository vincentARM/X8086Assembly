Mais Maitre, pour chaque message a afficher, s'il faut décrire le message dans la section .data, n'est ce pas trop contraignant ? N'existe-il pas de solution plus simple ?. <br>
En effet, nous allons voir que nasm autorise les macro instructions. Une macro instruction est une suite d'instruction assembleur que le compilateur va dupliquer et installer à l'endroit que vous voulez dans le programme.
L'interet, c'est que nous pouvons indiquer des variables et dupliquer une macro avec des petites variations lors de l'execution. <br>
Nous allons créer une macro qui va afficher un libellé quelconque dans le programme par exemple afficherLib "toto". afficherLib sera le nom de notre macro et "toto" pourraêtre remplacer par n'importe quelle texte.<br>
Dans le programme pgm4.asm, après la partie constantes, nous trouvons la description de notre macro entre les peseudo instructions %macro et %endmacro.<br>
Sur la première ligne nous trouvons le nom de la macro afficherLib et le chiffre 1. Ce chiffre indique le nombre de variable à passer à la macro. Ici nous n'avons que notre libellé.<br>
Puis nous trouvons une instruction de saut à l'étiquette %%endstr. En effet nous devons stocker notre libelle en mémoire avec l'instruction db comme nous l'avons vu dans les chapitres précédents et donc nous mettons cette instruction dans le code mais il ne faut pas que le processeur essair de l'executer donc nous la sautons.<br>
L'instruction db est précedée de son label %%str et contient notre libelle que nous inserons avec le code $1 puis il est suivi du code retour ligne et du 0 final de fin de chaine. <br>
Ensuite il nous suffit de mettre sur la pile le nouveau label et d'appeler notre routine d'affichage précedente : celle qui attend un paramètre sur la pile.<br>
Remarque : J'ai remplacé les 2 instructions push ebp et mov ebp,esp par une instruction qui fait a peu prés la même chose enter 0,0 (prologue) et l'instruction de fin pop ebp par l'instruction leave (epilogue).<br>
Nous pouvons donc inserer notre macro où bon nous semble dans le programme et voici le résultat.
Début du programme.
toto
Très bien l'assembleur sous linux !!
Fin normale du programme.<br>
Vous remarquerez que les labels de la macro sont précédes des caractères %%. Ceci indique à l'assembleur qu'il devra genérer une partie différente à chaque insertion de la macro dans notre programme.<br>
Nous pouvons voir cela en effectuant une compilation avec nasm en ajoutant l-option -l <pgm>.txt ce qui donne ici
nasm -f elf pgm4.asm -l pgm4.txt <br>
Et en regardant dans le fichier pgm4.txt, vous verrez à droite l'image de notre programme et à gauche les instructions machines générées par le compilateur. <br>
Vous voyez que le compilateur a inséré le code de notre macro à l'emplacement de nos 2 appels de macro. 
Vous pouvez voir aussi toutes les instructions machines générées par le compilateur et qui sont obscures pour nous !!!

