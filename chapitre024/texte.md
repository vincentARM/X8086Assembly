Dans ce chapitre nous allons voir quelques calculs avec des nombres au format BCD. Je vous conseille d’aller regarder quelques explications sur ces nombres sur Wikipedia. En bref, un chiffre est codé sur 4 bits avec des valeurs binaires de 0000 (0) à 1001 (9), ce qui facilite leur affichage mais complique les calculs. Heureusement l’assembleur offre quelques instructions supplémentaires pour faciliter ces calculs. <br>
Comme leur utilisation est peu fréquente, je n’ai pas étudié à fond toutes les possibilités et je me suis contenté dans le programme pgm24.asm d’effectuer quelques opérations.  Le plus intéressant est qu’il est possible de les utiliser pour des calculs sur des entiers avec un grand nombre de chiffres (mais il faudra optimiser les opérations élémentaires que j’ai écrites !!! et les compléter : division, exponentiation, modulo, racines etc.).
Pour les premières vérifications, je n’ai mis qu’un seul chiffre dans les registres (bcdNombre1 et bcdNombre2) car au début je pensais que l’on pouvait mettre 8 chiffres de 4 bits et effectuer l’addition ou la soustraction des 8 chiffres. Mais ce n’est pas possible !! donc ensuite j’ai déclaré des nombres de 9 chiffres en mettant chaque chiffre dans un octet de la mémoire. <br>
Voyons l’addition de 2 chiffres BCD 8 + 9 . En binaire cela revient à effectuer l’addition 1000 + 1001 (sur 4 bits) ce qui donnerait 10001 mais en bcd cela donne 0001 0001 soit 11 ce qui est faux. Il faut effectuer une instruction d’ajustement daa  qui donne 0001 0111  soit 17 ce qui est exact. <br>
Mais il y a plus sioux !! si on utilise l’instruction d’ajustement ascii aaa, la retenue est stockée sur le deuxième octet  ce qui donne  0000 0001 0000 0111 et il suffit d’effectuer un ou logique avec la valeur 0x30 (0011 0000) pour avoir le résultat  0011 0001  0011 0111 soit  31 37  en ascii ce qui à l’affichage donne 17. Pas besoin d’autre conversion pour l’affichage !! <br>
<pre>
Addition et ajustement :
eax = 00000017  ebx = 00000000  ecx = 00000000  edx = 00000000
esi = 00000000  edi = 00000000  ebp = BFD6A160  esp = BFD6A160
Ajustement ascii :
eax = 00000107  ebx = 00000000  ecx = 00000000  edx = 00000000
esi = 00000000  edi = 00000000  ebp = BFD6A160  esp = BFD6A160
Conversion ascii :
eax = 00003137  ebx = 00000000  ecx = 00000000  edx = 00000000
esi = 00000000  edi = 00000000  ebp = BFD6A160  esp = BFD6A160
</pre>
Pour la soustraction il faut utiliser les instructions das et aas, pour la multiplication aam et pour la division aad  <br>
Pour effectuer une addition sur un grand nombre de chiffres, il faut décrire les nombres par une suite d’octets chacun représentant un chiffre puis écrire une routine qui va additionner chaque chiffre des 2 nombres et reporter la retenue. Dans la routine additionBCD, on passe les adresses des 2 nombres en mémoire, l’adresse de stockage du résultat et le nombre de chiffres. Mais il existe d’autres possibilités surtout si nous voulons additionner des nombres avec un nombre de chiffres différents. Comme il n’est pas possible d’utiliser le délimiteur final 0, il faut prendre un délimiteur compris entre 0xA et 0xFF ( et réécrire les routines de calcul !!). <br>
Le programme montre l’addition de 2 nombres de 9 chiffres, la soustraction et la multiplication. Pour cette dernière nous utilisons une autre routine qui multiplie un nombre BCD en mémoire par un seul chiffre BCD. Tout cela n’est pas très optimisé !! et donc il y a du boulot pour ceux qui veulent absolument utilisé ce codage. <br>
Je n’ai pas non plus écrit la division que je vous laisse à titre d’exercice !!!<br>
Ah aussi un dernier point, il existe aussi des nombres en BCD packé mais je n’ai pas regardé leur utilisation. Bon courage. <br> 
