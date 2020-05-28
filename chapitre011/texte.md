Dans ce chapitre, nous allons approfondir le rôle des indicateurs d’états que nous avons commencé à rencontrer.  Les indicateurs pu drapeaux (ou flags en anglais) sont contenus dans un registre 32 bits qui s’appelle eflags mais qui peut être aussi représenté par les 16 bits partie basse appelés flags.<br>
Pour accéder aux bits de ce registre, il faut effectuer une sauvegarde du registre sur la pile avec l’instruction pushf et le restaurer sur un autre registre avec pop eax par exemple. Pour notre routine d’affichage binaire, ça tombe bien puisqu’il suffit de faire le pushf et d’appeler la routine.<br>
Il y a une deuxième façon de récupérer les 8 premiers bits du registre c’est d’utiliser l’instruction lahf. Celle-ci met les 8 bits dans le registre ah (donc le 2ième octet droit). C’est très curieux mais il doit y avoir une raison historique !! <br>
Vous trouverez sur internet la documentation sur le rôle de chaque bit du registre par exemple : https://fr.wikibooks.org/wiki/Programmation_Assembleur/x86/Les_flags.<br>
L’affichage binaire du registre n’est pas très passionnant. Ce qui nous intéresse c’est de connaitre l’état de chaque indicateur , son rôle et comment l’utiliser. Dans le programme précédent nous avons mis en place quelques petites routines pour afficher 3 indicateurs, routines que j’ai repris dans le programme pgm11.asm. <br>
Mais il est plus intéressant d’avoir un affichage groupé de tous les indicateurs (enfin les principaux pour l’instant). Donc dans ce programme j’ai ajouté la routine afficherFlags qui va afficher 0 ou 1 suivant l’état des indicateurs zéro, signe, overflow, carry et un nouvel indicateur parité.<br>
Donc je rappelle que l’indicateur zéro est mis à un si la valeur du  registre est égale à zéro, l’indicateur signe est mis à 1 si la valeur du registre est négative, l’indicateur overflow est mis à 1 s’il a un dépassement, et l’indicateur carry à 1 s’il y a une retenue. L’indicateur parité est mis à 1 si le nombre de bits à 1 du registre est pair. <br>
Attention, l’instruction mov de met pas à jour les indicateurs. Il ne sont mis à jour que par les opérations arithmètiques, logiques, de mouvement de bits et par les instructions de comparaison (test,cmp). <br>
Donc dans le programme, je remets le registre eax à zéro avec l’instruction xor (qui elle met les indicateurs à jour). Voici le résultat de l’affichage :
<pre>
Valeur nulle
Affichage des indicateurs :
Zéro : 1 Signe : 0 Carry : 0 Overflow : 0 Parité : 1
</pre>
L’indicateur zéro indique bien que la valeur du registre est zéro !!!!
Enlevons 1 au registre pour avoir -1 et les indicateurs mis à jour :
<pre>
Valeur négative
Affichage des indicateurs :
Zéro : 0 Signe : 1 Carry : 1 Overflow : 0 Parité : 1
</pre>
L’indicateur de zéro est revenu à zéro celui du signe est passé à 1 mais aussi l’indicateur de carry. En effet cela est important de savoir en arithmétique non signée qu’il y a un problème.
Comme – 1 est  aussi la représentation de la valeur maximum d’un registre, effectuons la multiplication non signée de eax par eax et affichons les indicateurs :
<pre>
Multiplication non signee
Affichage des indicateurs :
Zéro : 0 Signe : 1 Carry : 1 Overflow : 1 Parité : 1
</pre>
L’indicateur overflow est lui aussi passé à un puisque la multiplication déborde d’un seul registre.<br><br>
Ensuite nous effectuons plusieurs comparaisons signées ou non signées pour voir les indicateurs mis en place. En fait une comparaison est une soustraction sans mise à jour du résultat, seul les indicateurs sont mis en place.<br>
Vous pouvez le constater avec la comparaison cmp eax,5. Si eax contient 5, cette comparaison est vraie et vous pouvez utiliser les instructions je ou jne pour continuer mais vous pouvez aussi utiliser jz ou jnz  car la comparaison étant équivalente à une soustraction, le résultat théorique est zéro et donc l’indicateur zéro est positionné.<br>
A partir de ces indicateurs, l’assembleur offre une panoplie de sauts conditionnels qui va vous permettre d’obtenir toutes les conditions possibles. Mais attention comme vous l’avez vu, il faudra choisir les bons sauts en fonction de l’état signé ou non signée du registre.<br>
Par exemple vous disposez pour tester si un registre est supérieur à un autre de 2 instructions ja et jg
Ja doit être utilisée quand vous considérez comme des valeurs non signées (et dans ce cas la valeur -1 est plus grande que 1.
Jg doit être utilisée pour les valeurs signées (et dans ce cas -1 est plus petit que 1)
Voici les résultats :
<pre>
Comparaison eax=-1,ebx=1
eax plus grand
eax plus petit
</pre>
<br>
<B>Liste des sauts conditionnels pour valeurs non signées :</b> <br>
Ja     si supérieur<br>
Jae    si supérieur ou égal<br>
Jna    si pas supérieur<br>
Jnae   si ni supérieur ni égal<br>
Jb     si inférieur<br>
Jbe    si inférieur ou égal<br>
Jnb    si pas inférieur<br>
Jnbe   si ni inférieur ni égal<br>

<b>Liste des sauts conditionnels pour valeurs  signées :<b><br>
Jg      si supérieur<br>
Jge     si supérieur ou égal<br>
Jng     si pas supérieur<br>
Jnge    si ni supérieur ni égal<br>
Jl      si inférieur<br>
Jle     si inférieur ou égal<br>
Jnl     si pas inférieur<br>
Jnle    si ni inférieur ni égal<br>

<b>Liste des sauts conditionnels indifférents au signe :<B><br>
Je    si égal <br>
Jne   si différent <br>
Jo    si débordement (overflow) <br>
Jno   si pas de débordement <br>
Jp    si nombre pair de bit 1<br>
Jnp   si nombre impar de bit 1<br>
Jpe   si parité paire<br>
Jpo   si parité impaire<br>
jc    si retenue (carry)<br>
jnc   si pas de retenue<br>
Js    si négatif<br>
Jns   si positif<br>
Jz    si égal à zéro<br>
Jnz   si différent de zéro<br>

<b>Autres saut conditionnels : </b> <br>
Jcxz    si cx = zéro <br>
Jecxz   si ecx = zéro <br>
<br>
Dans le programme exemple, je n’ai pas testé tous ces cas !! je me suis contenté de tester le cas du registre cx à zéro. L’instruction jecxz peut servir d’arrêt dans une boucle qui décrémente le registre ecx.<br>
Comme exercice, vous pouvez  tester d’autres sauts en fonction des valeurs mises dans 2 registres.
