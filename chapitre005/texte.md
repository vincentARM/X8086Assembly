Bon maintenant fini d'afficher des chaines de caractères, nous allons voir comment afficher le contenu d'un registre.<br>
Un registre contient donc une valeur qui va de 0 à 4294967295 mais il n'est pas possible d'afficher directement le contenu puisque nous ne pouvons qu'afficher des chaines de caractères ASCII. <br>
Il nous faut donc convertir le nombre contenu dans le registre en chaine de caractères puis afficher celle çi.<br>
Partons du nombre 1234. Pour obtenir chaque chiffre il faut le diviser successivement par 10 et garder les restes successifs. <br>
Première division 1234 / 10 = 123 et le reste est 4. <br>
2ième division 123 / 10 = 12 et le reste est 3. <br>
3ième division 12 / 10 = 1 et le reste est 2. <br>
4 ième division 1 /10  = 0 et le reste est 1. <br>
Et il est inutile de continuer puisque nous n'avons plus que des zéros. <br>
Nous devons stocker chaque reste dans une zone en partant de la fin de celle çi puisque nous extrayons les chiffres dans l'ordre 4 3 2 et 1.<br>
Mais il y a un probléme ! ces chiffres ne sont pas des caractères ASCII si nous regardons une table de ces codes, nous voyons que les chiffres vont des codes 30 à 39. Il nous faut donc ajouter à chaque reste le nombre 30 avant de le stocker.
Puis il nous faudra recopier le résultat en début de la zone de stockage pour faciliter l'affichage. <br>
Donc en route pour creer la routine dans le programme pgm5.asm. 
