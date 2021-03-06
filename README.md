# X8086Assembly
Découverte de l'assembleur X8086 sur Linux Ubuntu

Lors de notre période de confinement, je décide de sacrifier un de mes vieux portable sous Windows7 pour passer sur Ubuntu. Et comme je suis passionné par le langage assembleur, je me décide à étudier les possibilités de ce langage sur Linux et donc avec un processeur Intel 32 bits.<br>
Ce document permet de suivre mon expérience et de comprendre les mécanismes de l’assembleur. Les chapitres sont écrits au fur et à mesure de la découverte de l'assembleur sans aucun recul !!! Il peut donc y avoir des explications bizarres qui ne correspondent qu'à ma compréhension du problème au moment où j'ai écris le texte.<br>
Ces textes ne seront pas donc véritablement un cours formel consacré à l'assembleur mais plutôt une suite de chapitres explorant les possibilités de l'assembleur.
Dans la partie code, vous trouverez les différents chapitres. Chaque chapitre contient un fichier explicatif texte.md  et des petits programmes avec l'extension .asm. Je conseille aux débutants de modifier ces exemples pour expérimenter et peut être contredire ce que j'ai écrit.  <br>
<br>
Ces exemples s'adressent plutôt à un public de débutants, et comme prérequis, il faut connaitre un minimum de commandes Linux pour créer des répertoires, lancer un programme etc et un minimum de connaissance en programmation et algorithmique.<br>
Remarque 1 : le répertoire principal s'appelle vincentARM, parce que j'ai commencé à apprendre l'assembleur ARM sur les Raspberry PI et j'ai mis mes programmes sur Github.<br>
Remarque 2 : ce document est écrit au fur et à mesure directement sur Github et donc il contient des fautes d'orthographe, des erreurs et des inexactitudes !!!!  Veuillez être indulgent et me le signalez dans la partie issues. <br>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre001">Chapitre 1 : installation des outils nécessaires.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre002">Chapitre 2 : affichage d'un message dans la console.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre003">Chapitre 3 : affichage d'un message dans la console (passage de l'adresse par la pile).</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre004">Chapitre 4 : affichage d'un libellé à l'aide d'une macro instruction.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre005">Chapitre 5 : affichage du contenu d'un registre.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre006">Chapitre 6 : opérations arithmétiques sur nombres entiers.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre007">Chapitre 7 : nombres négatifs et opérations arithmétiques.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre008">Chapitre 8 : affichage binaire, opérations logiques, affichage hexadécimal, sous registres.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre009">Chapitre 9 : insertion de fichiers sources, fichiers objets et utilitaire make.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre010">Chapitre 10 : instructions de déplacement et de test de bits.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre011">Chapitre 11 : le registre des indicateurs (Flags) et les sauts contitionnels.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre012">Chapitre 12 : les accès à la mémoire, affichage des zones mémoire.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre013">Chapitre 13 : les accès à la mémoire, copie de chaine, gestion des tableaux.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre014">Chapitre 14 : Affichages des piles, paramètres programme, variables d'environnement.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre015">Chapitre 15 : Saisie de données,conversion chaine de caractères en entier signé.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre016">Chapitre 16 : Lecture d'un fichier, écriture dans un fichier.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre017">Chapitre 17 : Retour sur les opérations mémoire, structures, tableau de chaines de caractères.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre018">Chapitre 18 : Retour sur les piles, variables locales sur la pile, appel de fonctions du langage C.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre019">Chapitre 19 : les sélecteurs de segments.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre020">Chapitre 20 : Affichage de tous les registres. .</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre021">Chapitre 21 : Nombres en virgule flottante (Floats).</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre022">Chapitre 22 : Lecture des informations d'un fichier. Utilisation du tas.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre023">Chapitre 23 : Instruction CPUID. Insertion sous chaine dans chaine.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre024">Chapitre 24 : Calculs avec des nombres au format BCD.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre025">Chapitre 25 : Dessiner avec le FrameBuffer.</a></h3>

<h3><a href="https://github.com/vincentARM/X8086Assembly/tree/master/chapitre026">Chapitre 26 : Calcul nombre d'instructions et de cycles avec perf-event-open.</a></h3>
