Dans ce chapitre, nous allons voir une seule instruction qui permet de découvrir toutes les informations liées au processeur (intel) : cpuid. <br>
Comme mon ordinateur sur lequel tourne Linux est assez vieux, il ne sera pas possible d’exploiter toutes les possibilités de cette instruction. Je vous conseille donc de regarder le détail de cette instruction dans le volume 2 de la documentation Intel (voir le lien au chapitre 1).<br>
Comme il y a plusieurs valeurs à afficher, j’ai écris une routine qui insère une chaîne de caractères dans une autre chaîne à la place d’un délimiteur (ici j’ai choisi @ ). Ceci permet d’insérer le résultat d’une routine de conversion déjà vue dans un libellé de message. La place nécessaire à la nouvelle chaîne est réservée sur le tas grâce à l’appel système sys_brk.. Il est possible de mettre dans le même message plusieurs délimiteurs.<br>
Dans le programme pgm23.asm, nous déclarons les différents messages en insérant pour certains le caractère @ qui sera remplacé par la valeur rendue par cpuid. <br>
Dans la partie code, nous effectuons un premier appel à cpuid en mettant le paramètre 0 dans le registre eax. Nous récupérons dans le registre eax, la valeur maximun que nous pouvons interroger pour le type de processeur utilisé. Par exemple si nous récupérons 5, nous allons pouvoir récupérer les informations en passant les paramètres 1 à 5. Dans mon cas, nous n’avons que 2 possibilités.<br>
Ensuite dans les registres ebx,edx,ecx nous récupérons le libellé « genuineIntel ». Pour d’autres processeurs j’ignore ce que l’on peut récupérer !!! <br>
Puis nous appelons la routine pour afficher les informations de type 1. Dans cette routine, nous exécutons cpuid avec le paramètre 1 puis nous extrayons les données des registres eax et ebx pour les insérer dans les messages d’information à l’aide de la routine insererChaine après les avoir converties en valeurs décimales.<br>
La routine insererChaine commence par calculer les longueurs des 2 chaînes passées en paramètre puis effectue la somme avec laquelle nous réservons la place nécessaire sur le tas. Ensuite nous recopions les caractères du message jusqu’à trouver le caractère @ et nous copions les caractères de la chaîne à insérer jusqu’au 0 final. Enfin nous terminons par la copie de la fin du message. <br>
Nous terminons l’affichage du contenu des registres ecx et edx en binaire seulement car tous les bits ont une information particulière à transmettre. Et donc cela faisait beaucoup de travail pour un intérêt limité !! <br>
Ensuite nous effectuons un appel à cpuid avec le paramètre 2 pour afficher le contenu des registres en hexa et  binaire simplement. Je vous renvoie à la documentation intel pour l’analyse détaillé des résultats que voici :
<pre>
Début du programme.
Registres :
eax = 00000002  ebx = 756E6547  ecx = 6C65746E  edx = 49656E69
esi = 00000000  edi = 00000000  ebp = BFC72F00  esp = BFC72F00
Vidage memoire adresse : 08049EE4
08049EE0 00 00 00 00*47 65 6E 75 69 6E 65 49 6E 74 65 6C  "????GenuineIntel"
08049EF0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  "????????????????"
01 Informations EAX
Affichage registre en binaire : 00000000000000000000011011011000
Famille ex : 0 Modèle ex : 0 type : 0 Famille : 6 Modèle : 13 Stepping : 8
Informations EBX
Affichage registre en binaire : 00000000000000000000100000010110
Brand index : 22 CLFLUSH line size : 8 Maximun ID : 0 Initial Apic ID : 0
Informations ECX
Affichage registre en binaire : 00000000000000000000000110000000
Informations EDX
Affichage registre en binaire : 10101111111010011111101111111111
INFORMATIONS 02
eax = 02B3B001  ebx = 000000F0  ecx = 00000000  edx = 2C04307D
esi = 00000000  edi = 00000000  ebp = BFC72EF8  esp = BFC72EE0
02 Informations EAX
Affichage registre en binaire : 00000010101100111011000000000001
Fin normale du programme.
</pre>

La famille de mon processeur est 6 et le modèle 13 ce qui d’après le site : https://en.wikichip.org/wiki/intel/cpuid#Family₆  correspond à un pentium M.
