Nous avons vu dès les premiers chapitres l’organisation de la zone mémoire allouée à notre programme par le système d’exploitation. Elle est découpée en section : .data .bss .text , chacune ayant une définition et un accès particulier. A ces sections il faut ajouter la zone dédiée à la pile et la zone dédiée au ras (heap) : à voir dans un autre chapitre.<br>
Nous avons aussi commencé à voir quelques instructions pour mettre un caractère d’un registre dans une zone mémoire et inversement.
Pour définir une zone mémoire contenant une chaine de caractères, il faut utiliser la pseudo instruction db pour data byte comme ceci :
Label :    db « Chaine de caractères »
Pour définir un seul caractère :
Car1 :    db  ‘a’
Ou avec son code ascii :
Car2 :   db  98     ; correspond à b   on peut mettre aussi en hexa 0x62
Il est donc possible avec db de définir toute valeur d’un octet soit de 0 à 255.
Pour définir des valeurs de 2 octets il faut utiliser dw, pour des valeurs de 4 octets dd et pour 8 octets dq. (voir des exemples dans la documentation PDF de nasm).
Pour réserver de la place pour une variable, il faut utiliser resb  pour réserver des octets, resw pour réserver des mots de 2 octets, resd pour réserver des doubles mots de 4 octets et resq des quadruples mots de 8 octets.<br>
Par exemple :   zone1 :    resb  10        ; reserve 10 octets en mémoire
                          Zone2 :     resd 50      ; réserve 50 double mots de 4 octets.
Pour lire un octet de la mémoire et le mettre dans un registre il faut utiliser l’instruction mov byte eax,[label] , le nom de la zone étant mis entre crochet.
Donc il est possible de faire :
     Mov ebx,label   ; met l’adresse de label dans le registre ebx
     Mov eax,[ebx]   ; lit les 4 octets de la mémoire à l’adresse contenue dans ebx et les mets dans eax.
Pour illustrer cela, nous devons écrire une routine qui affiche le contenu de la mémoire en code ascii si cela est possible et en valeur hexadécimale pour visualiser toutes les valeurs possibles d’un octet (et dont certaines ne sont pas des caractères ascii affichables).
Dans le programme pgm12.asm, j’ai écrit la routine afficherMemoire qui prend en entrée l’adresse de la zone mémoire de début d’affichage et le nombre de blocs de 16 octets à afficher. Nous n’allons pas commencer l’affichage exactement à l’adresse de début  mais à l’adresse d’une frontière de 16 octets, cad une adresse se terminant par zéro. Ainsi nous pourrons avoir suivant le cas quelques octets avant l’adresse de début.
Cette routine est plus complexe que les précédente car nous allons utiliser une boucle pour afficher un bloc  et qui contiendra 2 boucles la première pour afficher le contenu d’un octet en hexa soit 2 caractères (de 00 à FF), l’autre pour afficher les caractères en Ascii. Si le caractère n’est pas affichable nous afficherons à la place un ?. <br>
La routine commence par récupérer sur la pile ,les 2 paramètres d’entrée puis prépare l’affichage du titre en convertissant l’adresse demandée en hexa grâce à notre précédente routine de conversion conversion16. Le seul petit défaut c’est que cette routine installe un zéro final après les 8 caractères ce qui est gênant pour imprimer le titre car la routine d’affichage s’appuie sur le zéro final pour calcul la longueur à afficher et donc elle va tronquer notre titre. Pour cela nous forçons le cractère espace à la 8 ième position pour effacer le zéro.<br>
Ensuite nous calculons le début d’un bloc en effectuant l’opération logique and 0xFFFFFFF0 ce qui a pour effet de remettre le premier chiffre  (4bits) à droite à zéro. <br>
Pour nous permettre de situer l’adresse demandée dans les 16 octets du bloc, nous affichons une étoile devant le premier octet demandé. Pour cela nous calculons le déplacement entre l’adresse et le début du premier bloc puis nous plaçons l’étoile en sachant qu’il nous faut 2 positions pour afficher un octet + 1 position pour afficher le blanc intercalaire entre 2 octets.<br>
Puis nous entrons dans la première boucle d’édition d’un bloc. La boucle commence à l’étiquette locale .A1 :. Le point indique qu’il s’agit d’un label local à la routine (voir la documentation nasm sur ce type de label). J’ai décidé d’appeler mes étiquettes d’une lettre suivi d’un chiffre, chiffre qui va en augmentant au fil de la routine. Ainsi il est plus facile de localiser où vont les sauts à l’intérieur de la routine. Peut être qu’il existe un meilleur étiquetage ?  à expérimenter.<br>
Pour chaque bloc, nous commençons à convertir son adresse en hexa pour l’afficher en début de chaque ligne. Puis nous entrons dans une boucle qui va convertir chaque octet du bloc, en 2 caractères hexadécimal. Mais pour éviter la division par 16 et comme il n’y a que 2 chiffres à extraire nous extrayons le deuxième chiffre en effectuant un ET logique avec la valeur 0xF et nous ajoutons 48 ou 55 s’il s’agit d’un chiffre ou d’une lette (de A à F). Puis nous extrayons le premier chiffre en effectuant un ET logique avec la valeur 0xF0. Mais là il faut déplacer les bits du résultats de 4 bits sur la droite pour effectuer la comparaison (quoique il doit être possible d’effectuer la comparaison avec la valeur 0x90). <br>
Ensuite nous plaçons chaque caractère à la bonne place dans la ligne d’affichage.
Puis nous effectuons une deuxième boucle pour extraire chaque octet du bloc, regarder si c’est un caractère affichable ou non et le mettre à sa place dans la ligne d’affichage.
Nous terminons la boucle principale en affichant la ligne complète du bloc, puis en comparant si le nombre de bloc est atteint.
Dans le programme principal pgm12.asm nous effectuons un test pour demander l’affichage à partir de la zone szMessDebPgm  et pour 5 blocs. Le résultat donne ceci :
Début du programme.
Affichage zone
Vidage memoire adresse : 0804952C
08049520 68 49 96 04 08 E8 66 FD FF FF 58 C3*44 C3 A9 62  "hI????f???X?D??b"
08049530 75 74 20 64 75 20 70 72 6F 67 72 61 6D 6D 65 2E  "ut du programme."
08049540 0A 00 46 69 6E 20 6E 6F 72 6D 61 6C 65 20 64 75  "??Fin normale du"
08049550 20 70 72 6F 67 72 61 6D 6D 65 2E 0A 00 0A 00 33  " programme.????3"
08049560 34 12 78 56 34 12 C3 A0 C3 A9 C3 A8 C3 AA 56 69  "4?xV4?????????Vi"
Dans mon cas, l’adresse de la zone démandée est 0804952C, l’adresse du premier bloc est 08049520 et l’étoile indiquant le début de la zone est placée devant le caractère 44 qui correspond au D majuscule du début du message. Très bien !!!<br>
Mais on voit tout de suite que si la fin du message est correcte, il y a 2 caractères non affichables derrière le D et dont les codes sont C3A9 !! et qui représentent le caractère accentué « é » . Bon je suppose qu’il y a une particularité pour le codage des caractères accentués français. Nous essaierons d’approfondir cela ultérieurement.
Ensuite, nous trouvons bien à la fin de chaque message les codes 0A (10 en décimal) pour le retour ligne et 00 pour la fin de chaine.
Maintenant nous pouvons initialiser des caractères, des mots de 16 bits et des doubles mots de 32 bits pour voir leur stockage en mémoire.<br>
Et c’est curieux les données numériques sont stockées à l’envers : pour un mot la valeur 1234 est stockée sous la forme 3412 et pour le double mot la valeur 12345678 est stockée 78563412. <br>
Après une recherche sur Internet, il s’avère que les processeurs peuvent stocker les valeurs sous 2 formats différents : big endian et little endian. En français il s’agit du gros-boutiste et du petit-boutiste !! Je vous laisse le soin d’aller voir sur Wikipèdia l’explication amusante de ces noms. <br>
En clair, le format gros-boutiste commencent par stocker les octets de poids forts (bits 24 à 31 puis bits 16 à 23) avant les octets de poids faibles (bits 8 à 15 puis bits 0 à 7). Le petit-boutiste fait l’inverse. Donc ici avec Linux Ubuntu nous avons un format gros-boutiste.
Mais voyons ce que nous avons dans un registre après lecture d’un mot et d’un double mot. 
Affichage registre en hexa : 12345678
Affichage registre en hexa : 00001234
Affichage registre en hexa : 00000033
Ouf ! tout est correct nous retrouvons bien la valeur initialisée de chaque zone.
 A partir d’une adresse, nous pouvons ajouter un déplacement pour lire un octet (ou autre chose), par exemple lisons le 4ième octet de notre double mot (mais il est en position 3 car le premier octet correspond à la position 0).
Lecture avec déplacement
Affichage registre en hexa : 12345612
Affichage registre en hexa : 00000012
Le premier affichage ne correspond pas vraiment à un octet !! Mais oui c’est bien sûr, nous avons oublié d’initialiser à zéro le registre eax avant de récupérer l’octet dans la partie al. Après l’initialisation tout est correct et nous récupérons la valeur 12 qui est bien la valeur stockée dans le 4ième octet de la zone en mémoire.<br>
Nous venons de voir des lectures mémoire en partant d’une adresse donnée par un label, mais nous pouvons aussi lire la mémoire à partir d’une adresse stockée dans un registre. Puis lire une valeur avec une adresse contenue dans un registre + un déplacement. Vous remarquerez que la syntaxe des instructions est différente. Le déplacement peu aussi être négatif et il peut être aussi stocké dans un registre. C’est ce que nous avons fait dans la routine d’affichage mémoire.
Tiens, essayons d’afficher l’adresse zéro !! en la mettant dans le registre eax. La sanction est immédiate : 
Erreur de segmentation (core dumped)
En effet, Linux surveille et vous interdit l’accès à toutes les adresses hors de la plage allouée à votre programme et heureusement car sinon bonjour les dégâts !!
D’ailleurs, lorsque vous aurez cette erreur, le plus souvent elle aura pour origine que  le registre contenant l’adresse  contient zéro un ou nombre quelconque ne correspond pas à une adresse effective.<br>
Voyons maintenant l’écriture dans une zone de mémoire. Nous avons vu déjà le stockage d’un octet dans les routines d’affichage précédentes. Pour stocker un mot et un double mot réservons de la place dans la section bss avec les instructions resw et resd.<br>
Ensuite nous mettons la valeur 0x1234 dans le registre eax et nous stockons les 2 octets dans la zone bss wZoneEcr1 et nous effectuons un affichage de la mémoire à partir de cette zone.
Ecriture mémoire d'un mot
Vidage memoire adresse : 08049740
08049740 34 12 00 00 00 00 00 00 30 30 30 30 31 32 30 30  "4???????00001200"
08049750 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
Petit problème : l’étoile n’est pas stockée quand l’adresse demandée est un début de bloc : à corriger !!!
Nous remarquons que la valeur 0x1234 est stockée avec le format gros-boutiste 3421 ce qui est logique. Derrière il y a des zéros qui correspondent à la zone dZoneEcr2 non encore alimentée. Puis plus loin nous trouvons les caractères 00000012 qui ne correspondent pas à une zone définie dans la section BSS de notre programme et pourtant ils semblent correspondre à une valeur précédemment affichée. Mais oui cela correspond à la zone sZoneConv définie dans la section BSS de nos routines d’affichage. En fait lors de l’édition de liens, le linker ld rassemble les zones des mêmes sections de tous les programmes objet : les .data avec les .data, les .bss avec les .bss et les .text avec les . text.
Pour le vérifier, il suffit de demander l’affichage mémoire de plusieurs bloc à  partir de la zone zdec qui est la dernière de notre .data :
Vidage memoire adresse : 0804966E
08049660 43 33 20 41 41 2A 35 36 20 36 39 20 20 22*34 3F  "20 22*34 3F  "20"
08049670 20 32 32 2A 33 34 20 33 46 20 20 22 32 30 22 0A  " 22*34 3F  "20"?"
08049680 0D 00 00 00 41 66 66 69 63 68 61 67 65 20 64 C3  "????Affichage d?"
08049690 A9 63 69 6D 61 6C 20 64 27 75 6E 20 72 65 67 69  "?cimal d'un regi"
080496A0 73 74 72 65 20 3A 20 00 41 66 66 69 63 68 61 67  "stre : ?Affichag"
Nous voyons après les 16 octets de la zone zdec, les messages de la .data du programme routines.asm.
Nous terminons le programme en stockant un double mot de 4 octets cad la valeur d’un registre complet. Cette instruction sera très utilisée puisque elle conserve la valeur d’un registre en mémoire.
Tout comme la lecture il existe pour le stockage les mêmes possibilités pour accéder à la mémoire : à partir d’un label avec ou sans déplacement, à partir d’un registre avec ou sans déplacement, et même avec des opérations plus complexes (voir la documentation nasm).
