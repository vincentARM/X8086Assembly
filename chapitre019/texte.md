Dans ce court chapitre nous allons nous intéresser aux registres de sélecteurs de segments. Je n’ai pas trouvé d’utilité immédiate à ces registres mais il faut connaitre leurs existences. Ils existent  pour des raisons historiques lorsque les registres n’avaient qu’une taille de 16 bits et le bus qui communiquait avec la mémoire avait une taille de 20 bits. Ces registres servaient donc à compléter les registres d’usage général lorsqu’ils contenaient une adresse pour accéder à la mémoire. En 32 bits et 64 bits, ils me semblent que leur utilité est réduite. (peut être estil possible de s’en servir pour sauver des registres !!). <br>
Ces registres sont au nombre de 6 :<br>
cs  qui complète le segment de code (.text)<br>
ds qui complète le segment des données (.data)<br>
ss qui complète le segment de pile (.stack)<br>
et es, ef, eg qui complètent aussi le segment de données. <br>
Dans le programme pgm19.asm, nous effectuons une copie du segment cs dans eax pour afficher son contenu puis nous faisons appel à une routine qui affiche tous les registres de segments et nous effectuons plusieurs opérations de vérification en complétant une adresse mémoire avec le registre ds. <br>
<pre>
Test macro Affichage segments
cs: 00000073 ds: 0000007B ss: 0000007B es: 0000007B fs: 00000000 gs: 00000000
</pre>
En fin pour faciliter l’appel à la routine, le programme utilise une macro à laquelle il faut passer un titre.<br>
Vous pouvez consulter le chapitre 3.4.2 du volume 1 de la documentation Intel. <br>
Et c’est tout pour aujourd’hui.<br>
