Bon maintenant, fini d'afficher des chaines de caractères, nous allons voir comment afficher le contenu d'un registre.<br>
Un registre contient donc une valeur qui va de 0 à 4294967295 mais il n'est pas possible d'afficher directement le contenu puisque nous ne pouvons qu'afficher des chaines de caractères ASCII. <br>
Il nous faut donc convertir le nombre contenu dans le registre en chaine de caractères puis afficher celle çi.<br>
Partons du nombre 1234. Pour obtenir chaque chiffre, il faut le diviser successivement par 10 et garder les restes successifs. <br>
Première division 1234 / 10 = 123 et le reste est 4. <br>
2ième division 123 / 10 = 12 et le reste est 3. <br>
3ième division 12 / 10 = 1 et le reste est 2. <br>
4 ième division 1 /10  = 0 et le reste est 1. <br>
Et il est inutile de continuer puisque nous n'avons plus que des zéros. <br>
Nous devons stocker chaque reste dans une zone en partant de la fin de celle çi puisque nous extrayons les chiffres dans l'ordre 4 3 2 et 1.<br>
Mais il y a un probléme ! ces chiffres ne sont pas des caractères ASCII si nous regardons une table de ces codes, nous voyons que les chiffres vont des codes 48 à 57. Il nous faut donc ajouter à chaque reste le nombre 48 avant de le stocker.
Puis il nous faudra recopier le résultat en début de la zone de stockage pour faciliter l'affichage. <br>
Donc en route pour creer la routine dans le programme pgm5.asm. Nous trouvons comme auparavant, les constantes, la macro d'affichage d'un libellé, la definition des messages et en plus nous trouvons dans la section .bss une zone sZoneConv qui va nous servir à stocker tous les caractères Ascii extrait par la nouvelle routine. Nous réservons 12 octets avec l'instruction resb puisque nous savons que le nombre maxi résultat à une longueur de 10 chiffres + le zéro final + une petite marge = 12 octets.
Nous utilisons la section bss pour toutes les données qui n'ont pas besoin d'être initialisées par nos soins. Dans la section bss les données seront initialisées à zéro par Linux avant l'execution de notre programme. Mais rien de nous empêche de déclarer notre zone dans la .data si nous préférons.<br>
Après notre routine précédente d'affichage des messages, nous trouvons une nouvelle routine afficherReg qui va récupèrer sur la pile la valeur à convertir, afficher le début de message, puis appeler la routine de conversion en lui passant 2 paramètres sur la pile : la valeur à convertir et l'adresse de la zone réceptrice que nous venons de définir. La routine se termine par l'affichage du contenu de cette zone et l'affichage d'un retour ligne pour conclure l'affichage.<br>
Puis nous arrivons à la routine de conversion conversion10 : celle çi commence par récuperer les 2 paramètres passés sur la pile : la valeur dans le registre eax et l'adresse de la zone dans un nouveau registre edi. Celui çi est préconisé pour être utilisé dans les accès à la mémoire et il nous permet de ne pas utiliser un autre registre général.<br>
Nous commençons par stocker un zéro final en position 11 de la zone réceptrice. Puis nous commençons une boucle qui va diminuer le pointeur de caractère de la zone réceptrice de 1 puis qui va diviser le contenu du registre eax par le registre ebx dans lequel nous avons mis la valeur 10. L'instruction div effectue la division toujours du registre eax, met le quotient dans eax et le reste dans edx. Curieusement il faut initialiser edx à zéro avant la division mais à ce jour je n'ai pas encore trouvé un site avec les explications détaillées de chaque instruction. <br>
Cette division avec le reste dans edx correspond bien à notre besoin !! Maintenant il suffit d'ajouter la valeur 48 à ce registre pour avoir la valeur d'un caractère Ascii et de le stocker dans la zone receptrice. Puis si le quotient cad le contenu du registre eax est différent de zéro, nous bouclons pour effectuer une nouvelle division et extraire un nouveau chiffre. <br>
A ce niveau, il reste quelques interrogations que j'essairais de résoudre : le registre ebx évolue-t-il pendant la division ? quel est le coût de cette instruction ? existe-il d'autres possibilités ?
De plus l'instruction de stockage du caractère m'a posé problème, car je pensais utiliser mov byte [edi,ecx],edx mais le compilateur génére l'erreur : <br>
pgm5.asm:126: error: mismatch in operand sizes <br>
Donc pour stocker un octet, il faut utiliser une partie du registre edx ou plus exactement le premier octet  qui s'appelle dl. Nous verrons ultérieurement cette particularité.<br>
En fin de boucle, nous avons donc stocké tous les chiffres significatifs en fin de notre zone receptrice !! et il nous reste à ramener tous ces chiffres en début de zone : c'est le but de la 2ième boucle, nous initialisons le registre ebx à zéro et il nous servira de pointeur vers le début de la zone et le registre ecx pointe lui sur le premier chiffre du résultat. Il nous suffit donc de lire un caractère dans le registre dl puis de le charger au début de la zone réceptrice.<br>
Mais Maître pourquoi passer par un registre intermédiaire ? ne peut on pas avoir directement <b>mov byte [edi,ebx],[edi,ecx] </b>?
Et bien non, cela n'est pas possible car la liaison entre le processeur et la mémoire s'effectue par un seul bus et celui ci ne peut pas simultanément écrire et lire la mémoire.<br>
Puis nous terminons la routine par retourner le nombre de chiffre trouvé dans le registre eax et nous restaurons les registres comme déjà vu. Le retour d'une valeur dans eax est la méthode la plus préconisée pour retourner un résultat à l'appelant.<br>
Dans le programme principal, il ne nous reste plus qu'à mettre sur la pile, le registre que nous voulons afficher et appeler la routine afficherReg. Pour tester, nous essayons les valeurs 1234, 0, et la plus grande valeur ( (1<<32)- 1).
Voici les résultats :
<pre>
Début du programme.
Affichage décimal d'un registre : 1234
Affichage décimal d'un registre : 0
Affichage décimal d'un registre : 4294967295
Fin normale du programme.
</pre><br>
Ah j'oubliais, la routine de conversion se termine par ret 8  car en effet nous avons 2 paramètres en entrée de la routine et donc il faut réaligner la pile de 2 fois 4 octets = 8. <br>

Dans le programme pgm5_1.asm, nous modifions les appels à la routine pour d'abord afficher la valeur 1234 puis afficher ce que contient le registre eax et vérifier ainsi que la longueur retournée est bien de 4. Ce n'est pas le cas l'affichage reste à 1234 !! Pourquoi ? <br>
Dans la routine de conversion10, nous sauvegardons au début tous les registres par l'instruction pusha et en fin de routine, nous restaurons tous les registres à leur valeur initiale. Donc le registre eax retrouve sa valeur initiale et perd la longueur mise auparavant. De plus la routine appelante afficherReg sauve aussi le registre eax et le restaure en fin.<br>
Dans le programme pgm5_2.asm, nous mettons l'instruction push eax et pop eax en commentaire et dans la routine conversion10, nous ne sauvegardons et restaurons que les registres ebx,ecx edx et edi. <br>
L'execution est correcte et  retourne bien la bonne longueur :
<pre>
Début du programme.
Affichage décimal d'un registre : 1234
Affichage décimal d'un registre : 4
Fin normale du programme.
</pre>
Dans le programme pgm5_3.asm, nous mettons des valeurs quelconques dans les registres ebx,ecx,edx et edi et nous vérifions après l'appel si ces valeurs restent inchangées. Tout fonctionne !!! <br> 







