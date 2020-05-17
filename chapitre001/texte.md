Ce premier chapitre concerne les outils à mettre en place, et l'écriture d'un programme assembleur minimum  afin de tester leur bonne installation.  <br>
La saisie du source peut s'effectuer avec n'importe quel éditeur disponible sur Linux, du plus simple à l'atelier le plus complexe.<br>
En ce qui me concerne, j'ai installé notepad++ car cet éditeur bien que simple posséde des fonctions interessantes : coloration syntaxique, transferts, lancement de scripts etc.<br>
<br>
Pour la compilation, j'ai implanté le compilateur nasm (et pas Masm compilateur Microsoft) avec le package nasm.
Pour les informations, le forum etc. voir le site https://www.nasm.us/ et le manuel utilisateur en pdf : https://www.nasm.us/xdoc/2.14.02/nasmdoc.pdf.

Pour l'éditeur de liens, j'ai utilisé le linker standard ld mais il est aussi possible d'utiliser gcc ou d'autres linkers.<br>

Pour une première utilisation, j'ai crée un script qui lance la compilation et l'édition des liens en saississanr le nom du script et le nom du programme sans l'extention par exemple compil32.sh pgm1_0.

Pour vérifier le bon fonctionnement de ces outils, il faut saisir ou copier le premier programme pgm1_0.asm dans l'éditeur de texte choisi, installer sur votre machine le script compil32.sh et l'executer. (Attention pensez à modifier les droits pour le rendre executable chmod 777 compil32.sh).<br>
Normalement, vous ne devez pas avoir d'erreur !!. Vous devez trouver dans le répertoire de travail un fichier pgm1_0.o et un fichier pgm1_0 qui est l'executable à lancer. 
L'execution ne doit pas produire de message d'erreur et vous pouvez vérifier la valeur du code retour en tapant echo $?. <br>
Il doit s'afficher la valeur 255 et si cela se produit c'est que tout est OK.
<br>
Revenons au source de ce premier programme assembleur. Les 3 premières lignes commençant par ; sont des commentaires. Tous les commentaires commenceront par ; .
Ensuite nous trouvons les 2 instructions global main et main:. main: est une étiquette (ou un nom ou un label) qui indique l'adresse du début des instructions à executer. global main permet de faire connaitre l'etiquette main à tout processus externe à votre programme et en particulier à l'editeur de liens. Celui çi saura quelle est la première instruction à executer et l'indiquera dans le fichier executable. Ainsi linux chargera l'executable et executera la première instruction se trouvant à cette adresse main:
Puis nous trouvons la première vértitable instruction qui sera executer par le microprocesseur : mov eax,1


