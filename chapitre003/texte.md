Dans le chapitre précédent nous avons vu l'affichage d'un message par une routine dont on passait l'adresse de la chaine dans le registre eax. <br>
Dans ce chapitre nous allons voir une autre méthode pour passer un ou des paramètres à une routine en utilisant la pile.<br>
Dans le programme pgm3.asm, nous retrouvons les descriptions de nos chaines de caractères, cette fois cç j'ai ajouté un message de début de programme et une chaine qui ne contient que le retour ligne.
<br>
Dans la section code, à la place du mov eax, szMessDebPgm, nous trouvons l'instruction push szMessDebPgm qui va empiler sur la pile (normal !!) l'adresse de la première chaine. Puis nous trouvons le call afficherMess comme auparavant pour appeler notre routine. 
Mais attention je vous rappelle que cette instruction va aussi stocker l'adresse de l'instruction suivante sur la pile donc notre adresse de chaine va reculer de 4 octets (32 bits).
Maintenant, voyons les modifications de la routine. <br>
Pour récuperer notre adresse sur la pile, nous n'allons pas directement utiliser celle ci. En effet comme celle çi sert à sauvegarder des registres ou des valeurs ou même servir à des stockages temporaires, nous allons utiliser un autre registre dit de base ebp. <br> 
Et comme ce registre peut avoir déjà servir, nous commençons par le sauvegarder sur la pile par push ebp. Mais attention ceci à pour effet de reculer encore une fois notre adresse de 4 octets sur la pile.
(Euh, j'ai peut être oublier de vous dire que chaque stockage sur la pile faisait décroitre son adresse de 4 octets !!!).<br>
Et maintenant nous stockons dans le registre de base l'adresse actuelle de la pile par mov ebp,esp. <br>
Puis comme nous allons utiliser les registres, nous allons tous les sauvegarder avec une seule instruction pusha.  Et attention cette instruction va faire reculer l'adresse de la pile de x fois 4 octets x car nous ne savons pas combien cette instruction stocke de registres sur la pile).<br>
<br>
Il nous faut maintenant récupèrer l'adresse de notre chaine qui est donc stockée sur la pile à 8 octets de plus que l'adresse stockée dans le registre ebp; <br>
Nous trouvons donc l'instruction mov eax,[ebp + 8] qui va transferer notre adresse chaine de la pile dans le registre eax puis nous allons retrouver notre calcul de longueur et l'affichage de la chaine.<br>
Il ne nous reste plus qu'à terminer correctement notre routine. Il faut dépiler tous les registres pour les restaurer dans leur état d'origine avec l'instruction popa.<br>
Puis il faut dépiler le registre de base par l'instruction pop ebp puis il faut retourner au programme principal avec l'instruction ret.<br>
Mais vous voyez que j'ai ajouté le chiffre 4 derrière. Cela a pour effet d'indiquer au procédure qu'après avoir récupéré son adresse de retour, il devra encore incrementer l'adresse de la pile de 4 octets pour annuler l'effet de notre push szszMessDebPgm
et remettre ainsi la pile à son état initial.
Maitre, vous racontez des blagues, parce que j'ai enlevé ce chiffre de mon programme et ni le compilateur ni le linker n'ont signalé d'anomalie et l'exécution est correcte.
Oui en effet pour ce programme très simple, la pile bien que déphasée ne pose pas de problème mais dès que vous allez programmer des routines qui appellent d'autres routines les ennuis vont arriver et avec eux l'erreur segmentation fault !!
Nous regarderons ultèrieurement le fonctionnement et les valeurs que la pile contient.
Voici le résultat du programme :
Début du programme.
Bonjour depuis l'assembleur 32 bits.
Fin normale du programme.
Et c'est tout pour aujourd'hui !!!

