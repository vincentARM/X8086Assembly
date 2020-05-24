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
Nous verrons dans un autre chapitre d’autres instructions qui concernent des manipulations de bits mais nous allons voir d’abord l’affichage d’un registre en hexadécimal.

