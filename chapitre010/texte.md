Nous allons revenir sur des opérations sur des bits. Nous pouvons en plus des opérations logique ET,OU,OU EXCLUSIF et NON, déplacer les bits dans un registre.<br>
REMARQUE : à partir de ce chapitre, les routines d'affichage sont déportées dans le fichier routines.asm, compilées séparement. Le fichier objet de ces routines sera linké avec les programmes exemples. <br>
Dans le programme pgm10.asm, nous déplaçons les bits du registre eax de 5 positions sur la gauche avec l’instruction :
<pre>
Mov eax,0b11
Shl eax,5
</pre>
Résultat :
<pre>
Instruction déplacement gauche
Affichage registre en binaire : 00000000000000000000000001100000
</pre>
Vous voyez que les 2 bits à 1 ont été déplacés sur la gauche et  que le registre a été complété par des zéros.
Puis nous les déplaçons de 3 positions sur la droite avec l’instruction :
<pre>
Shr eax,3.
</pre>
Résultat :
<pre>
Instruction déplacement droite valeur immédiate
Affichage registre en binaire : 00000000000000000000000000001100
</pre>
Là aussi le registre a été complété par des zéros à gauche.<br>
Quels sont les conséquences sur les valeurs si nous les affichons en décimal. Nous constatons que chaque déplacement d’une position sur la gauche revient à multiplier par 2 et que chaque déplacement sur la droite revient à une division par 2. Cela est intéressant car nous pouvons remplacer des multiplications et divisions par 2 qui sont couteuses en temps par des instructions plus simples.<br> 
Voici le résultat pour un déplacement gauche de la valeur 5 :
<pre>
Instruction déplacement gauche = multiplication par 2
Affichage registre en binaire : 00000000000000000000000000000101
Affichage registre en binaire : 00000000000000000000000000001010
Affichage décimal d'un registre : +10
</pre>
Et un déplacement de 3 positions à droite pour la valeur 1000 et qui correspond donc à une division par 8.
<pre>
Instruction déplacement droite de 3 = division par 8
Affichage décimal d'un registre : +125
</pre>
Mais si le nombre de départ est négatif, cette instruction produit un résultat incorrect puisque les bits de gauche sont remplacés par des zéros. Heureusement il y a une instructions sar qui duplique le bit le plus à gauche à chaque déplacement et le résultat est correct :
<pre>
Instruction déplacement droite pour nombres signés
Affichage décimal d'un registre : -125 
</pre>
L‘autre question que l’on doit se poser est le devenir du bit (ou des bits) qui a été poussé sur la gauche ou sur la droite et qui a donc été éjecté du registre. Il n’est pas perdu car il est stocké dans l’indicateur de retenue (carry) et il peut donc être testé par les instructions de saut conditionnel  jc ou jnc. Nous écrivons une petite routine testerCarry qui effectuera ce test.
Voir dans le programme pgm10.asm le déplacement consécutif sur la droite de la valeur 0b01 et qui donne pour résultat :
<pre>
Instruction deplacement droite verif du carry
carry à zéro
carry à un
</pre>
Mais il existe aussi des instructions qui permettent de faire tourner tous les bits d’un registre soit sur la gauche instruction rol ou sur la droite instruction ror. Dans ce cas, aucun bit n’est perdu, ceux qui sortent par la gauche sont insérés sur la droite  pour la rotation gauche (l pour left) et vice versa pour l’instruction ror (r pour right).<br>
Il existe aussi une instruction de rotation rcl (ou rcr) qui fait tourner les bits du registre en icluant le bit de l’indicateur de retenue (carry).<br>
Dans le programme pgm10.asm, vous avez un exemple de la rotation gauche et un exemple de la rotation droite. Dans ce dernier cas, je force l’indicateur de retenue à 1 avec l’instruction stc avant la rotation. Vous voyez bien dans le résultat qu’un 1 apparait en 29iéme position :
<pre>
 Instruction rotation droite avec deplacement retenue
Affichage registre en binaire : 00100000000000000000000001110000
</pre>
L’assembleur propose aussi des instructions de test de bits. La première bt  recopie le bit de la position demandée dans l’indicateur de retenue et donc nous pouvons le tester.<br>
Une autre instruction btc effectue la même chose mais elle met le complément du  bit testé à la place du bit, bts fait aussi la même chose mais force le bit testé à 1 et btr le force à zéro. <br>
Ensuite nous trouvons les instructions bsf et bsr qui recherchent et mettent dans un registre destination la position du 1er bit à 1 en partant de la gauche ou de la droite.<br>
L’instruction bsr est intéressante car elle permet de trouver le premier bit significatif d’une valeur et de  limiter certaines opérations aux chiffres significatifs. Par exemple dans la routine d’affichage des bits, on pourrait initialiser la zone de conversion avec le caractère ascii Zéro et n’effectuer la boucle de conversion que pour les bits significatifs.<br>
Enfin nous terminons avec l’instruction test qui effectue un Et logique entre les 2 opérandes mais qui ne modifie pas  le registre destinataire. Cette instruction est intéressante car elle positionne aussi l’indicateur de signe comme nous le voyons dans les résultats.
<pre>
Affichage registre en binaire : 00000000000000000000000000001100
Signe positif
Indicateur Z = zéro
Signe positif
Indicateur Z différent de zéro
Signe positif
Indicateur Z différent de zéro
Test nombre négatif
Affichage registre en binaire : 10000000000000000000000000001100
Signe négatif
Indicateur Z différent de zéro
</pre>
