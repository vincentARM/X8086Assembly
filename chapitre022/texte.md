Au chapitre 16, nous avons vu la lecture d’un fichier à l’aide de l’appel système READ auquel il fallait passer un buffer de lecture et sa longueur. Le problème le plus souvent rencontré est de réserver la place nécessaire à cette lecture puisque la taille d’un fichier peut être très variable. <br>
Mais il est possible de récupérer cette taille en lisant les informations du fichier à l’aide de l’appel système sys_newfstat (code 108) de Linux. <br>
La taille récupérée nous servira à réserver la place du buffer de lecture sur le tas à l’aide d’un autre appel système sys_brk (code 45). Le tas est une autre zone de mémoire que nos programmes peuvent utiliser. Théoriquement, elle est comprise après les zones du segment data et du segment bss et avant la zone mémoire de la pile mais Linux attribue au tas, une adresse mémoire aléatoire pour éviter des possibilités de lecture par un autre process. <br>
Les zones du tas ne peuvent pas être nommées comme les zones de la data. C’est le programme qui doit réserver la place et stockée les adresses de début de chaque zone dans le segment bss pour les utiliser par la suite. <br>
Dans le programme pgm22.asm, nous déclarons une structure pour nommer toutes les zones d’information que l’appel système sys_newfstat va nous retourner. Vous remarquerez que ces zones peuvent avoir des longueurs variables. Les noms des zones sont ceux fournis dans la documentation linux ce qui facilite leur utilisation quoiqu’ici nous n’allons utiliser que la taille (size_t). j’ai ajouté à la fin la zone .fin qui nous servira à la réservation de la place nécessaire à cette structure (je vous rappelle que la définition d’une structure ne réserve pas de place mais sert à calculer les déplacements des adresses de chaque zone. <br>
Dans la section data nous déclarons les messages habituels et le nom du fichier à lire. Il faudra créer ce fichier dans le répertoire courant avec nano par exemple et y mettre quelques caractères (ou prendre un fichier déjà existant). Dans la section bss, nous déclarons une zone pour stocker le FD du fichier, une zone pour déclarer l’adresse du buffer et une zone pour la réservation de place correspondant à la structure. <br>
Dans la partie code, nous reprenons les parties du programme du chapitre 16 pour l’ouverture et la fermeture du fichier. Après l’ouverture, nous effectuons l’appel sys_newfstat en lui passant le FD du fichier et l’adresse de la zone réservée. Si l’appel se passe bien, nous effectuons un vidage mémoire et nous mettons dans le registre eax, la valeur de la taille en utilisant le descriptif de la structure. Si cela vous intéresse, vous pouvez regarder les informations recueillies et les comparer avec le résultat de la commande linux ls -l. <br>
Ensuite nous utilisons une première fois l’appel système BRK avec la valeur 0 dans le registre ebx, pour récupèerer l’adresse du début du tas et qui nous servira comme adresse du buffer de lecture. Nous stockons cette adresse dans la zone dAdrsBuffer. Nous copions cette adresse dans le registre ebx et nous y ajoutons la taille du fichier à lire. Nous effectuons avec cette valeur un deuxieme appel à BRK pour mettre à jour l’adresse du tas. Nous avons donc réservé sur le tas une zone de la taille du fichier. <br>
Il ne nous reste plus qu’à lire le fichier en modifiant la routine déjà utilisée au chapitre 16 pour passer en paramètre la taille à lire et l’adresse du buffer. Nous terminons en affichant le contenu du buffer pour vérification. <br>
Voilà le résultat : <pre>
Début du programme.
Vidage memoire adresse : 08049C24
08049C20 00 00 00 00*01 08 00 00 70 0D 0A 00 B4 81 01 00  "????????p???????"
08049C30 E8 03 E8 03 00 00 00 00 37 00 00 00 00 10 00 00  "????????7???????"
08049C40 08 00 00 00 E0 13 ED 5E 57 C0 F1 28 61 0D ED 5E  "???????^W??(a??^"
08049C50 90 9B 33 1D 61 0D ED 5E 90 9B 33 1D 00 00 00 00  "??3?a??^??3?????"
Verif taille :
eax = 00000037  ebx = 00000003  ecx = 08049C24  edx = 00000000
esi = 08049C24  edi = 00000000  ebp = BFFA2D70  esp = BFFA2D70
Adresse du tas :
eax = 0962F000  ebx = 00000000  ecx = 08049C24  edx = 00000000
esi = 08049C24  edi = 00000000  ebp = BFFA2D70  esp = BFFA2D70
Nouvelle adresse du tas :
eax = 0962F037  ebx = 0962F037  ecx = 08049C24  edx = 00000000
esi = 08049C24  edi = 00000000  ebp = BFFA2D70  esp = BFFA2D70
Vidage memoire adresse : 0962F000
0962F000 74 65 73 74 20 73 74 61 74 69 73 74 69 71 75 65  "test statistique"
0962F010 73 20 46 69 63 68 69 65 72 0A 4C 69 67 6E 65 32  "s Fichier?Ligne2"
0962F020 0A 41 41 41 41 41 41 41 41 41 41 41 41 41 41 41  "?AAAAAAAAAAAAAAA"
0962F030 41 41 41 41 41 41 0A 00 00 00 00 00 00 00 00 00  "AAAAAA??????????"
Fin normale du programme.
<pre>
Si vous exécutez plusieurs fois ce programme, vous constatez que l’adresse du tas varie d’un lancement à l’autre. <br>
