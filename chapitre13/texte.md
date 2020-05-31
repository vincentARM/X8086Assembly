Nous recopions la routine du chapitre précédent afficherMémoire dans notre fichier annexe routines.asm en la déclarant global et nous recompilons ce fichier pour avoir un objet à jour (cf chapitre9).<br>
Copier une valeur numérique de la mémoire dans une autre zone de la mémoire est facile car il suffit de passer par un registre mais copier une chaine dans une autre zone de la mémoire nécessite une boucle. L’assembleur propose plusieurs possibilités. <br>
D’abord une approche classique (voir le programme pgm13.asm) : chargement de l’adresse de la zone à lire dans un registre, chargement de l’adresse de réception dans un autre registre, initialisation d’un compteur à zéro souvent le registre ecx. Puis il suffit de lire un octet situé à l’adresse de la source + le déplacement donné par ecx et écriture de l’octet  à l’adresse destinataire plus le même déplacement. Et l’arrêt s’effectue quand l’octet lu est à zéro ce qui indique la fin de chaine.<br>
Une autre solution est d’utiliser les registres esi et edi. Le registre esi contiendra l’adresse de la chaine d’origine (s pour source) et edi l’adresse de la zone de destination (d pour destination). Ensuite les 2 instructions lodsb et stosb, lisent et stockent un octet en incrémentant automatiquement les adresses. La lecture de l’octet s’effectuant dans le registre al, Il ne reste plus qu’à tester sa valeur à zéro pour arrêter la copie.<br>
Une autre possibilité permet d’arrêter la copie après un certain nombre de caractères spécifié dans le registre ecx. On utilise les 2 instructions précédentes et on utilise l’instruction loopne (ou loopnz) qui décrémente automatiquement le registre ecx jusqu’ à zéro ou si le flag zéro passe à zéro. Ainsi si la chaine est plus courte que le nombre de caractères demandés,  la copie s’arrêtera en fin de chaine sinon elle copiera le nombre de caractères demandés. Il ne faut pas oublier dans ce cas, de forcer un 0 final pour avoir une chaine correcte.
Voyons maintenant la gestion des tableaux en assembleur. Un tableau est une suite de valeurs dont l’accès à une valeur s’effectue à l’aide d’un indice. Nous avons déjà utilisé cela car une chaine de caractères n’est en fait qu’un tableau de caractères, chacun ayant une longueur d’un octet.
Dans la data du programme pgm13.asm, nous décrivons un tableau de valeurs entières de la taille d’un registre soit 4 octets. Pour ne pas avoir à se préoccuper du nombre d’élément du tableau, nous laissons au compilateur le soin d’effectuer le calcul avec l’instruction :
<pre>
NBPOSTE equ ($ - tabdExp) / 4
</pre>
Qui signifie que la constante NBPOSTE est équivalente à l’adresse actuelle (le $) – l’adresse du début du tableau (tabdExp) divisé par le nombre d’octet de chaque valeur (4). 
Maintenant recherchons la valeur se trouvant au poste N° 3 . Le premier poste se trouve à l’adresse du tableau, le deuxième poste se trouve à l’adresse du tableau + 1 fois 4 octets et le 3ième poste se trouve à l’adresse du tableau + 2 fois 4 octets, ce qui donne l’instruction 
<pre>
mov eax,[esi+(2 * 4)]
</pre>
Mais le poste auquel on veut accéder sera le plus souvent contenu dans un registre et donc nous aurons l’instruction :
<pre>
mov eax,[esi,ebx * 4]
</pre>
Si ebx contient le N° de poste – 1. Il faudra toujours se souvenir que la position des postes commence à zéro.
Maintenant effectuons une recherche de la valeur d’un poste. Pour cela il faut écrire une boucle qui va lire chaque valeur jusqu’à trouver la bonne valeur ou jusqu’ à ce que l’indice dépasse le nombre de poste tel que calculé plus haut (NBPOSTES).<br>
L’assembleur offre une autre possibilité avec l’instruction scasd qui compare la valeur se trouvant à l’adresse contenue dans edi avec le registre eax, et incrémente l’adresse de edi de 4 pour lire la valeur suivante en cas de différence. Mais il faut cette fois ci mettre le nombre de postes maxi dans ecx et utiliser l’instruction loop qui décrémente le compteur ecx et saute au label indiqué si différent de zéro.<br>
Bien sûr il existe les instructions correspondantes pour chercher des octets (scasb) ou des mots (scasw). Vous pouvez vous amuser à tester ces instructions !!<br>
Scasb sera utilisé pour recherche un caractère particulier (par exemple un délimiteur ;) dans une chaine de caractères dont on connait la longueur (pour permettre l’arrêt).
