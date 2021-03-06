Maintenant que nous avons une routine d'affichage d'un registre, nous pouvons examiner les instructions arithmétiques disponibles et voir leur utilisation dans le programme pgm6.asm. <br>
Tout d'abord, nous vérifions l'instruction mov en mettant les valeurs 100 dans eax et 10 dans ebx puis en effectuant le mov eax,ebx. L'affichage montre bien que eax après l'opération contient bien 10 mais aussi que la valeur de ebx reste inchangée. Donc il s'agit plutôt d'une copie d'un registre dans un autre qu'un déplacement. <br>
Ensuite nous testons les instructions d'addition add, de soustraction sub, de multiplication (pour laquelle il n'est pas possible d'indiquer une valeur immédiate, il faut toujours utiliser un registre). <br>
Il existe aussi une instruction d'incrémentation inc eax qui augmente de 1 le registre et de décrémentation qui diminue de 1 la valeur d'un registre. Cette instruction peut remplacer les add eax,1 que nous avons utilisé plusieurs fois dans les routines.<br>
Nous vérifions aussi que les calculs sont possibles pour le registre edi.<br>
Nous vérifions la division du registre eax par ebx, et il est possible aussi de diviser eax par ecx. Nous pouvons aussi tester la division par zéro et nous avons le surprenant message :
<pre>
Exception en point flottant (core dumped)
</pre>
Puis nous vérifions à nouveau la division car l'initialisation du registre edx à zéro avant la division m'interpelle. Et en effet si on enchaine plusieurs divisions sans initialiser ce registre, les résultats sont déroutants.<br>
Mais en regardant plus précisément la documentation des instructions (par exemple sur gladir), je me rends compte que le dividende de la division est la paire de registres edx:eax et non pas le seul eax. Cela permet de diviser un nombre de 64 bits par un nombre de 32 bits.<br>
Voyons un exemple : mettre 1 dans le registre edx correspond à ajouter un 33 ieme bit à un nombre et donc d'ajouter la valeur 4 294 967 296 à la valeur du registre eax par exemple 100 ce qui donne 4 294 967 396. Si on le divise par 1000 et si on affiche le contenu du registre eax on doit trouver  4 294 967  et le registre edx doit donner comme reste 396. L'exécution du programme donne bien ces résultats.<br>
Mais en réfléchissant à cette histoire de division de 2 registres, je me suis demandé si la multiplication n'alimentait pas aussi la paire de registre edx:eax.<br>
Par exemple mettons dans eax une grande valeur comme 4 000 000 001 et multiplions par 1000. Nous trouvons après l'opération la valeur 1385448424 dans eax et 931 dans edx ce qui correspond à 4 294 967 296 * 931 = 3 998 614 552 576. Si on ajoute la valeur du registre eax 1385448424 cela donne 4 000 000 001 000‬, ce qui est bien exact.<br>
Il faudra donc être vigilant lors de la programmation de ces instructions pour éviter des erreurs longues à rechercher.
Nous terminons ce programme en essayant d'afficher la valeur des autres registres dont on a parlé: le pointeur d'instructions eip et le registre de pile esp. Il n'est pas possible d'afficher eip, le compilateur refuse d'utiliser le nom eip. Pour le registre de pile, nous pouvons afficher sa valeur mais cela ne nous donne pas grand chose sauf que c'est une adresse élevée !!!
Et les autres opérations comme l'élévation à la puissance ? ou le calcul d'une racine carrée ? etc.<br>
Non, l 'assembleur de dispose que de ces opérations pour les nombres entiers !! et pour le reste il vous faudra trouver un algorithme et écrire la routine correspondante.<br>

Dans le programme pgm6_1, nous allons revenir sur la multiplication car il est important de savoir si lors d'une opération, le résultat va dépasser la taille d'un registre. Et en effet, le processeur va positionner un indicateur (ou drapeau ou flag en anglais) dans ce cas. Pour notre multiplication, l'indicateur est l'indicateur Overflow dont la notation est o. Pour savoir s'il est positionné ou non, il faut utiliser les instructions de saut jo ou jno. <br>
Dans le code du programme, vous pouvez voir une structure de type if-else qui affiche le libellé overflow si l'instruction jo est vraie sinon elle affiche le libellé pas d'overflow.
Vérifions aussi l'addition, en additionnant une très grand valeur proche de la valeur maxi avec une autre valeur. Vous voyez que le résultat 4294967290 + 10 est egal à 4 ce qui est manifestement faux !! Et curieusement l'indicateur d'overflow n'est pas positionné. Dans ce cas le processeur positionne un autre indicateur, l'indicateur de retenue ou carry en anglais est qui est noté c. Et les instructions de saut pour tester cet indicateur sont jc et jnc. <br>
Attention : le registre edx n'est pas alimenté avec le surplus comme dans la multiplication. <br>

Vérifions maintenant la soustraction en effectuant le calcul tout simple 5 - 15 et le résultat est égal à 4294967286, ce qui de nouveau faux.
Quel est l'indicateur positionné dans ce cas ? <br>
Le test de l'indicateur overflow indique pas d'overflow, celui de retenue indique pas de retenue, il faut tester un nouvel indicateur, l'indicateur de signe nommé s qui passe à 1 lorsque le résultat est négatif.
Bon, nous allons voir la gestion des nombres négatifs dans le chapitre suivant. Et là les complications vont commencer !! <br> 
 



