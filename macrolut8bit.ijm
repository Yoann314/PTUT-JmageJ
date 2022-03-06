//cette macro associe une LUT pour une image en fonction de la colonne "SpotInCellsCount" de arrays.csv
//Les cellules sont distinguées par Indexofcell (value) dans le tableau arrays

	selectWindow("Results_Finished.csv");
	rouge=newArray(Table.size);	//création d'arrays pour chaque couleur primaire
	vert=newArray(Table.size);		//taille 256 car 255 niveau pour une LUT
	bleu=newArray(Table.size);
	rowmax=20; //On fixe le max de spot à 20 (valeur pouvant être changé). 
	coef= 255/20
	for (i = 1; i < Table.size ; i++) {
		row=Table.get("SpotInCellsCount", i);	//attribue à 3 niveaux de couleur en fonction du nombre de cluster indiqué dans "SpotInCellsCount"
		// print(row);
		if (row==0) {
			rouge[i]=89;	 //bleu pour les cellules ayants 0 spot
			vert[i]=89;
			bleu[i]=215;
		}
		else if (row==rowmax){			//rouge clair pour les cellules ayant le plus de spots
			rouge[i]=255;
			vert[i]=0;
			bleu[i]=0;
		}
		else{                       // Un rouge adapté en fonction du nombre de spot. 
			a=(coef*rowmax)-(coef*row);
			rouge[i]=a;
			vert[i]=0;
			bleu[i]=0;
		}
	}
//selectwindow("nom");
setLut(rouge, vert, bleu);
Array.show(rouge,vert,bleu);