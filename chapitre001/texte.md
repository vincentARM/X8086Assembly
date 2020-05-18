Ce premier chapitre concerne les outils à mettre en place, et l'écriture d'un programme assembleur minimum  afin de tester leur bonne installation.  <br>
La saisie du source peut s'effectuer avec n'importe quel éditeur disponible sur Linux, du plus simple à l'atelier le plus complexe.<br>
En ce qui me concerne, j'ai installé notepad++ car cet éditeur bien que simple posséde des fonctions interessantes : coloration syntaxique, transferts, lancement de scripts etc.<br>
<br>
Pour la compilation, j'ai implanté le compilateur nasm (et pas Masm compilateur Microsoft) avec le package nasm.
Pour les informations, le forum etc. voir le site https://www.nasm.us/ et le manuel utilisateur en pdf : https://www.nasm.us/xdoc/2.14.02/nasmdoc.pdf.
Après saisie, le programme source est sauvegardé abec l'extension .asm. <br>
Le compilateur nasm peut être lancé dans une console (terminal) linux avec la commande : nasm -f elf <pgm>.asm avec <pgm> correspondant au nom du programme à compiler. Après compilation sans erreur, un module objet nommé <pgm>.o doit se trouver dans le même répertoire. <br> 

Pour l'éditeur de liens, j'ai utilisé le linker standard ld mais il est aussi possible d'utiliser gcc ou d'autres linkers.<br>
L'éditeur ld est lancé avec la commande : ld -m elf_i386 <pgm>.o -o <pgm> -e main . Si aucune erreur n'est detectée, le programme executable <pgm> doit être présent dans le repertoire. <br>

Pour une première utilisation, j'ai crée un script qui lance la compilation et l'édition des liens en saississant le nom du script et le nom du programme sans l'extension par exemple compil32.sh pgm1_0.

Pour vérifier le bon fonctionnement de ces outils, il faut saisir ou copier le premier programme pgm1_0.asm dans l'éditeur de texte choisi, installer sur votre machine le script compil32.sh et l'executer. (Attention pensez à modifier les droits pour le rendre executable chmod 777 compil32.sh).<br>
Normalement, vous ne devez pas avoir d'erreur !!. Vous devez trouver dans le répertoire de travail un fichier pgm1_0.o et un fichier pgm1_0 qui est l'executable à lancer. 
L'execution ne doit pas produire de message d'erreur et vous pouvez vérifier la valeur du code retour en tapant echo $?. <br>
Il doit s'afficher la valeur 255 et si cela se produit c'est que tout est OK.
<br>
Revenons au source de ce premier programme assembleur. Les 3 premières lignes commençant par ; sont des commentaires. Tous les commentaires commenceront par ; .<br>
Ensuite nous trouvons les 2 instructions global main et main:. main: est une étiquette (ou un nom ou un label) qui indique l'adresse du début des instructions à executer. global main permet de faire connaitre l'etiquette main à tout processus externe à votre programme et en particulier à l'editeur de liens. Celui çi saura quelle est la première instruction à executer et l'indiquera dans le fichier executable. Ainsi linux chargera l'executable et executera la première instruction se trouvant à cette adresse main: <br>
Puis nous trouvons la première vértitable instruction qui sera executée par le microprocesseur : mov eax,1 <br>
eax est le nom d'un registre. Un registre est une entité électronique qui contient 32 positions (bits) qui peuvent prendre la valeur allumée ou eteinte. Cela représente les valeurs binaires 0 et 1 et permettent de représenter toutes les valeurs entières comprises entre 0 et 2 à la puissance 32 - 1 soit le nombre 4 294 967 295.<br>
Les registres sont les éléments essentiels du microprocesseur et les instructions assembleur vont les manipuler pour effectuer vos caculs et opérations. <br>
Pour ce type de microprocesseur, nous disposons de 4 registres principaux appelés eax, ebx, ecx, edx et de registres spéciaux que nous découvrirons petit à petit.<br>
Le mot clé mov est le code opération, il vient de l'anglais move. 
Cette première instruction met la valeur 1 dans le premier registre eax. Ah mais c'est bizarre, on ecrit le registre destinataire d'abord et la valeur source après. Oui et il faudra vous habituer !! Cela provient des tous premiers ordinateurs et cela est resté jusqu'à nos jours pour la plupart des assembleurs.<br>
La deuxième instruction met la valeur 255 dans le registre ebx et la 3ième instruction int 0x80 est une instruction d'interruption qui indique au microprocesseur d'appeler des fonctions du système d'exploitation Linux.
Que font donc exactement ces instructions ? <br>
L'instruction int 0x80 demande donc à Linux d'executer une fonction dont le code est égale à 1, code qui est mis dans le registre eax. Cette fonction 1 correspond à la fonction EXIT, c'est à dire l'execution de la fin du processus. <br>
Cette fonction attend comme paramètre un code retour qui sera transmis par le registre ebx à Linux qui pourra l'utiliser à votre demande (par exemple l'afficher par la commande echo $?).<br>
Donc ici, ces instructions demandent simplement de terminer votre programme proprement. <br>
Mais essayons d'executer ce programme en mettant l'instruction int 0x80 en commentaire (avec un ; devant). Le compilateur ne signale pas d'erreur, le linker non plus mais l'excution se termine par le message : Erreur de segmentation (core dumped)<br>
Pourquoi ? et bien le microprocesseur execute les 2 premières instructions puis continue à charger et à executer ce qu'il y a derrière c'est à dire n'importe quoi !! et donc il ne sait plus quoi faire et indique une erreur à Linux qui affiche ce message que vous aurez souvent !!<br>
Voyons aussi quelques erreurs signalées par le compilateur : remplaçons le mov eax,1 par muv eax,1
Le compilateur indique l'erreur suivante :<br>
pgm1_0.asm:9: error: parser: instruction expected  en indiquant une erreur ligne 9 <br>

Mettons maintenant mov dax,1 et le compilateur signale :
pgm1_0.asm:9: error: symbol 'dax' undefined

Et pour terminer, mettons la ligne global main en commentaire :
C'est le linker ld qui signale un avertissement mais qu'il faudra aussi corriger :
ld : avertissement : le symbole d'entrée main est introuvable ; utilise par défaut 0000000008048060

Vous remarquerez que hormis les commentaires, toutes ces instructions sont importantes pour le bon fonctionnement du programme.






