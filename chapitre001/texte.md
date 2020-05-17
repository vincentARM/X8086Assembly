Ce premier chapitre concerne les outils à mettre en place, et l'écriture d'un programme assembleur minimum  afin de tester leur bonne installation.  <br>
La saisie du source peut s'effectuer avec n'importe quel éditeur disponible sur Linux, du plus simple à l'atelier le plus complexe.<br>
En ce qui me concerne, j'ai installé notepad++ car cet éditeur bien que simple posséde des fonctions interessantes : coloration syntaxique, transferts, lancement de scripts etc.<br>
<br>
Pour la compilation, j'ai implanté le compilateur nasm (et pas Masm compilateur Microsoft) avec le package nasm.
Pour les informations, le forum etc. voir le site https://www.nasm.us/ et le manuel utilisateur en pdf : https://www.nasm.us/xdoc/2.14.02/nasmdoc.pdf.

Pour l'éditeur de liens, j'ai utilisé le linker standard ld mais il est aussi possible d'utiliser gcc ou d'autres linkers.<br>

Pour une première utilisation, j'ai crée un script qui lance la compilation et l'édition des liens en saississanr le nom du scrit et le nom du programme sans l'extention par exemple compil32.sh pgm1_0.

Pour vérifier le bon fonctionnement de ces outils, il faut saisir ou copier le premier programme pgm1_0.asm dans l'édirit de texte choisi, installer sur votre machine le script compil32.sh et l'executer. (Attention pensez à modifier les droits pour le rendre executable chmod 777 compil32.sh.<br>
Normalement, vous ne devez pa avoir d'erreur !!. Vous devez trouver dans le répertoire de travail un fichier pgm1_0.o et un fichier pgm1_0 qui est l'executable à lancer. 
L'execution ne doit pas produire de message d'erreur et vous pouvez vérifier la valeur du code retour en tapant echo $?. <br>
Il doit s'afficher la valeur 255 et si cela se produit c'est que tout est OK.



