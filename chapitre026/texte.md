Après avoir découvert les principales instructions de l’assembleur puis d’avoir écrit les premières routines, il est intéressant d’essayer d’optimiser celles ci soit en réduisant le nombre d’instructions soit en utilisant celles qui génèrent le moins de cycles. Intel fournit une documentation sur l’optimisation de ces processeurs disponible sur ce site : <br>
https://software.intel.com/content/www/us/en/develop/download/intel-64-and-ia-32-architectures-optimization-reference-manual.html <br>
Pour nous permettre de calculer le nombre d’instructions et le nombre de cycles, nous allons utiliser un appel systeme Linux qui permet d’effectuer de nombreuses analyses : perf_event_open . Vous trouverez la documentation en français sur ce site : <br> https://man.developpez.com/man2/perf_event_open/ <br>
Mais il existe aussi des documentations en anglais et aussi des exemples sur internet.<br>
Pour utiliser cet appel système il faut charger le package linux-tools-common et mettre la valeur -1 dans le fichier perf_event_paranoid avec la commande :<pre>
sudo nano /proc/sys/kernel/perf_event_paranoid
</pre>
En fait, vous pouvez voir les résultats d’un programme complet en utilisant directement la commande perf sous  Linux.
Dans le programme mesurePerfs.asm, nous allons afficher le nombre d’instructions puis le nombre de cycles mis par une petite routine qui pourra être complétée ou remplacée. Nous afficherons aussi le temps mis par la routine.  Le programme commence par un certain nombre de constantes puis par la description d’une structure qui contiendra  les paramètres particuliers de l’appel. (voir la documentation car les possibilités sont nombreuses).<br>
Dans la section code, nous commençons par alimenter les zones de la structure avec le type d’information souhaitée, la longueur de la structure, divers paramètres pour exclure les instructions du noyau ou du superviseur, la nature du compteur demandé. Ensuite nous effectuons l’appel système perf_event_open code 336 avec des paramètres standards pour ouvrir une entité qui va produire le compteur désiré. En retour et si tout se passe bien, nous récupérons un File Descriptor qui va servir aux commandes suivantes. <br>
Grâce à l’appel système IOCTL, nous allons remettre à zéro le compteur puis l’activer avec l’option PERF_EVENT_IOC_ENABLE. A partir de ce moment, le compteur sera incrémenté à chaque instruction. Nous effectuons une boucle pour appeler notre petite routine qui ne fait rien (mais vous pouvez enlever les commentaires pour avoir des comptages différents).<br>
Après la boucle, nous effectuons un nouvel appel avec IOCTL pour désactiver le compteur puis nous effectuons un appel READ pour lire le compteur et le stocker dans une zone de réception qui sera exploitée dans les instructions suivantes : conversion en décimal, insertion dans le corps du message et affichage. <br> 
Nous effectuons une deuxième fois la même séquence mais cette fois ci en demandant la mesure du nombre de cycles avec l’option PERF_COUNT_HW_CPU_CYCLES. Voici les résultats :
<pre>
instructions ou cycles : 68  temps en µs: 7457
instructions ou cycles : 342  temps en µs: 5004</pre>
Dans mon cas, la boucle fait 20 tours de 3 instructions (call,ret,loop) soit 60 instructions. Entre l’appel IOCTL de déclenchement et celui d’arrêt il y a 8 instructions : cmp,jl,mov (la boucle) puis mov mov mov mov et int soit au total 68 instructions.<br>
Plusieurs exécutions donne le même résultat pour le nombre d’instruction mais des temps d’exécution différents !!! <br>
Pour le nombre de cycles, le résultat donne 5 cycles en moyenne par instruction ce qui me paraît élevé. Ce nombre change suivant l’exécution !! et le temps est toujours différent de celui du premier comptage. Ces résultats sont donc à manier avec précaution. <br>
Je me demande si le nombre de cycle ne représente pas le nombre de micro instructions dans une architecture de type pipeline (chargement,décodage,exécution, etc).<br> 
Si vous mettez les bits 6 7 ou 8 à zéro dans la zone param de la structure, les chiffres prennent en compte les instructions du kernel et du superviseur. <br>
Vous pouvez aussi essayer d’obtenir tous les autres compteurs disponibles !! <br>
Il y a aussi une possibilité de regrouper différents compteurs pour éviter d’effectuer comme je l’ai fait 2 fois les mêmes instructions. Cela permet d’avoir les mêmes mesures pour la même séquence d’instructions. C’est ce que j’ai essayé de faire dans le programme mesurePerf2.asm mais je ne ny suis pas arrivé. !!!!! <br>
Je publie le programme car le problème vient soit d’un mauvais paramétrage soit d’un dysfonctionnement de la version LINUX sur mon vieil ordinateur. Si quelqu’un arrive à avoir un regroupement des résultats , qu’il signale ses corrections.<br>
