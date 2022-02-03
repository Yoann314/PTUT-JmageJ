//cette macro associe une LUT pour une image en fonction de la colonne "SpotInCellsCount" de arrays.csv
//Les cellules sont distinguées par Indexofcell (value) dans le tableau arrays
//PROBLEME: au niveau des valeur des cells


huitbit = getBoolean("L'image est de type 8-bits ?");
if(huitbit == true) {
	rouge=newArray(256);	//création d'arrays pour chaque couleur primaire
	vert=newArray(256);		//taille 256 car 255 niveau pour une LUT
	bleu=newArray(256);
	selectWindow("Arrays.csv");

	for (i=1;i<256;i++){
		row=Table.get("SpotInCellsCount", i);	//attribue à 3 niveaux de couleur en fonction du nombre de cluster indiqué dans "SpotInCellsCount"
		print(row);
		if (row==0) {
			rouge[i]=255;	//jaune pale pour les cellules ayants 0 spot
			vert[i]=206;
			bleu[i]=154;
		}
		else if (row<6){			//jaune pourles cellules ayant moins de 6 spots
			rouge[i]=255;
			vert[i]=255;
			bleu[i]=0;
		}
		else if (row<11){ 			//orange pour celles ayant entre 6 et 10 spots
			rouge[i]=255;
			vert[i]=170;
			bleu[i]=0;
		}
		else {
			rouge[i]=255;		// rouge pour celles qui ont plus de 10 spots
			vert[i]=0;
			bleu[i]=0;
		}
	}
//selectwindow("nom");
setLut(rouge, vert, bleu);
}
Array.show(rouge,vert,bleu);