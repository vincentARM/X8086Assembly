Nous avons vu qu'un registre est un composant électronique qui contient 32 positions (bits numérotés de 0 à 31) qui sont soit à zéro soit à un.<br>
Nous allons écrire une routine qui affiche ces positions puis nous effectuerons quelques vérifications sur les opérations logiques concernant les bits.<br>
Dans le programme pgm8.asm, la routine d’affichage afficherBinaire est semblable à la routine d’affichage décimale sauf qu’elle passe une zone de conversion de 33 octets à la routine de conversion conversion2.<br>
Dans conversion2, nous effectuons la boucle d’extraction 32 fois pour afficher toutes les positions. A la fin de la boucle, nous n’avons pas à déplacer les chiffres puisque nous affichons tous les bits.<br>
Dans le programme principal, nous mettons d’abord la valeur 1 dans le registre eax puis la valeur -1 puis la valeur maximum et nous appelons la nouvelle routine. Voici les résultats :
<pre>
Début du programme.
Affichage registre en binaire : 00000000000000000000000000000001
Affichage -1
Affichage registre en binaire : 11111111111111111111111111111111
2puissance 32 -1
Affichage registre en binaire : 11111111111111111111111111111111
</pre>
Vous voyez que la valeur -1 et la valeur maxi sont identiques et que tous les bits qui les composent sont à 1.
Ensuite nous mettons la valeur binaire 0011 dans le registre eax en la codant 0b0011 pour la différencier d’une valeur décimale. Nous mettons la valeur 0b0101 dans le registre ebx et nous exécutons l’instruction  ET logique : and eax,ebx. Voici le résultat :
<pre>
 Instruction and
Affichage registre en binaire : 00000000000000000000000000000001
</pre>
Vous remarquez que seul le bit dont les valeurs correspondantes de eax et ebx sont à un est à un, les autres sont remis à zéro ce qui correspond bien au ET logique. Nous testons les autres opérations logiques or, xor et not. <br>
Nous testons aussi l’instruction xor appliquée au même registre. Vous remarquez que tous les bits passent à zéro. Vous trouverez cette instruction dans de nombreux exemples de programmes pour initialiser un registre à zéro. L’interêt (tout relatif) est que cette instruction est plus courte de 4 octets que l’instruction mov eax,0. Nous pouvons l'utiliser pour mettre le code retour à 0 en fin de programme avec xor ebx,ebx<br>
Nous verrons dans un autre chapitre d’autres instructions qui concernent des manipulations de bits mais nous allons voir d’abord l’affichage d’un registre en hexadécimal.<br><br>
Dans le programme pgm8_1, nous trouvons une nouvelle routine d’affichage afficherReg16 qui appelle la routine de conversion conversion16. Dans cette dernière nous effectuons la boucle d’extraction de chaque chiffre 8 fois et nous devons coder les restes de la division par 16 en caractères Ascii pour les chiffres de 0 à 9 et coder les valeurs de 10 à 15 par les lettres A,B,C,D,E,F. Pour cela nous ajoutons 48 à l’octet lu s’il est inférieur à 10 sinon on ajoute 55. <br>
Dans le programme principal, nous mettons la valeur 1 puis -1 dans le registre eax puis nous appelons la nouvelle routine ce qui donne :
<pre>
Début du programme.
Affichage registre en hexa : 00000001
Affichage -1
Affichage registre en hexa : FFFFFFFF
</pre>
Nous voyons que la valeur -1 qui est aussi la valeur maximum d’un registre est affichée en FFFFFFFF, ce qui est plus lisible que les 32 bits en notation binaire. Maintenant si nous mettons la valeur 15 soit 0b1111 sur 4 bits nous voyons qu’elle est affichée F et la valeur maxi d’un octet (2 puissance 8 – 1) sera représenté par FF. <br>
Nous pouvons donc traduire facilement les données binaires en données hexadécimales et nous pouvons examiner plus facilement les manipulations des 4 octets qui composent un registre. Pour des raisons historiques et pour assurer la compatibilité des programmes au fil des évolutions des processeurs, les 16 bits(soit 2 octets) de la partie basse d’un  registre comme eax peuvent être manipulés sous le nom ax. Par exemple pour mettre tous les bits à 1 il suffit de mettre la valeur 0xFFFF dans le registre ax avec l’instruction mov ax,0xFFFF et l’affichage du registre complet donnera :
Et toujours pour des raisons historiques les 2 octets du registre ax peuvent être manipulés avec les nom ah pour l’octet du haut (h pour high en anglais) et al pour l’octet du bas ( l pour low en anglais). Par exemple nous pouvons mettre la valeur 0xFF dans le 2ième octet par mov ah,0xFF ce qui donne :

Il en est de même pour les registre ebx, ecx,edx qui se décomposent en bx,cx,dx qui eux-mêmes se décomposent en bh,bl,ch,cl,dh,dl. Ainsi nous pouvons  utiliser mov ah,bh ou inc cl ou même cmp dh,0. 
Il faudrait aussi vérifier le mov ah,al et la possibilité des opérations arithmétiques avec les notions de dépassement et de retenues !
Nous avons déjà vu l’utilisation de ses sous registres lors de la récupération et la mise à jour d’un caractère ASCII d’une donnée de la mémoire.
Il faut quand même être prudent dans la manipulation de ces sous registres car par exemple mov eax,0 remet à zéro les 4 octets du registre tandis que mov al,0 ne remet que le premier octet à zéro.


