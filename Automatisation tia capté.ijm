
//il manque des ligne pour fermer les images une fois que la fonction poisson zebre est executée, sauvegarder la result table dans le dossier correspondant.
//création d'une boite de dialogue qui explique la structure requise pour que le programme fonctionne.
Dialog.create("Conditions d'utilisation :");
Dialog.addMessage("    -Veuillez créer un dossier pour chaque embryon dans lequel se trouvera 3 dossiers pour chaque stade.(T1,T2 et T3) \n \n    -Dans chaque dossier stade, doit se trouver l'image 488 et l'image 561. Ainsi, il ne doit contenir que 2 éléments (488 et 561) \n \nPar exemple : \nEmbryon1/T1/488             ...pour l'embryon 1 au stade 1.");
Dialog.show();



repertoire_image=getDir("Veuillez séléctionner le repertoire contenant les images"); 	//récupération du chemin menant au repertoire des image, ex: C:\Users\nd202\Desktop\TEST\EMBRYON 1\T1\
chemin_stade=File.getParent(repertoire_image);  //récupération des repertoire contenant les différent stades et embryons
chemin_embryon=File.getParent(chemin_stade);

embryon=getFileList(chemin_embryon);	// récupération de la liste des dossier embryon et stade
stade=getFileList(chemin_stade);		//par exemple dans embryon si on a que 2 embryons, array.show(embryon) retourne EMBRYON 1/
																											//			EMBRYON 2/

Array.sort(stade);			//trie la liste des embryons au cas où il seraientt dans le désordre
Array.sort(embryon);

l=lengthOf(embryon);		//nombre d'embryons
for (i=0;i<l;i++){	
	
	chemin_stade=chemin_embryon+"\\"+embryon[i];	//chemin_stade = chemin pour accéder au stade pour chaque embryons
	
	for (j=0;j<3;j++){
													
		chemin_image=replace(chemin_stade+stade[j], "/", "\\");		 //chemin_image = C:\Users\nd202\Desktop\TEST\EMBRYON [i]\T[j]\
		
		image=replace(chemin_image, "\\", "\\\\");			//image = C:\\Users\\nd202\\Desktop\\TEST\\EMBRYON [i]\\T[j]\\
															//utilisation de double anti slash car sinon pour de specialiser le caractère '\' (sinon open() ne fonctionne pas)
		
		nb=getFileList(image);		//nb contient le nom des fichiers images

		Array.sort(nb);		// on met l'image 488 en premier 
		if (lengthOf(nb) == 2) {  // par précaution, il faut qu'il y ait seulement les images 488 et 561 dans le dossier 
			
			open(image+nb[1]);

			open(image+nb[0]);	//ouverture de 488 en dernier

			close("*");		//fermeture des images une fois le programme exécuté
			
			//appeler la fonction poisson zebre puis fermer les images

		}
		else {
			showMessage("Le repertoire contenant les images doit contenir seulement 488 et 561 !");
		}
	}
}



