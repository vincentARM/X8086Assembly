Il est possible en assembleur d’effectuer des calculs avec des nombres en virgule flottante mais il s’agit d’instructions très particulières qui sont exécutées par un coprocesseur X87 Floating Point Unit (FPU) . <br>
Ces nombres sont stockés sous un format particulier respectant la norme IEEE754 soit sur 4 octets en simple précision soit sur 8 octets en double précision. <br> 
Seul petit problème : nous n’avons aucune instruction en assembleur pour convertir ces formats en chaine de caractères que nous pouvons afficher. Et pour l’instant, je ne me sens pas capable d’écrire une routine pour décoder ces nombres. Donc en attendant cette routine !!! nous allons donc utiliser la fonction printf qui propose les codes format %e et %g pour afficher ce type de nombre. <br>
Après lecture du chapitre 8 du volume 1 de la documentation Intel et la lecture du manuel de Nasm, je me lance dans le programme pgm21.asm dans la découverte des instructions pour effectuer les premiers calculs. <br>
Tout d’abord, dans la .data, nous déclarons quelques nombres  pour voir les formats de Nasm : déjà la virgule française est remplacée par le point américain !! La déclaration se fait avec l’instruction dd pour les nombres en simple précision comme pour les entiers et avec dq pour les nombres en double précision. C’est le point qui détermine la nature du nombre entier ou virgule flottante.<br>
Dans le code, j’essaye d’afficher avec printf le premier nombre sur 4 octets. Impossible d’y arriver !! mais l’affichage du deuxième nombre en double précision en passant 2 fois 4 octets sur la pile fonctionne. La recherche sur Internet montre que printf ne peut pas afficher des nombres e simple précision . Il faut les convertir en double précision pour les afficher. Donc il est inutile de manipuler des nombres en simple précision dans nos programmes de calcul. Autant les déclarer sur 8 octets avec dq. <br>
Deuxième découverte : bien que 8 registres de 64 bits servent pour les calculs, ils ne sont pas accessibles avec des noms comme les registres eax,ebx etc (rectificatif : ils peuvent être manipulés par certaines instructions avec les noms st0 à st7). Ils sont organisés sous forme d’une pile et les instructions possibles effectuent des empilements et des dépilements successifs : il va falloir sérieusement réfléchir pour utiliser cette pile.<br>
Si nous commençons à charger un premier nombre de la mémoire dans la pile avec l’instruction <pre> fld dword[fNombre1]</pre> celui çi va être stocké dans le premier registre de la pile qui s’appelle st0. Si nous chargeons un deuxième nombre, le registre du premier nombre va s’appeler st1 et le nouveau nombre sera stockée dans le registre st0 et ainsi de suite.<br>
Puis si nous effectuons l’opération inverse cad stockage en mémoire du nombre contenu dans st0 avec l’instruction <pre> fstp qword[fqNombre3]</pre>, (notez le p derrière fst pour pop) , st0 sera dépilé et st1 deviendra le registre st0. Vous remarquez que les instructions fld et fst ne mentionnent aucun registre car c’est toujours le registre st0 qui est utilisé.<br>
Pour l’affichage par printf, rappelez vous ce que nous avons vu au chapitre 18, les paramètres doivent être placés dans l’ordre inverse et il faut réaligner la pile après l’appel. <br>
Les premiers affichages donnent ceci :
<pre>
Nombre virgule flottante : 1.234567e+20
Nombre virgule flottante : 1.2345678901234e+20
Vidage memoire adresse : 0804A054
0804A050 69 6E 0A 00*CA 29 D6 60 7F BB 04 7E 3A C5 1A 44  "in???)?`???~:??D"
0804A060 00 00 00 00 00 00 12 40 01 00 00 00 29 5C 1F 40  "???????@????)\?@"
</pre>
Remarque : toutes les instructions commencent par f pour float.  Il n’est pas possible de passer directement la valeur d’un registre à l’instruction printf, il faut passer par un stockage en mémoire (mais à vérifier).<br>
Voyons une petite addition du nombre 4,5 avec l’entier 1. <br> L’instruction <pre> fld qword [fqNombre6]</pre> va charger le nombre 4,5 en double précision dans le registre st0.  L’instruction <pre>   fild dword[dUn]</pre> va stocker un entier (notez le i après le f) dans le registre st0 et pousser la précédente valeur dans st1. <br>
Puis l’instruction <pre> fadd st0,st1</pre> va additionner le registre st1 au registre st0. Ensuite nous affichons successivement les registre st0 et st1 en les dépilant et nous effectuons un affichage supplémentaire. Voici le résultat :
<pre>
Nombre virgule flottante : 5.500000e+00
Nombre virgule flottante : 4.500000e+00
Nombre virgule flottante : -nan
</pre>
Nous voyons bien que le premier affichage correspondant à st0, contient bien la somme, que le deuxième correspondant à st1 contient bien le premier nombre stocké et que le 3ème donne la valeur nan (Not A Number) car la pile des registres est maintenant vide.
Puis nous continuons en faisant une autre addition mais cette fois en mettant le resultat dans st1 et en dépilant avec l’instruction <pre> faddp st1,st0</pre> et donc le résultat sera …. Oui dans st0 !! et nous le stockons en mémoire cette fois ci sous forme d’un entier avec l’instruction <pre> fist dword[dRes1]</pre> qui va stocker un entier arrondi et sans dépiler le registre car nous n’avons pas mis le p. Nous pouvons afficher la valeur en passant par le registre eax et nous affichons aussi le résultat réel avec printf :
<pre>
Registres apres fist :
eax = 00000003  ebx = B7729000  ecx = 7FFFFFE0  edx = B76E8870
esi = BFB2933C  edi = 08048410  ebp = BFB29330  esp = BFB29330
Nombre virgule flottante : 3.490000e+00
</pre>
Nous voyons que le calcul donne 3,49 et le résultat entier dans eax est 3. Si vous remplacez le premier nombre 2,49 par 2,51, vous verrez que l’entier stocké est arrondi à 4.
Ouf, suffit pour aujourd’hui !!  

Reprise quelques jours après !! Dans le programme pgm21_1 j’ai écris une routine de saisie des nombres en virgule flottante. Mais pas encore question de convertir directement la saisie en un float en double précision, alors j’ai préféré convertir tous les chiffres de  la saisie en entier avec la routine conversionAtoD déjà vue, déterminer le nombre de chiffres après la virgule pour calculer un diviseur puis effectuer avec les instructions en virgule flottante, la division des deux pour avoir un résultat correcte. <br>
Par exemple :  saisie de 1234,56   conversion en entier 123456 et nombre de chiffres après la virgule 2 soit un diviseur de 1 * 10 * 10 = 100.  Division de 123456 par 100 ce qui donnera 1234,56 stocké en virgule flottante. <br>
Bien sûr cette  routine ne peut pas être utilisée pour des nombres > 2 puissance 31 -1 ni pour des saisies de la forme x.xxxxEy mais cela suffira pour tester plusieurs instructions en virgule flottante.<br>
Dans le programme pgm21_1.asm, nous commençons par initialiser tous les registres (y compris ceux de contrôle) avec l’instruction finit. Attention les 8 registres de la pile (st0 à st7) sont initialisés à vide et non pas à zéro. Si vous essayez d’afficher st0, vous aurez le résultat nan (Not A Number). Ensuite nous affichons le message d’invite de saisie puis nous appelons la routine de saisie saisieFloat à la quelle nous passons en paramètre une zone de réception de 8 octets (définie avec resq). <br>
Dans la routine nous réservons une zone sur la pile de 88 octets avec l’instruction enter. 80 octets serviront à recevoir la chaine de saisie, 4 octets pour le dividende et 4 octets pour le diviseur. Nous pouvons attribuer des noms aux adresses des 3 zones avec l’instruction %define, ce qui facilite leur utilisation.<br>
Ensuite nous effectuons l’appel système READ en passant l’adresse de la zone de 80 octets puis nous effectuons une boucle pour détecter la virgule et la fin de chaine. Nous effectuons la conversion de la totalité de la chaine saisie (cad sans tenir compte de la virgule) dans le registre eax que nous stockons dans la zone dividende. Puis nous calculons le diviseur en effectuant une boucle de multiplication par 10 autant de fois que de chiffres après la virgule. <br>
Après stockage du diviseur nous effectuons la division en virgule flottante avec fdiv et nous stockons le résultat à l’adresse récupérée comme paramètre ([epb+8]).<br>
Au retour dans le programme principal, nous affichons la valeur de la zone réceptrice pour contrôle puis nous effectuons une multiplication pour calculer le carré (j’ai mis en commentaire les autres manières d’effectuer la multiplication) puis la racine carrée, la valeur absolue, l’inversion de signe, l’arrondi,  le cosinus puis enfin la comparaison avec PI (qui est une constante prédéfinie). <br>
Pour la comparaison, j’ai utilisé l’instruction fcomi qui met à jour directement les indicateurs zéro, parité et carry. Curieusement l’indicateur de signe n’est pas mis à jour. D’après des documentations, il est possible d’utiliser l’instruction fcom mais qui ne met pas à jour ces indicateurs. Il faut donc ensuite charger les indicateurs  dans le registre eflag par <pre>
Fstsw ax
Sahf </pre>
Voici un résultat de l’exécution de ce petit programme :
<pre>
Début du programme.
Veuillez saisir un nombre avec virgule :
3,14158
Nombre virgule flottante : 3.141580e+00
Carré = 9.8695248964e+00
Racine carrée = 1.7724502814e+00
Valeur absolue = 3.1415800000e+00
Inversion signe = -3.1415800000e+00
Arrondi = 3.0000000000e+00
Cosinus = -9.9999999992e-01
Nombre virgule flottante : 3.14159265358979
Plus petit que pi
Fin normale du programme.
</pre>
Il existe encore de nombreuses instructions ainsi que des définitions de constantes comme zéro (fldz) ou 1 (fld1). Je vous laisse le soin de les découvrir. <br>

En juillet 2020, je découvre par hasard un algorithme de calcul de l'inverse d'une racine carrée en virgule flottante  voir <br>
https://fr.wikipedia.org/wiki/Racine_carr%C3%A9e_inverse_rapide <br>
J'ai donc écrit la routine dans le programme calculInvRac.asm qui fonctionne comme décrit dans l'article. Le résultat est stocké en 32 bits dans une zone mémoire mais la routine peut être modifiée pour retourner le résultat dans le registre eax ou être stockée dans une zone de 64 bits. <br>
Si necessaire, la précision peut être augmentée soit en effectuant une deuxième fois la dernière partie du calcul soit en réécrivant la routine avec des floats de 64 bits. <br>
