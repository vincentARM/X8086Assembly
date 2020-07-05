En assembleur, il n’y a aucune instruction pour dessiner sur l’écran et donc il faut faire appel à des bibliothèques extérieures comme X11 ou openGL ou autres. Néanmoins il existe une solution qui nécessite d’écrire en assembleur toutes les fonctions graphiques de base. En effet pour dessiner, il s’agira de stocker la couleur de chaque pixel dans une zone mémoire , copie de la zone écran, le système d’exploitation effectuant automatiquement la mise à jour de la zone écran. <br>
Linux offre un mécanisme nommé FrameBuffer et je vous renvoie à la documentation disponible sur Internet pour le détail sur cette entité. Pour Linux, le FrameBuffer est un périphérique nommé /dev/fb0  (mais il est possible d’avoir plusieurs FrameBuffers nommé fb1 etc.). Il doit être ouvert comme un fichier et le File Descriptor servira à obtenir les informations nécessaires à son utilisation à l’aide de l’appel système IOCTL. <br>
Les informations importantes à  récupérer sont la taille de l’écran, le nombre de bits par pixel et la taille de la zone mémoire nécessaire. Nous pouvons aussi récupérer l’adresse de la zone mémoire du périphérique mais celle-ci restant inaccessible à nos programmes, nous allons être obligé d’effectuer un chainage (mapping) avec une autre zone mémoire que nous pourrons utiliser pour dessiner sur l’écran. <br>
Dans le programme pgm25.asm, nous trouvons après la définition des constantes, les définitions des structures nécessaires : les 2 premières sont issues des descriptions Linux pour détailler les informations fixes  et les informations variables du FrameBuffer, et la 3ième est une structure propre à notre programme pour stocker les données utiles.
Dans la section code, nous commençons par ouvrir le périphérique avec l’appel système OPEN, puis nous lisons les informations fixes à l’aide de l’appel système IOCTL et le code opération 0x4602. Les informations seront récupérées dans la zone bss sZone1 que nous affichons avec notre routine afficherMémoire puis nous extrayons les données adresse et taille pour les afficher en clair. L’extraction s’effectue à partir du nom de la structure FBFIXSCinfo et du nom des données dans cette structure .smem_start  et . smem_len. <br>
Ensuite nous effectuons les mêmes opérations pour les informations variables mais en utilisant le code 0X4600 pour l’appel IOCTL, la structure FBVARSCinfo  et les données .xres .yres et . bits_per_pixel. <br>
Nous terminons par la fermeture du périphérique avec l’appel système CLOSE. Vous remarquerez que le programme affiche les erreurs éventuelles pour chaque appel pour éviter toute recherche inutile. <br>
La première exécution se termine mal avec le message « pas de permission pour accèder à Fb0 ». L’exécution avec sudo ./pgm25  est ok, ce qui n’est pas très élégant pour tester et dessiner avec nos programmes.
Après recherche, il s’avère qu’il est possible de lever cette interdiction en rattachant l’utilisateur au groupe video (et en redémarrant linux) par la commande <pre>
sudo adduser nom_utilisateur nom_groupe </pre>
Voici les résultats pour mon écran :
<pre>
Début du programme.
Vidage memoire adresse : 08049D2C
08049D20 00 00 00 00 00 00 00 00 00 00 00 00*69 6E 74 65  "????????????inte"
08049D30 6C 64 72 6D 66 62 00 00 00 00 00 00 00 00 02 C0  "ldrmfb??????????"
08049D40 00 00 30 00 00 00 00 00 00 00 00 00 02 00 00 00  "??0?????????????"
08049D50 01 00 01 00 00 00 00 00 00 10 00 00 00 00 00 00  "????????????????"
Adresse = C0020000 taille = 3145728
Vidage memoire adresse : 08049D2C
08049D20 00 00 00 00 00 00 00 00 00 00 00 00*00 04 00 00  "????????????????"
08049D30 00 03 00 00 00 04 00 00 00 03 00 00 00 00 00 00  "????????????????"
08049D40 00 00 00 00 20 00 00 00 00 00 00 00 10 00 00 00  "???? ???????????"
08049D50 08 00 00 00 00 00 00 00 08 00 00 00 08 00 00 00  "????????????????"
Largeur = 1024 hauteur = 768 bits par pixel = 32
Fin normale du programme.
</pre>
Vous remarquerez que la largeur de l’écran * par la hauteur * 4 ( puisqu’il y a 32 bits par pixel soit 4 octets) donne la taille mémoire récupérée.<br>
Dans les constantes, j’ai mis le code IOCTL pour la modification des données variables. En effet il est possible de modifier ces données mais je n’ai pas essayé !! <br>
Après ce premier programme, nous allons dessiner quelques droites avec le programme pgm25_1.asm. Dans celui çi, j’ai déporté l’initialisation dans une routine initFrameBuffer qu’il suffira de recopier dans d’autre programmes si nécessaire. Dans cette routine, nous retrouvons l’ouverture et la lecture des informations fixes et variables. <br>
Et j’ai ajouté l’appel système MMAP pour mapper la zone écran du périphérique avec une zone mémoire. En paramètre nous devons passer la longueur de la zone, des constantes pour l’accès à la zone (voir la documentation lLinux de MMAP). Ici nous laissons le paramètre adresse mémoire à zéro, ce qui indique à Linux que c’est à lui de réserver l’espace mémoire nécessaire et de nous retourner dans le registre eax, l’adresse attribuée.<br>
Vous remarquerez que tous les registres sont utilisés pour le passage des paramètres et même qu’il faut utiliser le registre bsp pour passer le dernier paramètre (offset à 0) ce qui nous oblige à la sauvegarder avant l’appel et à la restaurer après.<br>
L’adresse retournée est stockée dans la structure interne FRAMEBUFFER ainsi que le FD du périphérique et les adresses des structures d’informations ce qui facilite leur utilisation dans les autres routines. <br>
Maintenant, nous disposons d’une vaste zone mémoire où nous pouvons dessiner ce que nous voulons. Il suffit de stocker la bonne couleur (code RGB sur 4 octets) au bon endroit  de la mémoire!! <br>
Les 4 premiers octets de la zone contiendront la couleur du premier pixel en haut à gauche de l’écran et les 4 derniers octets, le dernier pixel de l’écran en bas à droite.  Pour afficher un pixel de coordonnées (X , Y), il faudra calculer la position mémoire en multipliant la largeur de l’écran (donnée par FBVARSCinfo.xres)  par Y, ajouter X, et multiplié le tout par 4 (puisque 32 bits par pixel.<br>
Dans le programme nous commençons par appeler une routine pour effacer l’écran qui se contente de stocker le code RGB 0x00FFFFFF (noir) dans toute la zone mémoire retournée par MMAP. La longueur est bien sûr récupérée dans les informations fixes fournies par l’appel IOCTL.  Attention, si vous avez essayé de modifier le nombre de bits par pixels pour essayer d’autres résolutions, il faudra modifier la couleur pour stocker soit un octet (8 bits par pixel) soit 2 octets (16 bits) ou 3 octets (24 bits). <br>
Ensuite, nous traçons une droite horizontale (facile !), une droite verticale (moins facile) et comme je suis généreux une droite quelconque avec un algorithme trouvé sur internet sur un site qui ne semble plus fonctionner aujourd’hui !! . Remarque : tout cela est brut et donc rien n’est optimisé !! <br>
Après correction des erreurs,  la première exécution ne fait rien apparaitre sur l’écran de mon ordinateur : petite déception !!!! 
Après vérification et recherche sur Internet, le FrameBuffer Ubuntu n’affiche pas l’image sur le bureau graphique mais sur l’écran lié à la console N°1 accessible par les touches ctrl+alt+F1. Et là miracle les droites s’affichent bien à l’écran. Bon les messages d’infos aussi !! Il faut donc lancer le programme depuis soit un autre ordinateur soit depuis un autre terminal ou le bureau graphique d’Ubuntu. <br>
Je vous laisse le soin de pratiquer à fond l’assembleur pour écrire toutes les routines de dessin : rectangle, rectangle plein, cercle, arc de cercle, polygones etc. en testant divers algorithmes et en optimisant !!! Bon courage.<br>
Un dernier point : il est possible de charger une image au format .bmp rien qu’en assembleur et des appels système. Par contre pour des images png ou jpg il faudra passer par des appels de fonctions de librairies en C.<br>
Documentation : https://www.kernel.org/doc/Documentation/fb/framebuffer.txt
http://www.pinon-hebert.fr/Knowledge/index.php/Frame_Buffer
